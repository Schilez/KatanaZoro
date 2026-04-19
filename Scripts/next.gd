extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var can_interact := false
var next_level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if can_interact and Input.is_action_just_pressed("Interaction"):
		if is_inside_tree():
			GameManager.start_kill= GameManager.kill_count
			get_tree().change_scene_to_packed(next_level)

func awake(level: PackedScene):
	animated_sprite_2d.visible=true
	monitoring=true
	next_level=level


func _on_body_entered(_body: Node2D) -> void:
	get_tree().set_group("Interactions", "visible", true)
	can_interact=true


func _on_body_exited(_body: Node2D) -> void:
	get_tree().set_group("Interactions", "visible",false)
	can_interact=false
