extends Panel

var texture: StreamTexture setget set_texture

onready var _texture_rect := $TextureRect

func set_texture(new_texture: StreamTexture) -> void:
	texture = new_texture
	_texture_rect.texture = texture
