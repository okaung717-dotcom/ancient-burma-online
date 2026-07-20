extends CharacterBody3D

@export var move_speed: float = 5.4
@export var acceleration: float = 14.0
@export var jump_velocity: float = 6.2
@export var touch_look_sensitivity: float = 0.0042
@export var desktop_debug_controls: bool = true

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var interaction_ray: RayCast3D = $CameraPivot/SpringArm3D/Camera3D/InteractionRay
@onready var name_label: Label3D = $NameLabel

var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var sync_timer: float = 0.0
var target_position: Vector3
var target_yaw: float = 0.0
var _move_input: Vector2 = Vector2.ZERO
var _jump_queued: bool = false

func _ready() -> void:
	add_to_group("player_characters")
	name_label.text = "Player %s" % name
	target_position = global_position
	target_yaw = rotation.y
	interaction_ray.add_exception(self)
	if is_multiplayer_authority():
		camera.current = true
	else:
		camera.current = false

func set_move_input(value: Vector2) -> void:
	if not is_multiplayer_authority():
		return
	_move_input = value.limit_length(1.0)

func apply_look_delta(relative: Vector2) -> void:
	if not is_multiplayer_authority():
		return
	rotate_y(-relative.x * touch_look_sensitivity)
	camera_pivot.rotation.x = clamp(
		camera_pivot.rotation.x - relative.y * touch_look_sensitivity,
		deg_to_rad(-55.0),
		deg_to_rad(45.0)
	)

func request_jump() -> void:
	if is_multiplayer_authority():
		_jump_queued = true

func request_interact() -> String:
	if not is_multiplayer_authority():
		return "Only your character can use this."
	interaction_ray.force_raycast_update()
	if not interaction_ray.is_colliding():
		return "Move closer and face an object."
	var collider := interaction_ray.get_collider()
	if collider != null and collider.has_method("interact"):
		var result: Variant = collider.interact(self)
		if result is String:
			return result
		return "Interaction complete."
	return "This object cannot be used yet."

func _unhandled_input(event: InputEvent) -> void:
	if not desktop_debug_controls or not OS.has_feature("editor"):
		return
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		apply_look_delta(event.relative)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		request_jump()

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		_process_local_movement(delta)
		sync_timer += delta
		if sync_timer >= 0.05:
			sync_timer = 0.0
			sync_state.rpc(global_position, rotation.y, velocity)
	else:
		global_position = global_position.lerp(target_position, minf(1.0, delta * 14.0))
		rotation.y = lerp_angle(rotation.y, target_yaw, minf(1.0, delta * 14.0))

func _process_local_movement(delta: float) -> void:
	if desktop_debug_controls and OS.has_feature("editor"):
		var debug_input := Vector2(
			float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
			float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
		).normalized()
		if debug_input.length() > 0.0:
			_move_input = debug_input

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif _jump_queued:
		velocity.y = jump_velocity
	_jump_queued = false

	var move_basis := Basis(Vector3.UP, rotation.y)
	var direction := (move_basis * Vector3(_move_input.x, 0.0, _move_input.y)).normalized()
	var target_x := direction.x * move_speed
	var target_z := direction.z * move_speed
	velocity.x = move_toward(velocity.x, target_x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_z, acceleration * delta)
	move_and_slide()

	if global_position.y < -10.0:
		global_position = Vector3(0.0, 0.2, 8.0)
		velocity = Vector3.ZERO

@rpc("authority", "call_remote", "unreliable_ordered")
func sync_state(new_position: Vector3, new_yaw: float, new_velocity: Vector3) -> void:
	target_position = new_position
	target_yaw = new_yaw
	velocity = new_velocity
