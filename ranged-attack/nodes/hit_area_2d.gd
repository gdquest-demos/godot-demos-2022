# Detected by HitBox
@icon("hit_area_2d.svg")
class_name HitArea2D extends Area2D

@export var damage := 10

@onready var collision_shape := $CollisionShape2D


func _ready() -> void:
	# This turns off collision mask bit 1 and turns on bit 2. It's the physics layer we reserve to hurtboxes in this demo.
	collision_layer = 2
	collision_mask = 4


func set_disabled(is_disabled: bool) -> void:
	collision_shape.set_deferred("disabled", is_disabled)
