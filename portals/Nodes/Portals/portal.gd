class_name Portal
extends Node3D

#@export_group("Visual")
#@export var _portal_color : Color = Color.WHITE
@export_group("References")
@export var _linked_portal : Portal

@onready var _camera : Camera3D = $SubViewport/Camera3D
@onready var _sub_viewport : SubViewport = $SubViewport
@onready var _mesh_instance : MeshInstance3D = $MeshInstance3D
@onready var _surface_material : ShaderMaterial = _mesh_instance.mesh.surface_get_material(0)
@onready var _player_camera : Camera3D = Global.player_node.get_camera()

func _ready() -> void:
	_camera.fov = _player_camera.fov

func _process(_delta: float) -> void:
	if _linked_portal:
		_move_camera()
	_surface_material.set_shader_parameter("portal_texture", _sub_viewport.get_texture())

func _move_camera() -> void:
	var flip = Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	_camera.global_transform = _linked_portal.global_transform * flip * global_transform.affine_inverse() * _player_camera.global_transform
	_camera.near = _camera.global_position.distance_to(_linked_portal.global_position)
