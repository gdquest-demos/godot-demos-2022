extends KinematicBody2D

enum States { MOVING, DODGING, TAKING_DAMAGE }

const DIRECTION_TO_FRAME := {
	Vector2.DOWN: 0,
	Vector2.DOWN + Vector2.RIGHT: 1,
	Vector2.RIGHT: 2,
	Vector2.UP + Vector2.RIGHT: 3,
	Vector2.UP: 4,
}

const DRAG_FACTOR := 15.0
const SPEED_MOVE := 400.0
const SPEED_DODGE := 1000.0

var _state = States.MOVING
# The character's movement speed in pixels per second.
var _velocity := Vector2.ZERO
# The starting value is the first direction the sprite is looking at.
var _look_direction := Vector2.RIGHT

onready var _godot_sprite := $Godot
onready var _hurt_box := $HurtBox
onready var _smoke_particles := $SmokeParticles
onready var _dodge_timer := $DodgeTimer

onready var _move_animation_player := $MoveAnimationPlayer
onready var _damage_animation_player := $DamageAnimationPlayer


func _ready() -> void:
	_dodge_timer.connect("timeout", self, "_dodge_end")


func _physics_process(delta: float) -> void:
	match _state:
		States.MOVING:
			# Update direction and animation.
			var input_direction := Input.get_vector(
				"move_left", "move_right", "move_up", "move_down"
			)
			input_direction = input_direction.limit_length(1.0)

			if input_direction:
				_move_animation_player.play("walk")
				_look_direction = input_direction
			else:
				_move_animation_player.play("idle")

			# Update velocity using the follow steering equation.
			var desired_velocity := input_direction * SPEED_MOVE
			var steering = desired_velocity - _velocity
			_velocity += steering * DRAG_FACTOR * get_physics_process_delta_time()

			# If pressing the dodge key, we start dodging.
			if Input.is_action_just_pressed("dodge"):
				_dodge_start()

			# This function changes where the character is looking. See our
			# video on top-down character movement to learn how to do this.
			_update_sprite_direction()

		# In the dodge state, the player can't change direction or speed, so
		# we don't need to do anything.
		# We still include the state to make it clear it's intentional.
		States.DODGING:
			pass

	move_and_slide(_velocity)


func take_damage(damage: int) -> void:
	_damage_animation_player.play("take_damage")


func _update_sprite_direction() -> void:
	var direction_key := _look_direction.round()
	direction_key.x = abs(direction_key.x)
	if direction_key in DIRECTION_TO_FRAME:
		_godot_sprite.frame = DIRECTION_TO_FRAME[direction_key]
		_godot_sprite.flip_h = sign(_look_direction.x) != 1


func _dodge_start() -> void:
	_state = States.DODGING

	# We deactivate the hurt box while dodging to make the character invincible.
	_hurt_box.set_deferred("monitoring", false)

	_move_animation_player.play("dodge")
	_smoke_particles.emitting = true

	# We set a constant velocity for the duration of the dodge. The duration is
	# controled by the dodge timer.
	_velocity = SPEED_DODGE * _look_direction
	_dodge_timer.start()


func _dodge_end() -> void:
	_hurt_box.set_deferred("monitoring", true)
	_smoke_particles.emitting = false
	_state = States.MOVING
