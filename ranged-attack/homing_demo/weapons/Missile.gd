class_name Missile
extends Node2D

export var lifetime := 20.0

var travel_speed := 500.0
var turn_speed := 5.0

var start_direction := Vector2.ZERO
var target: Enemy

onready var _timer := $Timer
onready var _sprite := $Sprite

onready var _hitbox := $HitBox
onready var _impact_detector := $ImpactDetector
onready var _enemy_detector := $EnemyDetector

onready var _aim_line := $AimLine
onready var _target_line := $TargetLine


func _ready():
	_aim_line.set_as_toplevel(true)
	_target_line.set_as_toplevel(true)

	set_as_toplevel(true)
	look_at(position + start_direction)
	_timer.connect("timeout", self, "queue_free")
	_timer.start(lifetime)
	_impact_detector.connect("body_entered", self, "_on_impact")
	_enemy_detector.connect("body_entered", self, "_on_enemy_detected")


func _physics_process(delta: float) -> void:
	var current_velocity := global_position + global_transform.x * travel_speed * delta

	_aim_line.set_point_position(0, global_position)
	_aim_line.set_point_position(1, global_position + global_transform.x * 150)

	if target == null:
		position = current_velocity
		return

	var target_position := target.global_position

	var desired_direction := (target_position - global_position).normalized()
	var desired_velocity := global_position + desired_direction * travel_speed * delta

	_target_line.set_point_position(0, global_position)
	_target_line.set_point_position(1, global_position + desired_direction * 150)

	var turn_velocity := (desired_velocity - current_velocity) * turn_speed * delta
	var new_velocity := current_velocity + turn_velocity

	var distance_to_target: float = global_position.distance_to(target_position)

	# Prevents overshooting the target
	if global_position.distance_to(new_velocity) > distance_to_target:
		new_velocity = target_position

	look_at(new_velocity)
	position = new_velocity


func _on_impact(_body: Node) -> void:
	queue_free()


func _on_enemy_detected(enemy: Enemy):
	if target == null:
		target = enemy
