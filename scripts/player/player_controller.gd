extends CharacterBody3D

# Movement properties
@export var walk_speed: float = 3.0
@export var mouse_sensitivity: float = 0.002
@export var camera_pitch_limit: float = 80.0  # degrees

# Camera reference
@onready var camera: Camera3D = $Camera3D

# Camera rotation tracking
var camera_pitch: float = 0.0

func _ready() -> void:
	# Capture the mouse cursor for first-person control
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	# Quick exit for testing - press Escape to quit
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()
	
	# Handle mouse motion for camera rotation
	if event is InputEventMouseMotion:
		# Rotate player horizontally (yaw)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Update camera pitch with clamping
		camera_pitch -= event.relative.y * mouse_sensitivity
		camera_pitch = clamp(camera_pitch, deg_to_rad(-camera_pitch_limit), deg_to_rad(camera_pitch_limit))
		
		# Apply clamped pitch to camera
		camera.rotation.x = camera_pitch

func _physics_process(delta: float) -> void:
	handle_movement_input(delta)

func handle_movement_input(delta: float) -> void:
	# Get input direction from WASD keys
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Calculate movement direction relative to camera orientation
	var camera_forward = camera.global_transform.basis.z
	var camera_right = camera.global_transform.basis.x
	
	# Project directions onto horizontal plane (ignore vertical component)
	camera_forward.y = 0
	camera_right.y = 0
	camera_forward = camera_forward.normalized()
	camera_right = camera_right.normalized()
	
	# Calculate velocity based on input and camera direction
	var direction = (camera_right * input_dir.x + camera_forward * input_dir.y).normalized()
	
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	# Apply movement using Godot's built-in physics
	move_and_slide()


## Get the current player state as a dictionary
## @return: Dictionary containing position and rotation
func get_state() -> Dictionary:
	var state = {}
	state["position"] = global_position
	state["rotation"] = rotation
	return state


## Restore player state from a dictionary
## @param state: Dictionary containing position and rotation to restore
func set_state(state: Dictionary) -> void:
	if state.has("position"):
		global_position = state["position"]
	if state.has("rotation"):
		rotation = state["rotation"]
