extends Interactable

## Note interactable that displays text when examined

func interact(player: Node) -> void:
	super.interact(player)
	
	if description != "":
		print("You read the note:")
		print(description)
		# In a full implementation, this would display in a UI panel
		# For now, we just print to console
