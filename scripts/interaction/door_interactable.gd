extends Interactable

## Door interactable that can open or trigger scene transitions

@export var opens_door: bool = true
@export var triggers_scene_transition: bool = false
@export var target_scene: String = ""
@export var target_spawn_id: String = "default"

func interact(player: Node) -> void:
	super.interact(player)
	
	if opens_door:
		print("The door opens with a creak...")
		# In a full implementation, this would play an animation
		# For now, we just print a message
	
	if triggers_scene_transition and target_scene != "":
		print("Transitioning to: ", target_scene)
		# Use get_node to access the autoload
		var scene_manager = get_node("/root/SceneManager")
		if scene_manager:
			scene_manager.change_scene(target_scene, target_spawn_id)
