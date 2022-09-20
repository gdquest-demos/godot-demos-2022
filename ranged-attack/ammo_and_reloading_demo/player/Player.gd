extends Node2D

const BulletScene := preload("../weapons/Bullet.tscn")
const AmmoVisualScene = preload("../AmmoVisual.tscn")

onready var _shoot_position := $ShootPosition
onready var _ammo_display := $"%AmmoDisplay"
onready var _max_ammo_spin_box := $"%MaxAmmoSpinBox"
onready var _reloading_progress_bar := $"%ReloadingProgressBar"
onready var _reload_timer := $"ReloadTimer"
onready var _reload_time_spin_box := $"%ReloadTimeSpinBox"
onready var _reload_progress_display := $"%ReloadProgressDisplay"
onready var _shoot_timer := $"ShootTimer"
onready var _fire_rate_slider := $"%FireRateSlider"

var reload_time :float
var max_ammo:int
var current_ammo:int

var is_reloading := false
var left_click_held := false
var shoot_ready := true

func _ready() -> void:
	max_ammo = _max_ammo_spin_box.value
	_max_ammo_spin_box.connect("value_changed", self, "_on_max_ammo_changed")
	
	reload_time = _reload_time_spin_box.value
	_reload_time_spin_box.connect("value_changed", self, "_on_reload_time_changed")
	
	_reload_timer.connect("timeout", self, "reload")
	_shoot_timer.connect("timeout", self, "_on_shoot_timer_timeout")
	
	reload()


func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if left_click_held:
		shoot()
	
	if is_reloading:
		_reloading_progress_bar.value = 1 - (_reload_timer.time_left/reload_time)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		left_click_held = true
		
	if event.is_action_released("left_click"):
		left_click_held = false
		
	if event.is_action_pressed("right_click"):
		start_reload()
		

func shoot() -> void:
	if current_ammo == 0:
		start_reload()
		return
		
	if !shoot_ready:
		return
			
	if is_reloading:
		cancel_reload()
		
	current_ammo -= 1
	
	var bullet := BulletScene.instance() as Bullet
	bullet.global_position = _shoot_position.global_position
	bullet.direction = global_position.direction_to(get_global_mouse_position())
	add_child(bullet)
	_ammo_display.get_child(0).queue_free()
	
	_shoot_timer.start(0.251 - _fire_rate_slider.value)
	shoot_ready = false	
	
	
func start_reload() -> void:
	if current_ammo == max_ammo:
		return
		
	if is_reloading:
		return
		
	_reload_timer.start(reload_time)
	is_reloading = true
	_reload_progress_display.show()
	
	
func cancel_reload() -> void:
	_reload_timer.stop()
	is_reloading = false
	_reload_progress_display.hide()
		

func reload() -> void:
	current_ammo = max_ammo
	is_reloading = false
	_reload_progress_display.hide()
	
	for child in _ammo_display.get_children():
		child.queue_free()
		
	for i in max_ammo:
		var ammo_display_instance = AmmoVisualScene.instance()
		_ammo_display.add_child(ammo_display_instance)


func _on_max_ammo_changed(value) -> void:
	max_ammo = value
	reload()
	
	
func _on_reload_time_changed(value) -> void:
	reload_time = value
	
	
func _on_shoot_timer_timeout():
	shoot_ready = true
