extends Label

func _process(delta: float) -> void:
	text = "FPS: " + str(Engine.get_frames_per_second()).pad_zeros(4)
