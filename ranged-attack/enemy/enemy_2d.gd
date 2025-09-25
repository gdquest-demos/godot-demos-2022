class_name Enemy2D extends Node2D

@onready var animation_player = %AnimationPlayer


func take_damage(_damage: int) -> void:
	animation_player.stop(true)
	animation_player.play("hit")
