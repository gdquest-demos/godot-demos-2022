extends Node2D

export var gravity := Vector2(0, 9.8)

onready var _label := $Label

var _velocity := Vector2.ZERO


func _ready() -> void:
	_velocity = Vector2(rand_range(-2, 2), -2)


func _process(delta: float) -> void:
	_velocity += gravity * delta
	global_position += _velocity
	

func set_damage(amount: float):
	_label.text = "-" + str(amount)
	$AnimationPlayer.play("show")

