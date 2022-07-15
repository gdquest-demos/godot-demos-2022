tool
class_name DebugCollisionShape2D
extends CollisionShape2D


const DebugUtils := preload("../DebugUtils.gd")
const DebugCollisionTheme := preload("DebugCollisionTheme.gd")

var _theme := DebugCollisionTheme.new(self)


func _ready() -> void:
	if not Engine.editor_hint:
		add_to_group("GVTCollision")


func _draw() -> void:
	_theme.is_implemented = false
	material.shader = _theme.get_shader(shape.get_class())
	match _theme.theme:
		DebugCollisionTheme.ThemeType.SIMPLE, DebugCollisionTheme.ThemeType.DASHED:
			var method_name := "" if shape == null else "_draw_%s" % shape.get_class().to_lower()
			_theme.is_implemented = has_method(method_name)
			(
				_theme.is_implemented
				and _theme.theme_width > 0
				and funcref(self, method_name).call_func()
			)

		DebugCollisionTheme.ThemeType.HALO:
			var method_name := "" if shape == null else "_get_rect_%s" % shape.get_class().to_lower()
			_theme.is_implemented = has_method(method_name)
			if _theme.is_implemented:
				# We need to clear the canvas item first to prevent drawing the
				# default shape on top of the rectangle.
				VisualServer.canvas_item_clear(get_canvas_item())
				var rect: Rect2 = funcref(self, method_name).call_func()
				draw_rect(rect, Color.white)
				match shape.get_class():
					"CapsuleShape2D":
						material.set_shader_param("ratio", 0.5 * shape.height / shape.radius)
					"ConvexPolygonShape2D":
						var xform := Transform2D(0, -rect.position)
						xform = xform.scaled(Vector2.ONE / rect.size)
#						var xform := Transform2D.IDENTITY.scaled(Vector2.ONE / rect.size)
#						xform.origin = -rect.position
						var normalized_points: Array = xform.xform(shape.points)
						material.set_shader_param("points_size", normalized_points.size())
						material.set_shader_param(
							"points", DebugUtils.array_to_texture(normalized_points)
						)

	if not _theme.is_implemented:
		property_list_changed_notify()


func _draw_capsuleshape2d() -> void:
	var curve := DebugUtils.get_curve_capsule(shape.radius, shape.height, _theme.theme_sample)
	if _theme.theme == DebugCollisionTheme.ThemeType.SIMPLE:
		draw_polyline(curve.get_baked_points(), _theme.color, _theme.theme_width)
	else:
		DebugUtils.draw_polyline_dashed(
			self, curve, _theme.color, _theme.theme_width, _theme.theme_sample
		)


func _draw_circleshape2d() -> void:
	if _theme.theme == DebugCollisionTheme.ThemeType.SIMPLE:
		draw_arc(
			Vector2.ZERO,
			shape.radius,
			0,
			TAU,
			_theme.theme_sample,
			_theme.color,
			_theme.theme_width
		)
	else:
		var curve := DebugUtils.get_curve_circle(shape.radius, _theme.theme_sample)
		DebugUtils.draw_polyline_dashed(
			self, curve, _theme.color, _theme.theme_width, _theme.theme_sample
		)


func _draw_convexpolygonshape2d() -> void:
	if shape.points.size() < 2:
		return

	if _theme.theme == DebugCollisionTheme.ThemeType.SIMPLE:
		var points: Array = shape.points
		points.append_array(points.slice(0, 0))
		draw_polyline(points, _theme.color, _theme.theme_width)
	else:
		var full_curve_length := DebugUtils.get_curve_polygon(-1, shape.points).get_baked_length()
		for edge in range(shape.points.size()):
			var curve := DebugUtils.get_curve_polygon(edge, shape.points)
			DebugUtils.draw_polyline_dashed(
				self,
				curve,
				_theme.color,
				_theme.theme_width,
				_theme.theme_sample,
				curve.get_baked_length() / full_curve_length
			)


func _draw_rectangleshape2d() -> void:
	if _theme.theme == DebugCollisionTheme.ThemeType.SIMPLE:
		draw_rect(_get_rect_rectangleshape2d(), _theme.color, false, _theme.theme_width)
	else:
		for side in range(4):
			var curve := DebugUtils.get_curve_rectangle(side, shape.extents)
			DebugUtils.draw_polyline_dashed(
				self, curve, _theme.color, _theme.theme_width, _theme.theme_sample, 1.0 / 4.0
			)


func _get(property: String):
	return _theme.get_property(property)


func _get_property_list() -> Array:
	return _theme.get_property_list()


func _get_rect_capsuleshape2d() -> Rect2:
	var result := Rect2()
	result.size = 2.0 * Vector2(shape.radius, shape.radius + 0.5 * shape.height)
	result.position = -0.5 * result.size
	return result


func _get_rect_circleshape2d() -> Rect2:
	var result := Rect2()
	result.size = 2.0 * Vector2.ONE * shape.radius
	result.position = -0.5 * result.size
	return result


func _get_rect_rectangleshape2d() -> Rect2:
	return Rect2(-shape.extents, 2.0 * shape.extents)


func _get_rect_convexpolygonshape2d() -> Rect2:
	var result := Rect2()
	for point in shape.points:
		result = result.expand(point)
	return result


func _set(property: String, value) -> bool:
	return _theme != null and _theme.set_property(property, value)
