extends Control

# We need to:
# 1. Share the world of the first viewport with the second viewport.
# 2. Create a remote transform attached to each player that pushes their position to the camera.
# This data structure helps us to do that conveniently. See the _ready() function below.
@onready var players: Array[Dictionary] = [
	{
		sub_viewport = %LeftSubViewport,
		camera = %LeftCamera2D,
		player = $"%Room2D/Player2D1",
	},
	{
		sub_viewport = %RightSubViewport,
		camera = %RightCamera2D,
		player = $"%Room2D/Player2D2",
	},
]


func _ready() -> void:
	# The world_2d object of the viewport contains information about what to
	# render. Here, it's our game level. We need to pass it from the first to
	# the second viewport for both of them to render the same level.
	players[1].sub_viewport.world_2d = players[0].sub_viewport.world_2d
	# For each player, we create a remote transform that pushes the character's
	# position to the corresponding camera.
	for info in players:
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = info.camera.get_path()
		info.player.add_child(remote_transform)
