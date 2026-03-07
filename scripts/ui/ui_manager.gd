extends CanvasLayer

## UI Manager
## Manages all UI elements including HUD, dialogue, inventory, and pause menu

@onready var hud: Control = $HUD
@onready var dialogue_box: Control = $DialogueBox
@onready var inventory_panel: Control = $InventoryPanel
@onready var pause_menu: Control = $PauseMenu

@onready var interaction_prompt: Label = $HUD/InteractionPrompt
@onready var battery_indicator: ProgressBar = $HUD/BatteryIndicator
@onready var dialogue_label: Label = $DialogueBox/DialoguePanel/MarginContainer/DialogueLabel


func _ready() -> void:
	# Initialize UI state
	interaction_prompt.text = ""
	
	# Connect to narrative system
	var narrative_system = get_node("/root/NarrativeSystem")
	narrative_system.dialogue_started.connect(show_dialogue)
	narrative_system.dialogue_ended.connect(hide_dialogue)
	
	# Connect to player flashlight signals (wait for scene to be ready)
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.battery_changed.connect(update_battery)
		player.flashlight_toggled.connect(func(is_on): battery_indicator.visible = true)


## Show interaction prompt with custom text
func show_interaction_prompt(text: String) -> void:
	interaction_prompt.text = text
	interaction_prompt.visible = true


## Hide interaction prompt
func hide_interaction_prompt() -> void:
	interaction_prompt.text = ""
	interaction_prompt.visible = false



## Update battery indicator percentage
func update_battery(percentage: float) -> void:
	battery_indicator.value = clamp(percentage, 0.0, 100.0)
	
	# Show battery indicator when flashlight is available
	if not battery_indicator.visible:
		battery_indicator.visible = true



## Show dialogue text
func show_dialogue(text: String) -> void:
	dialogue_label.text = text
	dialogue_box.visible = true


## Hide dialogue
func hide_dialogue() -> void:
	dialogue_box.visible = false
	dialogue_label.text = ""
