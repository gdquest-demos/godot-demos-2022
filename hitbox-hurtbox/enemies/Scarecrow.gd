extends Node2D

export var health_max := 100
var health := health_max

onready var animation_player := $AnimationPlayer


func take_damage(amount: int) -> void:
	health -= amount
	
	if health < 0:
		health = 0
	
	animation_player.play("hit")
