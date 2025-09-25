extends Node2D

@onready var _player: Node2D = %Player2D
@onready var _max_ammo_spin_box: SpinBox = %MaxAmmoSpinBox
@onready var _reserve_ammo_spin_box: SpinBox = %ReserveAmmoSpinBox
@onready var _reload_time_spin_box: SpinBox = %ReloadTimeSpinBox
@onready var _fire_rate_h_slider: HSlider = %FireRateHSlider
@onready var _refill_reserves_button: Button = %RefillReservesButton


func _ready() -> void:
	_max_ammo_spin_box.value_changed.connect(_player.set_max_ammo)
	_reserve_ammo_spin_box.value_changed.connect(_player.set_reserve_ammo)
	_reload_time_spin_box.value_changed.connect(_player.set_reload_time)
	_fire_rate_h_slider.value_changed.connect(_player.set_fire_rate)
	_refill_reserves_button.pressed.connect(_on_refill_reserves_button_pressed)

	_player.max_ammo = _max_ammo_spin_box.value


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (not ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED


func _on_refill_reserves_button_pressed():
	_player.reserve_ammo = _reserve_ammo_spin_box.value
