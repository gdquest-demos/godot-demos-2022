extends KinematicBody2D

enum States { MOVE, LIGHT_ATTACK, HEAVY_ATTACK }

const DRAG_FACTOR := 15.0
const SPEED_MOVE := 400.0
const SPEED_ATTACK := 1000.0

var accept_next_attack := true setget set_accept_next_attack

var _state = States.MOVE
var _direction := Vector2.ZERO
var _velocity := Vector2.ZERO

var _previous_light_combo := "light_combo_3"
var _previous_heavy_combo := "heavy_combo_2"

onready var _skin := $Skin
onready var _animation_player := $AnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("light_attack") and accept_next_attack:
		_previous_heavy_combo = "heavy_combo_2"
		
		_state = States.LIGHT_ATTACK
		accept_next_attack = false
		
		_animation_player.stop()
		_animation_player.play("idle")
		
		match _previous_light_combo:
			"light_combo_1":
				_animation_player.play("light_combo_2")
			"light_combo_2":
				_animation_player.play("light_combo_3")
			"light_combo_3":
				_animation_player.play("light_combo_1")
		
		_previous_light_combo = _animation_player.current_animation
		return
	
	if event.is_action_pressed("heavy_attack") and accept_next_attack:
		_previous_light_combo = "light_combo_3"
		
		_state = States.HEAVY_ATTACK
		accept_next_attack = false
		
		_animation_player.stop()
		_animation_player.play("idle")
		
		match _previous_heavy_combo:
			"heavy_combo_1":
				_animation_player.play("heavy_combo_2")
			"heavy_combo_2":
				_animation_player.play("heavy_combo_1")
		
		_previous_heavy_combo = _animation_player.current_animation
		return


func _ready() -> void:
	_animation_player.connect("animation_finished", self, "_on_AnimationPlayer_finished")


func _physics_process(delta: float) -> void:
	if _state != States.MOVE:
		return

	var input_direction := Input.get_axis("move_left", "move_right")
	_direction = Vector2.RIGHT * input_direction
	
	if input_direction:
		_skin.scale.x = sign(input_direction)
	
	var desired_velocity := _direction * SPEED_MOVE
	var steering = desired_velocity - _velocity
	_velocity += steering * DRAG_FACTOR * delta
	move_and_collide(_velocity * delta)


func set_accept_next_attack(value := true) -> void:
	accept_next_attack = value
  

func _on_AnimationPlayer_finished(animation_name: String) -> void:
	if "light_combo" in animation_name:
		_previous_light_combo = "light_combo_3"
		_state = States.MOVE
	elif "heavy_combo" in animation_name:
		_previous_light_combo = "heavy_combo_2"
		_state = States.MOVE
