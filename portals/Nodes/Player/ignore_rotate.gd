extends Node3D

@export var top_parent : Node3D = get_parent()

func _physics_process(_delta: float) -> void:
	await get_tree().physics_frame
	set_rotation(-top_parent.rotation)
