extends Area2D

signal update_position

onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		_animation_player.play("Pickup")
	elif event.is_action_released("click"):
		_animation_player.play_backwards("Pickup")
	# ANCHOR: emit_signal
	if Input.is_action_pressed("click") and event is InputEventMouseMotion:
		position += event.relative
		emit_signal("update_position")
	# END: emit_signal
