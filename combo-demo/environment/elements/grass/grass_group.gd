tool
extends Node2D
export(Array, PackedScene) var possible_blades;

func _ready():
	for child in get_children():
		child.queue_free()
	randomize()
	var blade_count : int = int(round(rand_range(4, 8)))
	for i in range(blade_count):
		var max_angle = PI*.35
		var base_rotation = range_lerp(i, 0, blade_count-1, -max_angle, max_angle) * rand_range(0.6, 1.4)
		var rot_percent = range_lerp(base_rotation, -max_angle, max_angle, -1, 1)
		var base_scale =  (0.5  + ((1.0 - abs(rot_percent)) * .35))
		var blade : Polygon2D = possible_blades[randi() % possible_blades.size()].instance()
		blade.scale = Vector2.ONE * base_scale * rand_range(0.6, 1.2)
		blade.rotation = base_rotation
		blade.position.x += rot_percent * 10.0
		add_child(blade)
