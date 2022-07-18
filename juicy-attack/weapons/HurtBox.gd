extends Area2D

export var damage := 10 setget set_damage, get_damage

func set_damage(amount: int):
	damage = amount


func get_damage():
	return 1 + randi() % 5
