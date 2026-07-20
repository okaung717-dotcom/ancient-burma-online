extends CanvasLayer

const JOYSTICK_SCRIPT := preload("res://scripts/ui/virtual_joystick.gd")
const CAMERA_LOOK_SCRIPT := preload("res://scripts/ui/camera_look_area.gd")

var _move_direction: Vector2 = Vector2.ZERO
var _local_player = null
var _root: Control
var _toast: Label
var _toast_timer: float = 0.0

func _ready() -> void:
	layer = 20
	_build_interface()
	visible = false

func _process(delta: float) -> void:
	if not visible:
		return

	if not is_instance_valid(_local_player) or not _local_player.is_multiplayer_authority():
		_local_player = _find_local_player()

	if is_instance_valid(_local_player):
		_local_player.set_move_input(_move_direction)

	if _toast_timer > 0.0:
		_toast_timer -= delta
		if _toast_timer <= 0.0:
			_toast.visible = false

func reset_controls() -> void:
	_move_direction = Vector2.ZERO
	_local_player = null

func show_message(message: String, duration: float = 1.8) -> void:
	_toast.text = message
	_toast.visible = true
	_toast_timer = duration

func _find_local_player() -> Node:
	for candidate in get_tree().get_nodes_in_group("player_characters"):
		if candidate.is_multiplayer_authority():
			return candidate
	return null

func _build_interface() -> void:
	_root = Control.new()
	_root.name = "MobileHUD"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	var camera_area := Control.new()
	camera_area.name = "CameraLookArea"
	camera_area.set_script(CAMERA_LOOK_SCRIPT)
	camera_area.anchor_left = 0.34
	camera_area.anchor_top = 0.0
	camera_area.anchor_right = 1.0
	camera_area.anchor_bottom = 1.0
	camera_area.offset_left = 0.0
	camera_area.offset_top = 0.0
	camera_area.offset_right = 0.0
	camera_area.offset_bottom = 0.0
	camera_area.connect("look_dragged", Callable(self, "_on_look_dragged"))
	_root.add_child(camera_area)

	var joystick := Control.new()
	joystick.name = "MoveJoystick"
	joystick.set_script(JOYSTICK_SCRIPT)
	joystick.anchor_left = 0.0
	joystick.anchor_top = 1.0
	joystick.anchor_right = 0.0
	joystick.anchor_bottom = 1.0
	joystick.offset_left = 26.0
	joystick.offset_top = -226.0
	joystick.offset_right = 226.0
	joystick.offset_bottom = -26.0
	joystick.connect("direction_changed", Callable(self, "_on_joystick_changed"))
	_root.add_child(joystick)

	var jump_button := _create_action_button("JUMP", 118.0)
	jump_button.name = "JumpButton"
	jump_button.anchor_left = 1.0
	jump_button.anchor_top = 1.0
	jump_button.anchor_right = 1.0
	jump_button.anchor_bottom = 1.0
	jump_button.offset_left = -164.0
	jump_button.offset_top = -164.0
	jump_button.offset_right = -34.0
	jump_button.offset_bottom = -34.0
	jump_button.button_down.connect(_on_jump_pressed)
	_root.add_child(jump_button)

	var interact_button := _create_action_button("USE", 92.0)
	interact_button.name = "InteractButton"
	interact_button.anchor_left = 1.0
	interact_button.anchor_top = 1.0
	interact_button.anchor_right = 1.0
	interact_button.anchor_bottom = 1.0
	interact_button.offset_left = -284.0
	interact_button.offset_top = -252.0
	interact_button.offset_right = -176.0
	interact_button.offset_bottom = -144.0
	interact_button.pressed.connect(_on_interact_pressed)
	_root.add_child(interact_button)

	_toast = Label.new()
	_toast.name = "Toast"
	_toast.anchor_left = 0.5
	_toast.anchor_top = 0.0
	_toast.anchor_right = 0.5
	_toast.anchor_bottom = 0.0
	_toast.offset_left = -260.0
	_toast.offset_top = 34.0
	_toast.offset_right = 260.0
	_toast.offset_bottom = 88.0
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_toast.add_theme_font_size_override("font_size", 21)
	_toast.add_theme_color_override("font_color", Color(1.0, 0.90, 0.64))
	_toast.add_theme_stylebox_override("normal", _make_panel_style(Color(0.035, 0.045, 0.065, 0.86), 18.0))
	_toast.visible = false
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_toast)

func _create_action_button(label_text: String, minimum_size: float) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(minimum_size, minimum_size)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", Color(1.0, 0.93, 0.72))
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.21, 0.08, 0.045, 0.82), minimum_size * 0.5))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.29, 0.11, 0.055, 0.88), minimum_size * 0.5))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.68, 0.36, 0.08, 0.94), minimum_size * 0.5))
	return button

func _make_panel_style(color: Color, radius: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.95, 0.67, 0.19, 0.88)
	style.set_border_width_all(3)
	var corner := int(radius)
	style.corner_radius_top_left = corner
	style.corner_radius_top_right = corner
	style.corner_radius_bottom_left = corner
	style.corner_radius_bottom_right = corner
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style

func _on_joystick_changed(direction: Vector2) -> void:
	_move_direction = direction

func _on_look_dragged(relative: Vector2) -> void:
	if is_instance_valid(_local_player):
		_local_player.apply_look_delta(relative)

func _on_jump_pressed() -> void:
	if is_instance_valid(_local_player):
		_local_player.request_jump()

func _on_interact_pressed() -> void:
	if not is_instance_valid(_local_player):
		return
	var result: String = _local_player.request_interact()
	show_message(result)
