# Thanks for kleonc :)! https://www.reddit.com/r/godot/comments/mqp29g/how_do_i_get_a_random_position_inside_a_collision/

class_name Scatter

var points : PoolVector2Array = []
var triangles : PoolIntArray = []
var triangle_count : int = 0
var cumulated_triangle_areas : Array
var rand : RandomNumberGenerator

func set_shape(pointList : PoolVector2Array):
	rand = RandomNumberGenerator.new()
	points = pointList
	triangles = Geometry.triangulate_polygon(points)
	triangle_count = int(triangles.size() / 3.0)
	cumulated_triangle_areas.resize(triangle_count)
	cumulated_triangle_areas[-1] = 0
	for i in range(triangle_count):
		var triangle = get_triangle(i)
		var t_area = callv("triangle_area", triangle)	
		cumulated_triangle_areas[i] = cumulated_triangle_areas[i - 1] + t_area


func get_random_point() -> Vector2:
	var total_area: float = cumulated_triangle_areas[-1]
	var choosen_triangle_index: int = cumulated_triangle_areas.bsearch(rand.randf() * total_area)
	var choosen_triangle = get_triangle(choosen_triangle_index)
	return callv("random_triangle_point", choosen_triangle)

func get_triangle(triangle_index):
	var a: Vector2 = points[triangles[triangle_index * 3 + 0]]
	var b: Vector2 = points[triangles[triangle_index * 3 + 1]]
	var c: Vector2 = points[triangles[triangle_index * 3 + 2]]
	return [a, b, c]
	
func triangle_area(p1 : Vector2, p2 : Vector2, p3 : Vector2):
	return abs((p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + 
	  p3.x * (p1.y - p2.y)) / 2.0)

func random_triangle_point(a: Vector2, b: Vector2, c: Vector2):
	return a + sqrt(randf()) * (-a + b + randf() * (c - b))
