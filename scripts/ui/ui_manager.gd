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
@onready var item_grid: GridContainer = $InventoryPanel/InventoryContainer/MarginContainer/VBoxContainer/ItemGrid

@onready var resume_button: Button = $PauseMenu/MenuContainer/VBoxContainer/ResumeButton
@onready var quit_button: Button = $PauseMenu/MenuContainer/VBoxContainer/QuitButton


func _ready() -> void:
	# Allow UI to process input even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
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
	
	# Connect pause menu buttons
	resume_button.pressed.connect(toggle_pause_menu)
	quit_button.pressed.connect(func(): get_tree().quit())


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



## Toggle inventory panel visibility
func toggle_inventory() -> void:
	inventory_panel.visible = !inventory_panel.visible
	
	# Pause/unpause game when inventory is open
	get_tree().paused = inventory_panel.visible
	
	# Capture/release mouse
	if inventory_panel.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		refresh_inventory()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		if not pause_menu.visible:  # Don't open inventory if paused
			toggle_inventory()
	
	if event.is_action_pressed("pause"):
		if not inventory_panel.visible:  # Don't pause if inventory is open
			toggle_pause_menu()



## Refresh inventory display with current items
func refresh_inventory() -> void:
	# Clear existing items
	for child in item_grid.get_children():
		child.queue_free()
	
	# Get player's inventory
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var interaction_system = player.get_node_or_null("InteractionSystem")
	if not interaction_system:
		return
	
	var inventory = interaction_system.get_inventory()
	
	# Create item slots for each inventory item
	for item in inventory:
		var item_button = Button.new()
		item_button.text = item.display_name
		item_button.custom_minimum_size = Vector2(120, 80)
		item_button.pressed.connect(func(): show_item_description(item))
		item_grid.add_child(item_button)


## Show item description when selected
func show_item_description(item) -> void:
	# For now, just print to console
	# In a full implementation, this would show in a description panel
	print("Item: ", item.display_name)
	print("Description: ", item.description)



## Toggle pause menu visibility
func toggle_pause_menu() -> void:
	pause_menu.visible = !pause_menu.visible
	
	# Pause/unpause game
	get_tree().paused = pause_menu.visible
	
	# Capture/release mouse
	if pause_menu.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
