extends Node2D
@onready var player: CharacterBody2D = %Player
@onready var margin_container: MarginContainer = $CanvasLayer/MarginContainer
@onready var next: Area2D = $Next
const END = preload("res://Scenes/end.tscn")
@onready var label: Label = %Label
@onready var panel: Panel = $CanvasLayer/Panel
@onready var margin_container_2: MarginContainer = $CanvasLayer/MarginContainer2
@onready var pause_menu_buttons: VBoxContainer = $CanvasLayer/MarginContainer2/Panel/PauseMenuButtons
@onready var exit_text: Control = $"CanvasLayer/MarginContainer2/Panel/Exit text"
@onready var click: AudioStreamPlayer = $click

@export var cross_1: Texture2D
@export var cross_2: Texture2D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	margin_container_2.visible=get_tree().paused
	panel.visible=get_tree().paused
	change_cross(cross_2 if get_tree().paused else cross_1)

func change_cross(cross:Texture2D):
	if cross:
		var hotspot=cross.get_size()/2
		Input.set_custom_mouse_cursor(cross, Input.CURSOR_ARROW, hotspot)

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
		next.awake(END)

	label.text= str(GameManager.kill_count)

func setup_camera_limits():
	# Oyuncunun içindeki kameraya ulaşıyoruz
	var camera = player.get_node("Camera2D")
	
	# Limitleri hesaplayıp atıyoruz (Cell sayısı * Pixel boyutu)
	camera.limit_left = -1000
	camera.limit_right = 5800
	camera.limit_top = -1200
	camera.limit_bottom = 450


func _on_continue_pressed() -> void:
	toggle_pause()
	click.play()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	click.play()
	GameManager.music_play()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_exit_pressed() -> void:
	pause_menu_buttons.visible=false
	exit_text.visible=true
	click.play()


func _on_no_pressed() -> void:
	pause_menu_buttons.visible=true
	exit_text.visible=false
	click.play()
