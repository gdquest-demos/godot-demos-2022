extends KinematicBody2D

enum States { MOVING, DODGING, TAKING_DAMAGE }
var state = States.MOVING

const DIRECTION_TO_FRAME := {
	Vector2.DOWN: 0,
	Vector2.DOWN + Vector2.RIGHT: 1,
	Vector2.RIGHT: 2,
	Vector2.UP + Vector2.RIGHT: 3,
	Vector2.UP: 4,
}

const DRAG_FACTOR := 15.0
const MOVE_SPEED := 400.0
const DODGE_SPEED := 1000.0

var _velocity := Vector2.ZERO
var _last_direction := Vector2.RIGHT # Assign the first direction the sprite is looking at

onready var godot_sprite := $Godot
onready var hurt_box := $HurtBox
onready var smoke_particles := $SmokeParticles
onready var dodge_timer := $DodgeTimer

onready var move_animation_player := $MoveAnimationPlayer
onready var damage_animation_player := $DamageAnimationPlayer

func _physics_process(delta: float) -> void:
	var input_direction := Vector2.ZERO
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").limit_length(1)
	
	match state:
		States.MOVING:
			move(input_direction, delta)
		States.DODGING:
			dodge(_last_direction, delta)
		
	move_and_slide(_velocity)

func move(direction: Vector2, delta: float) -> void:
	calculate_velocity(direction, MOVE_SPEED, delta)
	set_sprite_direction(direction)
	move_animation_player.play("walk") if direction else move_animation_player.play("idle")
	if direction: _last_direction = direction
	if Input.is_action_just_pressed("dodge"):
		hurt_box.set_deferred("monitoring", false)
		move_animation_player.play("dodge")
		smoke_particles.emitting = true
		state = States.DODGING

func dodge(direction: Vector2, delta: float) -> void:
	calculate_velocity(direction, DODGE_SPEED, delta)
	if dodge_timer.time_left == 0: dodge_timer.start()

func take_damage(damage: int) -> void:
	if not damage_animation_player.is_playing():
		damage_animation_player.play("take_damage")

func calculate_velocity(direction: Vector2, speed: float, delta: float) -> void:
	var desired_velocity := direction * speed
	var steering = desired_velocity - _velocity
	_velocity += steering * DRAG_FACTOR * delta

func set_sprite_direction(direction: Vector2) -> void:
	var direction_key := direction.round()
	direction_key.x = abs(direction_key.x)
	if direction_key in DIRECTION_TO_FRAME:
		godot_sprite.frame = DIRECTION_TO_FRAME[direction_key]
		godot_sprite.flip_h = sign(direction.x) != 1
		
func _on_DodgeTimer_timeout() -> void:
	hurt_box.set_deferred("monitoring", true)
	smoke_particles.emitting = false
	state = States.MOVING
