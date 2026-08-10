extends Node
# FB[opportunity] These five vars are this project's only TRUE globals - and they
#   are unlabelled and untyped. Add types (e.g. `var dark_mode: bool = true`),
#   then claim C631 and C634 here with a why. This is your cleanest missing win.

#Setting defaults
var default_speed = 1
var show_formula = true
var rounding_mode = "dp" #sf and dp
var decimal_places = 2
var dark_mode = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
