extends CharacterBody2D

signal stunned

enum States { CHECK, MOVE_CLOSER, MOVE_AWAY, ATTACK, STUNNED }

const DRAG_FACTOR := 15.0
const SPEED_MOVE := 400.0

@export var player_min_distance := 100.0
@export var player_max_distance := 120.0

@export var player: CharacterBody2D = null
@export var weapon: Node2D = null

var _state = States.CHECK
var _velocity := Vector2.ZERO
var _direction := Vector2.LEFT

@onready var _skin: Node2D = %CharacterSkin2D
@onready var _hit_area: Area2D = weapon.get_node("HitArea2D")
@onready var _stun_timer: Timer = %StunTimer
@onready var _damage_animation_player: AnimationPlayer = %DamageAnimationPlayer


func _ready() -> void:
	_hit_area.area_entered.connect(_on_hit_area_area_entered)
	_stun_timer.timeout.connect(_on_stun_timer_timeout)

	_skin.attack_damage_started.connect(weapon.activate_collider)
	_skin.attack_damage_ended.connect(weapon.deactivate_collider)
	_skin.attack_finished.connect(_on_skin_attack_finished)


func _physics_process(delta: float) -> void:
	var player_distance := global_position.distance_to(player.global_position)

	match _state:
		States.CHECK:
			weapon.deactivate_collider()
			if player_distance < player_min_distance:
				_direction = Vector2.RIGHT
				_state = States.MOVE_AWAY
			elif player_distance > player_max_distance:
				_direction = Vector2.LEFT
				_state = States.MOVE_CLOSER
			else:
				_state = States.ATTACK
		States.MOVE_CLOSER:
			_skin.play("run")
			_direction = Vector2.LEFT
			_update_velocity()
			if player_distance < player_min_distance:
				_state = States.ATTACK
		States.MOVE_AWAY:
			_skin.play("run", -1)
			_direction = Vector2.RIGHT
			_update_velocity()
			if player_distance > player_min_distance:
				_state = States.ATTACK
		States.ATTACK:
			_velocity = Vector2.ZERO
			_skin.play("attack")
		States.STUNNED:
			_velocity = Vector2.ZERO

	move_and_collide(_velocity * delta)


func _update_velocity() -> void:
	var desired_velocity := _direction * SPEED_MOVE
	var steering = desired_velocity - _velocity
	_velocity += steering * DRAG_FACTOR * get_physics_process_delta_time()


func _set_stunned() -> void:
	weapon.deactivate_collider()

	_state = States.STUNNED
	_skin.play("stun")
	_stun_timer.start()

	_damage_animation_player.play("stun")
	stunned.emit()


func _on_stun_timer_timeout() -> void:
	_skin.play("idle")
	_state = States.CHECK


func _on_hit_area_area_entered(_area: Area2D) -> void:
	_set_stunned()


func _on_skin_attack_finished() -> void:
	_state = States.CHECK
