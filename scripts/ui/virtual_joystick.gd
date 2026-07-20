extends Control

signal direction_changed(direction: Vector2)

@export var dead_zone: float = 0.14
@export var knob_limit: float = 0.62

var direction: Vector2 = Vector2.ZERO
var _active_touch: int = -1
var _mouse_active: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _active_touch == -1:
			_active_touch = event.index
			_update_direction(event.position)
			accept_event()
		elif not event.pressed and event.index == _active_touch:
			_active_touch = -1
			_reset_direction()
			accept_event()
	elif event is InputEventScreenDrag and event.index == _active_touch:
		_update_direction(event.position)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_mouse_active = event.pressed
		if _mouse_active:
			_update_direction(event.position)
		else:
			_reset_direction()
		accept_event()
	elif event is InputEventMouseMotion and _mouse_active:
		_update_direction(event.position)
		accept_event()

func _update_direction(local_position: Vector2) -> void:
	var radius := maxf(1.0, minf(size.x, size.y) * 0.5)
	var offset := local_position - size * 0.5
	var normalized := offset / radius
	if normalized.length() > 1.0:
		normalized = normalized.normalized()
	if normalized.length() < dead_zone:
		normalized = Vector2.ZERO
	direction = normalized
	direction_changed.emit(direction)
	queue_redraw()

func _reset_direction() -> void:
	direction = Vector2.ZERO
	direction_changed.emit(direction)
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.43
	var knob_radius := radius * 0.43
	var knob_position := center + direction * radius * knob_limit

	draw_circle(center, radius, Color(0.04, 0.055, 0.075, 0.50))
	draw_arc(center, radius, 0.0, TAU, 64, Color(0.92, 0.67, 0.20, 0.72), 4.0, true)
	draw_circle(center, radius * 0.72, Color(0.17, 0.12, 0.08, 0.28))
	draw_circle(knob_position, knob_radius, Color(0.95, 0.72, 0.28, 0.88))
	draw_arc(knob_position, knob_radius, 0.0, TAU, 48, Color(1.0, 0.90, 0.62, 0.96), 3.0, true)
