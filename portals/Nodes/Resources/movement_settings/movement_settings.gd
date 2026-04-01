class_name MovementSettings
extends Resource

@export var gravity : float = 15.34
@export var friction : float = 8
@export var max_velocity_air : float = 0.5
@export var max_velocity_ground : float = 5.0
@export var max_velocity_crouch : float = 2.0
@export var terminal_velocity_y : float = 80.0
@export var stop_speed : float = 1.5

var max_acceleration : float = 12 * max_velocity_ground
var jump_impulse : float = sqrt(2 * gravity * 0.85)
