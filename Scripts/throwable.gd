extends Area2D

var is_in_range:=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if is_in_range==true and Input.is_action_just_pressed("Interaction"):
		get_tree().set_group("Player","have_throwable",true)
		queue_free()


func _on_body_entered(_body: Node2D) -> void:
	get_tree().set_group("Interactions", "visible", true)
	is_in_range=true


func _on_body_exited(_body: Node2D) -> void:
	get_tree().set_group("Interactions", "visible", false)
	is_in_range=false
