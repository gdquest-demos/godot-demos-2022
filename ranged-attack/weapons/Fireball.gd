extends Bullet


onready var hitbox := $HitBox
onready var impact_detector := $ImpactDetector
onready var explosion_particles := $ExplosionParticles


func _ready() -> void:
	impact_detector.connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body: Node) -> void:
	hitbox.set_disabled(false)
	speed = 0.0
	explosion_particles.emitting = true
