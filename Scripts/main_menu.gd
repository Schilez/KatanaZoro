extends Control

@onready var main_buttons: VBoxContainer = $CanvasLayer/Panel/MainButtons
@onready var option_buttons: Control = $CanvasLayer/Panel/OptionButtons
@onready var left: Button = $CanvasLayer/Panel/OptionButtons/Graphics/Left/Left
@onready var graphic: Label = $CanvasLayer/Panel/OptionButtons/Graphics/Graphic/Graphic
@onready var right: Button = $CanvasLayer/Panel/OptionButtons/Graphics/Right/Right
@onready var new_game: Control = $CanvasLayer/Panel/NewGame

var graphic_level := 1

func _ready() -> void:
	GameManager.change_cursor(GameManager.CursorType.DEFAULT)

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

func _on_continue_pressed() -> void:
	SoundManager.ui_play(SoundManager.CLICK)
	GameManager.start_game()

func _on_options_pressed() -> void:
	SoundManager.ui_play(SoundManager.CLICK)
	main_buttons.visible=false
	option_buttons.visible=true

func _on_back_pressed() -> void:
	SoundManager.ui_play(SoundManager.CLICK)
	main_buttons.visible=true
	option_buttons.visible=false

func _on_left_pressed() -> void:
	SoundManager.ui_play(SoundManager.CLICK)
	change_graphic(-1)

func _on_right_pressed() -> void:
	SoundManager.ui_play(SoundManager.CLICK)
	change_graphic(1)

func _on_new_game_pressed() -> void:
	SoundManager.ui_play(SoundManager.CLICK)
	new_game.visible=true
	main_buttons.visible=false

func _on_no_pressed() -> void:
	SoundManager.ui_play(SoundManager.CLICK)
	new_game.visible=false
	main_buttons.visible=true

func _on_exit_pressed() -> void:
	if is_inside_tree():
		get_tree().quit()

func _on_yes_pressed() -> void:
	SoundManager.ui_play(SoundManager.CLICK)
	GameManager.new_game()
	GameManager.start_game()
