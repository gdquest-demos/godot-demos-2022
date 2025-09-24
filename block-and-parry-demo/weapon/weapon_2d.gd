extends Marker2D

@onready var _trail: Sprite2D = %TrailSprite2D
@onready var _collision: CollisionShape2D = %CollisionShape2D


func activate_collider() -> void:
	_trail.visible = true
	_collision.set_deferred("disabled", false)


func deactivate_collider() -> void:
	_trail.visible = false
	_collision.set_deferred("disabled", true)
