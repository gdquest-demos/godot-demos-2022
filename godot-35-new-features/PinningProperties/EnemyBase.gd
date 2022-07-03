extends KinematicBody2D

const Bullet := preload("Fireball.gd")
const BulletScene := preload("Fireball.tscn")

export(float, 0.5, 3.0, 0.1) var cooldown_time := 2.0
export(float, 0.5, 3.0, 0.1) var charge_time := 0.1
export(float, 0.5, 3.0, 0.1) var initial_attack_delay := 0.3
export(float, 0.0, 30.0, 1.0) var angle_randomness := 10.0
export(float, 100.0, 2000.0, 1.0) var max_bullet_range := 2000.0
export(float, 100.0, 3000.0, 1.0) var max_bullet_speed := 400.0
export(float, 0.01, 1.0) var rotation_speed := 0.2
export var follow_during_charge := false

var target: PhysicsBody2D

onready var cooldown_timer := get_node("%CoolDownTimer") as Timer
onready var charge_timer := get_node("%ChargeTimer") as Timer
onready var cannon_position_2D := get_node("%Position2D") as Position2D
onready var cannon := get_node("%Cannon") as Sprite
onready var detection_area := get_node("%DetectionArea") as Area2D
onready var exclamation_mark := get_node("%ExclamationMark") as Sprite

func _ready() -> void:
	detection_area.connect("body_entered", self, "_on_DetectionArea_body_entered")
	detection_area.connect("body_exited", self, "_on_DetectionArea_body_exited")
	charge_timer.connect("timeout", self, "_on_ChargeTimer_timeout")
	cooldown_timer.connect("timeout", self, "_on_CoolDownTimer_timeout")
	exclamation_mark.scale = Vector2.ZERO
	yield(get_tree().create_timer(randf()), "timeout")
	$AnimationPlayer.play("float")

func _physics_process(_delta: float) -> void:
	if not target:
		return
	if follow_during_charge:
		_rotate_to_target()
	if not cooldown_timer.is_stopped():
		return
	if not charge_timer.is_stopped():
		attack()


func attack() -> void:
	var bullet: Bullet = BulletScene.instance()
	bullet.transform = cannon_position_2D.global_transform
	bullet.max_range = max_bullet_range
	bullet.speed = max_bullet_speed
	var angle := deg2rad(angle_randomness)
	bullet.rotation += randf() * angle - angle / 2.0
	add_child(bullet)


func _on_ChargeTimer_timeout() -> void:
	cooldown_timer.start(cooldown_time)


func _on_CoolDownTimer_timeout() -> void:
	_rotate_to_target()
	charge_timer.start(charge_time)


func _rotate_to_target() -> void:
	if not target:
		return
	var goal := get_angle_to(target.global_position)
	cannon.rotation = lerp_angle(cannon.rotation, goal, rotation_speed)


func _on_DetectionArea_body_entered(body: PhysicsBody2D) -> void:
	target = body
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(exclamation_mark, "scale", Vector2.ONE, 1)
	cooldown_timer.start(initial_attack_delay)

func _on_DetectionArea_body_exited(_body: PhysicsBody2D) -> void:
	target = null
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
	tween.tween_property(exclamation_mark, "scale", Vector2.ZERO, 0.3)
