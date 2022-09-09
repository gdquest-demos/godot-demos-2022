extends Node2D

const MissileScene := preload("res://homing-demo/weapons/Missile.tscn")

onready var shoot_position = $ShootPosition


func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		shoot(MissileScene)


func shoot(projectile: PackedScene) -> void:
	var bullet := projectile.instance()
	bullet.position = shoot_position.global_position
	bullet.direction = global_position.direction_to(get_global_mouse_position())
	add_child(bullet)
