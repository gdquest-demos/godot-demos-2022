tool
extends Node2D
export(Array, PackedScene) var possible_leaves;
export(Curve) var leaves_scale

func _ready():
	for child in get_children():
		child.queue_free()
	randomize()
	var blade_count : int = int(round(rand_range(4, 8)))
	for i in range(blade_count):
		var max_angle = PI*.35
		var base_rotation = range_lerp(i, 0, blade_count-1, -max_angle, max_angle) * rand_range(0.6, 1.4)
		var rot_percent = range_lerp(base_rotation, -max_angle, max_angle, -1, 1)
		var blade : Polygon2D = possible_leaves[randi() % possible_leaves.size()].instance()	
		var leave_percent = float(i) / (blade_count - 1)
		blade.scale = leaves_scale.interpolate(leave_percent) * Vector2.ONE
		if leave_percent >= 0.5:
			blade.scale.x *= -1.0
		blade.rotation = base_rotation
		blade.position.x += rot_percent * 10.0
		add_child(blade)
