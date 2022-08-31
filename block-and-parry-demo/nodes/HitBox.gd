# Detected by HitBox
class_name HitBox, "HitBox.svg"
extends Area2D

export var damage := 5


func _init() -> void:
	# This turns off collision mask bit 1 and turns on bit 2. It's the physics layer we reserve to hurtboxes in this demo.
	collision_layer = 2


func get_damage() -> int:
	return damage + randi() % 7 - 3
