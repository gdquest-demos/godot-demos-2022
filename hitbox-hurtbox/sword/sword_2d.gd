extends Node2D

const DRAG_FACTOR := 15.0
const RUN_SPEED := 600.0

var _velocity := Vector2.ZERO

@onready var animation_player := %AnimationPlayer


func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var desired_velocity := input_direction * RUN_SPEED
	var steering = desired_velocity - _velocity
	_velocity += steering * DRAG_FACTOR * delta
	translate(_velocity * delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		animation_player.play("slash")
