extends Node

## Narrative Manager Singleton
## Manages story progression, flags, dialogue, and narrative events

# Story state
var story_flags: Dictionary = {}  # String -> bool
var current_chapter: int = 0
var dialogue_queue: Array = []  # Array of dialogue entries

# Signals
signal flag_changed(flag_name: String, value: bool)
signal event_triggered(event_id: String)
signal dialogue_started(text: String)
signal dialogue_ended()
signal chapter_changed(chapter: int)


func _ready() -> void:
	# Initialize with default flags if needed
	pass


## Set a story flag to a specific value
func set_flag(flag_name: String, value: bool) -> void:
	story_flags[flag_name] = value
	flag_changed.emit(flag_name, value)


## Get the value of a story flag
## Returns false if the flag doesn't exist
func get_flag(flag_name: String) -> bool:
	return story_flags.get(flag_name, false)


## Display dialogue text on screen
## If duration is 0, waits for player input to continue
## If duration > 0, auto-hides after duration seconds
func show_dialogue(text: String, duration: float = 0.0) -> void:
	dialogue_queue.append({"text": text, "duration": duration})
	dialogue_started.emit(text)
	
	if duration > 0.0:
		# Auto-hide after duration
		await get_tree().create_timer(duration).timeout
		dialogue_ended.emit()
	# If duration is 0, the UI or another system should call hide_dialogue manually


## Trigger a narrative event
func trigger_event(event_id: String) -> void:
	event_triggered.emit(event_id)
	print("Narrative event triggered: ", event_id)


## Advance to the next chapter
func advance_chapter() -> void:
	current_chapter += 1
	chapter_changed.emit(current_chapter)


## Check if player has a specific item in inventory
func check_inventory_condition(item_id: String) -> bool:
	# Get the player node
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("NarrativeSystem: Player node not found")
		return false
	
	# Get the InteractionSystem from the player
	var interaction_system = player.get_node_or_null("InteractionSystem")
	if not interaction_system:
		push_error("NarrativeSystem: InteractionSystem not found on player")
		return false
	
	# Check if player has the item
	return interaction_system.has_item(item_id)
