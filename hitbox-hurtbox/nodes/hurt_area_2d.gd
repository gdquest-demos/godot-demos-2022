# Allows its owner to detect hits and take damage
@icon("hurt_area_2d.svg")
class_name HurtArea2D extends Area2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	# The hurtbox should detect hits but not deal them. This variable does that.
	monitorable = false
	# This turns off collision layer bit 1 and turns on bit 2. It's the physics layer we reserve to hurtboxes in this demo.
	collision_mask = 2


func _on_area_entered(hit_area: HitArea2D) -> void:
	if owner.has_method("take_damage"):
		owner.take_damage(hit_area.damage)
