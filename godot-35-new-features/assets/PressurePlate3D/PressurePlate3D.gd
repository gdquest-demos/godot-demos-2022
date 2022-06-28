tool
# ANCHOR: properties
extends Area

export var target_path: NodePath

onready var _target: Spatial = get_node_or_null(target_path)
# END: properties
onready var _tween: Tween = $Tween
onready var _button_mesh: Spatial = $PressurePlate/pressure_plate_base/pressure_plate_top


# ANCHOR: ready
func _ready() -> void:
	connect("body_entered", self, "_on_PressurePlate_body_entered")
	connect("body_exited", self, "_on_PressurePlate_body_exited")
# END: ready


# ANCHOR: callbacks
func _on_PressurePlate_body_entered(_body: PhysicsBody2D):
	_tween.interpolate_property(_button_mesh, "translation", Vector3(0.0, 0.0, 0.0), Vector3(0.0, -0.10, 0.0), 0.2,Tween.TRANS_CUBIC)
	_tween.start()
	if _target and _target.has_method("activate"):
		_target.activate()


func _on_PressurePlate_body_exited(_body: PhysicsBody2D):
	_tween.interpolate_property(_button_mesh, "translation", Vector3(0.0, -0.10, 0.0), Vector3(0.0, 0.00, 0.0), 0.3,Tween.EASE_OUT)
	_tween.start()
# END: callbacks
