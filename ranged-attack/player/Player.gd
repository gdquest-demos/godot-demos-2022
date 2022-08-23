extends Node2D

const FireballScene := preload("res://weapons/Fireball.tscn")
const ArrowScene := preload("res://weapons/Arrow.tscn")

onready var shoot_position = $ShootPosition


func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		shoot(FireballScene)
	elif event.is_action_pressed("right_click"):
		shoot(ArrowScene)


func shoot(projectile: PackedScene) -> void:
	var bullet := projectile.instance()
	bullet.position = shoot_position.global_position
	bullet.direction = global_position.direction_to(get_global_mouse_position())
	add_child(bullet)
