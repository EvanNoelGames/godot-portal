class_name PortalPhysics 
extends Node3D

@export_group("References")
@export var _linked_portal : Portal
@onready var portal_1: Portal = $".."

var _current_traveler : CharacterBody3D

var _previous_offset = Vector3(0.0,0.0,0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if (_current_traveler == null):
		return;
	
	#Get the sign of the dot product of
	#the players offset from the portal and the portals position
	
	#Calculate player offset from portal
	var playerOffset = _current_traveler.position - position;
	
	#Get which side of the portal the player is on
	var portalSide = sign(playerOffset.dot(transform.basis.z));
	var previousPortalSide = sign(
			_previous_offset.dot(transform.basis.z)
		);
		
	print(portalSide)
	
	if (portalSide != previousPortalSide):
		var m := _linked_portal.transform * global_transform * _current_traveler.transform
		_current_traveler.position = m.basis.z
		_current_traveler.rotation = m.basis.get_euler()
		
	#Cache old offset
	_previous_offset = playerOffset;

##Add player to current traveler
func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body is not CharacterBody3D):
		return
	
	_current_traveler = body;
	_previous_offset = _current_traveler.position - position
	print("Added!")

##Remove current traveler
func _on_area_3d_body_exited(body: Node3D) -> void:
	if (body is not CharacterBody3D):
		return
	
	_current_traveler = null;
	print("Removed!")
	_previous_offset = Vector3(0.0,0.0,0.0)
