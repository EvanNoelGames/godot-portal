class_name PortalPhysics 
extends Node3D

@export_group("References")
@export var _linked_portal : Portal
@onready var portal_1: Portal = $".."

var _current_traveler : CharacterBody3D

var _previous_offset = Vector3(0.0,0.0,0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if (_current_traveler == null):
		return
	
	#Get the sign of the dot product of
	#the players offset from the portal and the portals position
	
	#Calculate player offset from portal
	var playerOffset := _current_traveler.global_position - global_position
	
	#Get which side of the portal the player is on
	var portalSide = sign(playerOffset.dot(-global_transform.basis.z))
	DebugDraw3D.draw_line(global_position, playerOffset, Color(1,0,0,1))
	
	var previousPortalSide = sign(
			_previous_offset.dot(-global_transform.basis.z)
		)
	
	if (portalSide != previousPortalSide):
		#Transform traveller velocity, position, and orientation to new portal basis
		var flip := Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
		var m = _linked_portal.global_transform * flip * global_transform.affine_inverse() * _current_traveler.global_transform
		_current_traveler.position = m.origin
		_current_traveler.rotation = m.basis.get_euler()
		_current_traveler.velocity = m.basis * _current_traveler.velocity;
		
		var linked_physics = _linked_portal.get_node("PortalPhysics") as PortalPhysics
		linked_physics.register_traveller(_current_traveler)
		_current_traveler = null
		return
	
	#Cache old offset
	_previous_offset = playerOffset;
	
func register_traveller(body: CharacterBody3D) -> void:
	_current_traveler = body;
	_previous_offset = body.global_position - global_position;

##Add player to current traveler
func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body is not CharacterBody3D):
		return
		
	if (_current_traveler == body):
		return
	
	register_traveller(body)

##Remove current traveler
func _on_area_3d_body_exited(body: Node3D) -> void:
	if (body is not CharacterBody3D):
		return
	
	_current_traveler = null;
