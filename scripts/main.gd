extends Node3D

const PORT: int = 7000
const MAX_CLIENTS: int = 12
const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const INTERACTABLE_SCRIPT := preload("res://scripts/interactable.gd")

@onready var players: Node3D = $Players
@onready var menu: PanelContainer = $UI/Menu
@onready var dim: ColorRect = $UI/Dim
@onready var mobile_hint: Label = $UI/MobileHint
@onready var address: LineEdit = $UI/Menu/Margin/VBox/Address
@onready var status: Label = $UI/Menu/Margin/VBox/Status
@onready var mobile_controls = $MobileControls

var spawn_index: int = 0

func _ready() -> void:
	_build_demo_world()
	$UI/Menu/Margin/VBox/Offline.pressed.connect(start_offline)
	$UI/Menu/Margin/VBox/Host.pressed.connect(host_game)
	$UI/Menu/Margin/VBox/Join.pressed.connect(join_game)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	if OS.has_feature("dedicated_server"):
		host_game()

func start_offline() -> void:
	if players.get_child_count() == 0:
		spawn_player(1, Vector3(0.0, 0.2, 8.0))
	_set_gameplay_ui(true)
	status.text = "Offline mode"
	mobile_controls.show_message("Explore the courtyard")

func host_game() -> void:
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_server(PORT, MAX_CLIENTS)
	if result != OK:
		status.text = "Host failed: error %s" % result
		return
	multiplayer.multiplayer_peer = peer
	status.text = "Hosting on UDP port %s" % PORT
	spawn_player.rpc(1, _next_spawn_position())
	_set_gameplay_ui(true)
	mobile_controls.show_message("Room hosted on port %s" % PORT)

func join_game() -> void:
	var server_address := address.text.strip_edges()
	if server_address.is_empty():
		server_address = "127.0.0.1"
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_client(server_address, PORT)
	if result != OK:
		status.text = "Join failed: error %s" % result
		return
	multiplayer.multiplayer_peer = peer
	status.text = "Connecting to %s:%s…" % [server_address, PORT]

func _set_gameplay_ui(active: bool) -> void:
	menu.visible = not active
	dim.visible = not active
	mobile_hint.visible = not active
	mobile_controls.visible = active
	if not active:
		mobile_controls.reset_controls()

func _on_connected_to_server() -> void:
	status.text = "Connected — Peer ID %s" % multiplayer.get_unique_id()
	_set_gameplay_ui(true)
	mobile_controls.show_message("Connected to the realm")

func _on_connection_failed() -> void:
	status.text = "Connection failed. Check the server IP."
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	_set_gameplay_ui(false)

func _on_server_disconnected() -> void:
	status.text = "Server disconnected."
	for child in players.get_children():
		child.queue_free()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	_set_gameplay_ui(false)

func _on_peer_connected(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	for child in players.get_children():
		spawn_player.rpc_id(peer_id, int(child.name), child.global_position)
	spawn_player.rpc(peer_id, _next_spawn_position())

func _on_peer_disconnected(peer_id: int) -> void:
	if multiplayer.is_server():
		despawn_player.rpc(peer_id)

func _next_spawn_position() -> Vector3:
	var points := [
		Vector3(0.0, 0.2, 8.0),
		Vector3(2.5, 0.2, 8.0),
		Vector3(-2.5, 0.2, 8.0),
		Vector3(5.0, 0.2, 6.0),
		Vector3(-5.0, 0.2, 6.0),
		Vector3(0.0, 0.2, 11.0)
	]
	var result: Vector3 = points[spawn_index % points.size()]
	spawn_index += 1
	return result

@rpc("authority", "call_local", "reliable")
func spawn_player(peer_id: int, spawn_position: Vector3) -> void:
	var node_name := str(peer_id)
	if players.has_node(node_name):
		return
	var player := PLAYER_SCENE.instantiate()
	player.name = node_name
	player.position = spawn_position
	player.set_multiplayer_authority(peer_id)
	players.add_child(player, true)

@rpc("authority", "call_local", "reliable")
func despawn_player(peer_id: int) -> void:
	var player := players.get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _build_demo_world() -> void:
	var environment_node := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.055, 0.075, 0.11)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.50, 0.58, 0.72)
	environment.ambient_light_energy = 0.62
	environment_node.environment = environment
	add_child(environment_node)

	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-52.0, -28.0, 0.0)
	moon.light_color = Color(1.0, 0.83, 0.58)
	moon.light_energy = 1.45
	moon.shadow_enabled = true
	add_child(moon)

	_create_ground()
	_create_courtyard()
	_create_interactable_shrine()

func _create_ground() -> void:
	var ground_body := StaticBody3D.new()
	ground_body.name = "Ground"
	var ground_mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(70.0, 0.4, 70.0)
	box.material = _material(Color(0.12, 0.16, 0.16), 0.0, 0.95)
	ground_mesh.mesh = box
	ground_mesh.position.y = -0.2
	ground_body.add_child(ground_mesh)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(70.0, 0.4, 70.0)
	collision.shape = shape
	collision.position.y = -0.2
	ground_body.add_child(collision)
	add_child(ground_body)

func _create_courtyard() -> void:
	var red := _material(Color(0.31, 0.035, 0.03), 0.0, 0.7)
	var gold := _material(Color(0.78, 0.47, 0.055), 0.55, 0.34)
	var stone := _material(Color(0.32, 0.30, 0.27), 0.0, 0.92)
	var roof := _material(Color(0.18, 0.035, 0.025), 0.08, 0.72)

	_create_box(Vector3(0, 0.25, -8), Vector3(16, 0.5, 10), stone)
	_create_box(Vector3(0, 0.7, -11.5), Vector3(11, 0.9, 3), stone)

	for x in [-6.0, -3.0, 3.0, 6.0]:
		_create_cylinder(Vector3(x, 2.9, -9.0), 0.34, 5.4, red)
		_create_cylinder(Vector3(x, 2.9, -14.0), 0.34, 5.4, red)
		_create_cylinder(Vector3(x, 5.65, -9.0), 0.46, 0.22, gold)
		_create_cylinder(Vector3(x, 5.65, -14.0), 0.46, 0.22, gold)

	_create_box(Vector3(0, 5.65, -11.5), Vector3(15.5, 0.42, 6.8), roof)
	_create_box(Vector3(0, 6.15, -11.5), Vector3(12.2, 0.36, 5.2), gold)
	_create_box(Vector3(0, 6.55, -11.5), Vector3(8.4, 0.30, 3.8), roof)
	_create_cone(Vector3(0, 7.8, -11.5), 0.95, 2.4, gold)

	for x in [-9.0, 9.0]:
		for z in [-2.0, 5.0, 12.0]:
			_create_cylinder(Vector3(x, 1.4, z), 0.12, 2.8, gold)
			_create_sphere(Vector3(x, 3.1, z), 0.34, _material(Color(1.0, 0.30, 0.08), 0.0, 0.4))
			var light := OmniLight3D.new()
			light.position = Vector3(x, 3.1, z)
			light.light_color = Color(1.0, 0.28, 0.07)
			light.light_energy = 1.1
			light.omni_range = 5.0
			add_child(light)

func _create_interactable_shrine() -> void:
	var shrine = INTERACTABLE_SCRIPT.new()
	shrine.name = "AncientBellShrine"
	shrine.position = Vector3(0.0, 0.0, 3.8)
	shrine.set("interaction_message", "The ancient bell resonates across the Golden Realm.")

	var base_mesh := MeshInstance3D.new()
	var base_box := BoxMesh.new()
	base_box.size = Vector3(1.5, 0.45, 1.2)
	base_box.material = _material(Color(0.28, 0.08, 0.04), 0.05, 0.7)
	base_mesh.mesh = base_box
	base_mesh.position.y = 0.225
	shrine.add_child(base_mesh)

	var bell_mesh := MeshInstance3D.new()
	var bell := SphereMesh.new()
	bell.radius = 0.43
	bell.height = 0.72
	bell.material = _material(Color(0.82, 0.50, 0.08), 0.7, 0.28)
	bell_mesh.mesh = bell
	bell_mesh.position = Vector3(0.0, 1.25, 0.0)
	shrine.add_child(bell_mesh)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.5, 1.8, 1.2)
	collision.shape = shape
	collision.position = Vector3(0.0, 0.9, 0.0)
	shrine.add_child(collision)

	add_child(shrine)

func _material(color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material

func _create_box(position_value: Vector3, size_value: Vector3, material: Material) -> void:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size_value
	mesh.material = material
	instance.mesh = mesh
	instance.position = position_value
	add_child(instance)

func _create_cylinder(position_value: Vector3, radius: float, height: float, material: Material) -> void:
	var instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 20
	mesh.material = material
	instance.mesh = mesh
	instance.position = position_value
	add_child(instance)

func _create_cone(position_value: Vector3, radius: float, height: float, material: Material) -> void:
	var instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.05
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	mesh.material = material
	instance.mesh = mesh
	instance.position = position_value
	add_child(instance)

func _create_sphere(position_value: Vector3, radius: float, material: Material) -> void:
	var instance := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.material = material
	instance.mesh = mesh
	instance.position = position_value
	add_child(instance)
