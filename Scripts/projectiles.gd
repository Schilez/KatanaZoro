extends Area2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D

var SPEED := 3000
var direction := Vector2.ZERO
var group := ""
const move_tampon:=1.2

func _physics_process(delta: float) -> void:
	var move_vector:= direction*SPEED*delta
	ray_cast_2d.target_position=to_local(global_position+move_vector*move_tampon)
	ray_cast_2d.force_raycast_update()
	
	if ray_cast_2d.is_colliding():
		var body= ray_cast_2d.get_collider()
		if body.has_method("hit"):
			body.hit()
		kill()
	else:
		position += move_vector



func launch (target_dir: Vector2,source_group: String ):
	direction= target_dir.normalized()
	global_rotation=direction.angle()
	group= source_group
	add_to_group(source_group)
	
	if group=="Bullet":
		ray_cast_2d.set_collision_mask_value(5, true)
	elif group=="Throwable":
		ray_cast_2d.set_collision_mask_value(6,true)
		ray_cast_2d.set_collision_mask_value(7,true)


func kill():
	visible=false
	collision_layer=0
	collision_mask=0
	set_physics_process(false)
	set_process(false)
	queue_free()
