extends CanvasLayer

## UI Manager
## Manages all UI elements including HUD, dialogue, inventory, and pause menu

@onready var hud: Control = $HUD
@onready var dialogue_box: Control = $DialogueBox
@onready var inventory_panel: Control = $InventoryPanel
@onready var pause_menu: Control = $PauseMenu

@onready var interaction_prompt: Label = $HUD/InteractionPrompt
@onready var battery_indicator: ProgressBar = $HUD/BatteryIndicator


func _ready() -> void:
	# Initialize UI state
	interaction_prompt.text = ""


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
