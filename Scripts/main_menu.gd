extends Control

@export var cross_1: Texture2D
const MAIN_SCENE = preload("res://Scenes/main_scene.tscn")
@onready var main_buttons: VBoxContainer = $CanvasLayer/Panel/MainButtons
@onready var option_buttons: Control = $CanvasLayer/Panel/OptionButtons
@onready var left: Button = $CanvasLayer/Panel/OptionButtons/Graphics/Left/Left
@onready var graphic: Label = $CanvasLayer/Panel/OptionButtons/Graphics/Graphic/Graphic
@onready var right: Button = $CanvasLayer/Panel/OptionButtons/Graphics/Right/Right
@onready var new_game: Control = $CanvasLayer/Panel/NewGame
@onready var click: AudioStreamPlayer = $click

var graphic_level := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_cross(cross_1)
	GameManager.kill_count=0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match graphic_level:
		1:
			graphic.text="Low"
			left.disabled=true
		2:
			graphic.text="Medium"
			left.disabled=false
			right.disabled=false
		3:
			graphic.text="High"
			right.disabled=true

func change_graphic(i:int):
	graphic_level = graphic_level+i



func change_cross(cross:Texture2D):
	if cross:
		var hotspot=cross.get_size()/2
		Input.set_custom_mouse_cursor(cross, Input.CURSOR_ARROW, hotspot)



func _on_continue_pressed() -> void:
	click.play()
	get_tree().change_scene_to_packed(MAIN_SCENE)



func _on_options_pressed() -> void:
	main_buttons.visible=false
	option_buttons.visible=true
	click.play()


func _on_back_pressed() -> void:
	main_buttons.visible=true
	option_buttons.visible=false
	click.play()


func _on_left_pressed() -> void:
	change_graphic(-1)
	click.play()


func _on_right_pressed() -> void:
	change_graphic(1)
	click.play()


func _on_new_game_pressed() -> void:
	new_game.visible=true
	main_buttons.visible=false
	click.play()


func _on_no_pressed() -> void:
	new_game.visible=false
	main_buttons.visible=true
	click.play()


func _on_exit_pressed() -> void:
	if is_inside_tree():
		get_tree().quit()
