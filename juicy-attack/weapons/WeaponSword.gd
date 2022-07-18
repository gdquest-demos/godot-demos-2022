extends Node2D

onready var _pivot := $Pivot
onready var _attack_sound := $AudioStreamPlayer
onready var animation_player := $AnimationPlayer


func use() -> void:
	animation_player.play("slash")
	_attack_sound.pitch_scale = rand_range(1.7, 2.6)


func _physics_process(_delta: float) -> void:
	var mouse_position := get_global_mouse_position()
	
	_pivot.look_at(mouse_position)
	_pivot.position.y = sin(OS.get_ticks_msec() * _delta * 0.25) * 10

	# Flip pivot to avoid upside down attacks
	if mouse_position.x - global_position.x < 0:
		_pivot.scale.y = -1
	else:
		_pivot.scale.y = 1
