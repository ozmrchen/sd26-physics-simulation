extends Control


const HOME = preload("res://Scenes/HomeScreen.tscn")

var cooldown = false

func _ready() -> void:
	print(Global.dark_mode)
	
	$ReferenceRect4/Panel4/speedSlider.value = Global.default_speed
	
	if Global.dark_mode == true:
		$ReferenceRect4/Control4.on()
	else:
		$ReferenceRect4/Control4.off()
		
	if Global.dark_mode == true:
		pass
	else:
		$CanvasLayer.visible = true
	
func _process(_delta: float) -> void:
	
	$ReferenceRect4/Panel4/speedLabel.text = "%sx" % $ReferenceRect4/Panel4/speedSlider.value
	
	Global.default_speed = $ReferenceRect4/Panel4/speedSlider.value

func _on_settings_2_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/HomeScreen.tscn")

func _on_control_2_button_up() -> void:
	Global.show_formula = not Global.show_formula

func _on_control_4_button_up() -> void: # C732 when this button is pressed the user toggles on/off dark mode
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
