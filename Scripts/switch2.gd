extends Control

var selected = "dp"

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _on_control_button_up() -> void:
	if selected == "dp":
		pass
	else:
		selected = "dp"
		$Control/Panel.visible = true
		Global.rounding_mode = "dp"
		$Control2/Panel.visible = false
		$Control2/Label.visible = true
		$Control2/Label2.visible = false
		$Control/Label3.visible = false
		$Control/Label2.visible = true


func _on_control_2_button_up() -> void:
	if selected == "dp":
		selected = "sf"
		$Control/Panel.visible = false
		$Control/Label2.visible = false
		$Control/Label3.visible = true
		Global.rounding_mode = "sf"
		$Control2/Panel.visible = true
		$Control2/Label2.visible = true
		$Control2/Label.visible = false
	else:
		pass
