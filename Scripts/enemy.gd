extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Player = %Player
@onready var pivot_point: Node2D = $PivotPoint
@onready var ray_casat_left: RayCast2D = $RayCasatLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var sight_ray: RayCast2D = $SightRay
@onready var shoot_timer: Timer = $shoot_timer
@onready var bullet_point_left: Node2D = $bullet_point_left
@onready var bullet_point_right: Node2D = $bullet_point_right
@onready var stun_timer: Timer = $stun_timer




const projectile_scene = preload("res://Scenes/projectiles.tscn")

const Patrol_SPEED = 300.0
var Chase_SPEED=600

@export var is_gunman:= false

enum State {Patrol, Chase, Stand, Stunned, Shooting}

@export var current_state:= State.Stand

var direction := -1

@export var is_right := true

var can_see_player := false
var is_in_range := false
var gun_point
var can_shoot:= true

func _ready() -> void:
	if is_gunman:
		animated_sprite_2d.play("GunMan")
	else:
		animated_sprite_2d.play("Normal")
	
	if is_right:
		direction = 1



func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	handle_flip()
	
	if is_in_range:
		can_see_player= check_line_of_sight()
	
	match current_state:
		State.Patrol:
			handle_patrol()
		State.Chase:
			handle_chase()
		State.Stand:
			handle_stand()
		State.Shooting:
			handle_shooting()
		State.Stunned:
			handle_stun()
	
	if is_in_range and can_see_player and current_state!= State.Chase and current_state!=State.Stunned:
		if not is_gunman:
			current_state=State.Chase
			animated_sprite_2d.play("NormalChase")
		elif is_gunman:
			current_state= State.Shooting
			animated_sprite_2d.play("GunManChase")
		
	elif current_state!=State.Patrol and !is_in_range or !can_see_player:
		if current_state!=State.Stand and current_state != State.Stunned:
			current_state=State.Patrol
			if not is_gunman:
				animated_sprite_2d.play("Normal")
			elif is_gunman:
				animated_sprite_2d.play("GunMan")



	move_and_slide()

func handle_patrol():
	velocity.x = direction*Patrol_SPEED
	if ray_casat_left.is_colliding():
		direction = 1
	if ray_cast_right.is_colliding():
		direction = -1

func handle_chase():
	if player:
		if player.global_position.x< global_position.x:
			direction=-1
		elif player.global_position.x > global_position.x:
			direction= 1

	velocity.x = move_toward(velocity.x,Chase_SPEED*direction,20)

func handle_flip():
	animated_sprite_2d.flip_h= (direction== -1)
	pivot_point.rotation_degrees=180 if direction==-1 else 0

func handle_stand():
	velocity= Vector2.ZERO

func handle_shooting():
	if player:
		if player.global_position.x< global_position.x:
			direction=-1
		elif player.global_position.x > global_position.x:
			direction= 1
	
	velocity= Vector2.ZERO
	if can_shoot:
		shoot()
		can_shoot=false
		shoot_timer.start()

func handle_stun():
	velocity=Vector2.ZERO


func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if body==player:
		is_in_range=true


func _on_detection_area_2d_body_exited(body: Node2D) -> void:
	if  body==player:
		is_in_range=false

func check_line_of_sight()-> bool:
	if player:
		sight_ray.target_position= to_local(player.global_position)
		
		if sight_ray.is_colliding():
			var collider:= sight_ray.get_collider()
			if collider==player:
				return true
	return false

func shoot():
	var projectile= projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	
	projectile.global_position=bullet_point_left.global_position if direction==-1 else bullet_point_right.global_position
	
	var dir_to_player=(player.global_position-global_position).normalized()
	
	projectile.launch(dir_to_player,"Bullet")

func apply_stun():
	current_state=State.Stunned
	animated_sprite_2d.play("Stunned")
	stun_timer.start()

func kill():
	GameManager.add_kill()
	queue_free()
	
	visible=false
	
	collision_layer=0
	collision_mask=0
	
	set_physics_process(false)
	set_process(false)

func _on_shoot_timer_timeout() -> void:
	can_shoot=true


func _on_stun_timer_timeout() -> void:
	current_state=State.Patrol



func _on_hurt_box_area_entered(_area: Area2D) -> void:
	kill()
