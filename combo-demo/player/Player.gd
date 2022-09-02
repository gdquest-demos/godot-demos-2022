extends KinematicBody2D

enum States { MOVE, ATTACK }

enum { LIGHT_ATTACK, HEAVY_ATTACK }

const SPEED_MOVE := 400.0

const COMBOS = {
	[LIGHT_ATTACK, LIGHT_ATTACK, LIGHT_ATTACK]: ["light_combo_1", "light_combo_2", "light_combo_3"],
	[HEAVY_ATTACK, HEAVY_ATTACK]: ["heavy_combo_1", "heavy_combo_2"],
	[LIGHT_ATTACK, LIGHT_ATTACK, HEAVY_ATTACK]: ["light_combo_1", "light_combo_2", "heavy_combo_2"],
}

var accept_next_attack := true setget set_accept_next_attack

var _state = States.MOVE
var _combo_current := []

onready var _skin := $Skin
onready var _animation_player := $AnimationPlayer


func _ready() -> void:
	_animation_player.connect("animation_finished", self, "_on_AnimationPlayer_finished")


func _unhandled_input(event: InputEvent) -> void:
	if not accept_next_attack:
		return

	if event.is_action_pressed("light_attack"):
		_attack(LIGHT_ATTACK)
	elif event.is_action_pressed("heavy_attack"):
		_attack(HEAVY_ATTACK)


func _physics_process(delta: float) -> void:
	if _state != States.MOVE:
		return

	var input_direction := Vector2.RIGHT * Input.get_axis("move_left", "move_right")
	if input_direction:
		_skin.scale.x = sign(input_direction.x)

	var velocity := input_direction * SPEED_MOVE
	move_and_slide(velocity)


func _attack(attack_type: int) -> void:
	assert(
		attack_type in [LIGHT_ATTACK, HEAVY_ATTACK],
		"Unsupported attack type, please use an attack type from the enum."
	)

	accept_next_attack = false

	_combo_current.append(attack_type)
	_state = States.ATTACK

	_animation_player.stop()

	var next_attack_animation := ""
	var current_attack_count := _combo_current.size()
	for combo in COMBOS:
		if current_attack_count > combo.size():
			continue

		var is_match := true
		for index in current_attack_count:
			if _combo_current[index] != combo[index]:
				is_match = false
				break

		if is_match:
			next_attack_animation = COMBOS[combo][current_attack_count - 1]

	if next_attack_animation:
		_animation_player.play(next_attack_animation)
	else:
		_end_combo()


func _end_combo() -> void:
	_state = States.MOVE
	_animation_player.play("idle")
	_combo_current.clear()
	accept_next_attack = true


func set_accept_next_attack(value := true) -> void:
	accept_next_attack = value


func _on_AnimationPlayer_finished(animation_name: String) -> void:
	if "combo" in animation_name:
		_end_combo()
