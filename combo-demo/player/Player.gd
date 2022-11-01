extends KinematicBody2D

enum States { MOVE, ATTACK }

enum { LIGHT_ATTACK, HEAVY_ATTACK }

const SPEED_MOVE := 400.0

# This data structure stores the attack sequence of each combo as a key, and the
# corresponding animations and other data as values.
const COMBOS = {
	[LIGHT_ATTACK, LIGHT_ATTACK, LIGHT_ATTACK]:
	# Using a dictionary for each attack's data allows us to add any other data
	# we need per-attack, like damage, status effects...
	[{animation = "light_combo_1"}, {animation = "light_combo_2"}, {animation = "light_combo_3"}],
	[HEAVY_ATTACK, HEAVY_ATTACK]: [{animation = "heavy_combo_1"}, {animation = "heavy_combo_2"}],
	[LIGHT_ATTACK, LIGHT_ATTACK, HEAVY_ATTACK]:
	[{animation = "light_combo_1"}, {animation = "light_combo_2"}, {animation = "heavy_combo_2"}],
}

# There's a limited timeframe to register the next attack for each playing
# attack animation. This variable gets set to true from the animation to allow
# the player to use the next attack.
var accept_next_attack := true setget set_accept_next_attack

var _state = States.MOVE
# We store the list of attacks the player used as part of the current combo
# here. See the _attack() function to see how we use this.
var _combo_current := []

onready var _skin := $Skin


func _ready() -> void:
	_skin.connect("next_attack_enabled", self, "set_accept_next_attack")
	_skin.connect("attack_finished", self, "_on_Skin_attack_finished")


func _unhandled_input(event: InputEvent) -> void:
	if not accept_next_attack:
		return

	if event.is_action_pressed("light_attack"):
		_attack(LIGHT_ATTACK)
	elif event.is_action_pressed("heavy_attack"):
		_attack(HEAVY_ATTACK)


# This handles forward and back movement when the player isn't attacking.
func _physics_process(delta: float) -> void:
	if _state != States.MOVE:
		return

	var input_direction := Vector2.RIGHT * Input.get_axis("move_left", "move_right")
	if input_direction:
		_skin.scale.x = sign(input_direction.x) * _skin.start_scale.x
		_skin.play("run")
	else:
		_skin.play("idle")

	var velocity := input_direction * SPEED_MOVE
	move_and_slide(velocity)


# This is the function that handles combos. It appends attacks to the
# _combo_current array and, if it finds a matching combo, plays the
# corresponding attack animation.
func _attack(attack_type: int) -> void:
	assert(
		attack_type in [LIGHT_ATTACK, HEAVY_ATTACK],
		"Unsupported attack type, please use an attack type from the enum."
	)

	# We don't want to accept another attack until the attack animation allows
	# it.
	accept_next_attack = false

	_state = States.ATTACK
	_combo_current.append(attack_type)

	# We check every attack of the current combo against every attack of every
	# combo in the COMBOS data structure until we find a match.
	#
	# If we have a match, we assign the next attack's animation to the variable
	# below, which tells us if we should continue or end the combo.
	var next_attack_animation := ""
	var current_attack_count := _combo_current.size()
	for combo in COMBOS:
		# To avoid indexing errors, we skip any combo shorter than the current combo.
		if current_attack_count > combo.size():
			continue

		# We compare each value in the current combo with the values in our
		# reference combo. If any one value doesn't match, then we skip to the
		# next combo.
		var is_match := true
		for index in current_attack_count:
			if _combo_current[index] != combo[index]:
				is_match = false
				break

		# If the current combo matches the reference combo, we store the
		# animation to play next.
		if is_match:
			next_attack_animation = COMBOS[combo][current_attack_count - 1].animation

	if next_attack_animation:
		_skin.play(next_attack_animation)
	else:
		_end_combo()


# This function resets all combo-related variables, to allow the player to start
# another combo.
func _end_combo() -> void:
	_state = States.MOVE
	_combo_current.clear()
	accept_next_attack = true


func set_accept_next_attack(value := true) -> void:
	accept_next_attack = value


func _on_Skin_attack_finished() -> void:
	_end_combo()
