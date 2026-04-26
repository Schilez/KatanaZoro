extends Node2D
@onready var label: Label = $CanvasLayer/Label
@onready var player: Player = %Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_camera_limits()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func the_end():
	label.visible=true

func setup_camera_limits():
	# Oyuncunun içindeki kameraya ulaşıyoruz
	var camera = player.get_node("Camera2D")
	
	# Limitleri hesaplayıp atıyoruz (Cell sayısı * Pixel boyutu)
	camera.limit_left = -1400
	camera.limit_right = 2600
	camera.limit_top = -1000
	camera.limit_bottom = 500
