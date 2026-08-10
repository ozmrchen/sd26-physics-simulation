extends Control



































@onready var radius_slider: HSlider = $layout/options/radiusSlider
@onready var velocity_slider: HSlider = $layout/options/velocitySlider
@onready var mass_slider: HSlider = $layout/options/massSlider

@onready var save_dialog: FileDialog = $SaveFileDialog
@onready var import_dialog: FileDialog = $ImportFileDialog

@onready var radius_label: LineEdit = $layout/options/radiusLabel
@onready var velocity_label: LineEdit = $layout/options/velocityLabel
@onready var mass_label: LineEdit = $layout/options/massLabel
@onready var force_label: Label = $layout/options/forceLabel
@onready var formula_label: Label = $layout/options/formulaLabel
@onready var speed_label: Label = $layout/options/speedLabel


@onready var ball: Node2D = $Ball
@onready var pivot: Node2D = $Pivot
@onready var string_line: Line2D = $Line2D


const RADIUS_SCALE := 20.0




const MASS_MIN := 0.0
const MASS_MAX := 20.0
const RADIUS_MIN := 2.5
const RADIUS_MAX := 10.0
const VELOCITY_MIN := -60.0
const VELOCITY_MAX := 60.0



var _angle: float = 0.0
var _angular_velocity: float = 0.0

var radius: float = 100.0
var mass: float = 1.0

var tween_toggle: bool = true





func _ready() -> void:



	_setup_file_dialogs()
	_connect_slider_signals()
	_update_values_from_sliders()
	_update_all_labels()

	if Global.dark_mode == true:
		pass
	else:
		$CanvasLayer.visible = true


func _setup_file_dialogs() -> void:


	save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_dialog.add_filter("*.csv", "CSV Files")
	save_dialog.file_selected.connect(_on_save_file_selected)

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


	var linear_velocity: float = velocity_slider.value
	var current_radius: float = radius_slider.value
	var current_mass: float = max(mass_slider.value, 0.0)




	if current_radius > 0:
		var force: float = (current_mass * linear_velocity * linear_velocity) / current_radius

		force_label.text = "= %.2f N" % snapped(force, 0.01)
	else:
		force_label.text = "= 0.00 N"

	formula_label.text = "F = (%.2f * (%.2f)² ) / %.2f" % [current_mass, linear_velocity, current_radius]




func _update_values_from_sliders() -> void:
	mass = max(mass_slider.value, 0.0)
	radius = radius_slider.value * RADIUS_SCALE
	var linear_velocity: float = velocity_slider.value * 30.0

	if radius > 0:
		_angular_velocity = linear_velocity / radius


func _process(delta: float) -> void:
	var current_mass: float = max(mass_slider.value, 0.0)
	var old_angle: float = _angle



	_angle += _angular_velocity * delta
	if current_mass == 0:
		_angle = old_angle

	ball.position = pivot.position + Vector2(cos(_angle), sin(_angle)) * radius

	speed_label.text = "= %.0f" % (snapped(Engine.time_scale, 0.01) * 100) + "%"


	string_line.clear_points()
	string_line.add_point(pivot.position)
	string_line.add_point(ball.position)










func _is_valid_float_string(text: String) -> bool:

	var trimmed: String = text.strip_edges()
	if trimmed.is_empty():
		return false

	if not trimmed.is_valid_float():
		return false
	return true


func _clamp_to_range(value: float, min_value: float, max_value: float) -> float:

	return clamp(value, min_value, max_value)


func _try_parse_validated_float(text: String, min_value: float, max_value: float, fallback: float) -> float:


	if not _is_valid_float_string(text):
		push_warning("Invalid numeric input '%s' - keeping previous value" % text)
		return fallback
	return _clamp_to_range(text.to_float(), min_value, max_value)




func _on_radius_changed(new_value: float) -> void:
	radius_label.text = "%s" % new_value
	var new_radius: float = new_value * RADIUS_SCALE

	if new_radius > 0 and radius > 0:

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
	var linear_velocity: float = new_value * 30.0

	if radius > 0:
		_angular_velocity = linear_velocity / radius
	_update_force_label()


func _on_save_file_selected(path: String) -> void:
	save_to_csv(path)


func _on_import_file_selected(path: String) -> void:
	load_from_csv(path)






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


	if values.size() < 4:
		print("Save file looks malformed - expected 4 values, found %d" % values.size())
		return





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






func _on_button_button_up() -> void:
	Engine.time_scale = 0.0


func _on_button_2_button_down() -> void:
	Engine.time_scale = 1.0
	_reset_sliders_to_defaults()


func _reset_sliders_to_defaults() -> void:
	var sliders: Array = [mass_slider, velocity_slider, radius_slider]
	var defaults: Array = [2, 3, 3]

	for i in range(sliders.size()):
		sliders[i].value = defaults[i]


func _on_button_3_button_down() -> void:
	if Engine.time_scale < 3:
		Engine.time_scale += 0.1


func _on_button_4_button_down() -> void:
	if Engine.time_scale > 0.1:
		Engine.time_scale -= 0.1






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









func _on_radius_label_text_submitted(new_text: String) -> void:
	radius_slider.value = _try_parse_validated_float(new_text, RADIUS_MIN, RADIUS_MAX, radius_slider.value)


func _on_velocity_label_text_submitted(new_text: String) -> void:
	velocity_slider.value = _try_parse_validated_float(new_text, VELOCITY_MIN, VELOCITY_MAX, velocity_slider.value)


func _on_mass_label_text_submitted(new_text: String) -> void:
	mass_slider.value = _try_parse_validated_float(new_text, MASS_MIN, MASS_MAX, mass_slider.value)
