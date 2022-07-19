static func enum_to_string(e: Dictionary, slice := {}) -> String:
	var partial_result := PoolStringArray()
	var keys := e.keys()
	if not slice.empty():
		keys = keys.slice(slice.begin, slice.end, slice.get("step", 1))

	for key in keys:
		partial_result.push_back(key.capitalize())
	return partial_result.join(",")


static func array_to_texture(xs: Array) -> ImageTexture:
	var result := ImageTexture.new()
	if xs.empty():
		return result

	var stream := StreamPeerBuffer.new()
	var format := (
		Image.FORMAT_RF
		if xs[0] is int or xs[0] is float
		else Image.FORMAT_RGF if xs[0] is Vector2 else Image.FORMAT_RGBF
	)
	for x in xs:
		if x is int or x is float:
			stream.put_float(x)
		else:
			stream.put_float(x.x)
			stream.put_float(x.y)
			if x is Vector3:
				stream.put_float(x.z)
	var image := Image.new()
	image.create_from_data(xs.size(), 1, false, format, stream.data_array)
	result.create_from_image(image, 0)

	return result


static func draw_polyline_dashed(
	canvas_item: CanvasItem,
	curve: Curve2D,
	color: Color,
	width := 1.0,
	sample := 24,
	sample_scale := 1.0
) -> void:
	sample = int(sample * sample_scale)
	var fraction := curve.get_baked_length() / sample
	for step in range(0, sample):
		if step % 2 != 0:
			continue
		canvas_item.draw_line(
			curve.interpolate_baked(step * fraction),
			curve.interpolate_baked((step + 1) * fraction),
			color,
			width
		)


static func get_curve_circle(radius: float, sample := 24, transform := Transform2D.IDENTITY) -> Curve2D:
	var result := Curve2D.new()
	var step = TAU / sample
	for i in range(sample):
		var circle_point := Vector2(sin(i * step), cos(i * step)) * radius
		result.add_point(transform.xform(circle_point))
	result.add_point(result.get_point_position(0))
	return result


static func get_curve_capsule(
	radius: float, height: float, sample := 24, transform := Transform2D.IDENTITY
) -> Curve2D:
	sample = stepify(sample, 4)
	var result := Curve2D.new()
	var step := TAU / sample
	var quadrant1 := sample / 4
	var quadrant3 := 3 * quadrant1
	for i in range(sample):
		var offset := Vector2(0, height * 0.5 * (-1 if (i > quadrant1 and i <= quadrant3) else 1))
		var circle_point := Vector2(sin(i * step), cos(i * step)) * radius
		result.add_point(transform.xform(circle_point + offset))
		if i == quadrant1 or i == quadrant3:
			result.add_point(transform.xform(circle_point - offset))
	result.add_point(result.get_point_position(0))
	return result


static func get_curve_rectangle(side: int, extents: Vector2, transform := Transform2D.IDENTITY) -> Curve2D:
	var result := Curve2D.new()
	if side >= 0 and side < 4:
		var sides := [-1, Vector2.RIGHT + Vector2.UP, 1, Vector2.LEFT + Vector2.DOWN]
		result.add_point(transform.xform(sides[side] * extents))
		result.add_point(transform.xform(sides[(side + 1) % sides.size()] * extents))
	return result


static func get_curve_polygon(edge := -1, points := [], transform := Transform2D.IDENTITY) -> Curve2D:
	var result := Curve2D.new()
	if points.size() < 2:
		return result

	if edge == -1:
		for point in points:
			result.add_point(transform.xform(point))
		result.add_point(points[0])
	elif edge >= 0 and edge < points.size():
		result.add_point(transform.xform(points[edge]))
		result.add_point(transform.xform(points[(edge + 1) % points.size()]))
	return result


static func v3normal(v: Vector3) -> Vector3:
	var result := Vector3(v.z, v.z, -v.x - v.y)
	if result.is_equal_approx(Vector3.ZERO):
		result = Vector3(-v.y - v.z, v.x, v.x)
	return result.normalized()
