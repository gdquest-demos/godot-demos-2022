enum ThemeType { SIMPLE, DASHED, HALO }

const DebugUtils := preload("../DebugUtils.gd")
const DebugPalette := preload("../DebugPalette.gd")

const SHAPE_2D_SHADER := preload("shaders/Shape2D.tres")
const THEME_MAP := {
	ThemeType.HALO:
	{
		"CapsuleShape2D": preload("shaders/HaloCapsuleShape2D.tres"),
		"CircleShape2D": preload("shaders/HaloCircleShape2D.tres"),
		"RectangleShape2D": preload("shaders/HaloRectangleShape2D.tres"),
		"ConvexPolygonShape2D": preload("shaders/HaloPolygonShape2D.tres"),
		"CollisionPolygon2D": preload("shaders/HaloPolygonShape2D.tres"),
	}
}
const THEME_WIDTH_PROPERTY := {
	"name": "theme_width", "type": TYPE_INT, "hint": PROPERTY_HINT_RANGE, "hint_string": "0,10"
}
const THEME_SAMPLE_PROPERTY := {
	"name": "theme_sample", "type": TYPE_INT, "hint": PROPERTY_HINT_RANGE, "hint_string": "16,64"
}
const THEME_FALLOFF_PROPERTY := {
	"name": "theme_falloff",
	"type": TYPE_REAL,
	"hint": PROPERTY_HINT_RANGE,
	"hint_string": "0.025,1"
}

var _palette_property := {
	"name": "palette",
	"type": TYPE_INT,
	"hint": PROPERTY_HINT_ENUM,
	"hint_string": DebugUtils.enum_to_string(DebugPalette.Type)
}
var _theme_property := {
	"name": "theme",
	"type": TYPE_INT,
	"hint": PROPERTY_HINT_ENUM,
	"hint_string": DebugUtils.enum_to_string(ThemeType)
}
var _node: Node2D = null
var _previous_palette: int = DebugPalette.Type.INTERACT

var palette: int = _previous_palette
var theme: int = ThemeType.SIMPLE
var theme_width := 4
var theme_sample := 24
var theme_falloff := 0.25
var color: Color = DebugPalette.COLORS[palette]
var is_implemented := false


func _init(node: Node2D) -> void:
	_node = node
	_node.material = ShaderMaterial.new()
	is_implemented = _node is CollisionPolygon2D


func get_shader(key) -> Shader:
	return THEME_MAP.get(theme, {}).get(key, SHAPE_2D_SHADER)


func get_property_list() -> Array:
	var result := []
	match [is_implemented, theme, theme_width]:
		[false, _, _]:
			result = [_palette_property]
		[true, ThemeType.HALO, _]:
			result = [_palette_property, _theme_property, THEME_FALLOFF_PROPERTY]
		[true, _, 0]:
			result = [_palette_property, _theme_property, THEME_WIDTH_PROPERTY]
		_:
			result = [_palette_property, _theme_property, THEME_WIDTH_PROPERTY, THEME_SAMPLE_PROPERTY]
	return result


func get_property(name: String):
	match name:
		"palette": return palette
		"theme": return theme
		"theme_width": return theme_width
		"theme_sample": return theme_sample
		"theme_falloff": return theme_falloff


func set_property(name: String, value) -> bool:
	var method_name := "_set_%s" % [name]
	return has_method(method_name) and funcref(self, method_name).call_func(value)


func _set_disabled_effect() -> void:
	if palette != DebugPalette.Type.DISABLED:
		_previous_palette = palette
	color = DebugPalette.COLORS[palette]
	_node.self_modulate = color
	_node.update()


func _set_disabled(new_disabled: bool) -> bool:
	palette = DebugPalette.Type.DISABLED if new_disabled else _previous_palette
	_set_disabled_effect()
	return false


func _set_palette(new_palette: int) -> bool:
	palette = new_palette
	_set_disabled_effect()
	_node.set_deferred("disabled", palette == DebugPalette.Type.DISABLED)
	return true


func _set_theme(new_theme: int) -> bool:
	theme = new_theme
	_node.property_list_changed_notify()
	_node.update()
	return true


func _set_theme_width(new_theme_width: int) -> bool:
	theme_width = new_theme_width
	_node.update()
	return true


func _set_theme_sample(new_theme_sample: int) -> bool:
	theme_sample = new_theme_sample
	_node.update()
	return true


func _set_theme_falloff(new_theme_falloff: float) -> bool:
	theme_falloff = new_theme_falloff
	_node.material.set_shader_param("falloff", theme_falloff)
	return true
