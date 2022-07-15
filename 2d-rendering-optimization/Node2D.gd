extends Node2D


onready var sprite: Sprite = $Icon

func _ready() -> void:
	for i in 500:
		var new_sprite := sprite.duplicate()
		new_sprite.position = Vector2(randf(), randf()) * 8000
		add_child(new_sprite)
