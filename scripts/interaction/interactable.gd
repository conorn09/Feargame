class_name Interactable
extends StaticBody3D

## Base class for all interactable objects in the game
## Objects that extend this class can be examined, picked up, or trigger events

@export var interaction_prompt: String = "Examine"
@export var description: String = ""
@export var gives_item: bool = false
@export var item_data: Resource = null
@export var one_time_use: bool = true

var has_been_used: bool = false

func _ready() -> void:
	add_to_group("interactable")

## Called when the player interacts with this object
## Override this in child classes to implement custom behavior
func interact(player: Node) -> void:
	if not can_interact():
		return
	
	if one_time_use:
		has_been_used = true

## Returns whether this object can currently be interacted with
func can_interact() -> bool:
	if one_time_use and has_been_used:
		return false
	return true

## Returns the interaction prompt text to display to the player
func get_prompt() -> String:
	return interaction_prompt
