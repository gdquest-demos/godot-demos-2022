extends Line2D

signal ended

var resolution = 16
var duration = 2.0

func generate_and_play(rect_pos : Vector2, rect_size : Vector2):
	randomize()
	var spawn_pos = Vector2(
		rand_range(-1, 1) * (rect_size.x / 2.0),
		rand_range(-1, 1) * (rect_size.y / 2.0)
	)
	spawn_pos += rect_pos
	position = spawn_pos
	points = []
	var new_points = []
	
	var strand_width = rect_size.x * rand_range(0.8, 1.2)
	var strand_height = strand_width * 0.05 * rand_range(0.8, 1.2)
	var offset = randf()
	
	for x in resolution:
		var x_percent = float(x) / resolution
		var clamp_x = (x_percent) - 0.5
		var pos_x = strand_width * clamp_x
		var pos_y = sin((offset + x) * 0.3) * strand_height
		new_points.append(Vector2(pos_x, pos_y))
	points = new_points
	
	var m : ShaderMaterial = material
	
	var duration_variation = duration * rand_range(0.8, 2.0)
	
	var t = create_tween()
	t.tween_property(m, "shader_param/offset", 1.0, duration_variation).from(0.0)
	yield(t, "finished")
	emit_signal("ended")
	
	
	
