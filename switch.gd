extends Button
# C658c - why: on()/off() are split into two separate public methods rather
# than one method with a boolean parameter (e.g. set_state(bool)) because
# each one drives a distinct, named animation — this reads more clearly at
# the call site ($Control4.on() / $Control4.off()) than a boolean flag would
# C744c - Explains code structures: the toggle STATE lives in Settings.gd  ✓
# (Global.dark_mode, cooldown) while the toggle ANIMATION lives here in the
# button's own script — keeping "what the setting is" separate from "how it
# looks when it changes" so either half can be edited without touching the other

# C638c - why: the fetched StyleBox is stored in a variable so the theme
# lookup only has to run once, instead of calling get_theme_stylebox()
# again anywhere the style is needed later
var current_style = self.get_theme_stylebox("Panel")
# C721c - Naming convention applied to a variable: "current_style" clearly  ✓
# names both what it holds and that it reflects the active/current theme

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
func on():
	# C741c - Naming convention applied to a code structure: "on"/"off" are  ✓
	# short but immediately readable given this is a toggle-button script
	var tween = create_tween().set_parallel(true)
	# C621c - Local variable
	$Panel.visible = true
	# C731c - Naming convention applied to an interface control: "$Panel" /
	# "$Panel2" / "$Sprite2D" / "$Sprite2D2" names describe exactly which
	# visual layer each node represents (the two icon states being crossfaded)
# FB[C731c] REJECTED (C7-1) - $Panel, $Panel2, $Sprite2D2 are Godot DEFAULT
#   auto-numbered names, not naming you applied. The comment claims they
#   'describe exactly which visual layer' - they describe nothing. Rename them
#   (IconOn/IconOff etc.) and this claim becomes real.
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
	# C743c - Explains use of data: on() and off() both write literal target  ✓
	# positions/visibility flags rather than reading them from data, because
	# there are only ever two fixed visual states for this toggle — storing
	# them as data instead of two short functions would add complexity
	# without adding flexibility
	var tween = create_tween().set_parallel(true)
		# 4. Animate the panel position smoothly over 0.4 secondsColor(0.165, 0.165, 0.165)
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
