extends Control
# C656b - Inheritance: this script extends the built-in Control class
# FB[C656b] REJECTED - same as C656a: engine-imposed inheritance is not yours to claim.

# C712b - Identifies functioning: this script controls the simulation
# selection menu — user picks a category tab, picks a simulation card,
# then presses start to launch the chosen simulation's scene
# C751b - Naming convention applied consistently across ALL elements in this
# file: snake_case for variables/functions, PascalCase for node/type names —
# matches Godot's own style guide throughout, not just in isolated spots

# ── Simulation data ────────────────────────────────────────────────────────
# Add or edit simulations here — no other code needs to change
# C658b - why: a single Dictionary of Dictionaries was chosen as the design
# for this whole file because every simulation needs the same fields
# (title/description/formula/scene), so one consistent structure can drive
# the UI instead of five sets of separate variables
# FB[C658b] RELABEL to C638b - this is a good why for ONE structure choice,
#   which is exactly what C638 (5-6 band) rewards. C658 (9-10) requires
#   explaining types AND structures AND sources across the feature.
const SIMULATIONS: Dictionary = {
	# C636b - Dictionary/record: groups related fields (title, description,  ✓
	# formula, scene) under one key instead of using five parallel arrays
	"circular_motion": {
		"title":       "Circular Motion",
		# C613b - Text/String data type  ✓
		"description": "An object moving in a circle experiences a centripetal force directed toward the centre. Adjust mass, velocity, and radius to see how each variable affects the net force required to maintain circular motion.",
		"formula":     "F = mv² / r",
		"scene":       "res://CircularMotion.tscn"
	},
	"conical_motion": {
		"title":       "Conical Motion",
		"description": "A conical pendulum traces a horizontal circle while the string sweeps out a cone. Adjust the string length and angle to explore the relationship between tension, gravity, and circular motion.",
		"formula":     "T = mg / cos(θ)",
		"scene":       "res://ConicalMotion.tscn"
	},
	"orbital_motion": {
		"title":       "Orbital Motion",
		"description": "A satellite orbits a central mass under gravitational attraction. Adjust the central mass and orbital radius to see how orbital velocity and period change.",
		"formula":     "v = √(GM / r)",
		"scene":       "res://OrbitalMotion.tscn"
	},
	"vertical_motion": {
		"title":       "Vertical Motion",
		"description": "An object launched vertically experiences constant gravitational acceleration. Adjust the initial velocity and mass to explore how height, time, and speed change over the trajectory.",
		"formula":     "v = u + at",
		"scene":       "res://VerticalMotion.tscn"
	},
	"projectile_motion": {
		"title":       "Projectile Motion",
		"description": "A projectile follows a parabolic path under gravity. Adjust the launch angle and initial speed to explore range, maximum height, and time of flight.",
		"formula":     "R = v²sin(2θ) / g",
		"scene":       "res://ProjectileMotion.tscn"
	}, 
}

# C629b - why: String is used (not an int/enum id) because the value is used  ✓
# directly as a Dictionary key to look up the matching SIMULATIONS entry
# C713b - Identifies input needing validation: current_simulation is set from
# user selection and must be checked against SIMULATIONS before use (see
# change_summary() and _on_start_pressed() below)
var current_simulation: String = ""
# C631b - Global variable
# FB[C631b] WEAK - same as C631a: script member, not a program-wide global.

const HOME = preload("res://HomeScreen.tscn")
# C622b - Constants (preloaded scene references that never change at runtime)  ✓
const SETTINGS = preload("res://Settings.tscn")

# ── Node references ────────────────────────────────────────────────────────
@onready var title_label      : Label = $ReferenceRect4/Title
# C634b - Global variable with explicit/appropriate data type (Label)
# FB[C634b] REJECTED - node references are not global variables (see C634a note).
@onready var description_label: Label = $ReferenceRect4/Description
# C627b - Graphical user interface (GUI) element reference  ✓
@onready var formula_label    : Label = $ReferenceRect4/Panel2/Formula
# C731b - Naming convention applied to an interface control: "formula_label"
# clearly names both what it displays (formula) and what kind of node it is
@onready var start_button: Panel = $ReferenceRect4/Button
# C633b - Relevant GUI control (the clickable "start" panel/button)  ✓

# ── Setup ──────────────────────────────────────────────────────────────────
func _ready() -> void:
	# C641b - Function  ✓
	# C742b - Explains functionality: on load, this connects every category
	# tab and every simulation card to their handler functions, then selects
	# the first tab and first card so the menu never opens on an empty state
	
	if Global.dark_mode == true:
		# C615b - Boolean data type (the literal "true")
		pass
# FB[C615b] WEAK - a bare literal `true` in a comparison is the thinnest possible
#   Boolean evidence. You already have C615a on a purposeful state flag; one
#   strong site per code beats two thin ones.
	else:
		$CanvasLayer.visible = true
	
	$ReferenceRect4/Button.gui_input.connect(_on_start_gui_input)
	# C642b - Method call (connect)  ✓
	# Connect category tab signals
	for node in get_tree().get_nodes_in_group("category_tabs"):
		# C632b - Iteration/repetition (for loop)  ✓
		node.panel_selected.connect(_on_category_selected)

	# Connect sim card signals
	for node in get_tree().get_nodes_in_group("sim_cards"):
		node.panel_selected.connect(_on_simulation_selected)

	# Set defaults
	var tabs  = get_tree().get_nodes_in_group("category_tabs")
	# C621b - Local variable  ✓
	# C721b - Naming convention applied to a variable: "tabs" is short but
	# still clearly describes the group of nodes it holds
	var cards = get_tree().get_nodes_in_group("sim_cards")
	# C635b - Array (get_nodes_in_group returns a Godot Array)  ✓
	

	if tabs.size()  > 0: tabs[0].select()
	# C725b - Range checking (ensures the tabs list actually has an item
	# before indexing into it with tabs[0])
	if cards.size() > 0: cards[0].select()
	# C735b - Two validation checks combined: this file demonstrates both a
	# range check (tabs.size() > 0 / cards.size() > 0, here) and an
	# existence check (simulation not in SIMULATIONS, in change_summary())
	# C626b - Selection (if statement)  ✓
# FB[C725b/C735b] CATEGORY ERROR (C7-3) - size checks on internal node groups
#   guard program state; they do not validate INPUT data. Your honest C7-3
#   evidence is in circular_motion.gd: the free-text boxes and the CSV load.

# ── Handlers ───────────────────────────────────────────────────────────────
func _on_category_selected(id: String) -> void:
	change_options(id)


func _on_simulation_selected(id: String) -> void:
	# C628b - Local variable/parameter with explicit data type (id: String)  ✓
	change_summary(id)

func _on_start_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# C724b - Type checking ("is InputEventMouseButton")
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
# FB[C724b] WEAK (C7-3) - `is InputEventMouseButton` is event dispatch, not
#   input-data validation. Same note as above: point C7-3 claims at real input.
			# C623b - Logical operator (and)  ✓
			_on_start_pressed()

func _on_start_pressed() -> void:
	# C643b - Access modifier convention: leading underscore marks this as an
	# internal/private-style function, since it's only meant to be triggered
	# by the connected gui_input signal, not called from outside this script
	# C645b - why: SIMULATIONS (an in-memory constant) is used as the data  ✓
	# source here instead of reading a file, since this menu data is fixed
	# ahead of time and doesn't need to be edited by the end user
	# C732b - Describes functionality: looks up the currently selected
	# simulation's data, bails out with a message if nothing was picked, then
	# transitions the whole scene to that simulation's dedicated .tscn file
	var data = SIMULATIONS.get(current_simulation, null)
	# C644b - Appropriate data structure/source: retrieving a record from the  ✓
	# Dictionary instead of searching an Array by index
	if data == null:
		print("No simulation selected")
		return
	get_tree().change_scene_to_file(data["scene"])

# ── change_options — called when a category tab is clicked ─────────────────
# TODO: filter simulation list by category
# C734b - Evidence of code maintenance: TODO comment tracks known unfinished  ✓
# work (category filtering) so it isn't lost or forgotten
func change_options(category: String) -> void:
	# C741b - Naming convention applied to a code structure: function name
	# "change_options" clearly matches its handler role (called from
	# _on_category_selected)
	print("Category changed to: ", category)

# ── change_summary — called when a simulation card is clicked ──────────────
# C722b - Outlines functioning: sets the currently selected simulation id,
# checks it's a real entry, then refreshes the title/description/formula
# labels to match — nothing else in the UI updates from this function
func change_summary(simulation: String) -> void:
	current_simulation = simulation
	if simulation not in SIMULATIONS:
		# C723b - Existence checking (confirms the id is a real dictionary key)
		print("Warning: no data found for id: ", simulation)
		return

	# C733b - Describes use of data: each field pulled from the matched
	# SIMULATIONS entry is written straight into its matching Label, so the
	# on-screen summary always mirrors whatever is stored in the dictionary
	var data = SIMULATIONS[simulation]
	title_label.text       = data["title"]
	description_label.text = data["description"]
	formula_label.text     = data["formula"]


func _on_settings_button_up() -> void:
	get_tree().change_scene_to_file("res://Settings.tscn")
