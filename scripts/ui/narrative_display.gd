extends CanvasLayer

## Narrative Display UI
## Shows dialogue and narrative text on screen

@onready var dialogue_box: PanelContainer = $DialogueBox
@onready var dialogue_label: Label = $DialogueBox/MarginContainer/DialogueLabel


func _ready() -> void:
	# Connect to narrative system signals
	var narrative_system = get_node("/root/NarrativeSystem")
	narrative_system.dialogue_started.connect(_on_dialogue_started)
	narrative_system.dialogue_ended.connect(_on_dialogue_ended)


func _on_dialogue_started(text: String) -> void:
	dialogue_label.text = text
	dialogue_box.visible = true


func _on_dialogue_ended() -> void:
	dialogue_box.visible = false
