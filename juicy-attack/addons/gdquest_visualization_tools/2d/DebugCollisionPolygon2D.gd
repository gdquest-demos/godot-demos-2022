tool
class_name DebugCollisionPolygon2D
extends CollisionPolygon2D


const DebugUtils := preload("../DebugUtils.gd")
const DebugCollisionTheme := preload("DebugCollisionTheme.gd")

var _theme := DebugCollisionTheme.new(self)


func _ready() -> void:
	if not Engine.editor_hint:
		add_to_group("GVTCollision")


func _draw() -> void:
	material.shader = _theme.get_shader(get_class())
	match _theme.theme:
		DebugCollisionTheme.ThemeType.SIMPLE, DebugCollisionTheme.ThemeType.DASHED:
			if _theme.theme_width != 0:
				_draw_collisionpolygon2d()

		DebugCollisionTheme.ThemeType.HALO:
			VisualServer.canvas_item_clear(get_canvas_item())
			var rect := _get_rect_poligon2d()
			draw_rect(rect, Color.white)
			var xform := Transform2D(0, -rect.position)
			xform.origin = -rect.position
			xform = xform.scaled(Vector2.ONE / rect.size)
			var normalized_points: Array = xform.xform(polygon)
			material.set_shader_param("points_size", normalized_points.size())
			material.set_shader_param("points", DebugUtils.array_to_texture(normalized_points))
	property_list_changed_notify()


func _draw_collisionpolygon2d() -> void:
	if polygon.size() < 2:
		return

	if _theme.theme == DebugCollisionTheme.ThemeType.SIMPLE:
		var points: Array = polygon
		points.append_array(points.slice(0, 0))
		draw_polyline(points, _theme.color, _theme.theme_width)
	else:
		var full_curve_length := DebugUtils.get_curve_polygon(-1, polygon).get_baked_length()
		for edge in range(polygon.size()):
			var curve := DebugUtils.get_curve_polygon(edge, polygon)
			DebugUtils.draw_polyline_dashed(
				self,
				curve,
				_theme.color,
				_theme.theme_width,
				_theme.theme_sample,
				curve.get_baked_length() / full_curve_length
			)


func _get(property: String):
	return _theme.get_property(property)


func _get_property_list() -> Array:
	return _theme.get_property_list()


func _get_rect_poligon2d() -> Rect2:
	var result := Rect2()
	for point in polygon:
		result = result.expand(point)
	return result


func _set(property: String, value) -> bool:
	return _theme != null and _theme.set_property(property, value)
