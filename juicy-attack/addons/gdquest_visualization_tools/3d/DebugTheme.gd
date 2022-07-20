enum ThemeType {WIREFRAME, HALO}

const DebugUtils := preload("../DebugUtils.gd")
const DebugPalette := preload("../DebugPalette.gd")

const SHADERS := {
	ThemeType.WIREFRAME: preload("shaders/Wireframe.tres"),
	ThemeType.HALO: preload("shaders/Halo.tres")
}
const THEME_FRESNEL_POWER_PROPERTY := {
	"name": "theme_fresnel_power",
	"type": TYPE_REAL,
	"hint": PROPERTY_HINT_RANGE,
	"hint_string": "0.01,5"
}
const THEME_EDGE_INTENSITY_PROPERTY := {
	"name": "theme_edge_intensity",
	"type": TYPE_REAL,
	"hint": PROPERTY_HINT_RANGE,
	"hint_string": "0.0,5"
}

var palette_property := {
	"name": "palette",
	"type": TYPE_INT,
	"hint": PROPERTY_HINT_ENUM,
	"hint_string": DebugUtils.enum_to_string(DebugPalette.Type)
}
var theme_property := {
	"name": "theme",
	"type": TYPE_INT,
	"hint": PROPERTY_HINT_ENUM,
	"hint_string": DebugUtils.enum_to_string(ThemeType)
}



var _node: Spatial = null
var _previous_palette: int = DebugPalette.Type.INTERACT

var material := ShaderMaterial.new()
var rids := {"resources": [], "instances": []}
var is_implemented := false
var palette: int = _previous_palette
var theme: int = ThemeType.HALO
var theme_fresnel_power := 1.0
var theme_edge_intensity := 0.5


func _init(node: Spatial) -> void:
	_node = node
	is_implemented = _node is CollisionPolygon or _node is RayCast or _node is Path
	_set_palette(palette)
	_set_theme(theme)
	_set_theme_fresnel_power(theme_fresnel_power)
	_set_theme_edge_intensity(theme_edge_intensity)


func free_rids() -> void:
	for key in rids:
		for rid in rids[key]:
			funcref(VisualServer, "free_rid").call_func(rid)
		rids[key].clear()


func draw_meshes(meshes_info: Array) -> void:
	free_rids()
	for mesh_info in meshes_info:
		var material_RID: RID = mesh_info.get("material_override", material).get_rid()
		var mesh_RID := VisualServer.mesh_create()
		VisualServer.mesh_add_surface_from_arrays(mesh_RID, mesh_info.primitive_type, mesh_info.arrays)
		VisualServer.mesh_surface_set_material(mesh_RID, 0, material_RID)
		rids.instances.push_back(VisualServer.instance_create2(mesh_RID, _node.get_world().scenario))
		rids.resources.push_back(mesh_RID)


func get_shader() -> Shader:
	return SHADERS[theme]


func get_property_list() -> Array:
	var result := [] if _node is Path else [palette_property]
	match [is_implemented, theme]:
		[false, ThemeType.HALO]:
			_set_theme(ThemeType.WIREFRAME)
		[true, ThemeType.WIREFRAME]:
			result.push_back(theme_property)
		[true, ThemeType.HALO]:
			result.append_array([theme_property, THEME_FRESNEL_POWER_PROPERTY, THEME_EDGE_INTENSITY_PROPERTY])
	return result


func get_property(name: String):
	match name:
		"palette": return palette
		"theme": return theme
		"theme_fresnel_power": return theme_fresnel_power
		"theme_edge_intensity": return theme_edge_intensity


func set_property(name: String, value) -> bool:
	var method_name := "_set_%s" % [name]
	return has_method(method_name) and funcref(self, method_name).call_func(value)


func set_visible(new_visible: bool) -> void:
	_node.set_notify_transform(new_visible)
	for rid in rids.instances:
		VisualServer.instance_set_visible(rid, new_visible)


func _set_disabled_effect() -> void:
	if palette != DebugPalette.Type.DISABLED:
		_previous_palette = palette
	material.set_shader_param("color", DebugPalette.COLORS[palette])


func _set_disabled(new_disabled: bool) -> bool:
	palette = DebugPalette.Type.DISABLED if new_disabled else _previous_palette
	_set_disabled_effect()
	return false


func _set_enabled(new_enabled: bool) -> bool:
	_set_disabled(not new_enabled)
	return false


func _set_palette(new_palette: int) -> bool:
	palette = new_palette
	_set_disabled_effect()
	_node.set_deferred("disabled", palette == DebugPalette.Type.DISABLED)
	return true


func _set_theme(new_theme: int) -> bool:
	theme = new_theme
	material.shader = get_shader()
	_node.is_inside_tree() and _node.refresh()
	return true


func _set_theme_fresnel_power(new_theme_fresnel_power: float) -> bool:
	theme_fresnel_power = new_theme_fresnel_power
	material.set_shader_param("fresnel_power", theme_fresnel_power)
	return true


func _set_theme_edge_intensity(new_theme_edge_intensity: float) -> bool:
	theme_edge_intensity = new_theme_edge_intensity
	material.set_shader_param("edge_intensity", theme_edge_intensity)
	return true
