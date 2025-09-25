extends CharacterBody2D

const DRAG_FACTOR := 15.0
const RUN_SPEED := 600.0


func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var desired_velocity := input_direction * RUN_SPEED
	var steering = (desired_velocity - velocity) * DRAG_FACTOR * delta
	velocity += steering
	move_and_slide()
