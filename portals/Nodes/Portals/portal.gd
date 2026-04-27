class_name Portal
extends Node3D

const CAMERA_NEAR_SAFE_MARGIN : float = 0.5

@export_group("Visual")
@export var _portal_color : Color = Color.WHITE
@export_group("References")
@export var _linked_portal : Portal


static var blue_portal : Portal
static var orange_portal : Portal
var _portal_pos : Vector2

@onready var _camera : Camera3D = $SubViewport/Camera3D
@onready var _sub_viewport : SubViewport = $SubViewport
@onready var _mesh_instance : MeshInstance3D = $MeshInstance3D
@onready var _distortion_instance : MeshInstance3D = $DistortionInstance3D
@onready var _particles : GPUParticles3D = $PortalParticles
@onready var _surface_material : ShaderMaterial = _mesh_instance.mesh.surface_get_material(0)
@onready var _distortion_material : ShaderMaterial = _distortion_instance.mesh.surface_get_material(0)
@onready var _physics : Portal_Physics = $PortalPhysics

@onready var _player_camera : Camera3D = Global.player_node.get_camera()

func _ready() -> void:
	_camera.fov = _player_camera.fov
	
	if !blue_portal:
		blue_portal = self
	elif !orange_portal:
		orange_portal = self
	
	_distortion_material.set_shader_parameter("portal_color", _portal_color)
	_particles.draw_pass_1.material.albedo_color = _portal_color

func get_linked_portal() -> Portal:
	return _linked_portal

func reset() -> void:
	_particles.restart()
	_physics.reset_wall_collider()

func _process(_delta: float) -> void:
	if _linked_portal:
		_move_camera()
	
	_portal_pos = _player_camera.unproject_position(global_position)/ get_viewport().get_visible_rect().size
	_surface_material.set_shader_parameter("portal_texture", _sub_viewport.get_texture())

func _move_camera() -> void:
	var flip = Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	_camera.global_transform = _linked_portal.global_transform * flip * global_transform.affine_inverse() * _player_camera.global_transform
	
	## Help from https://github.com/Donitzo/godot-simple-portal-system
	## Get the four corners of the aabb
	var aabb = _mesh_instance.get_aabb()
	var first_corner : Vector3 = _linked_portal.to_global(Vector3(aabb.position.x, aabb.position.y, 0))
	var second_corner : Vector3 = _linked_portal.to_global(Vector3(aabb.position.x + aabb.size.x, aabb.position.y, 0))
	var third_corner : Vector3 = _linked_portal.to_global(Vector3(aabb.position.x + aabb.size.x, aabb.position.y + aabb.size.y, 0))
	var fourth_corner : Vector3 = _linked_portal.to_global(Vector3(aabb.position.x, aabb.position.y + aabb.size.y, 0))
	
	## Get the distance along the camera's forward vector at which each of the portal corners projects
	var camera_forward_vector : Vector3 = -_camera.global_transform.basis.z.normalized()
	var first_distance : float = (first_corner - _camera.global_position).dot(camera_forward_vector)
	var second_distance : float = (second_corner - _camera.global_position).dot(camera_forward_vector)
	var third_distance : float = (third_corner - _camera.global_position).dot(camera_forward_vector)
	var fourth_distance : float = (fourth_corner - _camera.global_position).dot(camera_forward_vector)
	## Set the camera's near clipping to the closest corner - the safe margin, or 0.01 if too close
	_camera.near = max(0.01, min(first_distance, second_distance, third_distance, fourth_distance) - CAMERA_NEAR_SAFE_MARGIN)
