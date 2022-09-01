extends KinematicBody2D

enum States { MOVING, BLOCKING }

const DRAG_FACTOR := 15.0
const SPEED_MOVE := 400.0

var _state = States.MOVING
var _velocity := Vector2.ZERO
var _blocked := false

onready var _hurt_box := $HurtBox
onready var _block_box := $BlockBox
onready var _parry_timer := $ParryTimer

onready var _move_animation_player := $MoveAnimationPlayer
onready var _damage_animation_player := $DamageAnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("block"):
		_block_start()
	
	if event.is_action_released("block"):
		_block_end()


func _ready() -> void:
	_block_box.connect("area_entered", self, "take_block_hit")
	_parry_timer.connect("timeout", self, "_on_ParryTimer_timeout")


func _physics_process(delta: float) -> void:
	match _state:
		States.MOVING:
			var horizontal_input_direction := Input.get_axis("move_left", "move_right")
			var desired_velocity := horizontal_input_direction * SPEED_MOVE
			var steering = desired_velocity - _velocity.x
			_velocity.x += steering * DRAG_FACTOR * get_physics_process_delta_time()
		
		States.BLOCKING:
			pass
	
	move_and_collide(_velocity * delta)


func take_damage(damage: int) -> void:
	if not _blocked:
		_damage_animation_player.play("take_damage")


func take_block_hit(area: Area2D) -> void:
	if not _damage_animation_player.is_playing():
		_blocked = true
		_damage_animation_player.play("take_block_damage")


func _block_start() -> void:
	_state = States.BLOCKING
	_velocity.x = 0
	_move_animation_player.play("block")


func activate_blocking() -> void:
	_parry_timer.start()
	_block_box.set_deferred("monitoring", true)
	_block_box.set_deferred("monitorable", true)


func _on_ParryTimer_timeout() -> void:
	_block_box.set_deferred("monitorable", false)


func _block_end() -> void:
	_blocked = false
	_parry_timer.stop()
	
	_block_box.set_deferred("monitoring", false)
	_block_box.set_deferred("monitorable", false)
	
	_move_animation_player.play("idle")
	_state = States.MOVING
