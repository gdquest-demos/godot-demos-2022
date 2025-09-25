extends Node2D

const Missile2DScene := preload("../weapons/missile_2d.tscn")

@onready var _shoot_marker: Marker2D = %ShootMarker2D
@onready var _travel_speed_h_slider: HSlider = %TravelSpeedHSlider
@onready var _drag_factor_h_slider: HSlider = %DragFactorHSlider


func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		_shoot()


func _shoot() -> void:
	var missile: Missile2D = Missile2DScene.instantiate()

	missile.drag_factor = _drag_factor_h_slider.value
	missile.max_speed = _travel_speed_h_slider.value

	missile.global_position = _shoot_marker.global_position
	missile.rotation = rotation

	add_child(missile)
