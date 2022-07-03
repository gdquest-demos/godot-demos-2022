class_name Player
extends KinematicBody2D

export var speed := 1000.0
export var drag := 4.0

var _velocity := Vector2.ZERO

onready var _weapon := get_node_or_null("Weapon")

onready var _sprite := $Sprite
onready var _animation_player := $AnimationPlayer

onready var _flame_main := $Sprite/FlameMain
onready var _flame_left := $Sprite/FlameLeft
onready var _flame_right := $Sprite/FlameRight


func _physics_process(_delta: float) -> void:
	var direction := Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")).normalized()

	var desired_velocity := direction * speed
	var steering := desired_velocity - _velocity
	_velocity += steering / drag
	_velocity = _velocity.clamped(speed)

	_velocity = move_and_slide(_velocity, Vector2.UP, false, 4, PI / 4, false)

	_sprite.rotation = _velocity.angle() + PI / 2
	if _weapon:
		_weapon.rotation = _sprite.rotation

	# Updating flames
	var speed_rate := _velocity.length() / speed

	_flame_main.scale = Vector2.ONE * speed_rate
	_flame_left.scale = Vector2.ONE * speed_rate * 0.35
	_flame_right.scale = Vector2.ONE * speed_rate * 0.35


# This method is triggered when the player hits the enemy's area
# The enemy triggers it from inside their callback (see `res://Screens/Enemies/Enemy.gd`)
func take_damage() -> void:
	start_blink(false)


func start_blink(loop := false) -> void:
	_animation_player.get_animation("blink").set_loop(loop)
	_animation_player.play("blink")


func stop_blink():
	_animation_player.stop()
	_animation_player.seek(0, true)


func change_weapon(new_weapon: Node2D) -> void:
	if _weapon:
		_weapon.queue_free()
	_weapon = new_weapon
	add_child(_weapon)
