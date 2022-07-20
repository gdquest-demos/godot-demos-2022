# Allows its owner to detect hits and take damage
class_name HitBox
extends Area2D


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")


func _on_area_entered(hurt_box: HurtBox) -> void:
	if owner.has_method("take_damage"):
		owner.take_damage(hurt_box.damage)
