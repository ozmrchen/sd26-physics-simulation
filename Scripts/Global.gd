extends Node

var default_speed: int = 1 # C631 - global variable that any other script can access
var show_formula: bool = true # C634 - this is a bool (as well as a global variable) as the formula either showing or it's not so true or false is best suited
var rounding_mode: String = "dp" # string used as there are two options "dp" or "sf" instead of on or off so string is used for the text
var decimal_places: int = 2
var dark_mode: bool = true

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass
