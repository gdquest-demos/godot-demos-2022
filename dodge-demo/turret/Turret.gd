extends StaticBody2D

const ProjectileScene := preload("res://projectile/Projectile.tscn")

export var player_path := NodePath()
onready var _player := get_node(player_path)

onready var _weapon := $Weapon
onready var _projectile_spawner := $Weapon/ProjectileSpawner

onready var _timer := $Timer


func _ready() -> void:
	_timer.connect("timeout", self, "_shoot")


func _physics_process(delta: float) -> void:
	_weapon.look_at(_player.global_position)


func _shoot() -> void:
	var projectile := ProjectileScene.instance()
	projectile.position = _projectile_spawner.global_position
	projectile.direction = _weapon.global_position.direction_to(_projectile_spawner.global_position)
	add_child(projectile)
