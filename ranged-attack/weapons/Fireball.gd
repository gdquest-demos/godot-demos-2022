extends Projectile

onready var explosion_particles := $ExplosionParticles


func _on_impact(_body: Node) -> void:
	hitbox.set_disabled(false)
	get_tree().create_timer(.1).connect("timeout",self,"_disable_hitbox")
	speed = 0.0
	explosion_particles.emitting = true
	sprite.visible = false
	timer.start(0.6)


func _disable_hitbox():
	hitbox.set_disabled(true)
