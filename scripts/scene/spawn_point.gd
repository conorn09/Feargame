extends Marker3D

## Spawn Point
## Marks a location where the player should spawn when entering a scene
## Used by SceneManager to position the player correctly during scene transitions

class_name SpawnPoint

# Unique identifier for this spawn point
@export var spawn_id: String = "default"

# Optional: Which scene this spawn point is intended for
# Can be used to have different spawn points for different entry points
@export var from_scene: String = ""


func _ready() -> void:
	# Add to spawn_points group so SceneManager can find it
	add_to_group("spawn_points")


## Get the spawn position in world space
## @return: The global position of this spawn point
func get_spawn_position() -> Vector3:
	return global_position


## Get the spawn rotation
## @return: The rotation of this spawn point
func get_spawn_rotation() -> Vector3:
	return rotation


## Get the spawn ID
## @return: The spawn_id string
func get_spawn_id() -> String:
	return spawn_id
