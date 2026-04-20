class_name PortalPhysics 
extends Node3D

@export_group("References")
@export var _linked_portal : Portal
@onready var portal_1: Portal = $".."

@onready var _player_camera : Camera3D = Global.player_node.get_camera()

var currentTraveler : CharacterBody3D

var previous_offset = Vector3(0.0,0.0,0.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#Get the sign of the dot product of
	#the players offset from the portal and the portals position
	
	#Calculate player offset from portal
	var playerOffset = _player_camera.position - position;
	
	#Get which side of the portal the player is on
	var portalSide = sign(playerOffset.dot(global_transform.basis.z));
	var previousPortalSide = sign(
			previous_offset.dot(global_transform.basis.z)
		);
	
	#Cache old offset
	previous_offset = playerOffset;
	
	#if (portalSide != previousPortalSide):
		#_linked_portal.transform
	
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

##Add player to current traveler
func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body is not CharacterBody3D):
		return
	
	currentTraveler = body;
	print("Added!")

##Remove current traveler
func _on_area_3d_body_exited(body: Node3D) -> void:
	if (body is not CharacterBody3D):
		return
	
	currentTraveler = null;
	print("Removed!")
