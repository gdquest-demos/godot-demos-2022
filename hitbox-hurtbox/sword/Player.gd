extends KinematicBody2D

const DRAG_FACTOR := 15.0
const RUN_SPEED := 600.0

var _velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
	var input_direction := Vector2.ZERO
	input_direction = Vector2(
				Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")
			)
	var desired_velocity := input_direction * RUN_SPEED
	var steering = desired_velocity - _velocity
	_velocity += steering * DRAG_FACTOR * delta
	_velocity = move_and_slide(_velocity)
