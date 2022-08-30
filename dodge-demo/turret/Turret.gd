extends StaticBody2D

const ProjectileScene := preload("res://projectile/Projectile.tscn")

export var player_path := NodePath()
onready var player := get_node(player_path)

onready var weapon := $Weapon
onready var projectile_spawner := $Weapon/ProjectileSpawner


func _physics_process(delta: float) -> void:
	weapon.look_at(player.global_position)


func shoot() -> void:
	var projectile := ProjectileScene.instance()
	projectile.position = projectile_spawner.global_position
	projectile.direction = weapon.global_position.direction_to(projectile_spawner.global_position)
	add_child(projectile)


func _on_Timer_timeout() -> void:
	shoot()
