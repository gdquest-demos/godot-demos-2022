extends Node2D

export var damage:float = 3
export var speed:float = 5
export var lifetime:float = 3

onready var timer:Timer = $"%Timer"
onready var hitbox = $"%HitBox"

var direction:Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(position + direction)
	timer.start(lifetime)
	
	
func _physics_process(delta):
	position += direction * speed * delta * 100


func _on_CollisionBox_area_entered(_area):
	for collisionBox in hitbox.get_overlapping_areas():
		var enemy = collisionBox.owner
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
	queue_free()
	
	
func _on_Timer_timeout():
	queue_free()



