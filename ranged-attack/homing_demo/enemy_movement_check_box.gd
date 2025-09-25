extends CheckBox

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _ready():
	toggled.connect(_on_toggled)


func _on_toggled(is_toggled: bool) -> void:
	if is_toggled:
		animation_player.play("enemy_move")
	else:
		animation_player.pause()
