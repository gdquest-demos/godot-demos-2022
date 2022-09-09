class_name Missile
extends Node2D

export var lifetime := 20.0

var travel_speed := 500.0
var turn_speed := 5.0

var start_direction := Vector2.ZERO
var target :Enemy

onready var timer := $Timer
onready var sprite := $Sprite

onready var hitbox := $HitBox
onready var impact_detector := $ImpactDetector
onready var enemy_detector := $EnemyDetector

onready var aim_line := $AimLine
onready var target_line := $TargetLine



func _ready():
	aim_line.set_as_toplevel(true)
	target_line.set_as_toplevel(true)
	
	set_as_toplevel(true)
	look_at(position + start_direction)
	timer.connect("timeout", self, "queue_free")
	timer.start(lifetime)
	impact_detector.connect("body_entered", self, "_on_impact")
	enemy_detector.connect("body_entered", self, "_on_enemy_detected")


func _physics_process(delta: float) -> void:
	move(delta)
	

func _on_impact(_body: Node) -> void:
	queue_free()
	
	
func _on_enemy_detected(enemy: Enemy):
	if target == null:
		target = enemy
		
		
func move(delta):
	if travel_speed == 0:
		return
		
	var current_velocity:Vector2 = global_position + global_transform.x * travel_speed * delta
	
	aim_line.set_point_position(0,global_position)
	aim_line.set_point_position(1,global_position + global_transform.x * 150)
	
	if target == null:
		position = current_velocity
		return

	var target_position:Vector2 = target.global_position	

	var desired_direction:Vector2 = (target_position - global_position).normalized()
	var desired_velocity:Vector2 = global_position + desired_direction * travel_speed * delta
	
	target_line.set_point_position(0,global_position)
	target_line.set_point_position(1,global_position + desired_direction * 150)
		
	var turn_velocity:Vector2 = (desired_velocity - current_velocity) * turn_speed * delta
	var new_velocity:Vector2 = current_velocity + turn_velocity
	
	var distance_to_target:float = global_position.distance_to(target_position)

	# Prevents overshooting the target
	if global_position.distance_to(new_velocity) > distance_to_target:
		new_velocity = target_position
	
	look_at(new_velocity)
	position = new_velocity
		
