extends Path2D
class_name ScatterPath2D
tool
export(NodePath) var scatter_target 
export(int) var objects_count = 10 setget set_object_count
export(float, 0.1, 1.0) var object_base_scale = 1.0
export(PackedScene) var object_to_scatter
var scatter : Scatter


func _ready():
	scatter = Scatter.new()
	generate()

func set_object_count(new_count):
	objects_count = new_count
	generate()

func generate():
	if !is_inside_tree(): return
	
	if scatter == null:
		scatter = Scatter.new()
		
	scatter.set_shape(curve.tessellate(2))
	
	var holder
	
	if scatter_target != null:
		holder = get_node(scatter_target)
	else:
		holder = YSort.new()
		add_child(holder)

	for child in holder.get_children():
		child.queue_free()
			
	for _i in range(objects_count):
		var obj = object_to_scatter.instance()
		obj.position = scatter.get_random_point()
		obj.scale = Vector2.ONE * object_base_scale
		holder.add_child(obj)
