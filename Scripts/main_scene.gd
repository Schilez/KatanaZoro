extends Node2D
@onready var next: Area2D = $Next
const SECOND_SCENE = preload("res://Scenes/second_scene.tscn")
@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = %Player
@onready var label: Label = $CanvasLayer/Label


func _ready() -> void:
	setup_camera_limits()


func _process(_delta: float) -> void:
	if get_tree().get_nodes_in_group("Enemies").size()==0:
		next.awake(SECOND_SCENE)
	label.text= str(GameManager.kill_count)

func setup_camera_limits():
	# Oyuncunun içindeki kameraya ulaşıyoruz
	var camera = player.get_node("Camera2D")
	
	# Limitleri hesaplayıp atıyoruz (Cell sayısı * Pixel boyutu)
	camera.limit_left = -1300
	camera.limit_right = 3800
	camera.limit_top = -1000
	camera.limit_bottom = 700
