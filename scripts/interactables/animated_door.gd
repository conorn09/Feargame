extends StaticBody3D

@export var is_locked: bool = false
@export var required_key_id: String = ""
@export var open_angle: float = 90.0  # Degrees to rotate when opening
@export var animation_duration: float = 1.0  # Seconds

var is_open: bool = false
var is_animating: bool = false
var door_mesh: Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Find the door mesh (first MeshInstance3D child)
	for child in get_children():
		if child is MeshInstance3D:
			door_mesh = child
			break

func interact() -> void:
	if is_animating:
		return
	
	if is_locked:
		# Check if player has the required key
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("has_item"):
			if not player.has_item(required_key_id):
				print("Door is locked. Need key: " + required_key_id)
				return
		else:
			print("Door is locked")
			return
	
	toggle_door()

func toggle_door() -> void:
	if is_open:
		close_door()
	else:
		open_door()

func open_door() -> void:
	if animation_player.has_animation("door_open"):
		animation_player.play("door_open")
	is_open = true
	is_animating = true
	await animation_player.animation_finished
	is_animating = false

func close_door() -> void:
	if animation_player.has_animation("door_close"):
		animation_player.play("door_close")
	is_open = false
	is_animating = true
	await animation_player.animation_finished
	is_animating = false

func get_interaction_prompt() -> String:
	if is_locked:
		return "Locked"
	return "Open Door" if not is_open else "Close Door"
