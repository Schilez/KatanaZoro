extends CharacterBody2D

#Referacnes
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

#Instantiate scene
const projectile_scene = preload("res://Scenes/projectiles.tscn")

#Movment
const Patrol_SPEED = 300.0
var Chase_SPEED=600

@export var is_gunman:= false

#State Machine
enum State {Patrol, Chase, Stand, Stunned, Shooting}
@export var current_state:= State.Stand

var direction := -1

@export var is_right := true

var can_see_player := false
var is_in_range := false
var gun_point
var can_shoot:= true
var agressive := false

func _ready() -> void:
	if is_gunman:
		animated_sprite_2d.play("GunMan")
	else:
		animated_sprite_2d.play("Normal")
	
	if is_right:
		direction = 1



func _physics_process(delta: float) -> void:
	
	#Handle gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	handle_flip()
	
	if is_in_range:
		can_see_player= check_line_of_sight()
	
	
	
	match current_state:
		State.Patrol:
			handle_patrol()
		State.Chase:
			handle_chase(delta)
		State.Stand:
			handle_stand()
		State.Shooting:
			handle_shooting()
		State.Stunned:
			handle_stun()
			return
	
	handle_states()
	
	move_and_slide()

func handle_patrol():
	velocity.x = direction*Patrol_SPEED
	if ray_casat_left.is_colliding():
		direction = 1
	if ray_cast_right.is_colliding():
		direction = -1

func handle_chase(delta: float):
	if player:
		if player.global_position.x< global_position.x:
			direction=-1
		elif player.global_position.x > global_position.x:
			direction= 1
	velocity.x = move_toward(velocity.x,Chase_SPEED*direction,1200*delta)

func handle_flip():
	animated_sprite_2d.flip_h= (direction== -1)
	pivot_point.rotation_degrees=180 if direction==-1 else 0

func handle_stand():
	pass

func handle_shooting():
	if player:
		if player.global_position.x< global_position.x:
			direction=-1
		elif player.global_position.x > global_position.x:
			direction= 1
	
	if can_shoot:
		shoot()
		can_shoot=false
		shoot_timer.start()

func handle_stun():
	pass

func change_state(state: State):
	match current_state:
		State.Patrol:
			pass
		State.Chase:
			agressive=false
		State.Stand:
			pass
		State.Stunned:
			if is_gunman:
				animated_sprite_2d.play("GunMan")
			else:
				animated_sprite_2d.play("Normal")
		State.Shooting:
			agressive=false
	
	current_state=state
	
	match current_state:
		State.Patrol:
			if is_gunman:
				animated_sprite_2d.play("GunMan")
			else:
				animated_sprite_2d.play("Normal")
		State.Chase:
			agressive =true
			animated_sprite_2d.play("NormalChase")
		State.Stand:
			velocity= Vector2.ZERO
		State.Stunned:
			velocity=Vector2.ZERO
			animated_sprite_2d.play("Stunned")
			stun_timer.start()
		State.Shooting:
			agressive=true
			velocity= Vector2.ZERO
			animated_sprite_2d.play("GunManChase")

func handle_states():
	
	if  can_see_player and not agressive:
		if is_gunman:
			change_state(State.Shooting)
		else:
			change_state(State.Chase)
	
	elif not can_see_player and agressive:
		change_state(State.Patrol)


func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if body==player:
		is_in_range=true


func _on_detection_area_2d_body_exited(body: Node2D) -> void:
	if  body==player:
		is_in_range=false
		can_see_player=false

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
	change_state(State.Stunned)

func kill():
	GameManager.add_kill()
	queue_free()

func _on_shoot_timer_timeout() -> void:
	can_shoot=true


func _on_stun_timer_timeout() -> void:
	change_state(State.Stand)


func _on_hurt_box_area_entered(_area: Area2D) -> void:
	kill()
