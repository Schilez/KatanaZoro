extends StaticBody2D

var enemy_in_range: Array[CharacterBody2D]=[]

func stun_enemy():
	for enemy in enemy_in_range:
		if is_instance_valid(enemy):
			if enemy.has_method("apply_stun"):
				enemy.apply_stun()
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		enemy_in_range.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		enemy_in_range.erase(body)
