extends Node2D
@onready var player: CharacterBody2D = %Player
@onready var margin_container: MarginContainer = $CanvasLayer/MarginContainer
@onready var next: Area2D = $Next
const THIRD_SCENE = preload("res://Scenes/third_scene.tscn")
@onready var label: Label = $CanvasLayer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_camera_limits()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player.have_throwable==true:
		margin_container.visible=true
	else:
		margin_container.visible=false
	
	if get_tree().get_nodes_in_group("Enemies").size()==0:
		next.awake(THIRD_SCENE)
	label.text= str(GameManager.kill_count)

func setup_camera_limits():
	# Oyuncunun içindeki kameraya ulaşıyoruz
	var camera = player.get_node("Camera2D")
	
	# Limitleri hesaplayıp atıyoruz (Cell sayısı * Pixel boyutu)
	camera.limit_left = -900
	camera.limit_right = 5900
	camera.limit_top = -1000
	camera.limit_bottom = 700
