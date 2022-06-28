tool
extends Area2D

export var target_path: NodePath
export var texture_normal: Texture = preload("pressurePlate.png")
export var texture_pressed: Texture = preload("pressurePlatePressed.png")

onready var _sprite := $Sprite
onready var _target: Node2D = get_node_or_null(target_path)

# ANCHOR: ready
func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
# END: ready


func _draw() -> void:
	if not _target or not Engine.editor_hint:
		return
	draw_line(Vector2.ZERO, _target.global_position - global_position, Color.aliceblue, 8.0)


# ANCHOR: callbacks
func _on_body_entered(_body: PhysicsBody2D):
	_sprite.texture = texture_pressed
	if _target and _target.has_method("activate"):
		_target.activate()


func _on_body_exited(_body: PhysicsBody2D):
	_sprite.texture = texture_normal
# END: callbacks
