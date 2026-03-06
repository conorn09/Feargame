extends Interactable

## Test interactable that prints a message when examined

func interact(player: Node) -> void:
	super.interact(player)
	print("You examine the cube: ", description)
