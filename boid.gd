extends CharacterBody2D

@export var speed: float = 100.0
var direction: Vector2

func _ready() -> void:
	add_to_group("boids")
	direction = Vector2(randf_range(-1, 1), randf_range(0.2, 1)).normalized()

func _physics_process(delta: float) -> void:
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var body = collision.get_collider()
		if body.is_in_group("player"):
			body.respawn()

	# rebond sur les bords gauche/droit
	if global_position.x < 0 or global_position.x > get_viewport_rect().size.x:
		direction.x = -direction.x

	# empêcher de descendre trop bas (comme un sol invisible)
	if global_position.y > get_viewport_rect().size.y - 50:
		direction.y = -abs(direction.y)


func make_colored():
	if $Sprite2D:
		$Sprite2D.modulate = Color(randf(), randf(), randf())
