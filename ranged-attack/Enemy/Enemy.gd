extends Node2D

onready var ap = $"%AnimationPlayer"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func take_damage(_damage):
	ap.stop(true)
	ap.play("Hit")
