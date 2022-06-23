extends KinematicBody2D

const DRAG_FACTOR := 0.15
const DIRECTION_TO_FRAME := {
	Vector2.DOWN: 0,
	Vector2.DOWN + Vector2.RIGHT: 1,
	Vector2.RIGHT: 2,
	Vector2.UP + Vector2.RIGHT: 3,
	Vector2.UP: 4,
}

var stats: Character setget set_stats
var velocity := Vector2.ZERO

onready var sprite := $Godot
onready var smoke_particles := $SmokeParticles
onready var camera := $Camera2D


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var desired_velocity := stats.run_speed * direction
	var steering := desired_velocity - velocity
	velocity += steering * DRAG_FACTOR
	velocity = move_and_slide(velocity, Vector2.ZERO)

	var direction_key := direction.round()
	direction_key.x = abs(direction_key.x)
	if direction_key in DIRECTION_TO_FRAME:
		sprite.frame = DIRECTION_TO_FRAME[direction_key]
		sprite.flip_h = sign(direction.x) == -1

	smoke_particles.emitting = velocity.length() > stats.run_speed / 2.0


func set_stats(new_stats: Character) -> void:
	stats = new_stats
	set_physics_process(stats != null)


func toggle_camera_offset(is_offset: bool) -> void:
	camera.position.x = 424.0 if is_offset else 0.0
