extends Navigation2D
# ANCHOR: setup_hazards
signal navigation_updated

onready var _polygon_instance: NavigationPolygonInstance = $NavigationPolygonInstance
onready var _base_polygon := _polygon_instance.get_navigation_polygon()


func setup_hazards() -> void:
	var hazard_list := get_tree().get_nodes_in_group("Hazard")
	var polygon := _base_polygon.duplicate()
	for child in hazard_list:
		assert(child is CollisionPolygon2D, "invalid Hazard type")
		var outline := []
		for point in child.get_polygon():
			outline.append(child.get_global_transform_with_canvas().xform(point))
		polygon.add_outline(outline)
		polygon.make_polygons_from_outlines()
	_polygon_instance.set_navigation_polygon(polygon)
	emit_signal("navigation_updated")
# END: setup_hazards
