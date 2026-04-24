extends Area2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D


var SPEED := 1600
var direction := Vector2.ZERO
var group := ""

func _physics_process(delta: float) -> void:
	
	
	var move_vector:= direction*SPEED*delta
	position += move_vector
	ray_cast_2d.target_position=to_local(global_position+move_vector)
	
	ray_cast_2d.force_raycast_update()
	
	if ray_cast_2d.is_colliding():
		kill()

func launch (target_dir: Vector2,source_group: String ):
	direction= target_dir.normalized()
	group= source_group
	add_to_group(source_group)
	
	
	if group=="Bullet":
		ray_cast_2d.set_collision_mask_value(5, true)
	elif group=="Throwable":
		ray_cast_2d.set_collision_mask_value(6,true)




func _on_body_entered(_body: Node2D) -> void:
	kill()

func kill():
	visible=false
	collision_layer=0
	collision_mask=0
	set_physics_process(false)
	set_process(false)
	queue_free()




func _on_area_entered(area: Area2D) -> void:
	kill()
