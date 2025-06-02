extends Node2D
tool

var resolution : int = 4
var sections = 0
export(Array, Resource) var themes
export(Texture) var tip_texture
export(PackedScene) var branch_scene
export(Curve) var branches_scale : Curve
export var branch_offset = 0
var bones_ref = []

export(float, 10,10000,10) onready var height setget set_height
export(float, 0.1, 2.0) var base_scale  setget set_base_scale
export var branch_count = 8

func _ready():
	generate()

func set_base_scale(new_base_scale):
	base_scale = new_base_scale
	scale = Vector2.ONE * base_scale
	
func set_height(new_height):
	height = new_height
	generate()

func generate():
	if !is_inside_tree(): return
	
	sections = height / (resolution - 1)
	
	var points : PoolVector2Array = [];
	var uv_points : PoolVector2Array = [];
	
	var uv_size = Vector2(128, $Body.texture.get_height())
	
	for i in range(resolution * 2):
		var x = 0
		var y_id = (i % resolution)
		if i >= resolution:
			y_id = abs(y_id - (resolution - 1))
			x = uv_size.x
		var y = y_id * -sections
		points.append(Vector2(x, y))
		uv_points.append(Vector2(x, y))

	$Body.polygon = points
	$Body.uv = uv_points
	# Set bones :(
	$Body.clear_bones()
	bones_ref = []
	# Remove all bones
	for child in $Skeleton.get_children():
		child.queue_free()
	
	var last_child = $Skeleton
	for i in range(resolution - 1):
		var b = Bone2D.new()
		if i > 0 :b.position.y = -sections
		b.rest = b.transform
		last_child.add_child(b)
		bones_ref.append(b)
		last_child = b
		
		var weights = []
		for _w in range(resolution * 2):
			weights.append(0.0)
		weights[(i + 1)] = 1.0
		weights[(resolution * 2 - 1) - (i + 1)] = 1.0
		$Body.add_bone(b.get_path(), PoolRealArray(weights))
	
	# Add tip :)
	var tip_sprite = Sprite.new()
	tip_sprite.texture = tip_texture
	tip_sprite.position.y = -sections
	tip_sprite.material = $Body.material
	last_child.add_child(tip_sprite)
	
	var total_branches = branch_count * (bones_ref.size())
		
	# Distribute branches along bone
	for bone_index in range(0, bones_ref.size()):
		for branch_index in range(branch_count):
			var global_branch_index = ((bone_index) * branch_count) + branch_index
			var branch_percent = (float(global_branch_index)/(total_branches))
			
			var branch_size = branches_scale.interpolate(branch_percent)

			
			if branch_percent < 0.1: continue
			var branch = branch_scene.instance()

			var y_offset = ( (float(branch_index)/branch_count)) * -sections
			
			branch.position.y = y_offset
			branch.position.x = branch_offset
			branch.scale = Vector2.ONE * branch_size
			
			if int(global_branch_index) % 2 == 0:
				branch.scale.x *= -1
				branch.position.x *= -1

			bones_ref[bone_index].add_child(branch)

	# Set colors
	randomize()
	var color_point = rand_range(0,1);
	var theme = themes[randi() % themes.size()]
	var m : ShaderMaterial = $Body.material
	m.set_shader_param("base_color", theme.diffuse.interpolate(color_point))
	m.set_shader_param("light_color", theme.light.interpolate(color_point))
	m.set_shader_param("occlusion_color", theme.occlusion.interpolate(color_point))
	m.set_shader_param("detail_colors", theme.details.interpolate(color_point))
	
func _process(_delta):
	var t = Time.get_ticks_msec() / 2000.0
	t += position.x
	for bone_index in bones_ref.size():
		bones_ref[bone_index].rotation = sin(t - (bone_index * 0.1)) * 0.01
