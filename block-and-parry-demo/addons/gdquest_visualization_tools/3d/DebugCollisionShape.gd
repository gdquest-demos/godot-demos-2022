tool
class_name DebugCollisionShape
extends CollisionShape


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
	if shape == null:
		return

	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			var xform := global_transform
			match [shape.get_class(), _theme.theme]:
				["RayShape", DebugTheme.ThemeType.WIREFRAME]:
					for rid in _theme.rids.instances:
						VisualServer.instance_set_transform(rid, xform)
						xform = xform.translated(shape.length * Vector3.BACK)
				["RayShape", DebugTheme.ThemeType.HALO]:
					xform.origin = Vector3.ZERO
					xform = xform.rotated(global_transform.basis.x, PI / 2)
					xform.origin = global_transform.origin
					var midway: Vector3 = 0.5 * shape.length * Vector3.UP
					for rid in _theme.rids.instances:
						xform = xform.translated(midway)
						VisualServer.instance_set_transform(rid, xform)
				_:
					for rid in _theme.rids.instances:
						VisualServer.instance_set_transform(rid, xform)


func refresh() -> void:
	if shape == null:
		return

	_theme.is_implemented = false
	if not shape.is_connected("changed", self, "_draw"):
		shape.connect("changed", self, "_draw")
	_draw()
	property_list_changed_notify()


func _update_boxshape() -> Array:
	var mesh := CubeMesh.new()
	mesh.size = 2 * shape.extents
	return [{
		"primitive_type": VisualServer.PRIMITIVE_TRIANGLES,
		"arrays": mesh.get_mesh_arrays()
	}]


func _update_cylindershape() -> Array:
	var mesh := CylinderMesh.new()
	mesh.top_radius = shape.radius
	mesh.bottom_radius = shape.radius
	mesh.height = shape.height
	mesh.radial_segments = 32
	mesh.rings = 0
	return [{
		"primitive_type": VisualServer.PRIMITIVE_TRIANGLES,
		"arrays": mesh.get_mesh_arrays()
	}]


func _update_capsuleshape() -> Array:
	var mesh := CapsuleMesh.new()
	mesh.radius = shape.radius
	mesh.mid_height = shape.height
	mesh.radial_segments = 32
	return [{
		"primitive_type": VisualServer.PRIMITIVE_TRIANGLES,
		"arrays": mesh.get_mesh_arrays()
	}]


func _update_rayshape() -> Array:
	var result := []
	var mesh: PrimitiveMesh = CylinderMesh.new()
	mesh.top_radius = 0.01
	mesh.bottom_radius = mesh.top_radius
	mesh.height = shape.length
	mesh.radial_segments = 4
	mesh.rings = 0
	result.push_back({
		"primitive_type": VisualServer.PRIMITIVE_TRIANGLES,
		"arrays": mesh.get_mesh_arrays()
	})

	mesh = SphereMesh.new()
	mesh.radius = 0.03
	mesh.height = 2 * mesh.radius
	mesh.radial_segments = 16
	mesh.rings = 8
	result.push_back({
		"primitive_type": VisualServer.PRIMITIVE_TRIANGLES,
		"arrays": mesh.get_mesh_arrays()
	})
	return result


func _update_sphereshape() -> Array:
	var mesh := SphereMesh.new()
	mesh.radius = shape.radius
	mesh.height = 2 * shape.radius
	mesh.radial_segments = 32
	mesh.rings = 16
	return [{
		"primitive_type": VisualServer.PRIMITIVE_TRIANGLES,
		"arrays": mesh.get_mesh_arrays()
	}]


func _draw_meshes(meshes_info: Array) -> void:
	var world := get_world()
	if meshes_info.empty() or world == null:
		return

	_theme.draw_meshes(meshes_info)
	_notification(NOTIFICATION_TRANSFORM_CHANGED)


func _draw() -> void:
	var method_name := "_update_%s" % [shape.get_class().to_lower()]
	_theme.is_implemented = has_method(method_name)
	var meshes_info := []
	match [_theme.is_implemented, _theme.theme]:
		[_, DebugTheme.ThemeType.WIREFRAME]:
			var mesh := shape.get_debug_mesh()
			if mesh.get_surface_count() > 0:
				meshes_info.push_back({
					"primitive_type": VisualServer.PRIMITIVE_LINES,
					"arrays": mesh.surface_get_arrays(0)
				})

				if shape.get_class() == "RayShape":
					var sphere_shape := SphereShape.new()
					sphere_shape.radius = 0.03
					meshes_info.push_back({
						"primitive_type": VisualServer.PRIMITIVE_LINES,
						"arrays": sphere_shape.get_debug_mesh().surface_get_arrays(0)
					})
		[true, DebugTheme.ThemeType.HALO]:
			meshes_info = funcref(self, method_name).call_func()
	_draw_meshes(meshes_info)


func _get(property: String):
	return _theme.get_property(property)


func _get_property_list() -> Array:
	return [] if shape == null else _theme.get_property_list()


func _set(property: String, value) -> bool:
	var result := false
	match property:
		"visible": set_visible(value)
		_: result = _theme != null and _theme.set_property(property, value)
	return result


func set_visible(new_visible: bool) -> void:
	visible = new_visible
	_theme.set_visible(visible)
