extends Panel

@onready var _h_slider: HSlider = %HSlider
@onready var _label: Label = %Label


func _ready() -> void:
	_h_slider.value_changed.connect(_on_h_slider_value_changed)
	_h_slider.value = 50
	_on_h_slider_value_changed(_h_slider.value)


func _on_h_slider_value_changed(value: float) -> void:
	_label.text = "%.0f%%" % [value]
	Engine.time_scale = value / 100
