extends Node2D


onready var _animation_player := $AnimationPlayer


func use() -> void:
	_animation_player.play("slash")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		use()
