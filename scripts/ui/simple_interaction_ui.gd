extends CanvasLayer

@onready var interaction_prompt: Label = $InteractionPrompt
@onready var description_text: Label = $DescriptionText

var description_timer: float = 0.0
var description_duration: float = 3.0

func _ready() -> void:
	# Connect to the player's interaction system signals
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var interaction_system = player.get_node_or_null("InteractionSystem")
		if interaction_system:
			interaction_system.interactable_focused.connect(_on_interactable_focused)
			interaction_system.interactable_unfocused.connect(_on_interactable_unfocused)
			interaction_system.interaction_performed.connect(_on_interaction_performed)

func _process(delta: float) -> void:
	# Auto-hide description after duration
	if description_text.visible and description_timer > 0:
		description_timer -= delta
		if description_timer <= 0:
			description_text.visible = false

func _on_interactable_focused(interactable) -> void:
	interaction_prompt.text = "Press E to " + interactable.get_prompt()
	interaction_prompt.visible = true

func _on_interactable_unfocused() -> void:
	interaction_prompt.visible = false

func _on_interaction_performed(interactable) -> void:
	if interactable.description and not interactable.description.is_empty():
		description_text.text = interactable.description
		description_text.visible = true
		description_timer = description_duration
