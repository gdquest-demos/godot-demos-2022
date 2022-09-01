extends KinematicBody2D

enum States { CHECK, MOVE_CLOSER, MOVE_AWAY, ATTACK, STUNNED }

const DRAG_FACTOR := 15.0
const SPEED_MOVE := 400.0

export var player_min_distance := 100.0
export var player_max_distance := 120.0

export var player_path := NodePath()

var _state = States.CHECK
var _velocity := Vector2.ZERO
var _direction := Vector2.LEFT

onready var _player := get_node(player_path)

onready var _hit_box := $Weapon/HitBox
onready var _stun_timer := $StunTimer
onready var _animation_player := $AnimationPlayer


func _ready() -> void:
	_hit_box.connect("area_entered", self, "_on_HitBox_area_entered")
	_stun_timer.connect("timeout", self, "_on_StunTimer_timeout")
	_animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")


func _physics_process(delta: float) -> void:
	var player_distance := global_position.distance_to(_player.global_position)
	
	match _state:
		States.CHECK:
			if player_distance < player_min_distance:
				_direction = Vector2.RIGHT
				_state = States.MOVE_AWAY
			elif player_distance > player_max_distance:
				_direction = Vector2.LEFT
				_state = States.MOVE_CLOSER
			else:
				_state = States.ATTACK
		States.MOVE_CLOSER:
			_direction = Vector2.LEFT
			_update_velocity()
			if player_distance < player_min_distance:
				_state = States.ATTACK
		States.MOVE_AWAY:
			_direction = Vector2.RIGHT
			_update_velocity()
			if player_distance > player_min_distance:
				_state = States.ATTACK
		States.ATTACK:
			_velocity = Vector2.ZERO
			_animation_player.play("attack")
		States.STUNNED:
			_velocity = Vector2.ZERO
			_animation_player.play("stunned")
	
	move_and_collide(_velocity * delta)


func _update_velocity() -> void:
	var desired_velocity := _direction * SPEED_MOVE
	var steering = desired_velocity - _velocity
	_velocity += steering * DRAG_FACTOR * get_physics_process_delta_time()


func _set_stunned() -> void:
	_state = States.STUNNED
	_animation_player.play("stunned")
	_stun_timer.start()


func _on_StunTimer_timeout() -> void:
	_animation_player.play("RESET")
	_state = States.CHECK


func _on_HitBox_area_entered(area: Area2D) -> void:
	_set_stunned()


func _on_AnimationPlayer_animation_finished(animation_name: String) -> void:
	if animation_name == "attack":
		_state = States.CHECK
