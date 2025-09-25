extends PanelContainer

# The character stats to display and update with this interface.
var character: Character:
	set = set_character

var _ignore_value_change := false

@onready var _player_position_label: Label = %PlayerPositionLabel
@onready var _run_speed_slider := %RunSpeedHSlider
@onready var _strength_spinbox := %StrengthSpinBox
@onready var _endurance_spinbox := %EnduranceSpinBox
@onready var _intelligence_spinbox := %IntelligenceSpinBox


func _ready() -> void:
	_run_speed_slider.value_changed.connect(_on_value_changed)
	_strength_spinbox.value_changed.connect(_on_value_changed)
	_endurance_spinbox.value_changed.connect(_on_value_changed)
	_intelligence_spinbox.value_changed.connect(_on_value_changed)


func update_player_position(player_position: Vector2) -> void:
	_player_position_label.text = "Global position: " + str(player_position.round())


func set_character(new_character: Character) -> void:
	character = new_character
	# Changing the spin box value triggers their value_changed signal, which we
	# use to update the character stats using the panel.
	# This boolean prevents changing the spinbox values from code from
	# overwriting the character resource.
	_ignore_value_change = true

	_run_speed_slider.value = character.run_speed
	_strength_spinbox.value = character.strength
	_endurance_spinbox.value = character.endurance
	_intelligence_spinbox.value = character.intelligence

	_ignore_value_change = false


func _on_value_changed(_new_value: float) -> void:
	if _ignore_value_change:
		return

	character.run_speed = _run_speed_slider.value
	character.strength = _strength_spinbox.value
	character.endurance = _endurance_spinbox.value
	character.intelligence = _intelligence_spinbox.value
