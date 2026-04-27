extends Node3D

enum PortalType {
	BLUE,
	ORANGE,
}

@export var _enabled : bool = true

var _valid_hit : bool = false
var _spawning_portal : bool = false

@onready var _raycast : RayCast3D = $RayCast3D
@onready var _spawn_area : Area3D = $SpawnArea3D

func _ready() -> void:
	if !_enabled:
		queue_free()

func _process(_delta: float) -> void:
	_valid_hit = _raycast.is_colliding()
	
	if _valid_hit:
		_spawn_area.global_position = _raycast.get_collision_point() - _raycast.get_collision_normal() * 0.01
		_spawn_area.look_at(_raycast.get_collision_point() - _raycast.get_collision_normal())

func _input(event: InputEvent) -> void:
	if _spawning_portal: return
	
	if event.is_action_pressed("player_fire1") and _valid_hit:
		_spawn_portal(PortalType.BLUE)
	elif event.is_action_pressed("player_fire2") and _valid_hit:
		_spawn_portal(PortalType.ORANGE)

func _spawn_portal(portal_type : PortalType) -> void:
	_spawning_portal = true
	await get_tree().physics_frame
	
	var new_position : Vector3 = _raycast.get_collision_point()
	var new_normal : Vector3 = _raycast.get_collision_normal()
	
	var target_portal : Portal
	match portal_type:
		PortalType.BLUE:
			target_portal = Portal.blue_portal
		PortalType.ORANGE:
			target_portal = Portal.orange_portal
	
	# Check if we're attempting to place one portal on top of another
	if _raycast.get_collider().is_in_group("portal"):
		if portal_type == PortalType.ORANGE and _raycast.get_collider().get_parent() == Portal.blue_portal:
			_spawning_portal = false
			return
		if portal_type == PortalType.BLUE and _raycast.get_collider().get_parent() == Portal.orange_portal:
			_spawning_portal = false
			return
		_raycast.add_exception(_raycast.get_collider())
		_raycast.force_raycast_update()
		if _raycast.get_collider().get_parent() == Portal.blue_portal or _raycast.get_collider().get_parent() == Portal.orange_portal:
			_spawning_portal = false
			return
		new_position = _raycast.get_collision_point()
		new_normal = _raycast.get_collision_normal()
		if new_normal.y != 0:
			_spawning_portal = false
			return
	
	# Don't put portal half-way through ground
	_spawn_area.global_position = new_position - new_normal * 0.01
	_spawn_area.look_at(new_position - new_normal)
	await get_tree().physics_frame
	if _spawn_area.get_overlapping_bodies().size() > 1:
		new_position += Vector3.UP * 0.5
	
	# Spawn portal
	target_portal.global_position = new_position + (new_normal * 0.01)
	target_portal.reset_physics_interpolation()
	target_portal.look_at(new_position - new_normal)
	target_portal.reset()
	var portal_physics = target_portal.get_node("PortalPhysics") as Portal_Physics
	portal_physics.init_portal()
	
	_raycast.clear_exceptions()
	_spawning_portal = false
