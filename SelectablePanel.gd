extends Panel

# ── Customise these per-node in the Inspector ──────────────────────────────
@export var normal_bg           : Color  = Color("#2a2a2a")
@export var selected_bg         : Color  = Color("#F5A62322")
@export var normal_border       : Color  = Color("#333333")
@export var selected_border     : Color  = Color("#F5A623")
@export var normal_text_color   : Color  = Color("#E8E6E0")
@export var selected_text_color : Color  = Color("#F5A623")
@export var normal_icon_bg      : Color  = Color("#1a1a1a")
@export var selected_icon_bg    : Color  = Color("#4e3919ff")
@export var normal_icon_border  : Color  = Color("#333333")
@export var selected_icon_border: Color  = Color("#0d0a06")
@export var border_width        : int    = 1
@export var corner_radius       : int    = 9

# Unique ID for this panel — set this in the Inspector
# e.g. "motion", "fields", "circular_motion", "orbital_motion"
@export var panel_id: String = ""

# "category_tabs" for the top bar, "sim_cards" for the simulation list
@export var selection_group: String = "selectable_panels"

# ── State ──────────────────────────────────────────────────────────────────
var is_selected: bool = false
var _style     : StyleBoxFlat

# Passes panel_id so the parent script knows which panel was clicked
signal panel_selected(id: String)

# ── Setup ──────────────────────────────────────────────────────────────────
func _ready() -> void:
	add_to_group(selection_group)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	_style = StyleBoxFlat.new()
	_style.corner_radius_top_left     = corner_radius
	_style.corner_radius_top_right    = corner_radius
	_style.corner_radius_bottom_left  = corner_radius
	_style.corner_radius_bottom_right = corner_radius
	_style.border_width_left   = border_width
	_style.border_width_right  = border_width
	_style.border_width_top    = border_width
	_style.border_width_bottom = border_width

	add_theme_stylebox_override("panel", _style)
	_apply_style(false)

	var title = get_node_or_null("Title")
	if title and title.label_settings:
		title.label_settings = title.label_settings.duplicate()

# ── Input ──────────────────────────────────────────────────────────────────
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			select()

# ── Public methods ─────────────────────────────────────────────────────────
func select() -> void:
	for node in get_tree().get_nodes_in_group(selection_group):
		if node != self and node.has_method("deselect"):
			node.deselect()

	is_selected = true
	_apply_style(true)
	panel_selected.emit(panel_id)

func deselect() -> void:
	is_selected = false
	_apply_style(false)

# ── Internal ───────────────────────────────────────────────────────────────
func _apply_style(selected: bool) -> void:
	_style.bg_color     = selected_bg     if selected else normal_bg
	_style.border_color = selected_border if selected else normal_border

	var text_color = selected_text_color if selected else normal_text_color
	var title = get_node_or_null("Title")
	if title and title.label_settings:
		title.label_settings.font_color = text_color

	var icon_panel = get_node_or_null("Panel")
	if icon_panel:
		var icon_style = icon_panel.get_theme_stylebox("panel") as StyleBoxFlat
		if icon_style:
			icon_style.bg_color     = selected_icon_bg     if selected else normal_icon_bg
			icon_style.border_color = selected_icon_border if selected else normal_icon_border
