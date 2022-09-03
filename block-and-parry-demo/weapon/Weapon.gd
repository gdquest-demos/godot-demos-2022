extends Position2D

onready var _collision := $HitBox/CollisionShape2D


func activate_collider() -> void:
	_collision.set_deferred("disabled", false)
	

func deactivate_collider() -> void:
	_collision.set_deferred("disabled", true)
