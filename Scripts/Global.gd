extends Node

const MAIN_MENU = preload("res://Scenes/main_menu.tscn")
const MAIN_SCENE = preload("res://Scenes/main_scene.tscn")
const SECOND_SCENE = preload("res://Scenes/second_scene.tscn")
const THIRD_SCENE = preload("res://Scenes/third_scene.tscn")
const END = preload("res://Scenes/end.tscn")

var kill_count: int= 0
var start_kill:= 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func add_kill():
	kill_count += 1

func music_play():
	SoundManager.playing = !SoundManager.playing

func save():
	SaveManager.save_data.current_level += 1
	SaveManager.save_data.high_score = kill_count
	SaveManager.save_game()

func load():
	
	match  SaveManager.save_data.current_level:
		1:
			get_tree().change_scene_to_packed(MAIN_SCENE)
		2:
			get_tree().change_scene_to_packed(SECOND_SCENE)
		3:
			get_tree().change_scene_to_packed(THIRD_SCENE)
		4:
			get_tree().change_scene_to_packed(END)
	
	kill_count = SaveManager.save_data.high_score
