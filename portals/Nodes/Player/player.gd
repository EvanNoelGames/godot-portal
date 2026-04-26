class_name Player
extends CharacterBody3D

@export_group("Settings")
@export var _sensitivity : float = 3.0
@export_group("Movement")
@export var _allow_jump : bool = true
@export var _allow_crouch : bool = true
@export var _movement_settings : MovementSettings
@export_group("References")
@export var _camera : Camera3D

var pressing_crouch : bool = false
var crouching : bool = false

var direction : Vector3 = Vector3.ZERO
var wish_jump : bool = false

@onready var _head : Node3D = $HeadAnchor
@onready var _bounding_box : CollisionShape3D = $BoundingBox
@onready var _rotation_helper = $HeadAnchor/RotationHelper
@onready var _crouch_area : Area3D = $BoundingBox/CrouchArea

#region Enter Tree, Ready, Process
func _enter_tree() -> void:
	Global.player_node = self

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float):
	process_movement(delta)

func _process(_delta: float):
	poll_input()
#endregion

#region Getters
func get_camera() -> Camera3D:
	return _camera
#endregion

#region Input
func _input(event):
	# Handle mouse look
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mouseEvent: InputEventMouseMotion = event as InputEventMouseMotion
		_rotation_helper.rotate_x(deg_to_rad(-mouseEvent.relative.y * (_sensitivity * 0.01)))
		rotate_y(deg_to_rad(-mouseEvent.relative.x * (_sensitivity * 0.01)))
		var cameraRot: Vector3 = _rotation_helper.rotation_degrees
		cameraRot.x = clamp(cameraRot.x, -89, 89)
		_rotation_helper.rotation_degrees = cameraRot
	
	if event.is_action_pressed("quit"):
		get_tree().quit()

func poll_input():
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	direction = Vector3.ZERO
	if Input.is_action_pressed("player_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("player_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("player_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("player_right"):
		direction += transform.basis.x
	
	if _allow_jump:
		wish_jump = Input.is_action_pressed("player_jump")
	
	if _allow_crouch:
		pressing_crouch = Input.is_action_pressed("player_crouch")
#endregion

#region Movement
func process_movement(delta: float):
	handle_crouch(delta)
	
	var wish_dir = direction.normalized()
	
	if is_on_floor():
		if wish_jump:
			velocity.y = _movement_settings.jump_impulse
			wish_jump = false
		velocity = update_velocity_ground(wish_dir, delta)
	else:
		velocity.y -= _movement_settings.gravity * delta
		velocity = update_velocity_air(wish_dir, delta)
	
	var clamped_velocity : Vector3 = velocity
	clamped_velocity.y = clampf(clamped_velocity.y, -_movement_settings.terminal_velocity_y, _movement_settings.terminal_velocity_y)
	velocity = clamped_velocity
	
	move_and_slide()

func accelerate(wish_dir: Vector3, max_velocity: float, delta: float):
	var current_speed = velocity.dot(wish_dir)
	var add_speed = clamp(max_velocity - current_speed, 0, _movement_settings.max_acceleration * delta)
	
	return velocity + add_speed * wish_dir

func update_velocity_ground(wish_dir: Vector3, delta: float):
	var speed = velocity.length()
	
	if speed != 0:
		var control = max(_movement_settings.stop_speed, speed)
		var drop = control * _movement_settings.friction * delta
		
		velocity *= max(speed - drop, 0) / speed
	
	if crouching:
		return accelerate(wish_dir, _movement_settings.max_velocity_crouch, delta)
	
	return accelerate(wish_dir, _movement_settings.max_velocity_ground, delta)

func update_velocity_air(wish_dir: Vector3, delta: float):
	return accelerate(wish_dir, _movement_settings.max_velocity_air, delta)

func handle_crouch(delta: float):
	if pressing_crouch:
		_bounding_box.position.y = 0.5225
		_bounding_box.shape.size.y = 1.125
		crouching = true
	elif not _crouch_area.has_overlapping_bodies():
		_bounding_box.position.y = 0.85
		_bounding_box.shape.size.y = 1.75
		crouching = false
	_head.position.y = lerpf(_head.position.y, _bounding_box.shape.size.y - 0.25, 10 * delta)
#endregion

#region Getters
func get_look_vector() -> Vector3:
	return (_camera.global_basis * Vector3.FORWARD).normalized()

func get_relative_velocity():
	return Vector3(-global_transform.basis.z.dot(velocity), velocity.y, global_transform.basis.x.dot(velocity))
#endregion
