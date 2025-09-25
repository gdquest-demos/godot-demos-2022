extends Node2D

@onready var _pivot: Marker2D = %Pivot2D
@onready var _attack_sound := %AudioStreamPlayer
@onready var _animation_player := %AnimationPlayer


func _physics_process(delta: float) -> void:
	var mouse_position := get_global_mouse_position()

	_pivot.look_at(mouse_position)
	_pivot.position.y = sin(Time.get_ticks_msec() * delta * 0.20) * 10

	# Flip pivot to avoid upside down attacks
	_pivot.scale.y = sign(mouse_position.x - global_position.x)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		_attack()


func _attack() -> void:
	_attack_sound.pitch_scale = randf_range(1.7, 2.6)
	_animation_player.play("slash")
