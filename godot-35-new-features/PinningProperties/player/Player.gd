extends KinematicBody2D

export var max_health := 5
export var speed := 460.0
export var drag_factor := 5.0
var velocity := Vector2.ZERO

func _physics_process(_delta: float) -> void:
	var move_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	var desired_velocity := speed * move_direction
	var steering := desired_velocity - velocity
	velocity += steering / drag_factor
	velocity = move_and_slide(velocity, Vector2.ZERO)

func take_damage(_damage: float) -> void:
	pass
