extends KinematicBody2D

export var health_max := 100

var health := health_max
var _pushback_force := Vector2.ZERO
onready var animation_player := $AnimationPlayer
onready var _hit_particles := $HitParticles


func take_damage(amount: int, source_position: Vector2) -> void:
	health -= amount

	if health < 0:
		health = 0

	animation_player.play("hit")
	_hit_particles.rotation = get_angle_to(source_position) + PI
	_pushback_force = -global_position.direction_to(source_position) * 300


func _physics_process(delta: float) -> void:
	_pushback_force = lerp(_pushback_force, Vector2.ZERO, delta * 10)
	move_and_slide(_pushback_force)
