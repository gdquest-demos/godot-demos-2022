class_name Bullet
extends Node2D

export var damage := 3.0
export var speed := 1000.0
export var lifetime := 3.0

var direction := Vector2.ZERO

onready var timer := $Timer


func _ready():
	set_as_toplevel(true)
	look_at(position + direction)
	timer.connect("timeout", self, "queue_free")
	timer.start(lifetime)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta

