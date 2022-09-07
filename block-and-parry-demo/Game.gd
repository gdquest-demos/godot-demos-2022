extends Node2D

var _freezing := false

onready var _player := $Player
onready var _enemy := $Enemy
onready var _camera := $Camera2D
onready var _tween := $Tween


func _ready() -> void:
	_player.connect("blocked", self, "_on_Player_blocked")
	_player.connect("hit", self, "_on_Player_hit")
	_enemy.connect("stunned", self, "_on_Enemy_stunned")


func _shake_screen(strength: float, frequency: int, rate: float) -> void:
	for i in frequency:
		var rand_offset: Vector2 = Vector2.ZERO
		rand_offset.x = rand_range(-strength, strength)
		rand_offset.y = rand_range(-strength, strength)
		
		_tween.interpolate_property(_camera, "offset", _camera.offset, rand_offset, rate, Tween.TRANS_LINEAR, Tween.EASE_IN)
		_tween.start()

		yield(_tween, "tween_all_completed")
	
	_tween.interpolate_property(_camera, "offset", _camera.offset, Vector2.ZERO, rate, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_tween.start()
	

func _freeze_frame(duration: float, time_scale: float) -> void:
	if _freezing:
		return
	
	_freezing = true
	Engine.time_scale = time_scale
	yield(get_tree().create_timer(duration * time_scale), "timeout")
	
	_freezing = false
	Engine.time_scale = 1.0


func _on_Player_blocked() -> void:
	_freeze_frame(0.15, 0.1)
	_shake_screen(2, 5, 0.01)


func _on_Player_hit() -> void:
	_shake_screen(5, 12, 0.02)


func _on_Enemy_stunned() -> void:
	_freeze_frame(0.5, 0.04)

