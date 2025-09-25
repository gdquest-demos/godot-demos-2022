class_name Bullet2D extends Node2D

const SPEED := 1800.0

@export var lifetime := 3.0

var direction := Vector2.ZERO

@onready var _hit_area: Area2D = %HitArea2D


func _ready() -> void:
	_hit_area.body_entered.connect(_on_hit_area_body_entered)

	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

	top_level = true
	look_at(position + direction)


func _physics_process(delta: float) -> void:
	translate(direction * SPEED * delta)


func _on_hit_area_body_entered(_body: Node2D) -> void:
	queue_free()
