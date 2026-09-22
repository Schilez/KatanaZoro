extends Node

#Load datas
var starting_score: int
var score: int
var current_level: int

#Signals
signal next_level_signal
signal dead_signal

#Cursors
enum CursorType {DEFAULT, CROSSHAIR}
const CURSOR_DEFAULT = preload("res://Assets/UI_Materials/Textures/CURSOR_DEFAULT.png")
const CURSOR_CROSSHAIR = preload("res://Assets/UI_Materials/Textures/CURSOR_CROSSHAIR.png")

#Scenes
const MAIN_MENU_PATH = "res://Scenes/main_menu.tscn"
const MAIN_SCENE_PATH = "res://Scenes/main_scene.tscn"

func _ready() -> void:
	pass

func music_play() -> void:
	SoundManager.playing = !SoundManager.playing

func start_game() -> void:
	change_root_scene(MAIN_SCENE_PATH)

func new_game() ->  void:
	if current_level == 0:
		SaveManager.load_game()
		load_data()
	
	starting_score = 0
	score = starting_score
	current_level = 1
	
	SaveManager.save_data.score = score
	SaveManager.save_data.current_level = current_level
	
	start_game()

func next_level() -> void:
	current_level += 1
	starting_score = score
	next_level_signal.emit()
	
	SaveManager.save_data.current_level= current_level
	SaveManager.save_data.score= score


func load_data() -> void:
	starting_score = SaveManager.save_data.score
	score = starting_score
	current_level = SaveManager.save_data.current_level

func restart() -> void:
	score = starting_score
	dead_signal.emit.call_deferred()

func add_score() -> void:
	score += 1

func change_cursor(type: CursorType) -> void:
	var cross:Texture2D
	var hotspot:Vector2
	
	match type:
		CursorType.DEFAULT:
			cross = CURSOR_DEFAULT
			hotspot = Vector2(20,20)
		CursorType.CROSSHAIR:
			cross = CURSOR_CROSSHAIR
			hotspot = cross.get_size()/2
	
	if cross:
		Input.set_custom_mouse_cursor(cross, Input.CURSOR_ARROW, hotspot)

func change_root_scene(scene: String) -> void:
	get_tree().change_scene_to_file(scene)
