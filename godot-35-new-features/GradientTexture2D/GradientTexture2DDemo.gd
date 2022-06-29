extends Control

var tex := preload("GradientTexture2D.tres") as GradientTexture2D

onready var night_texture_rect := get_node("%Night") as TextureRect
onready var night_button := get_node("%NightButton") as Button
onready var fire_button := get_node("%FireButton") as Button
onready var repeat_button := get_node("%RepeatButton") as Button
onready var light_2d := get_node("%Light2D") as Light2D
onready var fire := get_node("%Fire") as Control

func _ready() -> void:
	night_texture_rect.visible = false
	repeat_button.connect("toggled", self, "_on_RepeatButton_toggled")
	night_button.connect("toggled", self, "_on_NightButton_pressed")
	fire_button.connect("toggled", fire, "set_visible")

func _physics_process(delta: float) -> void:
	light_2d.global_position = get_global_mouse_position()


func _on_RepeatButton_toggled(toggled: bool) -> void:
	tex.repeat = toggled
	tex.fill_to.x = 0.6 if toggled else 1.0

func _on_NightButton_pressed(toggle: bool) -> void:
	night_texture_rect.visible = toggle
	light_2d.energy = 2.0 if toggle else 1.15
