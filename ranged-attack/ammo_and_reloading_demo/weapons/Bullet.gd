class_name Bullet
extends Node2D

const SPEED := 1800.0

export var lifetime := 3.0

var direction := Vector2.ZERO

onready var _sprite := $Sprite
onready var _hitbox := $HitBox


func _ready():
	set_as_toplevel(true)
	look_at(position + direction)
	_hitbox.connect("body_entered", self, "_on_HitBox_body_entered")

	var timer := get_tree().create_timer(lifetime)
	timer.connect("timeout", self, "queue_free")
	

	
func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta


func _on_HitBox_body_entered(_body: Node) -> void:
	queue_free()
