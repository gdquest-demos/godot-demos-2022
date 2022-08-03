extends Node2D

export var gravity := Vector2(0, 980)

var _velocity := Vector2.ZERO

onready var _label := $Label
onready var _animation_player := $AnimationPlayer


func _init() -> void:
	set_as_toplevel(true)


func _ready() -> void:
	_velocity = Vector2(rand_range(-200, 200), -300)


func _process(delta: float) -> void:
	_velocity += gravity * delta
	global_position += _velocity * delta
	

func set_damage(amount: int) -> void:
	if not _label:
		yield(self, "ready")
	_label.text = "-" + str(amount)
	_animation_player.play("show")
