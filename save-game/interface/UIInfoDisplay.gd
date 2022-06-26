extends PanelContainer

# The character stats to display and update with this interface.
var character: Character setget set_character

var _ignore_value_change := false

onready var _player_position_label := $MarginContainer/VBoxContainer/PlayerPositionLabel as Label

onready var _run_speed_slider := $MarginContainer/VBoxContainer/HBoxContainer/RunSpeedSlider as HSlider
onready var _strength_spinbox := $MarginContainer/VBoxContainer/HBoxContainer2/StrengthSpinbox as SpinBox
onready var _endurance_spinbox := $MarginContainer/VBoxContainer/HBoxContainer3/EnduranceSpinbox as SpinBox
onready var _intelligence_spinbox := $MarginContainer/VBoxContainer/HBoxContainer4/IntelligenceSpinbox as SpinBox


func _ready() -> void:
	_run_speed_slider.connect("value_changed", self, "_on_value_changed")
	_strength_spinbox.connect("value_changed", self, "_on_value_changed")
	_endurance_spinbox.connect("value_changed", self, "_on_value_changed")
	_intelligence_spinbox.connect("value_changed", self, "_on_value_changed")


func update_player_position(global_position: Vector2) -> void:
	_player_position_label.text = "Global position: " + str(global_position.round())


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


func _on_value_changed(new_value: float) -> void:
	if _ignore_value_change:
		return

	character.run_speed = _run_speed_slider.value
	character.strength = _strength_spinbox.value
	character.endurance = _endurance_spinbox.value
	character.intelligence = _intelligence_spinbox.value
