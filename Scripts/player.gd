extends CharacterBody2D

@onready var player_animated_sprite_2d: AnimatedSprite2D = $PlayerAnimatedSprite2D
@onready var weapon: Node2D = $Weapon
@onready var camera_2d: Camera2D = $Camera2D
const throwable_scene = preload("res://Scenes/throwable.tscn")
@onready var left_throw_point: Node2D = $left_throw_point
@onready var right_throw_point: Node2D = $right_throw_point
const projectile_scene = preload("res://Scenes/projectiles.tscn")

var camera_offset_value:=200.0
const SPEED = 750
const JUMP_VELOCITY_UP = -650
const JUMP_VELOCITY_FRONT= 120
const DODGE_VELOCITY= 1000
var is_dodging:=false
var is_right:=true
var is_attacking:=false
var is_touched_floor_after_attack:=true
var have_throwable:=false


func _physics_process(delta: float) -> void:
	# Direction diye variable yarat ve değer ver
	var direction := Input.get_axis("move_left", "move_right")
	handle_camera_look_ahead(delta)
	if is_on_floor():
		is_touched_floor_after_attack=true
# Add the gravity.
	if not is_on_floor():
		if is_dodging:
			velocity += get_gravity() * delta*2
		elif is_attacking:
			velocity += get_gravity() * delta*4
		else:
			velocity += get_gravity() * delta*1.5
# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_dodging and not is_attacking:
		velocity.y = JUMP_VELOCITY_UP
		velocity.x += JUMP_VELOCITY_FRONT*direction

# Handle attack
	if Input.is_action_just_pressed("Attack") and not is_dodging and not is_attacking and is_touched_floor_after_attack:
		var mouse_pos=get_global_mouse_position()
		var pos=global_position
		is_attacking=true
		is_touched_floor_after_attack=false
		weapon.on_attack()
		
		velocity =(mouse_pos-pos).normalized()*1000
		
		velocity.x= move_toward(velocity.x,0,3000*delta)
		velocity.y= move_toward(velocity.y,0,3000*delta)
		
		if mouse_pos.x>pos.x:
			player_animated_sprite_2d.play("DefaultSağ")
			is_right=true
		elif mouse_pos.x<pos.x:
			player_animated_sprite_2d.play("DefaultSol")
			is_right=false

#Handle throw
	if Input.is_action_just_pressed("Throw") and have_throwable:
		if !is_dodging and !is_attacking:
			throw()

#Handle dodge
	if  Input.is_action_just_pressed("Dodge") and not is_dodging and not is_attacking:
		is_dodging=true
		get_tree().call_group("Enemies", "set_collision_mask_value", 1, false)
		set_collision_mask_value(2,false)
		var dodge_dir = 1 if is_right else -1
		velocity.x =DODGE_VELOCITY*dodge_dir
		player_animated_sprite_2d.play("TaklaSağ" if is_right else "TaklaSol")
#Handle movment
	if is_attacking:
		velocity.x=move_toward(velocity.x,0,30)
	elif is_dodging:
		velocity.x=move_toward(velocity.x,0,10)
	else:
		update_animations(direction)
		if direction!=0:
			velocity.x= move_toward(velocity.x,direction*SPEED,2000*delta) if is_on_floor() else move_toward(velocity.x,direction*SPEED,500*delta)
		elif direction==0:
			velocity.x=move_toward(velocity.x,0,30) if is_on_floor() else move_toward(velocity.x,0,120*delta)
	move_and_slide()

func update_animations(direction):
	if is_dodging and is_attacking:
		return
	if direction>0:
		player_animated_sprite_2d.play("DefaultSağ")
		is_right=true
	elif direction<0:
		player_animated_sprite_2d.play("DefaultSol")
		is_right=false

func _on_player_animated_sprite_2d_animation_finished() -> void:
	if "Takla" in player_animated_sprite_2d.animation:
		get_tree().call_group("Enemies", "set_collision_mask_value", 1, true)
		set_collision_mask_value(2,true)
		#velocity.x=0
		is_dodging=false

func throw():
	var throwable=projectile_scene.instantiate()
	get_tree().current_scene.add_child(throwable)
	
	var start_pos=right_throw_point.global_position if is_right else left_throw_point.global_position
	throwable.global_position= start_pos
	
	var dir_to_throw:= (get_global_mouse_position()-start_pos).normalized()
	throwable.launch(dir_to_throw,"throwable")
	have_throwable=false

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies") and is_dodging==false:
		if is_inside_tree():
			GameManager.kill_count=GameManager.start_kill
			get_tree().call_deferred("reload_current_scene")

func handle_camera_look_ahead(delta: float):
	var target_offset = camera_offset_value if is_right else -camera_offset_value
	camera_2d.offset.x = lerp(camera_2d.offset.x, target_offset, 5.0*delta)
