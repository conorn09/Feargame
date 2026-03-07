extends Node

## Audio Manager Singleton
## Manages ambient audio, music, sound effects, and 3D positional audio

# Audio players
var ambient_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

@export var max_sfx_players: int = 10

# Track which SFX player was used last for round-robin
var last_sfx_index: int = 0


func _ready() -> void:
	# Create ambient audio player
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Ambient"
	add_child(ambient_player)
	
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Create pool of SFX players
	for i in range(max_sfx_players):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = "SFX"
		sfx_players.append(sfx_player)
		add_child(sfx_player)



## Play ambient audio with optional fade-in
func play_ambient(stream: AudioStream, fade_in: float = 0.0) -> void:
	if not stream:
		push_error("AudioManager: Cannot play null ambient stream")
		return
	
	ambient_player.stream = stream
	
	if fade_in > 0.0:
		# Start at volume 0 and fade in
		ambient_player.volume_db = -80.0
		ambient_player.play()
		
		var tween = create_tween()
		tween.tween_property(ambient_player, "volume_db", 0.0, fade_in)
	else:
		ambient_player.volume_db = 0.0
		ambient_player.play()


## Stop ambient audio with optional fade-out
func stop_ambient(fade_out: float = 0.0) -> void:
	if fade_out > 0.0:
		var tween = create_tween()
		tween.tween_property(ambient_player, "volume_db", -80.0, fade_out)
		tween.tween_callback(ambient_player.stop)
	else:
		ambient_player.stop()



## Play music with optional fade-in
func play_music(stream: AudioStream, fade_in: float = 0.0) -> void:
	if not stream:
		push_error("AudioManager: Cannot play null music stream")
		return
	
	music_player.stream = stream
	
	if fade_in > 0.0:
		# Start at volume 0 and fade in
		music_player.volume_db = -80.0
		music_player.play()
		
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", 0.0, fade_in)
	else:
		music_player.volume_db = 0.0
		music_player.play()


## Stop music with optional fade-out
func stop_music(fade_out: float = 0.0) -> void:
	if fade_out > 0.0:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_out)
		tween.tween_callback(music_player.stop)
	else:
		music_player.stop()



## Play a sound effect using the player pool
func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if not stream:
		push_error("AudioManager: Cannot play null SFX stream")
		return
	
	# Find an available player or reuse the oldest one
	var player: AudioStreamPlayer = null
	
	# First, try to find a player that's not playing
	for sfx_player in sfx_players:
		if not sfx_player.playing:
			player = sfx_player
			break
	
	# If all players are busy, use round-robin to reuse oldest
	if not player:
		player = sfx_players[last_sfx_index]
		last_sfx_index = (last_sfx_index + 1) % max_sfx_players
	
	# Play the sound
	player.stream = stream
	player.volume_db = volume_db
	player.play()



## Play a 3D positional sound at a specific location
func play_3d_sound(stream: AudioStream, position: Vector3, volume_db: float = 0.0) -> void:
	if not stream:
		push_error("AudioManager: Cannot play null 3D sound stream")
		return
	
	# Create a temporary 3D audio player
	var player_3d = AudioStreamPlayer3D.new()
	player_3d.stream = stream
	player_3d.position = position
	player_3d.volume_db = volume_db
	player_3d.bus = "SFX"
	
	# Add to scene tree
	get_tree().root.add_child(player_3d)
	
	# Play the sound
	player_3d.play()
	
	# Auto-cleanup when finished
	player_3d.finished.connect(func(): player_3d.queue_free())
