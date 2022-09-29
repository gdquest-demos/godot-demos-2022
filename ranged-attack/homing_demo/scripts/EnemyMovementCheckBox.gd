extends CheckBox

onready var animation_player = $"../../../../../AnimationPlayer"


func _ready():
	connect("toggled", self, "_on_toggled")
	pressed = true


func _on_toggled(value: bool):
	if value:
		animation_player.play("Move Enemy")
	else:
		animation_player.stop(false)
