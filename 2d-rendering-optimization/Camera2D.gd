extends Camera2D

const ZOOM_LOWER_LIMIT := 0.5
const ZOOM_UPPER_LIMIT := 10.0
const ZOOM_BASE_STEP := 1.0

export var speed := 1000.0
export var zoom_speed := 10.0
export var smooth_zoom := 1.0 setget set_smooth_zoom


func _ready() -> void:
	zoom = Vector2.ONE * smooth_zoom


func _process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += direction * speed * smooth_zoom * delta

	if abs(zoom.x - smooth_zoom) > 0.005:
		zoom = lerp(zoom, Vector2.ONE * smooth_zoom, delta * zoom_speed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		set_smooth_zoom(smooth_zoom - ZOOM_BASE_STEP * smooth_zoom / ZOOM_UPPER_LIMIT)
	elif event.is_action_pressed("zoom_out"):
		set_smooth_zoom(smooth_zoom + ZOOM_BASE_STEP * smooth_zoom / ZOOM_UPPER_LIMIT)


func set_smooth_zoom(value: float) -> void:
	smooth_zoom = clamp(value, ZOOM_LOWER_LIMIT, ZOOM_UPPER_LIMIT)
