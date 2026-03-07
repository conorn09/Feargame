extends Node

## Manages player interactions with objects in the environment
## Handles raycast detection, interaction triggering, and inventory management

@export var interaction_range: float = 2.5
@export var raycast_node: RayCast3D

var current_interactable: Interactable = null
var inventory: Array[InventoryItem] = []

# Signals for interaction events
signal interactable_focused(object: Interactable)
signal interactable_unfocused()
signal item_collected(item: InventoryItem)
signal interaction_performed(object: Interactable)

func _ready() -> void:
	# Find the raycast node if not already set
	if not raycast_node:
		var player = get_parent()
		if player:
			var camera = player.get_node_or_null("Camera3D")
			if camera:
				raycast_node = camera.get_node_or_null("RayCast3D")
	
	# Set up raycast if found
	if raycast_node:
		raycast_node.target_position = Vector3(0, 0, -interaction_range)
		raycast_node.enabled = true
	else:
		push_error("InteractionSystem: Could not find RayCast3D node!")
	
	# Connect to UI Manager if it exists (wait a frame for scene to be ready)
	await get_tree().process_frame
	var ui_manager = get_tree().current_scene.get_node_or_null("UIManager")
	if ui_manager:
		interactable_focused.connect(func(obj): ui_manager.show_interaction_prompt("Press E to " + obj.get_prompt()))
		interactable_unfocused.connect(func(): ui_manager.hide_interaction_prompt())
	else:
		print("InteractionSystem: UIManager not found in scene")

func _process(_delta: float) -> void:
	check_for_interactable()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()

## Checks for interactable objects in front of the player using raycast
func check_for_interactable() -> Interactable:
	if not raycast_node:
		return null
		
	if not raycast_node.is_colliding():
		if current_interactable:
			interactable_unfocused.emit()
			current_interactable = null
		return null
	
	var collider = raycast_node.get_collider()
	
	# Check if the collider is in the interactable group
	if collider and collider.is_in_group("interactable"):
		var interactable = collider as Interactable
		
		# Only emit signal if this is a new interactable
		if interactable != current_interactable:
			if current_interactable:
				interactable_unfocused.emit()
			
			current_interactable = interactable
			interactable_focused.emit(interactable)
		
		return interactable
	else:
		# No interactable found
		if current_interactable:
			interactable_unfocused.emit()
			current_interactable = null
		return null

## Triggers interaction with the currently focused interactable object
func interact() -> void:
	if not current_interactable:
		return
	
	if not current_interactable.can_interact():
		return
	
	# Call the interactable's interact method
	current_interactable.interact(get_parent())
	
	# If the interactable gives an item, add it to inventory
	if current_interactable.gives_item and current_interactable.item_data:
		add_to_inventory(current_interactable.item_data)
	
	# Emit interaction performed signal
	interaction_performed.emit(current_interactable)

## Adds an item to the player's inventory
func add_to_inventory(item: InventoryItem) -> void:
	if item:
		inventory.append(item)
		item_collected.emit(item)
		print("Collected: ", item.display_name)

## Checks if the player has a specific item in their inventory
func has_item(item_id: String) -> bool:
	for item in inventory:
		if item.item_id == item_id:
			return true
	return false

## Returns the player's inventory array
func get_inventory() -> Array[InventoryItem]:
	return inventory
