extends CharacterBody2D

@export var max_speed: float = 400.0       # vitesse maximale
@export var acceleration: float = 800.0    #accélration (quand A/D pressé)
@export var friction: float = 600.0        # décélération (quand aucune touche)
@export var projectile_scene: PackedScene
@export var max_projectiles: int = 10

var speed_x: float = 0.0

var screen_left: float
var screen_right: float
var half_width: float = 32.0  # ajuste selon la largeur réelle de ton sprite

func _ready() -> void:
	add_to_group("player")
	var vw = get_viewport_rect().size.x
	var vh = get_viewport_rect().size.y
	screen_left = 0.0
	screen_right = vw
	global_position = Vector2(vw / 2, vh - 50)


func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("gauche", "droite")

	if dir != 0:
		speed_x = move_toward(speed_x, dir * max_speed, acceleration * delta)
	else:
		speed_x = move_toward(speed_x, 0.0, friction * delta)

	velocity = Vector2(speed_x, 0.0)
	move_and_slide()

	global_position.x = clampf(global_position.x, screen_left + half_width, screen_right - half_width)

func shoot() -> void:
	# Vérifier combien de projectiles sont déjà actifs
	var current_projectiles = get_tree().get_nodes_in_group("projectiles").size()
	if current_projectiles >= max_projectiles:
		return  # limite atteinte

	# Instancier le projectile
	var bullet = projectile_scene.instantiate()
	bullet.position = global_position + Vector2(0, -30) # spawn devant le canon
	bullet.add_to_group("projectiles")
	
	# Ajouter dans la scène principale
	get_tree().current_scene.add_child(bullet)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot()


func respawn():
	# cacher le joueur comme s’il était détruit
	hide()
	set_physics_process(false)

	# Timer 2s avant réapparition
	var t = Timer.new()
	t.wait_time = 2.0
	t.one_shot = true
	t.timeout.connect(_on_respawn_timer_timeout)
	add_child(t)
	t.start()


func _on_respawn_timer_timeout():
	var vw = get_viewport_rect().size.x
	var vh = get_viewport_rect().size.y

	var new_pos = Vector2(randf_range(100, vw - 100), vh - 50)

	# vérifier qu’aucun boid n’est trop proche
	for b in get_tree().get_nodes_in_group("boids"):
		if b.global_position.distance_to(new_pos) < 120: # marge de sécurité
			return _on_respawn_timer_timeout()  # si trop proche → on retente

	global_position = new_pos
	show()
	set_physics_process(true)
