extends Area2D

@onready var parent: Node2D=$".."

func hit():
	kill()

func kill():
	GameManager.add_kill()
	parent.queue_free()

func _on_area_entered(_area: Area2D) -> void:
	kill()
