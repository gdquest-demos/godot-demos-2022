class_name Enemy
extends Node2D

onready var animation_player = $AnimationPlayer


func take_damage(_damage: int) -> void:
	animation_player.stop(true)
	animation_player.play("Hit")
