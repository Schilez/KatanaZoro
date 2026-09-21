extends Control

@onready var score_label: Label = %ScoreLabel
@onready var margin_container: MarginContainer = $MarginContainer
@onready var writing: MarginContainer = $Writing
@onready var label: Label = $Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.interaction_on_signal.connect(_on_interaction_on_signal)
	Events.interaction_off_signal.connect(_on_interaction_off_signal)
	Events.have_throwable_signal.connect(_on_have_throwable_signal)
	Events.havent_throwable_signal.connect(_on_havent_throwable_signal)
	Events.the_end_signal.connect(_on_the_end_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	score_label.text= str(GameManager.score)

func _on_interaction_on_signal() -> void:
	writing.visible = true

func _on_interaction_off_signal() -> void:
	writing.visible = false

func _on_have_throwable_signal() -> void:
	margin_container.visible = true

func _on_havent_throwable_signal() -> void:
	margin_container.visible = false

func _on_the_end_signal () -> void:
	label.visible = true
