extends CharacterBody2D
class_name Player

# Referance variables
@onready var player_animated_sprite_2d: AnimatedSprite2D = $PlayerAnimatedSprite2D
@onready var weapon: Node2D = $Weapon
@onready var camera_2d: Camera2D = $Camera2D
@onready var left_throw_point: Node2D = $left_throw_point
@onready var right_throw_point: Node2D = $right_throw_point
@onready var player_hurt_box: Area2D = $PlayerHurtBox


# Instantiate scenes
const projectile_scene = preload("res://Scenes/projectiles.tscn")

#Camera variables
var camera_offset_value:=200.0

#Movment variables
const SPEED = 750
const JUMP_VELOCITY_UP = -650
const JUMP_VELOCITY_FRONT= 120
const DODGE_VELOCITY= 1000

#Gravity variables
@export var base_gravity:=1.5
@export var dodge_gravity:=2.0
@export var attack_gravity:= 4.0


#State checks
var is_right:=true
var is_touched_floor_after_attack:=true
var have_throwable:=false

# State Machine
enum State {Base, Dodging, Attacking}
var current_state: State= State.Base

func _physics_process(delta: float) -> void:
	
	# Handle LeftandRight Input
	var direction := Input.get_axis("move_left", "move_right")
	
	#Handle Camera
	handle_camera_look_ahead(delta)
	
	# is_touched_ground_after_attack check
	if is_on_floor() and not is_touched_floor_after_attack:
		is_touched_floor_after_attack=true
	
	# Handle Gravity
	if not is_on_floor():
		handle_gravity(delta)
	
	#State Actions
	match current_state:
		State.Base:
			# Handle jump.
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY_UP
				velocity.x += JUMP_VELOCITY_FRONT*direction
			
			# Handle attack
			if Input.is_action_just_pressed("Attack") and is_touched_floor_after_attack:
				handle_attack(delta)
			
			#Handle throw
			if Input.is_action_just_pressed("Throw") and have_throwable:
				throw()
			
			#Handle dodge
			if  Input.is_action_just_pressed("Dodge"):
				handle_dodge()
	
	#Handle movment
	if current_state==State.Attacking:
		velocity.x=move_toward(velocity.x,0,30)
	elif current_state==State.Dodging:
		velocity.x=move_toward(velocity.x,0,10)
	else:
		update_animations(direction)
		if not direction==0:
			velocity.x= move_toward(velocity.x,direction*SPEED,2000*delta) if is_on_floor() else move_toward(velocity.x,direction*SPEED,500*delta)
		elif direction==0:
			velocity.x=move_toward(velocity.x,0,1000*delta) if is_on_floor() else move_toward(velocity.x,0,120*delta)
	move_and_slide()

func handle_gravity(delta:float):
	var gravity_mult:= attack_gravity if current_state==State.Attacking else (dodge_gravity if current_state==State.Dodging else base_gravity)
	velocity += get_gravity() * gravity_mult * delta

func handle_attack(delta:float):
	var mouse_pos=get_global_mouse_position()
	var pos=global_position
	current_state= State.Attacking
	is_touched_floor_after_attack=false
	weapon.on_attack()
	
	velocity =(mouse_pos-pos).normalized()*1000
	
	velocity.x= move_toward(velocity.x,0,5000*delta)
	velocity.y= move_toward(velocity.y,0,5000*delta)
	
	if mouse_pos.x>pos.x:
		player_animated_sprite_2d.play("DefaultSağ")
		is_right=true
	elif mouse_pos.x<pos.x:
		player_animated_sprite_2d.play("DefaultSol")
		is_right=false

func handle_dodge():
	current_state=State.Dodging
	player_hurt_box.monitorable=false
	player_hurt_box.monitoring=false
	player_hurt_box.set_collision_layer_value(5,false)
	var dodge_dir = 1 if is_right else -1
	velocity.x =DODGE_VELOCITY*dodge_dir
	player_animated_sprite_2d.play("TaklaSağ" if is_right else "TaklaSol")

func update_animations(direction):
	if not current_state==State.Base:
		return
	if direction>0:
		player_animated_sprite_2d.play("DefaultSağ")
		is_right=true
	elif direction<0:
		player_animated_sprite_2d.play("DefaultSol")
		is_right=false

func throw():
	var throwable=projectile_scene.instantiate()
	get_tree().current_scene.add_child(throwable)
	
	var start_pos=right_throw_point.global_position if is_right else left_throw_point.global_position
	throwable.global_position= start_pos
	
	var dir_to_throw:= (get_global_mouse_position()-start_pos).normalized()
	throwable.launch(dir_to_throw,"Throwable")
	have_throwable=false

func handle_camera_look_ahead(delta: float):
	var target_offset = camera_offset_value if is_right else -camera_offset_value
	camera_2d.offset.x = lerp(camera_2d.offset.x, target_offset, 5.0*delta)

func kill():
	if not current_state==State.Dodging:
			if is_inside_tree():
				GameManager.kill_count=GameManager.start_kill
				get_tree().call_deferred("reload_current_scene")

func _on_player_animated_sprite_2d_animation_finished() -> void:
	if "Takla" in player_animated_sprite_2d.animation:
		player_hurt_box.monitorable=true
		player_hurt_box.monitoring=true
		player_hurt_box.set_collision_layer_value(5,true)
		current_state=State.Base
		if is_right:
			player_animated_sprite_2d.play("DefaultSağ")
		else:
			player_animated_sprite_2d.play("DefaultSol")

func _on_player_hurt_box_was_hit() -> void:
	kill()
