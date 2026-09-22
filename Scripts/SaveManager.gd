extends Node

var save_data: SaveData

func _ready() -> void:
	pass


func load_game():
	if not save_data:
		save_data = SaveData.new()
