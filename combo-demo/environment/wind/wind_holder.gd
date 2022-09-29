tool
extends Node2D

export(PackedScene) var strand_scene
export(Vector2) var size setget set_size
export(int) var strands_count = 2
export(int) var time_between = 4

var timers = []
var strands = []

var half_size = Vector2.ZERO

func set_size(new_size):
	size = new_size
	half_size = size / 2.0
	update()
	
func _draw():
	if not Engine.editor_hint: return
	draw_rect(Rect2(-half_size.x, -half_size.y, size.x, size.y), Color.lavender, false, 4.0)

func _ready():
	for i in strands_count:
		# Create timer
		var t = Timer.new()
		t.one_shot = true
		t.wait_time = time_between
		add_child(t)
		timers.append(t)
		# Create Strand
		var strand = strand_scene.instance()
		add_child(strand)
		strands.append(strand)
		# Launch strand
		t.start()
		launch_strand(i)
		yield(t, "timeout")

func launch_strand(strand_index):
	var strand = strands[strand_index]
	var timer = timers[strand_index]
	# Generate and place strand
	strand.generate_and_play(position, size)
	# Animate and wait ...
	yield(strand, "ended")
	# Wait and relaunch strand...
	timer.start()
	yield(timer, "timeout")
	launch_strand(strand_index)
