extends Node2D

export var speed := 1000.0
var direction := Vector2.ZERO

func _ready() -> void:
	set_as_toplevel(true)
	look_at(position + direction)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()
