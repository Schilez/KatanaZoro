extends Control

@onready var pause_menu_buttons: VBoxContainer = %PauseMenuButtons
@onready var exit_text: Control = %"Exit text"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible=get_tree().paused
	GameManager.change_cursor(GameManager.CursorType.DEFAULT if get_tree().paused else GameManager.CursorType.CROSSHAIR)

func _on_continue_pressed() -> void:
	SoundManager.ui_play(SoundManager.CLICK)
	toggle_pause()

func _on_exit_pressed() -> void:
	SoundManager.ui_play(SoundManager.CLICK)
	pause_menu_buttons.visible=false
	exit_text.visible=true

func _on_no_pressed() -> void:
	SoundManager.ui_play(SoundManager.CLICK)
	pause_menu_buttons.visible=true
	exit_text.visible=false

func _on_main_menu_pressed() -> void:
	SoundManager.ui_play(SoundManager.CLICK)
	get_tree().paused = false
	SoundManager.music_stop()
	GameManager.change_root_scene(GameManager.MAIN_MENU_PATH)
