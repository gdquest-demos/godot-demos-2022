extends Spatial

onready var billboard_check_box: CheckBox = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/BillboardCheckBox
onready var depth_test_check_box: CheckBox = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/DepthTestCheckBox
onready var enemy_label: Label3D = $NavigationEnemy3D/Label3D
onready var player_label: Label3D = $Player3D/Label3D

onready var labels := [enemy_label, player_label]


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	billboard_check_box.pressed = enemy_label.billboard
	billboard_check_box.connect("toggled", self, "_on_BillboardCheckbox_toggled")
	
	depth_test_check_box.pressed = enemy_label.no_depth_test
	depth_test_check_box.connect("toggled", self, "_on_DepthTestCheckbox_toggled")


func _on_BillboardCheckbox_toggled(toggled: bool) -> void:
	for label in labels:
		label.billboard = toggled
	

func _on_DepthTestCheckbox_toggled(toggled: bool) -> void:
	for label in labels:
		label.no_depth_test = toggled
		if toggled:
			label.render_priority = 2
			label.outline_render_priority = 1
		else:
			label.render_priority = 0
			label.outline_render_priority = -1
