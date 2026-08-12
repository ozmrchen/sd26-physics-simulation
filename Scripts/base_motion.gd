class_name BaseMotionSimulation
extends Control

# ============================================================================
# BASE MOTION SIMULATION
# ----------------------------------------------------------------------------
# C651a - Classes: this is a custom class (declared with "class_name"), not
# just a built-in node type. Every simulation script should use
# "extends BaseMotionSimulation" instead of "extends Control" directly.
#
# C652a - Objects: whichever simulation scene uses this class becomes an
# OBJECT — a running instance of BaseMotionSimulation — the moment that
# scene loads. circular_motion.tscn's root node is one such object.
#
# C655a - Generalisation: circular, conical, orbital, vertical and
# projectile motion all need the SAME save/load-to-CSV behaviour, the SAME
# existence/type/range validation on typed input, and the SAME
# play/pause/speed transport controls. Rather than copy-pasting that logic
# into five separate scripts, it is written ONCE here and shared by every
# simulation that inherits from this class. That is what generalisation
# means: pulling out what's common across a family of related classes so it
# only has to exist — and be fixed, if it's ever buggy — in one place.
#
# C657a - Range of data types/structures/sources used in this class alone:
# float (physical values), bool (_cooldown flag), String (file paths, CSV
# text), const (fixed validation ranges), and a CSV file on disk as the
# data source for save/load.
#
# C658a - why (overall design): a base class was chosen over five unrelated
# scripts because mass/radius/velocity validation and CSV persistence are
# IDENTICAL in shape across every simulation type — only the physics
# formula and the animated node positions actually differ per simulation.
# Sharing the common logic here means a bug fix or a rule change (e.g. a
# new minimum mass) only ever needs to be made in one place, not five.
# ============================================================================


# --- Encapsulated physical state --------------------------------------------
# C654a - Encapsulation: state is private (leading underscore) and can only
# be read or changed through the get_/set_ methods below — never assigned
# directly by a subclass or by outside code, so invalid values can't sneak in
var _mass: float = 1.0
var _radius: float = 100.0
var _velocity: float = 0.0
var _cooldown: bool = false

# why float: mass/radius/velocity are continuous physical quantities, not
# whole-number counts, so float is the appropriate numeric type here
const MASS_MIN := 0.0
const MASS_MAX := 20.0
const RADIUS_MIN := 2.5
const RADIUS_MAX := 10.0
const VELOCITY_MIN := -60.0
const VELOCITY_MAX := 60.0


# --- Encapsulated access (getters / validated setters) ----------------------
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


# --- Abstraction --------------------------------------------------------
# C653a - Abstraction: a subclass calls get_centripetal_force() to get an
# answer WITHOUT needing to know (or repeat) the actual F = mv²/r formula.
# If the formula ever changed, only this one function would need editing.
func get_centripetal_force() -> float:
	if _radius <= 0:
		return 0.0
	return (_mass * _velocity * _velocity) / _radius


# =============================================================================
# INPUT VALIDATION
# why: every value that can come from free-text user input (the label
# text_submitted callbacks) or from an external CSV file needs to be checked
# for existence, type and range before it is trusted - unlike slider input,
# which is already numeric and pre-clamped by the slider's own min/max.
# =============================================================================

# --- Shared validation helpers (generalised across every simulation) -------
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
	# RANGE check: keep validated numeric input inside a sensible range
	return clamp(value, min_value, max_value)

func try_parse_validated_float(text: String, min_value: float, max_value: float, fallback: float) -> float:
	# Combines existence + type + range checks in one reusable helper so
	# every subclass's text_submitted callback stays short and consistent
	if not _is_valid_float_string(text):
		push_warning("Invalid numeric input '%s' - keeping previous value" % text)
		return fallback
	return _clamp_to_range(text.to_float(), min_value, max_value)

# =============================================================================
# FILE I/O (C644a / C645a - data source: CSV on disk, chosen for readability)
# =============================================================================

# --- Shared CSV persistence (generalised across every simulation) ----------
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


# --- Shared transport controls (generalised across every simulation) -------
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
