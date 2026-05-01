extends Area2D

@onready var parent: Node2D=$".."

var is_dead:= false

signal was_hit

func hit():
	if is_dead: return
	is_dead=true
	was_hit.emit()
	queue_free()
