extends Spatial

onready var _camera: Camera = $CameraFollow/Camera
onready var _cursor: Spatial = $Cursor
onready var _navigation: Navigation = $Navigation
onready var _navigation_mesh_instance: NavigationMeshInstance = $Navigation/NavigationMeshInstance
onready var _player = $GridMovementPlayer3D


func _unhandled_input(event: InputEvent) -> void:
	# ANCHOR: camera_raycast
	if event is InputEventMouseMotion:
		var from := _camera.project_ray_origin(event.position)
		var to := from + _camera.project_ray_normal(event.position) * 9999.0
		var space := get_world().direct_space_state
		var result := space.intersect_ray(from, to)
		if result:
			var point = _navigation.get_closest_point(result["position"])
			# We need to negatively offset the point we get on the navigation
			# mesh by 2 x the height set on the Navigation Mesh Instance on the
			# y-axis for it to align exactly with the mesh.
			point -= Vector3(0.0, _navigation_mesh_instance.navmesh.get("cell/height") * 2.0, 0.0)
			_set_grid_cursor(point)
	# END: camera_raycast
	# ANCHOR: on_click
	if event.is_action_pressed("shoot_3d"):
		_player.set_destination(_cursor.global_transform.origin)
	# END: on_click


# ANCHOR: set_grid_cursor
func _set_grid_cursor(position: Vector3) -> void:
	position = position.snapped(Vector3(1.0, 1.0, 1.0))
	_cursor.global_transform.origin = position
# END: set_grid_cursor
