extends Area3D
class_name StoryTrigger

## Story Trigger
## Triggers narrative events when the player enters the area
## Supports conditional triggering based on story flags

@export var trigger_id: String = ""
@export var required_flags: Array[String] = []
@export var required_items: Array[String] = []  # Item IDs that must be in inventory
@export var sets_flags: Dictionary = {}  # flag_name -> value (bool)
@export var dialogue: Array[DialogueEntry] = []
@export var trigger_audio: AudioStream = null  # Optional audio to play when triggered
@export var one_time: bool = true

var has_triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	# Check if already triggered and one_time is true
	if has_triggered and one_time:
		return
	
	# Check if the body is the player
	if not body.is_in_group("player"):
		return
	
	# Check if all required conditions are met
	if not check_conditions():
		return
	
	# Trigger the event
	trigger_event()


## Check if all required story flags are set
func check_conditions() -> bool:
	var narrative_system = get_node("/root/NarrativeSystem")
	
	# Check story flags
	for flag in required_flags:
		if not narrative_system.get_flag(flag):
			return false
	
	# Check inventory items
	for item_id in required_items:
		if not narrative_system.check_inventory_condition(item_id):
			return false
	
	return true


## Execute the trigger event
func trigger_event() -> void:
	has_triggered = true
	var narrative_system = get_node("/root/NarrativeSystem")
	var audio_manager = get_node("/root/AudioManager")
	
	# Play audio if provided
	if trigger_audio:
		audio_manager.play_sfx(trigger_audio)
	
	# Set story flags
	for flag_name in sets_flags:
		narrative_system.set_flag(flag_name, sets_flags[flag_name])
	
	# Show dialogue entries
	for entry in dialogue:
		narrative_system.show_dialogue(entry.text, entry.duration)
	
	# Trigger the narrative event
	narrative_system.trigger_event(trigger_id)
