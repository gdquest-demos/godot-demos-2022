extends Control

onready var ok_button := get_node("%OkButton") as Button
onready var cancel_button := get_node("%CancelButton") as Button
onready var accept_dialog := $AcceptDialog

func _ready() -> void:
	
	ok_button.connect("pressed", accept_dialog, "popup_centered")
	cancel_button.connect("pressed", accept_dialog, "popup_centered")
