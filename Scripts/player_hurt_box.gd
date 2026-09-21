extends Area2D

@onready var player: Player = $".."

func hit():
	player.kill()
