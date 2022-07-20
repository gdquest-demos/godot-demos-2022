tool
class_name DebugRayCast
extends RayCast


const DebugUtils := preload("../DebugUtils.gd")
const DebugPalette := preload("../DebugPalette.gd")
const DebugTheme := preload("DebugTheme.gd")

var _theme := DebugTheme.new(self)
var _cast_to := cast_to


func _ready() -> void:
	set_notify_transform(true)
	if not Engine.editor_hint:
		add_to_group("GVTCollision")


func _enter_tree() -> void:
	_draw()


func _exit_tree() -> void:
	_theme.free_rids()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			var xform := global_transform
			var global_cast_to: Vector3 = xform.xform(_cast_to)
			var global_cast_to_normal = DebugUtils.v3normal(global_cast_to)
			xform = xform.looking_at(global_cast_to, global_cast_to_normal)

			match _theme.theme:
				DebugTheme.ThemeType.WIREFRAME:
					if not _theme.rids.instances.empty():
						xform = xform.translated(_cast_to.length() * Vector3.FORWARD)
						for rid in _theme.rids.instances:
							VisualServer.instance_set_transform(rid, xform)
							VisualServer.instance_set_transform(rid, xform)

				DebugTheme.ThemeType.HALO:
					xform.origin = Vector3.ZERO
					xform = xform.rotated(xform.basis.x, PI / 2)
					xform.origin = global_transform.origin
					var midway: Vector3 = 0.5 * _cast_to.length() * Vector3.DOWN
					for rid in _theme.rids.instances:
						xform = xform.translated(midway)
						VisualServer.instance_set_transform(rid, xform)


func _physics_process(delta: float) -> void:
	if is_colliding():
		_theme.material.set_shader_param("color", DebugPalette.COLORS[_theme.palette].contrasted())
		_cast_to = transform.xform_inv(get_collision_point())
	else:
		_theme.material.set_shader_param("color", DebugPalette.COLORS[_theme.palette])
		_cast_to = cast_to
	_draw()


func refresh() -> void:
	_draw()
	property_list_changed_notify()


func _draw() -> void:
	if not visible:
		return

	var meshes_info := []
	match _theme.theme:
		DebugTheme.ThemeType.WIREFRAME:
			var shape: Shape = RayShape.new()
			shape.length = _cast_to.length()
			var mesh := shape.get_debug_mesh()
			if mesh.get_surface_count() > 0:
				meshes_info.push_back({
					"primitive_type": VisualServer.PRIMITIVE_LINES,
					"arrays": mesh.surface_get_arrays(0)
				})
				shape = SphereShape.new()
				shape.radius = 0.03
				meshes_info.push_back({
					"primitive_type": VisualServer.PRIMITIVE_LINES,
					"arrays": shape.get_debug_mesh().surface_get_arrays(0)
				})

		DebugTheme.ThemeType.HALO:
			var mesh: PrimitiveMesh = CylinderMesh.new()
			mesh.top_radius = 0.01
			mesh.bottom_radius = mesh.top_radius
			mesh.height = _cast_to.length()
			mesh.radial_segments = 4
			mesh.rings = 0
			meshes_info.push_back({
				"primitive_type": VisualServer.PRIMITIVE_TRIANGLES,
				"arrays": mesh.get_mesh_arrays()
			})
			mesh = SphereMesh.new()
			mesh.radius = 0.03
			mesh.height = 2 * mesh.radius
			mesh.radial_segments = 16
			mesh.rings = 8
			meshes_info.push_back({
				"primitive_type": VisualServer.PRIMITIVE_TRIANGLES,
				"arrays": mesh.get_mesh_arrays()
			})

	if not meshes_info.empty():
		_theme.draw_meshes(meshes_info)
		_notification(NOTIFICATION_TRANSFORM_CHANGED)


func _get(property: String):
	return _theme.get_property(property)


func _get_property_list() -> Array:
	return _theme.get_property_list()


func _set(property: String, value) -> bool:
	var result := false
	match property:
		"visible": set_visible(value)
		_: result = _theme != null and _theme.set_property(property, value)
	return result


func set_visible(new_visible: bool) -> void:
	visible = new_visible
	_theme.set_visible(new_visible)
