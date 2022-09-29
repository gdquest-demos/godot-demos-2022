extends Position2D

onready var _trail := $Sprite/Trail
onready var _collision := $HitBox/CollisionShape2D


func activate_collider() -> void:
	_trail.visible = true
	_collision.set_deferred("disabled", false)
	

func deactivate_collider() -> void:
	_trail.visible = false
	_collision.set_deferred("disabled", true)
