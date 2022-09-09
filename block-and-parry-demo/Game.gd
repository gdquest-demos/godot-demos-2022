extends Node2D

var _freezing := false

onready var _player := $Player
onready var _enemy := $Enemy
onready var _camera := $Camera2D

onready var _timer := $Timer


func _ready() -> void:
	_player.connect("blocked", self, "_on_Player_blocked")
	_player.connect("hit", self, "_on_Player_hit")
	_enemy.connect("stunned", self, "_on_Enemy_stunned")


func _shake_screen(max_distance := 10.0) -> void:
	var tween := create_tween()
	var half_distance := max_distance / 2.0
	for i in 10:
		var rand_offset := Vector2(
			rand_range(-half_distance, half_distance),
			rand_range(-half_distance, half_distance)
		)
		tween.tween_property(_camera, "offset", rand_offset, 0.04)
	tween.tween_property(_camera, "offset", Vector2.ZERO, 0.04)


func _slow_down_time(duration: float, time_scale: float) -> void:
	assert(time_scale > 0.0)
	if not _timer.is_stopped():
		return
	
	Engine.time_scale = time_scale
	_timer.start(duration * time_scale)
	yield(_timer, "timeout")
	Engine.time_scale = 1.0


func _on_Player_blocked() -> void:
	_slow_down_time(0.2, 0.1)
	_shake_screen(7.0)


func _on_Player_hit() -> void:
	_shake_screen(18.0)


func _on_Enemy_stunned() -> void:
	_slow_down_time(0.5, 0.04)

