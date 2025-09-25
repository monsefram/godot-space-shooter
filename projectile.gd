extends Area2D

@export var speed: float = 600.0

func _physics_process(delta: float) -> void:
	position.y -= speed * delta
	if position.y < -10:
		queue_free()

func _ready() -> void:
	# Quand ce projectile entre en collision avec quelque chose, appelle _on_hit
	body_entered.connect(_on_hit)

func _on_hit(body):
	if body.is_in_group("boids"):
		body.queue_free()   # détruit le boid
		queue_free()        # détruit le projectile
