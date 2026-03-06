extends Area3D
## Scene transition trigger that loads a new scene when the player enters it.
##
## This trigger detects when the player character enters its collision area
## and initiates a scene transition to the specified target scene.

## Path to the target scene file (e.g., "res://scenes/environments/house_interior.tscn")
@export var target_scene: String = ""

## Spawn point ID in the target scene where the player should appear
@export var target_spawn_id: String = "default"


func _ready() -> void:
	# Connect to the body_entered signal to detect when something enters the trigger
	body_entered.connect(_on_body_entered)
	print("SceneTransitionTrigger ready! Target scene: ", target_scene)


func _on_body_entered(body: Node3D) -> void:
	print("Body entered trigger: ", body.name)
	
	# Check if the entering body is the player
	if not body.is_in_group("player"):
		print("Body is not in player group")
		return
	
	print("Player detected! Transitioning to: ", target_scene)
	
	# Validate that a target scene is set
	if target_scene.is_empty():
		push_error("SceneTransitionTrigger: target_scene is not set!")
		return
	
	# Trigger the scene transition through the SceneManager singleton
	SceneManager.change_scene(target_scene, target_spawn_id)
