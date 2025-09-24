extends Node2D

@onready var _player: CharacterBody2D = %Player2D
@onready var _enemy: CharacterBody2D = %Enemy2D
@onready var _camera: Camera2D = %Camera2D
@onready var _timer: Timer = %Timer


func _ready() -> void:
	_player.blocked.connect(_on_player_blocked)
	_player.hit.connect(_on_player_hit)
	_enemy.stunned.connect(_on_enemy_stunned)


func _shake_screen(max_distance := 10.0) -> void:
	var tween := create_tween()
	var half_distance := max_distance / 2.0
	for i in 10:
		var rand_offset := Vector2(
			randf_range(-half_distance, half_distance),
			randf_range(-half_distance, half_distance),
		)
		tween.tween_property(_camera, "offset", rand_offset, 0.04)
	tween.tween_property(_camera, "offset", Vector2.ZERO, 0.04)


func _slow_down_time(duration: float, time_scale: float) -> void:
	assert(time_scale > 0.0)
	if not _timer.is_stopped():
		return

	Engine.time_scale = time_scale
	_timer.start(duration * time_scale)
	await _timer.timeout
	Engine.time_scale = 1.0


func _on_player_blocked() -> void:
	_slow_down_time(0.2, 0.1)
	_shake_screen(7.0)


func _on_player_hit() -> void:
	_shake_screen(18.0)


func _on_enemy_stunned() -> void:
	_slow_down_time(0.5, 0.04)
