extends Spatial

onready var physics_label := $"%PhysicsLabel" as Label 
onready var hslider := $"%HSlider" as HSlider
onready var interpolation_toggle := $"%InterpolationToggle" as CheckBox

onready var tree := get_tree()


func _ready() -> void:
	hslider.connect("value_changed", self, "_update_physics_properties")
	interpolation_toggle.connect("toggled", self, "_toggle_physics_interpolation")
	interpolation_toggle.pressed = tree.physics_interpolation
	hslider.value = Engine.iterations_per_second


func _update_physics_properties(new_physics_fps: float) -> void:
	Engine.iterations_per_second = int(new_physics_fps)
	physics_label.text = "Physics FPS (%s)" % str(Engine.iterations_per_second).pad_zeros(2)


func _toggle_physics_interpolation(is_on: bool) -> void:
	tree.physics_interpolation = is_on
