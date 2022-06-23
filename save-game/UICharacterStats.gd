extends Panel

export var character: Resource = null

onready var name_label := $VBoxContainer/Label
onready var strength_spinbox := $VBoxContainer/HBoxContainer/StrengthSpinBox
onready var endurance_spinbox := $VBoxContainer/HBoxContainer2/EnduranceSpinBox
onready var intelligence_spinbox := $VBoxContainer/HBoxContainer3/IntelligenceSpinBox


func _ready() -> void:
	if not character or not character is Character:
		return
	
	name_label.text = character.display_name
	
	strength_spinbox.connect("value_changed", self, "_on_StrengthSpinBox_value_changed")
	endurance_spinbox.connect("value_changed", self, "_on_EnduranceSpinBox_value_changed")
	intelligence_spinbox.connect("value_changed", self, "_on_IntelligenceSpinBox_value_changed")

	strength_spinbox.value = character.strength
	endurance_spinbox.value = character.endurance
	intelligence_spinbox.value = character.intelligence


func _on_StrengthSpinBox_value_changed(new_value: int) -> void:
	character.strength = new_value


func _on_EnduranceSpinBox_value_changed(new_value: int) -> void:
	character.endurance = new_value


func _on_IntelligenceSpinBox_value_changed(new_value: int) -> void:
	character.intelligence = new_value
