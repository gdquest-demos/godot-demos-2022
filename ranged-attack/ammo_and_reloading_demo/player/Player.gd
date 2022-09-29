extends Node2D

const BulletScene := preload("../weapons/Bullet.tscn")
const AmmoVisualScene = preload("../AmmoVisual.tscn")

var max_ammo := 10 setget set_max_ammo
var reserve_ammo := 30 setget set_reserve_ammo

var _reload_time := 1.0 setget set_reload_time
var _current_ammo := max_ammo
var _fire_rate := 0.13 setget set_fire_rate

onready var _shoot_position := $ShootPosition
onready var _ammo_display := $"%AmmoDisplay"

onready var _reload_progress_display := $"%ReloadProgressDisplay"
onready var _reloading_progress_bar := $"%ReloadingProgressBar"
onready var _ammo_reserves_label := $"%AmmoReservesLabel"
onready var _reload_timer := $"ReloadTimer"
onready var _shoot_timer := $"ShootTimer"


func _ready() -> void:
	_reload_timer.connect("timeout", self, "refill_ammo")
	refill_ammo()


func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())

	if not _reload_timer.is_stopped():
		return

	if Input.is_action_pressed("left_click"):
		if _current_ammo > 0:
			shoot()
		else:
			reload()
	elif Input.is_action_just_pressed("right_click") and _current_ammo < max_ammo:
		reload()


func shoot() -> void:
	if not _shoot_timer.is_stopped():
		return

	_current_ammo -= 1

	var bullet := BulletScene.instance() as Bullet
	bullet.global_position = _shoot_position.global_position
	bullet.direction = global_position.direction_to(get_global_mouse_position())
	add_child(bullet)

	_ammo_display.get_child(0).queue_free()
	_shoot_timer.start(0.25 - _fire_rate)


func reload() -> void:
	if reserve_ammo <= 0:
		return
	
	_reload_timer.start(_reload_time)
	_reload_progress_display.show()

	var tween := create_tween()
	_reloading_progress_bar.value = 0.0
	tween.tween_property(_reloading_progress_bar, "value", 1.0, _reload_time)


func refill_ammo() -> void:
	var ammo_missing := max_ammo - _current_ammo
	
	if reserve_ammo >= ammo_missing:
		set_reserve_ammo(reserve_ammo - ammo_missing)
		_current_ammo = max_ammo
	else:
		_current_ammo += reserve_ammo
		set_reserve_ammo(0)
		
	_reload_progress_display.hide()
	for child in _ammo_display.get_children():
			child.queue_free()
	for i in _current_ammo:
		var instance = AmmoVisualScene.instance()
		_ammo_display.add_child(instance)


func set_max_ammo(value: int) -> void:
	max_ammo = value
	refill_ammo()
	
	
func set_reserve_ammo(value: int) -> void:
	reserve_ammo = value
	_ammo_reserves_label.text = str(reserve_ammo)


func set_reload_time(value: float) -> void:
	_reload_time = value
	
	
func set_fire_rate(value: float) -> void:
	_fire_rate = value
