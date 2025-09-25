extends Panel

# Emitted when the player presses the save button
signal save_requested
# Emitted when the player presses the load button
signal reload_requested

@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton


func _ready() -> void:
	save_button.pressed.connect(save_requested.emit)
	load_button.pressed.connect(reload_requested.emit)
