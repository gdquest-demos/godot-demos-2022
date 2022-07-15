extends Area2D


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")


func _on_area_entered(area: Area2D) -> void:
	if owner.has_method("take_damage"):
		owner.take_damage(area.damage)
