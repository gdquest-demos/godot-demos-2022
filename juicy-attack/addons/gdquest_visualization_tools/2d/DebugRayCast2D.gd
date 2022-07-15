tool
class_name DebugRayCast2D
extends RayCast2D


enum ThemeType { SIMPLE, DASHED }

const DebugUtils := preload("../DebugUtils.gd")
const DebugPalette := preload("../DebugPalette.gd")

const THEME_SAMPLE := 48

export(DebugPalette.Type) var palette := DebugPalette.Type.INTERACT setget set_palette
export(ThemeType) var theme := ThemeType.SIMPLE setget set_theme
export(int, 0, 10) var theme_width := 4 setget set_theme_width

var _previous_palette: int = palette
var _color: Color = DebugPalette.COLORS[palette]
var _cast_to := cast_to


func _ready() -> void:
	if not Engine.editor_hint:
		add_to_group("GVTCollision")


func _physics_process(delta: float) -> void:
	if is_colliding():
		_color = DebugPalette.COLORS[palette].contrasted()
		_cast_to = transform.xform_inv(get_collision_point())
	else:
		_color = DebugPalette.COLORS[palette]
		_cast_to = cast_to
	update()


func _draw() -> void:
	if not visible:
		return

	draw_circle(_cast_to, theme_width, _color)
	match theme:
		ThemeType.SIMPLE:
			draw_line(Vector2.ZERO, _cast_to, _color, theme_width)
			draw_arc(_cast_to, 3 * theme_width, 0, TAU, THEME_SAMPLE, _color, theme_width / 2)
		ThemeType.DASHED:
			DebugUtils.draw_polyline_dashed(
				self, _get_curve_line(), _color, theme_width, THEME_SAMPLE
			)
			var circle_curve := DebugUtils.get_curve_circle(
				3 * theme_width, THEME_SAMPLE / 2, Transform2D.IDENTITY.translated(_cast_to)
			)
			DebugUtils.draw_polyline_dashed(
				self, circle_curve, _color, theme_width / 2, THEME_SAMPLE
			)


func _get_curve_line() -> Curve2D:
	var result := Curve2D.new()
	result.add_point(Vector2.ZERO)
	result.add_point(_cast_to)
	return result


func _set_enabled_effect() -> void:
	if palette != DebugPalette.Type.DISABLED:
		_previous_palette = palette
	_color = DebugPalette.COLORS[palette]
	update()


func _set(property: String, value) -> bool:
	match property:
		"enabled":
			palette = _previous_palette if value else DebugPalette.Type.DISABLED
			_set_enabled_effect()
	return false


func set_palette(new_palette: int) -> void:
	palette = new_palette
	set_deferred("enabled", palette != DebugPalette.Type.DISABLED)
	_set_enabled_effect()


func set_theme(new_theme: int) -> void:
	theme = new_theme
	update()


func set_theme_width(new_theme_width: int) -> void:
	theme_width = new_theme_width
	update()
