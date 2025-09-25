extends Arrow2D

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _hit_area: Area2D = %HitArea2D
@onready var _explosion_particles: GPUParticles2D = %ExplosionGPUParticles2D


func _on_impact_detector_area_body_entered(_body: Node2D) -> void:
	speed = 0.0

	_sprite.visible = false
	_explosion_particles.emitting = true
	_hit_area.set_disabled(false)

	get_tree().create_timer(.1).timeout.connect(_hit_area.set_disabled.bind(true))
	_timer.start(0.6)
