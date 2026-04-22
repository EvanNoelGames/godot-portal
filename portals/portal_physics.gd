class_name PortalPhysics 
extends Node3D

@export_group("References")
@export var _linked_portal : Portal
@onready var portal_1: Portal = $".."

var _current_traveler : CharacterBody3D

var _previous_offset = Vector3(0.0,0.0,0.0)

var _just_recieved_traveller := false

func _physics_process(delta: float) -> void:
	if _just_recieved_traveller:
		_just_recieved_traveller = false
		return
	
	#DebugDraw3D.draw_ray(global_position, global_transform.basis.z, 2, Color.BLACK)
	if (_current_traveler == null):
		return
	
	#Calculate player offset from portal
	var playerOffset := _current_traveler.global_position - global_position
	
	#Get which side of the portal the player is on
	var portalSide = sign(playerOffset.dot(global_transform.basis.z))
	var previousPortalSide = sign(_previous_offset.dot(global_transform.basis.z))
		
	print("side: %d  prev: %d  offset: %s" % [portalSide, previousPortalSide, playerOffset])
	#Cache old offset
	_previous_offset = playerOffset;
	
	#Stop entry from back side of portal
	#if (portalSide > 0):
		#return
	
	if (portalSide != previousPortalSide && previousPortalSide != 0):
		_update_player_transform()
		var linked_physics = _linked_portal.get_node("PortalPhysics") as PortalPhysics
		linked_physics.call_deferred("register_traveller", _current_traveler)
		_current_traveler = null
	

func _update_player_transform() -> void:
	#Transform traveller velocity, position, and orientation to new portal basis
	var flip := Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	var m = _linked_portal.global_transform * flip * global_transform.affine_inverse() * _current_traveler.global_transform
	_current_traveler.global_position = m.origin
	_current_traveler.global_rotation = m.basis.get_euler()
	_current_traveler.velocity = m.basis * _current_traveler.velocity;

func register_traveller(body: CharacterBody3D) -> void:
	_current_traveler = body;
	_previous_offset = body.global_position - global_position;
	_just_recieved_traveller = true

##Add player to current traveler
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
