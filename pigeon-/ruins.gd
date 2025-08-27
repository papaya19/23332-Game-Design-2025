extends Node

# A reference to the player node for easier access.
@onready var audio_player = $AudioStreamPlayer

func _ready():
	# Connect to the 'scene_changed' signal when the game starts.
	# When the scene changes, the 'on_scene_changed' function will be called.
	get_tree().scene_changed.connect(on_scene_changed)


# This function runs automatically whenever a new scene is loaded.
# Godot automatically passes the new scene's root node to it.
func on_scene_changed(new_scene):
	# Check if the new scene is part of the "no_music" group.
	if new_scene.is_in_group("no_music"):
		audio_player.stop()
	else:
		# If it's not a "no_music" scene, and the music isn't
		# already playing, then start it. This prevents the
		# track from restarting when moving between two music-enabled scenes.
		if not audio_player.playing:
			audio_player.play()
