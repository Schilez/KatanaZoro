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
@onready var hurt_box: Area2D = $HurtBox
@onready var bullet_container: Node2D = %BulletContainer


#Instantiate scene
const projectile_scene = preload("res://Scenes/projectiles.tscn")

#Movment
const Patrol_SPEED = 300.0
var Chase_SPEED=600

#State Machine
enum State {Patrol, Chase, Stand, Stunned, Shooting}
@export var current_state:= State.Stand

#Enemy Types
enum Types {Normal,GunMan}
@export var type:= Types.Normal

var base_attack_state: State
var base_animation: String

var direction := -1

@export var is_right := true

var can_see_player := false
var is_in_range := false
var gun_point
var can_shoot:= true
var is_dead:= false

func _ready() -> void:
	
	match type:
		Types.Normal:
			base_attack_state=State.Chase
			base_animation="Normal"
		Types.GunMan:
			base_attack_state=State.Shooting
			base_animation="GunMan"
	
	animated_sprite_2d.play(base_animation)
	
	if is_right:
		direction = 1

func _physics_process(delta: float) -> void:
	
	#Handle gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	handle_flip()
	
	if is_in_range:
		can_see_player= check_line_of_sight()
	
	think()
	
	match current_state:
		State.Patrol:
			handle_patrol()
		State.Chase:
			handle_chase(delta)
		State.Stand:
			pass
		State.Shooting:
			handle_shooting()
		State.Stunned:
			pass
	
	move_and_slide()

func handle_patrol():
	velocity.x = direction*Patrol_SPEED
	if ray_casat_left.is_colliding():
		direction = 1
	if ray_cast_right.is_colliding():
		direction = -1

func handle_chase(delta: float):
	update_direction_to_player()
	velocity.x = move_toward(velocity.x,Chase_SPEED*direction,800*delta)

func handle_flip():
	animated_sprite_2d.flip_h= (direction== -1)
	pivot_point.rotation_degrees=180 if direction==-1 else 0

func handle_shooting():
	update_direction_to_player()
	if can_shoot:
		shoot()
		can_shoot=false
		shoot_timer.start()

func change_state(state: State):
	match current_state:
		State.Patrol:
			pass
		State.Chase:
			pass
		State.Stand:
			pass
		State.Stunned:
			animated_sprite_2d.play(base_animation)
		State.Shooting:
			pass
	
	current_state=state
	
	match current_state:
		State.Patrol:
			animated_sprite_2d.play(base_animation)
		State.Chase:
			animated_sprite_2d.play("NormalChase")
		State.Stand:
			velocity= Vector2.ZERO
			animated_sprite_2d.play(base_animation)
		State.Stunned:
			velocity=Vector2.ZERO
			animated_sprite_2d.play("Stunned")
			stun_timer.start()
		State.Shooting:
			velocity= Vector2.ZERO
			animated_sprite_2d.play("GunManChase")

func think():
	if not current_state==State.Stunned:
		
		if can_see_player:
			if not current_state==base_attack_state:
				change_state(base_attack_state)
		
		else:
			if current_state==base_attack_state:
				change_state(State.Patrol)

func update_direction_to_player():
	if player:
		direction= sign(player.global_position.x-global_position.x)

func hit():
	if is_dead: return
	is_dead=true
	GameManager.add_score()
	queue_free()

func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if body==player:
		is_in_range=true
		sight_ray.enabled=true

func _on_detection_area_2d_body_exited(body: Node2D) -> void:
	if body==player:
		is_in_range=false
		can_see_player=false
		sight_ray.enabled=false
		sight_ray.target_position=Vector2.ZERO

func check_line_of_sight()-> bool:
	if not player or not sight_ray.enabled:
		return false
	sight_ray.target_position= to_local(player.global_position)
	
	if sight_ray.is_colliding():
		var collider:= sight_ray.get_collider()
		if collider==player:
			return true
	return false

func shoot():
	var projectile= projectile_scene.instantiate()
	bullet_container.add_child(projectile)
	
	projectile.global_position=bullet_point_left.global_position if direction==-1 else bullet_point_right.global_position
	
	var dir_to_player=(player.global_position-global_position).normalized()
	
	projectile.launch(dir_to_player,"Bullet")

func apply_stun():
	change_state(State.Stunned)

func _on_shoot_timer_timeout() -> void:
	can_shoot=true

func _on_stun_timer_timeout() -> void:
	change_state(State.Stand)

func _on_hurt_box_area_entered(area: Area2D) -> void:
	area.hit()
