extends Node2D

onready var _pivot := $Pivot
onready var _attack_sound := $AudioStreamPlayer
onready var _animation_player := $AnimationPlayer
onready var _shadow_circle := $ShadowCircle


func use() -> void:
	_attack_sound.pitch_scale = rand_range(1.7, 2.6)
	_animation_player.play("slash")


func _physics_process(delta: float) -> void:
	var mouse_position := get_global_mouse_position()

	_pivot.look_at(mouse_position)
	_pivot.position.y = sin(OS.get_ticks_msec() * delta * 0.20) * 10

	# Flip pivot to avoid upside down attacks
	if mouse_position.x - global_position.x < 0:
		_pivot.scale.y = -1
	else:
		_pivot.scale.y = 1

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		use()
