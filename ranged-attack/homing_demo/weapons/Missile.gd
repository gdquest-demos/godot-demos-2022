class_name Missile
extends Node2D

export var lifetime := 20.0

var max_speed := 500.0
var drag_factor := 0.15 setget set_drag_factor

var _target: Enemy

var _current_velocity := Vector2.ZERO

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
	_timer.connect("timeout", self, "queue_free")
	_timer.start(lifetime)
	_impact_detector.connect("body_entered", self, "_on_impact")
	_enemy_detector.connect("body_entered", self, "_on_enemy_detected")


func _physics_process(delta: float) -> void:
	if not _target:
		return

	var direction := global_position.direction_to(_target.global_position)
	var desired_velocity := direction * max_speed
	_current_velocity += (desired_velocity - _current_velocity) * drag_factor

	position += _current_velocity * delta
	rotation = _current_velocity.angle()

	# TODO: use _draw()?
	_aim_line.set_point_position(0, global_position)
	_aim_line.set_point_position(1, global_position + direction * 150)
	_target_line.set_point_position(0, global_position)
	_target_line.set_point_position(1, global_position + direction * 150)



func set_drag_factor(new_value: float) -> void:
	drag_factor = clamp(new_value, 0.01, 1.0)


func _on_impact(_body: Node) -> void:
	queue_free()


func _on_enemy_detected(enemy: Enemy):
	if _target == null:
		_target = enemy
