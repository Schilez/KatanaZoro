extends Node2D
@onready var next: Area2D = $Next
const SECOND_SCENE = preload("res://Scenes/second_scene.tscn")
@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = %Player
@onready var label: Label = %Label
@onready var panel: Panel = $CanvasLayer/Panel
@onready var margin_container: MarginContainer = $CanvasLayer/MarginContainer
@onready var pause_menu_buttons: VBoxContainer = $CanvasLayer/MarginContainer/Panel/PauseMenuButtons
@onready var exit_text: Control = $"CanvasLayer/MarginContainer/Panel/Exit text"
@onready var click: AudioStreamPlayer = $click



@export var cross_1: Texture2D
@export var cross_2: Texture2D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	margin_container.visible=get_tree().paused
	panel.visible=get_tree().paused
	change_cross(cross_2 if get_tree().paused else cross_1)



func _ready() -> void:
	setup_camera_limits()
	change_cross(cross_1)
	GameManager.music_play()


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

func change_cross(cross:Texture2D):
	if cross:
		var hotspot=cross.get_size()/2
		Input.set_custom_mouse_cursor(cross, Input.CURSOR_ARROW, hotspot)


func _on_continue_pressed() -> void:
	click.play()
	toggle_pause()


func _on_exit_pressed() -> void:
	click.play()
	pause_menu_buttons.visible=false
	exit_text.visible=true


func _on_no_pressed() -> void:
	click.play()
	pause_menu_buttons.visible=true
	exit_text.visible=false


func _on_main_menu_pressed() -> void:
	click.play()
	get_tree().paused = false
	GameManager.music_play()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
