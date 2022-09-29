extends Node2D


onready var _max_ammo_spin_box := $"%MaxAmmoSpinBox"
onready var _reserve_ammo_spin_box := $"%ReserveAmmoSpinBox"
onready var _reload_time_spin_box := $"%ReloadTimeSpinBox"
onready var _fire_rate_slider := $"%FireRateSlider"
onready var player = $Player

func _ready() -> void:
	_max_ammo_spin_box.connect("value_changed", player, "set_max_ammo")
	_reserve_ammo_spin_box.connect("value_changed", player, "set_reserve_ammo")
	_reload_time_spin_box.connect("value_changed", player, "set_reload_time")
	_fire_rate_slider.connect("value_changed", player, "set_fire_rate")
	
	player.set_max_ammo(_max_ammo_spin_box.value)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen


func _on_RefillReservesButton_pressed():
	player.reserve_ammo = _reserve_ammo_spin_box.value
