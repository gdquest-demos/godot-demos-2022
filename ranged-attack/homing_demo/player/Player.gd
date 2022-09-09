extends Node2D

const MissileScene := preload("../weapons/Missile.tscn")

onready var _shoot_position := $ShootPosition
onready var _travel_speed_slider := $"%TravelSpeedSlider"
onready var _turn_speed_slider := $"%TurnSpeedSlider"


func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		shoot()


func shoot() -> void:
	var missile := MissileScene.instance() as Missile
	missile.position = _shoot_position.global_position
	missile.drag_factor = _turn_speed_slider.value
	missile.max_speed = _travel_speed_slider.value
	add_child(missile)
