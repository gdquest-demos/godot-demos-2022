class_name Missile
extends Node2D

const LAUNCH_SPEED := 1800.0

export var lifetime := 20.0

var max_speed := 500.0
var drag_factor := 0.15 setget set_drag_factor

var _target: Enemy

var _current_velocity := Vector2.ZERO

onready var _sprite := $Sprite

onready var _hitbox := $HitBox
onready var _enemy_detector := $EnemyDetector

onready var _aim_line := $AimLine
onready var _target_line := $TargetLine


func _ready():
	set_as_toplevel(true)
	_aim_line.set_as_toplevel(true)
	_target_line.set_as_toplevel(true)

	_hitbox.connect("body_entered", self, "_on_HitBox_body_entered")
	# Detects a target to lock on within a large radius.
	_enemy_detector.connect("body_entered", self, "_on_EnemyDetector_body_entered")

	var timer := get_tree().create_timer(lifetime)
	timer.connect("timeout", self, "queue_free")
	
	_current_velocity = LAUNCH_SPEED * Vector2.RIGHT.rotated(rotation)

	
func _physics_process(delta: float) -> void:
	if not _target:
		return

	var direction := global_position.direction_to(_target.global_position)
	var desired_velocity := direction * max_speed
	_current_velocity += (desired_velocity - _current_velocity) * drag_factor

	position += _current_velocity * delta
	rotation = _current_velocity.angle()

	# Update the drawing of lines following the missile
	_aim_line.set_point_position(0, global_position)
	_aim_line.set_point_position(1, global_position + _current_velocity.normalized() * 150)
	_target_line.set_point_position(0, global_position)
	_target_line.set_point_position(1, global_position + direction * 150)


func set_drag_factor(new_value: float) -> void:
	drag_factor = clamp(new_value, 0.01, 1.0)


func _on_HitBox_body_entered(_body: Node) -> void:
	queue_free()


func _on_EnemyDetector_body_entered(enemy: Enemy):
	if enemy == null:
		return
	_target = enemy
