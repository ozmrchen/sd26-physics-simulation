extends Control


const SIMULATIONS: Dictionary = {
	"circular_motion": {
		"title":       "Circular Motion",
		"description": "An object moving in a circle experiences a centripetal force directed toward the centre. Adjust mass, velocity, and radius to see how each variable affects the net force required to maintain circular motion.",
		"formula":     "F = mv² / r",
		"scene":       "res://Scenes/CircularMotion.tscn"
	},
	"conical_motion": {
		"title":       "Conical Motion",
		"description": "A conical pendulum traces a horizontal circle while the string sweeps out a cone. Adjust the string length and angle to explore the relationship between tension, gravity, and circular motion.",
		"formula":     "T = mg / cos(θ)",
		"scene":       "res://Scenes/ConicalMotion.tscn"
	},
	"orbital_motion": {
		"title":       "Orbital Motion",
		"description": "A satellite orbits a central mass under gravitational attraction. Adjust the central mass and orbital radius to see how orbital velocity and period change.",
		"formula":     "v = √(GM / r)",
		"scene":       "res://Scenes/OrbitalMotion.tscn"
	},
	"vertical_motion": {
		"title":       "Vertical Motion",
		"description": "An object launched vertically experiences constant gravitational acceleration. Adjust the initial velocity and mass to explore how height, time, and speed change over the trajectory.",
		"formula":     "v = u + at",
		"scene":       "res://Scenes/VerticalMotion.tscn"
	},
	"projectile_motion": {
		"title":       "Projectile Motion",
		"description": "A projectile follows a parabolic path under gravity. Adjust the launch angle and initial speed to explore range, maximum height, and time of flight.",
		"formula":     "R = v²sin(2θ) / g",
		"scene":       "res://Scenes/ProjectileMotion.tscn"
	}, 
}

var current_simulation: String = ""

const HOME = preload("res://Scenes/HomeScreen.tscn")
const SETTINGS = preload("res://Scenes/Settings.tscn")

@onready var title_label      : Label = $ReferenceRect4/Title
@onready var description_label: Label = $ReferenceRect4/Description
@onready var formula_label    : Label = $ReferenceRect4/Panel2/Formula
@onready var start_button: Panel = $ReferenceRect4/Button

func _ready() -> void:
	
	if Global.dark_mode == true:
		pass
	else:
		$CanvasLayer.visible = true
	
	$ReferenceRect4/Button.gui_input.connect(_on_start_gui_input)
	for node in get_tree().get_nodes_in_group("category_tabs"):
		node.panel_selected.connect(_on_category_selected)

	for node in get_tree().get_nodes_in_group("sim_cards"):
		node.panel_selected.connect(_on_simulation_selected)

	var tabs  = get_tree().get_nodes_in_group("category_tabs")
	var cards = get_tree().get_nodes_in_group("sim_cards")
	

	if tabs.size()  > 0: tabs[0].select()
	if cards.size() > 0: cards[0].select()

func _on_category_selected(id: String) -> void:
	change_options(id)


func _on_simulation_selected(id: String) -> void:
	change_summary(id)

func _on_start_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_start_pressed()

func _on_start_pressed() -> void:
	var data = SIMULATIONS.get(current_simulation, null)
	if data == null:
		print("No simulation selected")
		return
	get_tree().change_scene_to_file(data["scene"])

func change_options(category: String) -> void:
	print("Category changed to: ", category)

func change_summary(simulation: String) -> void:
	current_simulation = simulation
	if simulation not in SIMULATIONS:
		print("Warning: no data found for id: ", simulation)
		return

	var data = SIMULATIONS[simulation]
	title_label.text       = data["title"]
	description_label.text = data["description"]
	formula_label.text     = data["formula"]


func _on_settings_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/Settings.tscn")
