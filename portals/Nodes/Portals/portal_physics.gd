class_name Portal_Physics 
extends Node3D

@onready var _linked_portal : Portal = get_parent().get_linked_portal()

@onready var _wall_raycast = $"RayCast3D"

@onready var _rotation_helper = Global.player_node.get_camera().get_node("../..") as Node3D

var _current_traveler : CharacterBody3D

var _wall_collider : CollisionShape3D

var _position_last_frame : Vector3

var _just_recieved_traveller = false

var _target_camera_x = 0.0

const FLIP := Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)

const RAY_LENGTH = 1.0

const CAMERA_SMOOTH_SPEED = 10.0

const CAMERA_LERP_TIME = 1.5

func init_portal() -> void:
	_wall_collider = null


func _process(delta: float) -> void:
	#Try to get wall collider behind portal
	_get_wall_collider()
	
	if (_current_traveler == null):
		_wall_collider.disabled = false
	else:
		_wall_collider.disabled = true


func _physics_process(delta: float) -> void:
	if (_wall_collider == null):
		return
	
	if _just_recieved_traveller:
		_just_recieved_traveller = false
		return
		
	if (_current_traveler == null):
		return
	
	#Calculate player offset from portal
	var player_offset : Vector3 = _current_traveler.global_position - self.global_position
	var previous_offset : Vector3 = _position_last_frame - self.global_position
	var forward : Vector3 = self.global_transform.basis.z
	
	#Debug visualization
	#DebugDraw3D.draw_line(global_position, global_position + player_offset, Color.BLUE)
	#DebugDraw3D.draw_line(global_position, global_position + previous_offset, Color.RED)
	
	#Get which side of the portal the player is on
	var portal_side = _clamped_sign(player_offset.dot(forward))
	var previous_portal_side = _clamped_sign(previous_offset.dot(forward))
	
	print("side: %d  prev: %d  offset: %s" % [portal_side, previous_portal_side, player_offset])
	
	_position_last_frame = _current_traveler.global_position
	
	if (portal_side != previous_portal_side):
		_update_player_transform(_current_traveler)
		var linked_physics = _linked_portal.get_node("PortalPhysics") as Portal_Physics
		linked_physics.call_deferred("register_traveller", _current_traveler)
		_current_traveler = null


func reset_wall_collider() -> void:
	_wall_collider = null


##Tries to get wall collider behind portal
func _get_wall_collider() -> void:
	if (_wall_collider != null):
		return
	
	if (!_wall_raycast.is_colliding()):
		return
	
	var wall = _wall_raycast.get_collider()
	
	if (wall is CollisionObject3D):
		_wall_collider = wall.get_node("CollisionShape3D") 


##Used to prevent edge case of sign being zero
func _clamped_sign(value : float) -> int:
	var x = sign(value)
	if (x == 0):
		x = -1
	return x


##Uses change of basis to modify player position and velocity around new portal transform
func _update_player_transform(traveler : CharacterBody3D) -> void:
	#Transformation matrix from entry portal to exit portal
	var portal_matrix = _linked_portal.global_transform * FLIP * self.global_transform.affine_inverse()
	
	#Transformation matrix for traveler orientation and position
	var traveler_matrix = portal_matrix * _current_traveler.global_transform
	
	#Apply position transformation
	_current_traveler.global_position = traveler_matrix.origin
	
	#Apply rotation transformation only to y-axis
	_current_traveler.global_rotation = Vector3(0, traveler_matrix.basis.get_euler().y, 0)
	
	#Apply velocity transformation
	_current_traveler.velocity = portal_matrix.basis * _current_traveler.velocity;
	
	#Rotate camera x-axis after exitting portal
	_target_camera_x = traveler_matrix.basis.get_euler().x
	var camera_rotate_tween = create_tween()
	camera_rotate_tween.tween_property(_rotation_helper, "rotation.x", _target_camera_x, CAMERA_LERP_TIME)



##Sets current traveler and signals that a traveler was recieved
func register_traveller(body: CharacterBody3D) -> void:
	_current_traveler = body;
	_position_last_frame = body.global_position
	_just_recieved_traveller = true


##Called when something enters the Area3D
func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body is not CharacterBody3D):
		return
		
	if (_current_traveler == body):
		return
		
	if (_just_recieved_traveller):
		return
	
	register_traveller(body)


##Remove current traveler
func _on_area_3d_body_exited(body: Node3D) -> void:
	if (body is not CharacterBody3D):
		return
	
	_current_traveler = null;
