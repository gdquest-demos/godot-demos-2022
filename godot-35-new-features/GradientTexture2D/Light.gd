extends Light2D

onready var tex := texture as GradientTexture2D

func _physics_process(delta: float) -> void:
	global_position = get_global_mouse_position()


func _on_Button_toggled(button_pressed: bool) -> void:
	tex.repeat = button_pressed
	tex.fill_to.x = 0.6 if button_pressed else 1.0
