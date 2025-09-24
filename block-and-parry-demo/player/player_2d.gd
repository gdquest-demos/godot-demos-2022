extends CharacterBody2D

signal hit
signal blocked

enum States { MOVING, BLOCKING }

const DRAG_FACTOR := 15.0
const SPEED_MOVE := 400.0

var _state = States.MOVING
var _velocity := Vector2.ZERO
var _blocked := false

@onready var _block_area: Area2D = %BlockArea2D
@onready var _parry_timer: Timer = %ParryTimer

@onready var _block_gpu_particles: GPUParticles2D = %BlockGPUParticles2D
@onready var _hit_gpu_particle: GPUParticles2D = %HitGPUParticles2D

@onready var _skin: Node2D = %CharacterSkin2D
@onready var _damage_animation_player: AnimationPlayer = %DamageAnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("block"):
		_block_start()

	if event.is_action_released("block"):
		_block_end()


func _ready() -> void:
	_block_area.area_entered.connect(take_block_hit)
	_parry_timer.timeout.connect(_on_parry_timer_timeout)
	_skin.blocking_started.connect(activate_blocking)


func _physics_process(delta: float) -> void:
	match _state:
		States.MOVING:
			var horizontal_input_direction := Input.get_axis("move_left", "move_right")
			var desired_velocity := horizontal_input_direction * SPEED_MOVE
			var steering = desired_velocity - _velocity.x
			_velocity.x += steering * DRAG_FACTOR * get_physics_process_delta_time()

			if horizontal_input_direction:
				_skin.play("run", sign(horizontal_input_direction))
			else:
				_skin.play("idle")
		States.BLOCKING:
			pass

	move_and_collide(_velocity * delta)


func take_damage(_damage: int) -> void:
	if not _blocked:
		_damage_animation_player.play("take_damage")
		_hit_gpu_particle.emitting = true
		hit.emit()


func take_block_hit(_area: Area2D) -> void:
	if not _damage_animation_player.is_playing():
		_blocked = true
		_damage_animation_player.play("take_block_damage")
		_block_gpu_particles.emitting = true
		blocked.emit()


func _block_start() -> void:
	_state = States.BLOCKING
	_velocity.x = 0
	_skin.play("block")


func activate_blocking() -> void:
	_parry_timer.start()
	_block_area.set_deferred("monitoring", true)
	_block_area.set_deferred("monitorable", true)


func _on_parry_timer_timeout() -> void:
	_block_area.set_deferred("monitorable", false)


func _block_end() -> void:
	_blocked = false
	_parry_timer.stop()

	_block_area.set_deferred("monitoring", false)
	_block_area.set_deferred("monitorable", false)

	_skin.play("idle")
	_state = States.MOVING
