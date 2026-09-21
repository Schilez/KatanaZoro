extends Node2D

@onready var level_container: Node2D = $LevelContainer

func _ready() -> void:
	#Connecting to the signals
	GameManager.next_level_signal.connect(_on_next_level_signal)
	GameManager.dead_signal.connect(_on_dead_signal)
	
	#Change cursor to the in game crosshair
	GameManager.change_cursor(GameManager.CursorType.CROSSHAIR)
	GameManager.score = GameManager.starting_score
	
	set_level(GameManager.current_level)

func set_level(scene_number: int) -> void:
	for child in level_container.get_children():
		child.queue_free()
	
	var level_scene : PackedScene
	
	match scene_number:
		1:
			level_scene = load("res://Scenes/level_1.tscn")
			print("geldi abe")
		2:
			level_scene = load("res://Scenes/level_2.tscn")
		3:
			level_scene = load("res://Scenes/level_3.tscn")
		4:
			level_scene = load("res://Scenes/end.tscn")
	
	var level_instance : Node = level_scene.instantiate()
	
	level_container.add_child(level_instance)

func _on_next_level_signal():
	set_level(GameManager.current_level)

func _on_dead_signal():
	set_level(GameManager.current_level)
