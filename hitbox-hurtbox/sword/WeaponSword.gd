extends Node2D

onready var _animation_player := $AnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		_animation_player.play("slash")
