extends Control

signal look_dragged(relative: Vector2)

var _active_touch: int = -1
var _mouse_active: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _active_touch == -1:
			_active_touch = event.index
			accept_event()
		elif not event.pressed and event.index == _active_touch:
			_active_touch = -1
			accept_event()
	elif event is InputEventScreenDrag and event.index == _active_touch:
		look_dragged.emit(event.relative)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_mouse_active = event.pressed
		accept_event()
	elif event is InputEventMouseMotion and _mouse_active:
		look_dragged.emit(event.relative)
		accept_event()
