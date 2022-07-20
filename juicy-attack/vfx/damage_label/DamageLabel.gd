extends Node2D

export var gravity := Vector2(0, 9.8)

var _velocity := Vector2.ZERO

onready var _label := $Label
onready var _animation_player := $AnimationPlayer


func _ready() -> void:
	_velocity = Vector2(rand_range(-2, 2), -2)


func _process(delta: float) -> void:
	_velocity += gravity * delta
	global_position += _velocity
	

func set_damage(amount: float) -> void:
	_label.text = "-" + str(amount)
	_animation_player.play("show")
