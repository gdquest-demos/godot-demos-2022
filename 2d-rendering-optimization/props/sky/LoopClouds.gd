extends Node2D

@export var speed := 0.1

@onready var _animation_player: AnimationPlayer = %AnimationPlayer

func _ready():
	_animation_player.speed_scale = speed
