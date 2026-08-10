extends Control









const HOME = preload("res://HomeScreen.tscn")




var cooldown = false


func _ready() -> void:




	print(Global.dark_mode)






	if Global.dark_mode == true:

		$ReferenceRect4/Control4.on()

	else:
		$ReferenceRect4/Control4.off()

	if Global.dark_mode == true:
		pass
	else:
		$CanvasLayer.visible = true



func _on_settings_2_button_up() -> void:
	get_tree().change_scene_to_file("res://HomeScreen.tscn")


func _on_control_2_button_up() -> void:



	Global.show_formula = not Global.show_formula


func _on_control_4_button_up() -> void:








	if cooldown == false:

		cooldown = true

		Global.dark_mode = not Global.dark_mode

		if Global.dark_mode == true:
			$ReferenceRect4/Control4.on()
		else:
			$ReferenceRect4/Control4.off()

		$CanvasLayer.visible = not $CanvasLayer.visible

		await get_tree().create_timer(0.3).timeout





		cooldown = false
	else:
		pass
