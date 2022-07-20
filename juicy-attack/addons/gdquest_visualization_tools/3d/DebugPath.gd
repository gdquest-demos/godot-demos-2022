tool
class_name DebugPath
extends Path


const DebugUtils := preload("../DebugUtils.gd")
const DebugTheme := preload("DebugTheme.gd")

const DELTA := 0.01

export(int, 0, 100) var samples := 10 setget set_samples

var _theme := DebugTheme.new(self)
var _end_sphere_material := _theme.material.duplicate()
var _spheres := [SphereShape.new(), SphereMesh.new()]
var _pointer := CylinderMesh.new()
var _pointer_mesh_RID := RID()
var _pointer_multimesh_RID := RID()
var _pointer_instance_RID := RID()


func _init() -> void:
	_end_sphere_material.set_shader_param("fresnel_power", 0.15)
	_end_sphere_material.set_shader_param("edge_intensity", 1.1)
	_spheres[0].radius = 0.06
	_spheres[1].radius = _spheres[0].radius
	_spheres[1].height = 2 * _spheres[1].radius
	_spheres[1].radial_segments = 16
	_spheres[1].rings = 8
	_pointer.radial_segments = 4
	_pointer.rings = 0


func _ready() -> void:
	connect("curve_changed", self, "refresh")
	set_notify_transform(true)
	if not Engine.editor_hint:
		add_to_group("GVTNavigation")


func _enter_tree() -> void:
	refresh()


func _exit_tree() -> void:
	_theme.free_rids()
	_free_pointer_rids()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			var xform := global_transform
			xform.origin = global_transform.xform(curve.get_point_position(0))
			VisualServer.instance_set_transform(_theme.rids.instances[0], xform)
			xform.origin = global_transform.xform(curve.get_point_position(curve.get_point_count() - 1))
			VisualServer.instance_set_transform(_theme.rids.instances[1], xform)
			if _theme.theme == DebugTheme.ThemeType.WIREFRAME:
				VisualServer.instance_set_transform(_theme.rids.instances[2], global_transform)

			xform = global_transform
			var unit := curve.get_baked_length() / (samples + 1)
			var n := samples if _theme.theme == DebugTheme.ThemeType.WIREFRAME else int(curve.get_baked_length() / curve.bake_interval)
			for index in range(n):
				var t := (index + 1) * unit if _theme.theme == DebugTheme.ThemeType.WIREFRAME else (index + 0.5) * curve.bake_interval
				var offset1: Vector3 = global_transform.xform(curve.interpolate_baked(t))
				var offset2: Vector3 = global_transform.xform(curve.interpolate_baked(t - DELTA))
				var direction := offset1 - offset2
				xform.origin = offset1
				xform = xform.looking_at(offset1 + DebugUtils.v3normal(direction), direction)
				VisualServer.multimesh_instance_set_transform(_pointer_multimesh_RID, index, xform)

			if _theme.theme == DebugTheme.ThemeType.HALO:
				var t := n * curve.bake_interval + 0.5 * (curve.get_baked_length() - n * curve.bake_interval)
				var offset1: Vector3 = global_transform.xform(curve.interpolate_baked(t))
				var offset2: Vector3 = global_transform.xform(curve.interpolate_baked(t - DELTA))
				var direction := offset1 - offset2
				xform.origin = offset1
				xform = xform.looking_at(offset1 + DebugUtils.v3normal(direction), direction)
				xform.basis.y *= curve.get_baked_length()/curve.bake_interval - n
				VisualServer.multimesh_instance_set_transform(_pointer_multimesh_RID, n, xform)


func refresh() -> void:
	_free_pointer_rids()
	_draw()
	property_list_changed_notify()


func _free_pointer_rids() -> void:
	VisualServer.free_rid(_pointer_mesh_RID)
	VisualServer.free_rid(_pointer_multimesh_RID)
	VisualServer.free_rid(_pointer_instance_RID)



func _draw() -> void:
	if not visible:
		return

	match _theme.theme:
		DebugTheme.ThemeType.WIREFRAME:
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_LINES)
			for sample in range(curve.get_baked_length() / curve.bake_interval):
				st.add_vertex(curve.interpolate_baked(sample * curve.bake_interval))
			st.add_vertex(curve.interpolate_baked(curve.get_baked_length()))

			var meshes_info := [{
				"primitive_type": VisualServer.PRIMITIVE_LINES,
				"arrays": _spheres[0].get_debug_mesh().surface_get_arrays(0)
			}, {
				"primitive_type": VisualServer.PRIMITIVE_TRIANGLES,
				"arrays": _spheres[1].get_mesh_arrays()
			}, {
				"primitive_type": VisualServer.PRIMITIVE_LINE_STRIP,
				"arrays": st.commit_to_arrays()
			}]
			_theme.draw_meshes(meshes_info)

			_pointer.bottom_radius = 0.06
			_pointer.top_radius = 0
			_pointer.height = 2 * _pointer.bottom_radius
			_pointer_mesh_RID = VisualServer.mesh_create()
			VisualServer.mesh_add_surface_from_arrays(_pointer_mesh_RID, VisualServer.PRIMITIVE_LINES, _pointer.get_mesh_arrays())
			VisualServer.mesh_surface_set_material(_pointer_mesh_RID, 0, _theme.material.get_rid())
			_pointer_multimesh_RID = VisualServer.multimesh_create()
			VisualServer.multimesh_set_mesh(_pointer_multimesh_RID, _pointer_mesh_RID)
			VisualServer.multimesh_allocate(_pointer_multimesh_RID, samples, VisualServer.MULTIMESH_TRANSFORM_3D, VisualServer.MULTIMESH_COLOR_NONE)
			_pointer_instance_RID = VisualServer.instance_create2(_pointer_multimesh_RID, get_world().scenario)

		DebugTheme.ThemeType.HALO:
			var meshes_info := [{
				"primitive_type": VisualServer.PRIMITIVE_TRIANGLES,
				"arrays": _spheres[1].get_mesh_arrays()
			}, {
				"primitive_type": VisualServer.PRIMITIVE_TRIANGLES,
				"arrays": _spheres[1].get_mesh_arrays(),
				"material_override": _end_sphere_material
			}]
			_theme.draw_meshes(meshes_info)

			_pointer.bottom_radius = 0.03
			_pointer.top_radius = _pointer.bottom_radius
			_pointer.height = curve.bake_interval
			_pointer_mesh_RID = VisualServer.mesh_create()
			VisualServer.mesh_add_surface_from_arrays(_pointer_mesh_RID, VisualServer.PRIMITIVE_TRIANGLES, _pointer.get_mesh_arrays())
			VisualServer.mesh_surface_set_material(_pointer_mesh_RID, 0, _theme.material.get_rid())
			_pointer_multimesh_RID = VisualServer.multimesh_create()
			VisualServer.multimesh_set_mesh(_pointer_multimesh_RID, _pointer_mesh_RID)
			var pointers := int(curve.get_baked_length() / curve.bake_interval) + 1
			VisualServer.multimesh_allocate(_pointer_multimesh_RID, pointers, VisualServer.MULTIMESH_TRANSFORM_3D, VisualServer.MULTIMESH_COLOR_NONE)
			_pointer_instance_RID = VisualServer.instance_create2(_pointer_multimesh_RID, get_world().scenario)

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
	VisualServer.instance_set_visible(_pointer_instance_RID, visible)
	_theme.set_visible(new_visible)


func set_samples(new_samples: int) -> void:
	samples = new_samples
	refresh()
