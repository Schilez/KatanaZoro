extends CharacterBody2D
class_name Player

#Referance variables
@onready var player_animated_sprite_2d: AnimatedSprite2D = $PlayerAnimatedSprite2D
@onready var weapon: Node2D = $Weapon
@onready var camera_2d: Camera2D = $Camera2D
@onready var left_throw_point: Node2D = $left_throw_point
@onready var right_throw_point: Node2D = $right_throw_point
@onready var player_hurt_box: Area2D = $PlayerHurtBox
@onready var attack_timer: Timer = $attack_timer

#Instantiate scenes
const projectile_scene = preload("res://Scenes/projectiles.tscn")

#Camera variables
var camera_offset_value:=200.0
var camera_offset_speed:=2.5

#Movment variables
const SPEED:= 750
const ACCELERATION_ON_FLOOR := 2000
const ACCELERATION_ON_AIR := 750
const FRICTION_ON_FLOOR := 1000
const FRICTION_ON_AIR := 500
#Jump movment variables
const JUMP_VELOCITY_UP:= -650
const JUMP_VELOCITY_FRONT:= 120
#Dodge movment variables
const DODGE_VELOCITY:= 1000
const DODGE_FRICTION := 600
#Attack movment variables
const ATTACK_VELOCITY := 1000
const ATTACK_FRICTION := 2000
#Kill slow
const kill_slow:=0.85

#Gravity variables
var base_gravity:=1.5
var dodge_gravity:=2.0
var attack_gravity:= 4.0


#Bools
var is_right:=true
var is_touched_floor_after_attack:= true
var have_throwable:= false
var can_attack := true

# State Machine
enum State {Base, Dodging, Attacking}
var current_state: State= State.Base


func _physics_process(delta: float) -> void:
	#Handle Camera
	handle_camera_look_ahead(delta)
	
	# is_touched_ground_after_attack check
	if is_on_floor() and not is_touched_floor_after_attack:
		is_touched_floor_after_attack=true
	
	# Handle Gravity
	if not is_on_floor():
		handle_gravity(delta)
	
	#State physics
	match current_state:
		State.Base:
			handle_base_physics(delta)
		State.Attacking:
			handle_attack_physics(delta)
		State.Dodging:
			handle_dodge_physics(delta)
	
	move_and_slide()

#Base state physics
func handle_base_physics(delta: float):
	var direction := Input.get_axis("move_left", "move_right")
	update_animations(direction)
	
	var target_vel= SPEED*direction
	
	if not direction==0:
		var acceleration= ACCELERATION_ON_FLOOR if is_on_floor() else ACCELERATION_ON_AIR
		velocity.x= move_toward(velocity.x,target_vel,acceleration*delta)
	else:
		var friction= FRICTION_ON_FLOOR if is_on_floor() else FRICTION_ON_AIR
		velocity.x= move_toward(velocity.x,target_vel,friction*delta)
	
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY_UP
		velocity.x += JUMP_VELOCITY_FRONT*direction
	
	if Input.is_action_just_pressed("Attack") and is_touched_floor_after_attack:
		if can_attack:
			state_change(State.Attacking)
	
	if  Input.is_action_just_pressed("Dodge"):
		state_change(State.Dodging)
	
	if Input.is_action_just_pressed("Throw") and have_throwable:
		throw()

#Attacking state physics
func handle_attack_physics(delta:float):
	velocity.x= move_toward(velocity.x,0,ATTACK_FRICTION*delta)
	velocity.y= move_toward(velocity.y,0,ATTACK_FRICTION*delta)

#Dodging state physics
func handle_dodge_physics(delta:float):
	velocity.x=move_toward(velocity.x,0,DODGE_FRICTION*delta)

#Handle gravity
func handle_gravity(delta:float):
	var gravity_mult:= attack_gravity if current_state==State.Attacking else (dodge_gravity if current_state==State.Dodging else base_gravity)
	velocity += get_gravity() * gravity_mult * delta

#Animation update
func update_animations(direction):
	if direction>0:
		player_animated_sprite_2d.play("DefaultSağ")
		is_right=true
	elif direction<0:
		player_animated_sprite_2d.play("DefaultSol")
		is_right=false

#Handle throw
func throw():
	var throwable=projectile_scene.instantiate()
	get_tree().current_scene.add_child(throwable)
	
	var start_pos=right_throw_point.global_position if is_right else left_throw_point.global_position
	throwable.global_position= start_pos
	
	var dir_to_throw:= (get_global_mouse_position()-start_pos).normalized()
	throwable.launch(dir_to_throw,"Throwable")
	have_throwable=false

#Handle camera
func handle_camera_look_ahead(delta: float):
	var target_offset = camera_offset_value if is_right else -camera_offset_value
	camera_2d.offset.x = lerp(camera_2d.offset.x, target_offset,camera_offset_speed*delta)

#Handle death
func kill():
	if not current_state==State.Dodging:
			if is_inside_tree():
				GameManager.kill_count=GameManager.start_kill
				get_tree().call_deferred("reload_current_scene")

#Handle state changes
func state_change(state: State):
	match current_state:
		State.Dodging:
			player_hurt_box.monitorable=true
			player_hurt_box.monitoring=true
			player_hurt_box.set_collision_layer_value(5,true)
		State.Attacking:
			attack_timer.start()
		State.Base:
			pass
	
	current_state=state
	
	match current_state:
		State.Dodging:
			player_hurt_box.monitorable=false
			player_hurt_box.monitoring=false
			player_hurt_box.set_collision_layer_value(5,false)
			player_animated_sprite_2d.play("TaklaSağ" if is_right else "TaklaSol")
			var dodge_dir = 1 if is_right else -1
			velocity.x =DODGE_VELOCITY*dodge_dir
		State.Attacking:
			can_attack=false
			var mouse_pos=get_global_mouse_position()
			var pos=global_position
			velocity =(mouse_pos-pos).normalized()*ATTACK_VELOCITY
			is_touched_floor_after_attack=false
			weapon.on_attack()
			if mouse_pos.x>pos.x:
				player_animated_sprite_2d.play("DefaultSağ")
				is_right=true
			elif mouse_pos.x<pos.x:
				player_animated_sprite_2d.play("DefaultSol")
				is_right=false
		State.Base:
			if is_right:
				player_animated_sprite_2d.play("DefaultSağ")
			else:
				player_animated_sprite_2d.play("DefaultSol")

func stop():
	velocity=velocity*kill_slow


func _on_player_animated_sprite_2d_animation_finished() -> void:
	if "Takla" in player_animated_sprite_2d.animation:
		state_change(State.Base)

func _on_player_hurt_box_was_hit() -> void:
	kill()

func _on_weapon_attack_finished() -> void:
	state_change(State.Base)

func _on_attack_timer_timeout() -> void:
	can_attack=true
