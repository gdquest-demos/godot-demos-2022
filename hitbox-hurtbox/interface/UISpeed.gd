extends HBoxContainer


onready var speed_slider := $HSlider
onready var label := $Label


func _ready() -> void:
	speed_slider.connect("value_changed", self, "_on_HSlider_value_changed")
	speed_slider.value = 50
	_on_HSlider_value_changed(speed_slider.value)


func _on_HSlider_value_changed(value: float) -> void:
	label.text = "%s%%" % [value]
	Engine.time_scale = value/100
