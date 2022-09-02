extends KinematicBody2D

enum States { MOVE, LIGHT_ATTACK, HEAVY_ATTACK }

enum { LIGHT_ATTACK, HEAVY_ATTACK }

const DRAG_FACTOR := 15.0
const SPEED_MOVE := 400.0
const SPEED_ATTACK := 1000.0

const COMBOS = {
	LIGHT_ATTACK: ["light_combo_1", "light_combo_2", "light_combo_3"],
	HEAVY_ATTACK: ["heavy_combo_1", "heavy_combo_2"]
}

var accept_next_attack := true setget set_accept_next_attack

var _state = States.MOVE
var _direction := Vector2.ZERO
var _velocity := Vector2.ZERO

var _previous_attack := LIGHT_ATTACK
var _current_attack := LIGHT_ATTACK
var _current_attack_index := -1

onready var _skin := $Skin
onready var _animation_player := $AnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("light_attack") and accept_next_attack:
		_state = States.LIGHT_ATTACK
		_current_attack = LIGHT_ATTACK
		attack()
		return
	
	if event.is_action_pressed("heavy_attack") and accept_next_attack:
		_state = States.HEAVY_ATTACK
		_current_attack = HEAVY_ATTACK
		attack()
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


func attack() -> void:
	accept_next_attack = false
	
	_animation_player.stop()
	_animation_player.play("idle")
	
	if _previous_attack != _current_attack:
		_current_attack_index = -1
	
	_current_attack_index = (_current_attack_index + 1) % COMBOS[_current_attack].size() 
	_animation_player.play(COMBOS[_current_attack][_current_attack_index])
	
	_previous_attack = _current_attack


func set_accept_next_attack(value := true) -> void:
	accept_next_attack = value
  

func _on_AnimationPlayer_finished(animation_name: String) -> void:
	if "combo" in animation_name:
		_current_attack_index = -1
		_state = States.MOVE
