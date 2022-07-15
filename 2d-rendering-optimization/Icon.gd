extends Sprite

onready var notifier := $VisibilityNotifier2D


func _ready() -> void:
	notifier.connect("screen_entered", self, "show")
	notifier.connect("screen_exited", self, "hide")
	visible = false


func hide():
	.hide()
