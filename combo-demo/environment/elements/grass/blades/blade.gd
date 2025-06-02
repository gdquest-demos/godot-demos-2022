extends Polygon2D

func _ready():
	var m : ShaderMaterial = material
	var r_x = cos(rotation)
	var r_y = cos(rotation)
	m.set_shader_param("world_position", global_position + Vector2(r_x, r_y))
