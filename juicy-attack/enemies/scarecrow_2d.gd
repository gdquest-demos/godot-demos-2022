extends CharacterBody2D

signal hit

var _pushback_force := Vector2.ZERO

@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _hit_gpu_particles: GPUParticles2D = %HitGPUParticles2D
@onready var _damage_spawning_point: Marker2D = %DamageSpawningPoint2D


func take_damage(amount: int) -> void:
	_animation_player.play("hit")
	var label := preload("damage_label_ui.tscn").instantiate()
	label.global_position = _damage_spawning_point.global_position
	add_child(label)
	label.set_damage(amount)
	hit.emit()


func knock_back(source_position: Vector2) -> void:
	_hit_gpu_particles.rotation = get_angle_to(source_position) + PI
	_pushback_force = -global_position.direction_to(source_position) * 300.0


func _physics_process(delta: float) -> void:
	_pushback_force = lerp(_pushback_force, Vector2.ZERO, delta * 10.0)
	velocity = _pushback_force
	move_and_slide()
