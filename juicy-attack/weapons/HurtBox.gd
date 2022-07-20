extends Area2D

export var damage_min := 1
export var damage_max := 5


func get_damage() -> int:
	return damage_min + randi() % damage_max
