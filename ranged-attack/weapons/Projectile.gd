class_name Projectile
extends Node2D

export var speed := 1000.0
export var lifetime := 3.0

var direction := Vector2.ZERO

onready var timer := $Timer
onready var hitbox := $HitBox
onready var sprite := $Sprite
onready var impact_detector := $ImpactDetector


func _ready():
	set_as_toplevel(true)
	look_at(position + direction)
	timer.connect("timeout", self, "queue_free")
	timer.start(lifetime)
	impact_detector.connect("body_entered", self, "_on_impact")


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_impact(_body: Node) -> void:
	queue_free()
