extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var can_interact := false
var is_all_dead := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if not is_all_dead:
		if get_tree().get_nodes_in_group("Enemies").size()==0:
			awake()
	
	if can_interact and Input.is_action_just_pressed("Interaction"):
		if is_inside_tree():
			GameManager.starting_score= GameManager.score
			GameManager.next_level()

func awake():
	animated_sprite_2d.visible=true
	monitoring=true


func _on_body_entered(_body: Node2D) -> void:
	Events.interaction_on_signal.emit()
	can_interact=true


func _on_body_exited(_body: Node2D) -> void:
	Events.interaction_off_signal.emit()
	can_interact=false
