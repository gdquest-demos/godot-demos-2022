extends Spatial

onready var billboard_check_box: CheckBox = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/BillboardCheckBox
onready var depth_test_check_box: CheckBox = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/DepthTestCheckBox
onready var label_3d: Label3D = $NavigationEnemy3D/Label3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	billboard_check_box.pressed = label_3d.billboard
	billboard_check_box.connect("toggled", self, "_on_BillboardCheckbox_toggled")
	
	depth_test_check_box.pressed = label_3d.no_depth_test
	depth_test_check_box.connect("toggled", self, "_on_DepthTestCheckbox_toggled")


func _on_BillboardCheckbox_toggled(toggled: bool) -> void:
	label_3d.billboard = toggled
	

func _on_DepthTestCheckbox_toggled(toggled: bool) -> void:
	label_3d.no_depth_test = toggled
	if toggled:
		label_3d.render_priority = 2
		label_3d.outline_render_priority = 1
	else:
		label_3d.render_priority = 0
		label_3d.outline_render_priority = -1
