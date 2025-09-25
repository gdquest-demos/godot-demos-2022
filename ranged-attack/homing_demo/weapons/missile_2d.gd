class_name Missile2D extends Node2D

const LAUNCH_SPEED := 1800.0

@export var lifetime := 20.0

var max_speed := 500.0
var drag_factor := 0.15:
	set = set_drag_factor

var _target: Enemy2D = null

var _current_velocity := Vector2.ZERO

@onready var _hit_area: Area2D = %HitArea2D
@onready var _enemy_detector_area: Area2D = %EnemyDetectorArea2D

@onready var _aim_line: Line2D = %AimLine2D
@onready var _target_line: Line2D = %TargetLine2D
@onready var _change_line: Line2D = %ChangeLine2D


func _ready():
	_hit_area.body_entered.connect(_on_hit_area_body_entered)
	# Detects a target to lock on within a large radius.
	_enemy_detector_area.body_entered.connect(_on_enemy_detector_area_body_entered)

	top_level = true
	_aim_line.top_level = true
	_target_line.top_level = true
	_change_line.top_level = true

	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

	_current_velocity = max_speed * 5 * Vector2.RIGHT.rotated(rotation)


func _physics_process(delta: float) -> void:
	var direction := Vector2.RIGHT.rotated(rotation).normalized()

	if _target != null:
		direction = global_position.direction_to(_target.global_position)

	var desired_velocity := direction * max_speed
	var previous_velocity = _current_velocity
	var change = (desired_velocity - _current_velocity) * drag_factor

	_current_velocity += change

	translate(_current_velocity * delta)
	look_at(global_position + _current_velocity)

	# Update the drawing of lines following the missile
	_aim_line.set_point_position(0, global_position)
	_aim_line.set_point_position(1, global_position + _current_velocity.normalized() * 150)
	_target_line.set_point_position(0, global_position)
	_target_line.set_point_position(1, global_position + direction * 150)
	_change_line.set_point_position(0, global_position + previous_velocity.normalized() * 150)
	_change_line.set_point_position(1, global_position + _current_velocity.normalized() * 150)


func set_drag_factor(new_value: float) -> void:
	drag_factor = clamp(new_value, 0.01, 0.5)


func _on_hit_area_body_entered(_body: Node) -> void:
	queue_free()


func _on_enemy_detector_area_body_entered(enemy: Enemy2D) -> void:
	if _target != null or enemy == null:
		return

	_target = enemy
