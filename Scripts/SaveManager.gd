extends Node

const SAVE_PATH = "user://save_data.tres"

var save_data: SaveData

func _ready() -> void:
	load_game()
	GameManager.load_data()

func save_game():
	
	if not save_data:
		save_data = SaveData.new()

	var error = ResourceSaver.save(save_data, SAVE_PATH)
	
	if error == OK:
			print("oyun başarıyla kaydedildi")
	else:
			print ("kaydetme hatası: ", error)

func load_game():
	if ResourceLoader.exists(SAVE_PATH):
		save_data = ResourceLoader.load(SAVE_PATH) as SaveData
	else:
		save_data = SaveData.new()
