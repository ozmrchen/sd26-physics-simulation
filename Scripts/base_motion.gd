class_name BaseMotionSimulation
extends Control



var _mass: float = 1.0
var _radius: float = 100.0
var _velocity: float = 0.0
var _cooldown: bool = false

const MASS_MIN := 0.0
const MASS_MAX := 20.0
const RADIUS_MIN := 2.5
const RADIUS_MAX := 10.0
const VELOCITY_MIN := -60.0
const VELOCITY_MAX := 60.0


func get_mass() -> float:
	return _mass

func set_mass(value: float) -> void:
	_mass = clamp(value, MASS_MIN, MASS_MAX)

func get_radius() -> float:
	return _radius

func set_radius(value: float) -> void:
	_radius = clamp(value, RADIUS_MIN, RADIUS_MAX)

func get_velocity() -> float:
	return _velocity

func set_velocity(value: float) -> void:
	_velocity = clamp(value, VELOCITY_MIN, VELOCITY_MAX)


func get_centripetal_force() -> float:
	if _radius <= 0:
		return 0.0
	return (_mass * _velocity * _velocity) / _radius



func _is_valid_float_string(text: String) -> bool:
	var trimmed: String = text.strip_edges()
	if trimmed.is_empty():
		return false
	if not trimmed.is_valid_float():
		return false
	return true

func _clamp_to_range(value: float, min_value: float, max_value: float) -> float:
	return clamp(value, min_value, max_value)

func try_parse_validated_float(text: String, min_value: float, max_value: float, fallback: float) -> float:
	if not _is_valid_float_string(text):
		push_warning("Invalid numeric input '%s' - keeping previous value" % text)
		return fallback
	return _clamp_to_range(text.to_float(), min_value, max_value)


func save_state_to_csv(path: String, mass: float, velocity: float, radius: float) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		print("Error opening file for writing: ", FileAccess.get_open_error())
		return
	file.store_csv_line(["mass", "velocity", "radius", "simulation_speed"])
	file.store_csv_line([str(mass), str(velocity), str(radius), str(Engine.time_scale)])
	file.close()
	print("Saved to: ", path)

func load_state_from_csv(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		print("File not found: ", path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("Error opening file for reading: ", FileAccess.get_open_error())
		return {}

	var _headers: PackedStringArray = file.get_csv_line()
	var values: PackedStringArray = file.get_csv_line()
	file.close()

	if values.size() < 4:
		print("Save file looks malformed - expected 4 values, found %d" % values.size())
		return {}

	if not (_is_valid_float_string(values[0]) and _is_valid_float_string(values[1])
			and _is_valid_float_string(values[2]) and _is_valid_float_string(values[3])):
		print("Save file contains non-numeric data - load aborted")
		return {}

	return {
		"mass": _clamp_to_range(values[0].to_float(), MASS_MIN, MASS_MAX),
		"velocity": _clamp_to_range(values[1].to_float(), VELOCITY_MIN, VELOCITY_MAX),
		"radius": _clamp_to_range(values[2].to_float(), RADIUS_MIN, RADIUS_MAX),
		"time_scale": _clamp_to_range(values[3].to_float(), 0.1, 3.0)
	}


func pause_simulation() -> void:
	Engine.time_scale = 0.0

func resume_simulation(speed: float = 1.0) -> void:
	Engine.time_scale = speed

func speed_up(step: float = 0.1, max_speed: float = 3.0) -> void:
	if Engine.time_scale < max_speed:
		Engine.time_scale += step

func slow_down(step: float = 0.1, min_speed: float = 0.1) -> void:
	if Engine.time_scale > min_speed:
		Engine.time_scale -= step
