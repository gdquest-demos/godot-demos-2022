extends Node2D

onready var animation_player := $AnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		animation_player.play("slash")
