extends Node2D

const MissileScene := preload("res://homing-demo/weapons/Missile.tscn")

onready var shoot_position := $ShootPosition
onready var travel_speed_slider := $"%TravelSpeedSlider"
onready var turn_speed_slider := $"%TurnSpeedSlider"

func _ready():
	pass

func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		shoot()


func shoot() -> void:
	var missile := MissileScene.instance() as Missile
	missile.position = shoot_position.global_position
	missile.start_direction = global_position.direction_to(get_global_mouse_position())
	missile.turn_speed = turn_speed_slider.value
	missile.travel_speed = travel_speed_slider.value
	add_child(missile)
