extends Node2D

export var health_max := 100

var health := health_max

onready var animation_player := $AnimationPlayer


func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	animation_player.play("hit")
