extends Node2D

@export var speed := 1000.0

var direction := Vector2.ZERO

@onready var _visible_on_screen_notifier: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D


func _ready() -> void:
	_visible_on_screen_notifier.screen_exited.connect(queue_free)
	top_level = true
	look_at(position + direction)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
