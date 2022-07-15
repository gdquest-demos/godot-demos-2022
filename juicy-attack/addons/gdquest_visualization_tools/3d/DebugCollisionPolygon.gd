tool
class_name DebugCollisionPolygon
extends CollisionPolygon


const DebugTheme := preload("DebugTheme.gd")

var _theme := DebugTheme.new(self)


func _ready() -> void:
	set_notify_transform(true)
	if not Engine.editor_hint:
		add_to_group("GVTCollision")


func _enter_tree() -> void:
	refresh()


func _exit_tree() -> void:
	_theme.free_rids()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			for rid in _theme.rids.instances:
				VisualServer.instance_set_transform(rid, global_transform)


func refresh() -> void:
	_draw()
	property_list_changed_notify()


func _draw() -> void:
	var polygon_size := polygon.size()
	if polygon_size < 3:
		return

	_theme.free_rids()
	var is_drawn := false
	match _theme.theme:
		DebugTheme.ThemeType.WIREFRAME:
			var complete_polygon := []
			for point in polygon:
				for direction in [-1, 1]:
					complete_polygon.push_back(Vector3(point.x, point.y, 0.5 * depth * direction))
			var convex_polygon_shape := ConvexPolygonShape.new()
			convex_polygon_shape.points = complete_polygon
			var mesh := convex_polygon_shape.get_debug_mesh()
			if mesh.get_surface_count() > 0:
				_theme.rids.resources.push_back(VisualServer.mesh_create())
				VisualServer.mesh_add_surface_from_arrays(_theme.rids.resources[0], VisualServer.PRIMITIVE_LINES, mesh.surface_get_arrays(0))
				VisualServer.mesh_surface_set_material(_theme.rids.resources[0], 0, _theme.material.get_rid())
				is_drawn = true

		DebugTheme.ThemeType.HALO:
			_theme.rids.resources.push_back(VisualServer.immediate_create())
			for direction in [-1, 1]:
				VisualServer.immediate_begin(_theme.rids.resources[0], VisualServer.PRIMITIVE_TRIANGLE_FAN)
				VisualServer.immediate_normal(_theme.rids.resources[0], Vector3.BACK if Geometry.is_polygon_clockwise(polygon) else Vector3.FORWARD)
				for point in polygon:
					VisualServer.immediate_vertex(_theme.rids.resources[0], Vector3(point.x, point.y, 0.5 * depth * direction))
				VisualServer.immediate_end(_theme.rids.resources[0])

			var closed_polygon := Array(polygon) + [polygon[0]]
			for index in range(polygon_size):
				VisualServer.immediate_begin(_theme.rids.resources[0], VisualServer.PRIMITIVE_TRIANGLE_FAN)
				var level := 0.5 * depth
				var v0 := Vector3(closed_polygon[index].x, closed_polygon[index].y, -level)
				var v1 := Vector3(closed_polygon[index + 1].x, closed_polygon[index + 1].y, -level)
				var v2 := Vector3(closed_polygon[index + 1].x, closed_polygon[index + 1].y, level)
				var normal := (v1 - v0).cross(v1 - v2).normalized()
				VisualServer.immediate_normal(_theme.rids.resources[0], normal)
				VisualServer.immediate_vertex(_theme.rids.resources[0], v0)
				VisualServer.immediate_vertex(_theme.rids.resources[0], v1)
				VisualServer.immediate_vertex(_theme.rids.resources[0], v2)
				VisualServer.immediate_vertex(_theme.rids.resources[0], Vector3(closed_polygon[index].x, closed_polygon[index].y, level))
				VisualServer.immediate_end(_theme.rids.resources[0])
				VisualServer.immediate_set_material(_theme.rids.resources[0], _theme.material.get_rid())
			is_drawn = true

	if is_drawn and get_world().scenario:
		_theme.rids.instances.push_back(VisualServer.instance_create2(_theme.rids.resources[0], get_world().scenario))
		_notification(NOTIFICATION_TRANSFORM_CHANGED)


func _get(property: String):
	return _theme.get_property(property)


func _get_property_list() -> Array:
	return _theme.get_property_list()


func _set(property: String, value) -> bool:
	var result := false
	match property:
		"visible": set_visible(value)
		"depth": set_depth(value)
		"polygon": set_polygon(value)
		_: result = _theme != null and _theme.set_property(property, value)
	return result


func set_depth(new_depth: float) -> void:
	depth = new_depth
	_draw()


func set_polygon(new_polygon: PoolVector2Array) -> void:
	polygon = new_polygon
	_draw()


func set_visible(new_visible: bool) -> void:
	visible = new_visible
	_theme.set_visible(visible)
