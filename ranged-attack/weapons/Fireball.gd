extends Bullet


onready var explosion_particles := $ExplosionParticles


func _on_impact(_body: Node) -> void:
	hitbox.set_disabled(false)
	speed = 0.0
	explosion_particles.emitting = true
	sprite.visible = false
	timer.start(0.7)
