extends KinematicBody2D

enum States { MOVING, DODGING, TAKING_DAMAGE }
var state = States.MOVING

const DRAG_FACTOR := 15.0
const MOVE_SPEED := 400.0
const DODGE_SPEED := 1000.0

var _velocity := Vector2.ZERO
var _last_direction := Vector2.RIGHT # Assign the first direction the sprite is looking at

onready var hurt_box := $HurtBox
onready var dodge_timer := $DodgeTimer

onready var move_animation_player := $MoveAnimationPlayer
onready var damage_animation_player := $DamageAnimationPlayer

func _physics_process(delta: float) -> void:
	var input_direction := Vector2.ZERO
	input_direction = Vector2(
			Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")
		).limit_length(1)
	
	match state:
		States.MOVING:
			move(input_direction, delta)
		States.DODGING:
			dodge(_last_direction, delta)
		
	move_and_slide(_velocity)

func move(direction: Vector2, delta: float) -> void:
	calculate_velocity(direction, MOVE_SPEED, delta)
	move_animation_player.play("walk") if direction else move_animation_player.play("idle")
	if direction: _last_direction = direction
	if Input.is_action_just_pressed("dodge"):
		hurt_box.set_deferred("monitoring", false)
		move_animation_player.play("dodge")
		state = States.DODGING

func dodge(direction: Vector2, delta: float) -> void:
	calculate_velocity(direction, DODGE_SPEED, delta)
	if dodge_timer.time_left == 0: dodge_timer.start()

func take_damage(damage: int) -> void:
	if damage_animation_player.is_playing(): return
	damage_animation_player.play("take_damage")

func calculate_velocity(direction: Vector2, speed: float, delta: float) -> void:
	var desired_velocity := direction * speed
	var steering = desired_velocity - _velocity
	_velocity += steering * DRAG_FACTOR * delta

func _on_DodgeTimer_timeout() -> void:
	hurt_box.set_deferred("monitoring", true)
	state = States.MOVING
