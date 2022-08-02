extends Node


onready var players := {
	"1": {
		viewport = $Row/LeftViewportContainer/Viewport,
		camera = $Row/LeftViewportContainer/Viewport/Camera2D,
		player = $Row/LeftViewportContainer/Viewport/Level/Player1
	},
	"2": {
		viewport = $Row/RightViewportContainer/Viewport,
		camera = $Row/RightViewportContainer/Viewport/Camera2D,
		player = $Row/LeftViewportContainer/Viewport/Level/Player2
	}
}


func _ready() -> void:
	players["2"].viewport.world_2d = players["1"].viewport.world_2d
	for node in players.values():
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player.add_child(remote_transform)
