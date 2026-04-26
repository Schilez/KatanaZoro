extends Area2D

signal was_hit

func hit():
	was_hit.emit()



func _on_area_entered(_area: Area2D) -> void:
	hit()
