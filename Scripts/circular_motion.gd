extends BaseMotionSimulation
# C656 - Inheritance
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
# Naming convention (C751a): every GUI
# control variable is named <purpose>_<control type> (e.g. radius_slider,
# radius_label) so its role and node type are both obvious at a glance.
@onready var radius_slider: HSlider = $layout/options/radiusSlider # C627a - GUI element
@onready var velocity_slider: HSlider = $layout/options/velocitySlider # C611a - instruction to make 
#																	   a variable called velocity slider which  
#																	   is assigned the path of velocity slider
@onready var mass_slider: HSlider = $layout/options/massSlider

@onready var save_dialog: FileDialog = $SaveFileDialog
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

# --- Physics state -------------------------------------------------------
# why float: angle/angular_velocity are continuous, not whole-number therefor a float should be used - C629a
var _angle: float = 0.0                 # C643a - "_" prefix denotes private/internal use
var _angular_velocity: float = 0.0
# why float: distance and mass can be fractional (e.g. 152.5g or 153.6 px)
var radius: float = 100.0               # C614a - numeric data type
var mass: float = 1.0                   

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
	Engine.time_scale = Global.default_speed
	
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
	save_state_to_csv(path, mass_slider.value, velocity_slider.value, radius_slider.value)

func _on_import_file_selected(path: String) -> void:
	var data := load_state_from_csv(path)
	if data.is_empty():
		return
	mass_slider.value = data["mass"]
	velocity_slider.value = data["velocity"]
	radius_slider.value = data["radius"]
	Engine.time_scale = data["time_scale"]
	_update_values_from_sliders()
	_update_all_labels()

# =============================================================================
# TRANSPORT CONTROLS (pause / resume / speed up / slow down)
# =============================================================================

func _on_button_button_up() -> void:
	pause_simulation()

func _on_button_3_button_down() -> void:
	speed_up()

func _on_button_4_button_down() -> void:
	slow_down()


func _reset_sliders_to_defaults() -> void:
	var sliders: Array = [mass_slider, velocity_slider, radius_slider]
	# C635a - array [mass_slider, velocity_slider, radius_slider]
	var defaults: Array = [2, 3, 3]

	for i in range(sliders.size()):   # C632a - iteration over an array
		sliders[i].value = defaults[i]


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

func _on_mass_label_text_submitted(new_text: String) -> void:
	mass_slider.value = try_parse_validated_float(new_text, MASS_MIN, MASS_MAX, mass_slider.value)

func _on_radius_label_text_submitted(new_text: String) -> void:
	radius_slider.value = try_parse_validated_float(new_text, RADIUS_MIN, RADIUS_MAX, radius_slider.value)

func _on_velocity_label_text_submitted(new_text: String) -> void:
	velocity_slider.value = try_parse_validated_float(new_text, VELOCITY_MIN, VELOCITY_MAX, velocity_slider.value)
