extends Button

var current_style = self.get_theme_stylebox("Panel")

func _ready():
	pass
func _process(_delta):
	pass
func on():
	var tween = create_tween().set_parallel(true)
	$Panel.visible = true
	$Panel2.visible = false
	$Sprite2D2.visible = false
	$Sprite2D.visible = true
	tween.tween_property($Sprite2D, "position", Vector2(38, 11), 0.3)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprite2D2, "position", Vector2(38, 11), 0.3)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
func off():
	var tween = create_tween().set_parallel(true)
	$Panel.visible = false
	$Panel2.visible = true
	$Sprite2D2.visible = true
	$Sprite2D.visible = false
	tween.tween_property($Sprite2D, "position", Vector2(11, 11), 0.3)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprite2D2, "position", Vector2(11, 11), 0.3)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
