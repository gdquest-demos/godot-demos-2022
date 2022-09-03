extends KinematicBody2D

enum States { CHECK, MOVE_CLOSER, MOVE_AWAY, ATTACK, STUNNED }

const DRAG_FACTOR := 15.0
const SPEED_MOVE := 400.0

export var player_min_distance := 100.0
export var player_max_distance := 120.0

export var player_path := NodePath()
export var weapon_path := NodePath()

var _state = States.CHECK
var _velocity := Vector2.ZERO
var _direction := Vector2.LEFT

onready var _player := get_node(player_path)
onready var _weapon := get_node(weapon_path)

onready var _hit_box := _weapon.get_node("HitBox")
onready var _stun_timer := $StunTimer
onready var _skin := $Skin


func _ready() -> void:
	_hit_box.connect("area_entered", self, "_on_HitBox_area_entered")
	_stun_timer.connect("timeout", self, "_on_StunTimer_timeout")
	
	_skin.connect("attack_damage_started", _weapon, "activate_collider")
	_skin.connect("attack_damage_ended", _weapon, "deactivate_collider")
	_skin.connect("attack_finished", self, "_on_Skin_attack_finished")


func _physics_process(delta: float) -> void:
	var player_distance := global_position.distance_to(_player.global_position)
	
	match _state:
		States.CHECK:
			_weapon.deactivate_collider()
			
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
	_weapon.deactivate_collider()
	
	_state = States.STUNNED
	_skin.play("stun")
	_stun_timer.start()


func _on_StunTimer_timeout() -> void:
	_skin.play("idle")
	_state = States.CHECK


func _on_HitBox_area_entered(area: Area2D) -> void:
	_set_stunned()


func _on_Skin_attack_finished() -> void:
	_state = States.CHECK
