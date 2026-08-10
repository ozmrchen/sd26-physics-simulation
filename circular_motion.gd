extends Control
# C656a - Inheritance: this script extends the built-in Control class
#
# ============================================================================
# CIRCULAR MOTION SIMULATOR
# ----------------------------------------------------------------------------
# FUNCTIONALITY (C742a): This script drives an interactive simulation of a
# ball moving in a horizontal circle on a string (centripetal motion). The
# user adjusts mass, radius and velocity with sliders; the script recalculates
# the centripetal force (F = m*v^2/r) in real time, animates the ball's
# position each frame, and lets the user save/load their slider settings to
# a CSV file so a session can be resumed later.
#
# USE OF DATA (C743a): Three continuous physical quantities (mass, radius,
# velocity) are read from GUI sliders as floats, combined with the physics
# formula, and pushed back out to Label nodes as formatted strings. The same
# three values (plus the simulation's time_scale) are the only data written
# to / read from disk, using CSV because it is small, human-readable, and can
# be opened outside Godot for marking/checking (C645a).
#
# USE OF CODE STRUCTURES (C744a): Logic is grouped into clearly named regions:
#   - Setup (_ready)                : one-time wiring of signals/dialogs
#   - Physics update (_process)     : per-frame motion + string drawing
#   - Recalculation helpers         : _update_force_label, _update_all_labels
#   - Input validation helpers      : _is_valid_float_string, _clamp_to_range
#   - File I/O                      : save_to_csv / load_from_csv
#   - Signal callbacks              : _on_* functions, grouped by control
# Each region is a small, single-purpose function rather than one long block,
# which keeps the simulation logic (physics) separate from the interface
# logic (labels/dialogs) and from persistence logic (CSV).
# ============================================================================

# --- Interface controls (GUI) -----------------------------------------------
# C627a and C633a - GUI control references. Naming convention (C751a): every GUI
# control variable is named <purpose>_<control type> (e.g. radius_slider,
# radius_label) so its role and node type are both obvious at a glance.
@onready var radius_slider: HSlider = $layout/options/radiusSlider
@onready var velocity_slider: HSlider = $layout/options/velocitySlider
@onready var mass_slider: HSlider = $layout/options/massSlider

@onready var save_dialog: FileDialog = $SaveFileDialog     # C634a - global var, explicit type
@onready var import_dialog: FileDialog = $ImportFileDialog # C711a - snakecase naming convention

@onready var radius_label: LineEdit = $layout/options/radiusLabel
@onready var velocity_label: LineEdit = $layout/options/velocityLabel
@onready var mass_label: LineEdit = $layout/options/massLabel
@onready var force_label: Label = $layout/options/forceLabel
@onready var formula_label: Label = $layout/options/formulaLabel
@onready var speed_label: Label = $layout/options/speedLabel

# --- Simulation nodes ---------------------------------------------------
@onready var ball: Node2D = $Ball
@onready var pivot: Node2D = $Pivot
@onready var string_line: Line2D = $Line2D

# --- Constants ---------------------------------------------------------
const RADIUS_SCALE := 20.0   # C622a - pixels per slider unit, so the ball's
							  # on-screen radius matches the slider intuitively

# Acceptable ranges for validation (C735a/C745a). Kept as constants rather than
# magic numbers so the "why" is documented once and reused everywhere.
const MASS_MIN := 0.0
const MASS_MAX := 20.0
const RADIUS_MIN := 2.5
const RADIUS_MAX := 10.0
const VELOCITY_MIN := -60.0
const VELOCITY_MAX := 60.0

# --- Physics state -------------------------------------------------------
# why float: angle/angular_velocity are continuous, not whole-number counts
var _angle: float = 0.0                 # C643a - "_" prefix denotes private/internal use
var _angular_velocity: float = 0.0
# why float: distance and mass can be fractional (e.g. 152.5g or 153.6 px)
var radius: float = 100.0               # C614a - numeric data type
var mass: float = 1.0                   # C631a - global variable

var tween_toggle: bool = true           # C615a - boolean data type, why: tracks
										  # whether the options panel is currently
										  # shown or hidden so show/hide can't
										  # be triggered twice in a row


func _ready() -> void:
	# C641a - function. Sequence (C625a): dialogs, then slider signals, then
	# an initial label refresh, so every control is fully configured before
	# anything reads its value.
	_setup_file_dialogs()
	_connect_slider_signals()
	_update_values_from_sliders()
	_update_all_labels()
	
	if Global.dark_mode == true:
		pass
	else:
		$CanvasLayer.visible = true


func _setup_file_dialogs() -> void:
	# why: isolates FileDialog configuration from _ready() so _ready() stays
	# readable as a short list of setup steps (C744a - code structure)
	save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_dialog.add_filter("*.csv", "CSV Files")
	save_dialog.file_selected.connect(_on_save_file_selected)   # C642a - method call

	import_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	import_dialog.access = FileDialog.ACCESS_FILESYSTEM
	import_dialog.add_filter("*.csv", "CSV Files")
	import_dialog.file_selected.connect(_on_import_file_selected)


func _connect_slider_signals() -> void:
	radius_slider.value_changed.connect(_on_radius_changed)
	mass_slider.value_changed.connect(_on_mass_changed)
	velocity_slider.value_changed.connect(_on_velocity_changed)


func _update_all_labels() -> void:
	mass_label.text = "%s" % mass_slider.value
	radius_label.text = "%s" % radius_slider.value
	velocity_label.text = "%s" % velocity_slider.value
	_update_force_label()


func _update_force_label() -> void:
	# why local vars: values are read once per call rather than looked up
	# repeatedly from the sliders, which is both faster and clearer to read
	var linear_velocity: float = velocity_slider.value   # C621a - local var, C628a typed
	var current_radius: float = radius_slider.value
	var current_mass: float = max(mass_slider.value, 0.0)

	# Centripetal Force: F = (m * v^2) / r
	# Guarded by radius > 0 (C624a comparison, C626a selection) because
	# division by zero is undefined and would crash the simulation
	if current_radius > 0:
		var force: float = (current_mass * linear_velocity * linear_velocity) / current_radius
		# C612a - arithmetic operators (*, /)
		force_label.text = "= %.2f N" % snapped(force, 0.01)
	else:
		force_label.text = "= 0.00 N"

	formula_label.text = "F = (%.2f * (%.2f)² ) / %.2f" % [current_mass, linear_velocity, current_radius]
	# C613a - string data type (format string)
	# C635a - array (the [current_mass, linear_velocity, current_radius] literal)


func _update_values_from_sliders() -> void:
	mass = max(mass_slider.value, 0.0)
	radius = radius_slider.value * RADIUS_SCALE
	var linear_velocity: float = velocity_slider.value * 30.0

	if radius > 0:
		_angular_velocity = linear_velocity / radius


func _process(delta: float) -> void:
	var current_mass: float = max(mass_slider.value, 0.0)
	var old_angle: float = _angle

	# Update the ball's angle using angular velocity; freeze motion at
	# zero mass instead of letting the angle keep advancing (C626a selection)
	_angle += _angular_velocity * delta
	if current_mass == 0:
		_angle = old_angle

	ball.position = pivot.position + Vector2(cos(_angle), sin(_angle)) * radius

	speed_label.text = "= %.0f" % (snapped(Engine.time_scale, 0.01) * 100) + "%"

	# Redraw the string each frame so it always connects pivot -> ball
	string_line.clear_points()
	string_line.add_point(pivot.position)
	string_line.add_point(ball.position)


# =============================================================================
# INPUT VALIDATION HELPERS (C735a / C745a)
# why: every value that can come from free-text user input (the label
# text_submitted callbacks) or from an external CSV file needs to be checked
# for existence, type and range before it is trusted - unlike slider input,
# which is already numeric and pre-clamped by the slider's own min/max.
# =============================================================================

func _is_valid_float_string(text: String) -> bool:
	# EXISTENCE check: reject empty/whitespace-only input
	var trimmed: String = text.strip_edges()
	if trimmed.is_empty():
		return false
	# TYPE check: reject anything that doesn't actually parse as a number
	if not trimmed.is_valid_float():
		return false
	return true


func _clamp_to_range(value: float, min_value: float, max_value: float) -> float:
	# RANGE check: keep validated numeric input inside a sensible physical range
	return clamp(value, min_value, max_value)


func _try_parse_validated_float(text: String, min_value: float, max_value: float, fallback: float) -> float:
	# Combines existence + type + range checks in one reusable helper so
	# each text_submitted callback stays short and consistent (C744a)
	if not _is_valid_float_string(text):
		push_warning("Invalid numeric input '%s' - keeping previous value" % text)
		return fallback
	return _clamp_to_range(text.to_float(), min_value, max_value)


# --- Signal callbacks ---------------------------------------------------

func _on_radius_changed(new_value: float) -> void:
	radius_label.text = "%s" % new_value
	var new_radius: float = new_value * RADIUS_SCALE

	if new_radius > 0 and radius > 0:
		# C623a - logical operator (and)
		var current_linear_velocity: float = velocity_slider.value * 30.0
		_angular_velocity = current_linear_velocity / new_radius

	radius = new_radius
	_update_force_label()


func _on_mass_changed(new_value: float) -> void:
	mass_label.text = "%s" % new_value
	mass = max(new_value, 0.01)
	_update_force_label()


func _on_velocity_changed(new_value: float) -> void:
	velocity_label.text = "%s" % new_value
	var linear_velocity: float = new_value * 30.0   # C628a - typed local var

	if radius > 0:
		_angular_velocity = linear_velocity / radius
	_update_force_label()


func _on_save_file_selected(path: String) -> void:
	save_to_csv(path)


func _on_import_file_selected(path: String) -> void:
	load_from_csv(path)


# =============================================================================
# FILE I/O (C644a / C645a - data source: CSV on disk, chosen for readability)
# =============================================================================

func save_to_csv(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		print("Error opening file for writing: ", FileAccess.get_open_error())
		return
	file.store_csv_line(["mass", "velocity", "radius", "simulation_speed"])
	file.store_csv_line([
		str(mass_slider.value),
		str(velocity_slider.value),
		str(radius_slider.value),
		str(Engine.time_scale)
	])
	file.close()
	print("Saved to: ", path)


func load_from_csv(path: String) -> void:
	# EXISTENCE check: the file itself must exist before we try to read it
	if not FileAccess.file_exists(path):
		print("File not found: ", path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("Error opening file for reading: ", FileAccess.get_open_error())
		return

	var _headers: PackedStringArray = file.get_csv_line()
	var values: PackedStringArray = file.get_csv_line()
	file.close()

	# EXISTENCE check: the data row must contain all four expected fields
	if values.size() < 4:
		print("Save file looks malformed - expected 4 values, found %d" % values.size())
		return

	# TYPE + RANGE checks: every field must parse as a float and sit inside
	# a physically sensible range before it is applied to the sliders. This
	# stops a hand-edited or corrupted CSV from crashing the simulation or
	# pushing sliders to nonsensical values.
	if not (_is_valid_float_string(values[0]) and _is_valid_float_string(values[1])
			and _is_valid_float_string(values[2]) and _is_valid_float_string(values[3])):
		print("Save file contains non-numeric data - load aborted")
		return

	mass_slider.value = _clamp_to_range(values[0].to_float(), MASS_MIN, MASS_MAX)
	velocity_slider.value = _clamp_to_range(values[1].to_float(), VELOCITY_MIN, VELOCITY_MAX)
	radius_slider.value = _clamp_to_range(values[2].to_float(), RADIUS_MIN, RADIUS_MAX)
	Engine.time_scale = _clamp_to_range(values[3].to_float(), 0.1, 3.0)

	_update_values_from_sliders()
	_update_all_labels()
	print("Loaded from: ", path)


# =============================================================================
# TRANSPORT CONTROLS (pause / resume / speed up / slow down)
# =============================================================================

func _on_button_button_up() -> void:
	Engine.time_scale = 0.0


func _on_button_2_button_down() -> void:
	Engine.time_scale = 1.0
	_reset_sliders_to_defaults()


func _reset_sliders_to_defaults() -> void:
	var sliders: Array = [mass_slider, velocity_slider, radius_slider]
	var defaults: Array = [2, 3, 3]

	for i in range(sliders.size()):   # C632a - iteration over an array
		sliders[i].value = defaults[i]


func _on_button_3_button_down() -> void: # C741a - interface controls
	if Engine.time_scale < 3:
		Engine.time_scale += 0.1


func _on_button_4_button_down() -> void:
	if Engine.time_scale > 0.1:
		Engine.time_scale -= 0.1


# =============================================================================
# OPTIONS PANEL SHOW / HIDE ANIMATION
# =============================================================================

func _on_hide_button_up() -> void:
	var panel_options := $layout/options
	var panel_options2 := $layout/options2
	var mainpanel := $layout

	var target_pos: Vector2 = panel_options.position - Vector2(400, 0)
	var target_pos2: Vector2 = panel_options2.position + Vector2(0, 400)
	var target_pos4: Vector2 = mainpanel.position + Vector2(158, 0)

	var tween := create_tween().set_parallel(true)

	if tween_toggle == true:
		$layout/UpperPanel/hide.disabled = true
		tween_toggle = false
		tween.tween_property(panel_options, "position", target_pos, 0.5) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(panel_options2, "position", target_pos2, 0.7) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(mainpanel, "position", target_pos4, 0.7) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.7).timeout
		$layout/UpperPanel/hide.visible = false
		$layout/UpperPanel/show.visible = true
		$layout/UpperPanel/show.disabled = false


func _on_show_button_up() -> void:
	var panel_options := $layout/options
	var panel_options2 := $layout/options2
	var mainpanel := $layout

	var target_pos: Vector2 = panel_options.position + Vector2(400, 0)
	var target_pos2: Vector2 = panel_options2.position - Vector2(0, 400)
	var target_pos4: Vector2 = mainpanel.position - Vector2(158, 0)

	var tween := create_tween().set_parallel(true)

	if tween_toggle == false:
		tween_toggle = true
		$layout/UpperPanel/show.disabled = true
		tween.tween_property(panel_options, "position", target_pos, 0.5) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(panel_options2, "position", target_pos2, 0.5) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(mainpanel, "position", target_pos4, 0.7) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.7).timeout
		$layout/UpperPanel/show.visible = false
		$layout/UpperPanel/hide.visible = true
		$layout/UpperPanel/hide.disabled = false


func _on_save_button_up() -> void:
	save_dialog.popup_centered(Vector2i(600, 400))


func _on_import_button_up() -> void:
	import_dialog.popup_centered(Vector2i(600, 400))


# =============================================================================
# LABEL TEXT-SUBMITTED CALLBACKS
# why: these are the only places a user can type arbitrary free text, so
# they are the only places that need the full existence/type/range check
# (C735a / C745a) rather than relying on the slider's built-in clamping.
# =============================================================================

func _on_radius_label_text_submitted(new_text: String) -> void:
	radius_slider.value = _try_parse_validated_float(new_text, RADIUS_MIN, RADIUS_MAX, radius_slider.value)


func _on_velocity_label_text_submitted(new_text: String) -> void:
	velocity_slider.value = _try_parse_validated_float(new_text, VELOCITY_MIN, VELOCITY_MAX, velocity_slider.value)


func _on_mass_label_text_submitted(new_text: String) -> void:
	mass_slider.value = _try_parse_validated_float(new_text, MASS_MIN, MASS_MAX, mass_slider.value)
