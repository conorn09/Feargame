extends Resource
class_name DialogueEntry

## Dialogue Entry Resource
## Represents a single dialogue entry with text, duration, speaker, and optional audio

@export var text: String = ""
@export var duration: float = 3.0  # 0 = wait for input, > 0 = auto-hide after duration
@export var speaker: String = ""
@export var audio: AudioStream = null
