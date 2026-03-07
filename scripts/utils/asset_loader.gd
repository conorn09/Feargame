extends Node
class_name AssetLoader

## Asset Loader Utility
## Provides safe loading functions for models, textures, and audio with error handling


## Load a 3D model from the assets directory
## Returns the loaded PackedScene or null on error
static func load_model(path: String) -> PackedScene:
	if not FileAccess.file_exists(path):
		push_error("AssetLoader: Model file not found: " + path)
		return null
	
	var model = load(path) as PackedScene
	if not model:
		push_error("AssetLoader: Failed to load model: " + path)
		return null
	
	return model


## Load a texture from the assets directory
## Returns the loaded Texture2D or null on error
static func load_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		push_error("AssetLoader: Texture file not found: " + path)
		return null
	
	var texture = load(path) as Texture2D
	if not texture:
		push_error("AssetLoader: Failed to load texture: " + path)
		return null
	
	return texture


## Load an audio stream from the assets directory
## Returns the loaded AudioStream or null on error
static func load_audio(path: String) -> AudioStream:
	if not FileAccess.file_exists(path):
		push_error("AssetLoader: Audio file not found: " + path)
		return null
	
	var audio = load(path) as AudioStream
	if not audio:
		push_error("AssetLoader: Failed to load audio: " + path)
		return null
	
	return audio


## Check if an asset file exists
static func asset_exists(path: String) -> bool:
	return FileAccess.file_exists(path)
