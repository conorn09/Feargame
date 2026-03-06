extends Node

## Scene Manager Singleton
## Handles scene transitions and player state persistence across scenes

# Signals for scene transition events
signal scene_load_started(scene_path: String)
signal scene_load_completed(scene: Node)
signal transition_started()
signal transition_completed()

# Current scene reference
var current_scene: Node = null

# Player state dictionary to preserve across transitions
var player_state: Dictionary = {}

# Flag to prevent multiple simultaneous transitions
var is_transitioning: bool = false


func _ready() -> void:
	# Get the current scene when the manager initializes
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)


## Change to a new scene with optional spawn point
## @param scene_path: Path to the scene file (e.g., "res://scenes/house_interior.tscn")
## @param spawn_id: ID of the spawn point to use in the new scene (default: "default")
func change_scene(scene_path: String, spawn_id: String = "default") -> void:
	if is_transitioning:
		push_warning("Scene transition already in progress")
		return
	
	if not FileAccess.file_exists(scene_path):
		push_error("Scene file not found: " + scene_path)
		return
	
	is_transitioning = true
	transition_started.emit()
	scene_load_started.emit(scene_path)
	
	# Save current player state before transition
	var player = get_tree().get_first_node_in_group("player")
	if player:
		save_player_state(player)
	
	# Change to the new scene
	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Failed to change scene: " + str(error))
		is_transitioning = false
		return
	
	# Wait for the new scene to be ready
	await get_tree().process_frame
	
	# Update current scene reference
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
	# Restore player state in the new scene
	player = get_tree().get_first_node_in_group("player")
	if player:
		restore_player_state(player, spawn_id)
	
	scene_load_completed.emit(current_scene)
	is_transitioning = false
	transition_completed.emit()


## Save the player's current state
## @param player: The player node to save state from
func save_player_state(player: Node) -> void:
	if not player:
		push_warning("Cannot save player state: player node is null")
		return
	
	# Save position and rotation
	if player is Node3D:
		player_state["position"] = player.global_position
		player_state["rotation"] = player.rotation
	
	# Save inventory if the player has an interaction system
	var interaction_system = player.get_node_or_null("InteractionSystem")
	if interaction_system and interaction_system.has_method("get_inventory"):
		player_state["inventory"] = interaction_system.get_inventory().duplicate()
	
	# Save any additional state (can be extended later)
	# For example: flashlight battery, health, etc.


## Restore the player's saved state
## @param player: The player node to restore state to
## @param spawn_id: The spawn point ID to use for positioning
func restore_player_state(player: Node, spawn_id: String = "default") -> void:
	if not player:
		push_warning("Cannot restore player state: player node is null")
		return
	
	# Get spawn point position if available
	var spawn_point = get_spawn_point(spawn_id)
	
	if player is Node3D:
		if spawn_point:
			# Use spawn point position and rotation
			player.global_position = spawn_point.global_position
			if spawn_point.has_method("get_spawn_rotation"):
				player.rotation = spawn_point.get_spawn_rotation()
			else:
				player.rotation = spawn_point.rotation
		elif player_state.has("position"):
			# Fall back to saved position if no spawn point
			player.global_position = player_state["position"]
			if player_state.has("rotation"):
				player.rotation = player_state["rotation"]
	
	# Restore inventory if available
	if player_state.has("inventory"):
		var interaction_system = player.get_node_or_null("InteractionSystem")
		if interaction_system and interaction_system.has_method("set_inventory"):
			interaction_system.set_inventory(player_state["inventory"])


## Get a spawn point node by ID from the current scene
## @param spawn_id: The ID of the spawn point to find
## @return: The spawn point node, or null if not found
func get_spawn_point(spawn_id: String) -> Node:
	if not current_scene:
		return null
	
	# Search for spawn points in the current scene
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	for spawn_point in spawn_points:
		if spawn_point.has_method("get_spawn_id"):
			if spawn_point.get_spawn_id() == spawn_id:
				return spawn_point
		elif spawn_point.get("spawn_id") == spawn_id:
			return spawn_point
	
	# If no matching spawn point found, log warning
	if spawn_id != "default":
		push_warning("Spawn point not found: " + spawn_id)
	
	return null
