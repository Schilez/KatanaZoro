extends Area2D

var SPEED := 1600
var direction := Vector2.ZERO
var group := ""

func _physics_process(delta: float) -> void:
	position += direction*SPEED*delta

func launch (target_dir: Vector2,source_group: String ):
	direction= target_dir.normalized()
	group= source_group
	
	if group=="bullet":
		set_collision_mask_value(1,true)
	elif group=="throwable":
		set_collision_mask_value(2,true)



func _on_body_entered(body: Node2D) -> void:
	if group== "bullet" and body.is_in_group("Player"):
		if body.get("current_state")==body.get("State.Dodging"):
			if is_inside_tree():
				GameManager.kill_count=GameManager.start_kill
				get_tree().call_deferred("reload_current_scene")
				queue_free()

	elif  group=="throwable" and body.is_in_group("Enemies"):
		GameManager.add_kill()
		body.queue_free()
		queue_free()
	else:
		queue_free()
