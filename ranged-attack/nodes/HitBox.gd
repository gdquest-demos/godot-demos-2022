# Detected by HitBox
class_name HitBox, "HitBox.svg"
extends Area2D

export var damage := 10

onready var collision_shape := $CollisionShape2D


func _init() -> void:
	collision_mask = 4
	# This turns off collision mask bit 1 and turns on bit 2. It's the physics layer we reserve to hurtboxes in this demo.
	collision_layer = 2


func set_disabled(is_disabled: bool) -> void:
	collision_shape.set_deferred("disabled", is_disabled)
