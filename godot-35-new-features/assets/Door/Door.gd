extends StaticBody2D

var activated := false

onready var initial_rotation := rotation_degrees
onready var tween: Tween = $Tween
onready var hinge: Node2D = $Hinge


func _ready():
	var hinge_position := hinge.global_position
	hinge.set_as_toplevel(true)
	hinge.position = hinge_position


func activate() -> void:
	activated = not activated
	tween.stop_all()
	var target_rotation := initial_rotation
	if activated:
		target_rotation += 90

	tween.interpolate_property(
		self,
		"rotation_degrees",
		rotation_degrees,
		target_rotation,
		1.5,
		Tween.TRANS_ELASTIC,
		Tween.EASE_IN_OUT
	)
	tween.start()
