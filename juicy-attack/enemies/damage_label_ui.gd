extends Control

@export var gravity := Vector2(0, 980)

var _velocity := Vector2.ZERO

@onready var _label: Label = %Label


func _ready() -> void:
	_velocity = Vector2(randf_range(-200, 200), -300)


func _process(delta: float) -> void:
	_velocity += gravity * delta
	position += _velocity * delta


func set_damage(amount: int) -> void:
	_label.text = str(-absi(amount))
