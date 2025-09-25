extends StaticBody2D

const ProjectileScene := preload("res://projectile/projectile_2d.tscn")

@onready var _player: CharacterBody2D = %Player2D
@onready var _weapon: Node2D = %Weapon2D
@onready var _projectile_spawner: Marker2D = %ProjectileSpawner2D
@onready var _timer: Timer = %Timer


func _ready() -> void:
	_timer.timeout.connect(_shoot)


func _physics_process(_delta: float) -> void:
	_weapon.look_at(_player.global_position)


func _shoot() -> void:
	var projectile := ProjectileScene.instantiate()
	projectile.position = _projectile_spawner.global_position
	projectile.direction = _weapon.global_position.direction_to(_projectile_spawner.global_position)
	add_child(projectile)
