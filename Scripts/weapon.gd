extends Node2D
@onready var weapon_animated_sprite_2d: AnimatedSprite2D = $WeaponAnimatedSprite2D
@onready var weapon_area_2d: Area2D = $Area2D
@onready var player: CharacterBody2D = $".."
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

signal attack_finished

func on_attack():
	look_at(get_global_mouse_position())
	weapon_animated_sprite_2d.visible=true
	weapon_area_2d.monitoring=true
	weapon_area_2d.monitorable=true
	weapon_animated_sprite_2d.play("Attack")
	audio_stream_player_2d.play()

func _on_weapon_animated_sprite_2d_animation_finished() -> void:
	if "Attack" in weapon_animated_sprite_2d.animation:
		weapon_animated_sprite_2d.visible=false
		weapon_area_2d.monitoring=false
		weapon_area_2d.monitorable=false
		attack_finished.emit()
