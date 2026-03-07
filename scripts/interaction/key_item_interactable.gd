extends Interactable

## Key item interactable that adds an item to the player's inventory when picked up

func interact(_player: Node) -> void:
	super.interact(_player)
	
	if gives_item and item_data != null:
		print("Picked up: ", item_data.display_name)
		# Queue the item for deletion instead of just hiding it
		# This avoids physics callback issues
		call_deferred("queue_free")
