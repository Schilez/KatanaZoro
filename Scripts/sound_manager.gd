extends Node

#Audio Stream Players
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var ui_player: AudioStreamPlayer = $UIPlayer

#Musics
const MUSIC_1 = preload("res://Assets/Sounds/Katana Zero (Ost-Version).mp3")

#UI sounds
const CLICK = preload("res://Assets/Sounds/click.mp3")

func music_play(music: AudioStream) -> void:
	music_player.stream = music
	music_player.play()

func ui_play(sound: AudioStream) -> void:
	ui_player.stream = sound
	ui_player.play()

func music_stop() -> void:
	if music_player.playing:
		music_player.stop()
