extends Node2D

@export var boid_scene: PackedScene
@export var boid_count: int 
#@export var respawn_time: float = 5.0   # toutes les X secondes un boid revient

var current_boids: Array = []

func _ready() -> void:
	
	boid_count = randi_range(10, 20)
	spawn_initial_boids()
	## Timer pour respawn
	#var timer = Timer.new()
	#timer.wait_time = respawn_time
	#timer.autostart = true
	#timer.one_shot = false
	#timer.timeout.connect(_on_respawn_timeout)
	#add_child(timer)
	

func spawn_initial_boids() -> void:
	var vw = get_viewport_rect().size.x
	for i in range(boid_count):
		spawn_one_boid(Vector2(randf_range(50, vw - 50), randf_range(50, 200)))

func spawn_one_boid(pos: Vector2, colored := false) -> void:
	var boid = boid_scene.instantiate()
	boid.global_position = pos
	
	if colored:
		boid.make_colored()
	
	add_child(boid)
	current_boids.append(boid)
	boid.tree_exited.connect(_on_boid_destroyed.bind(boid))


func _on_boid_destroyed(boid) -> void:
	current_boids.erase(boid)

	var vw = get_viewport_rect().size.x
	# respawn immédiat, mais coloré
	spawn_one_boid(Vector2(randf_range(50, vw - 50), randf_range(50, 200)), true)

func _on_respawn_timeout() -> void:
	if current_boids.size() < boid_count:
		var vw = get_viewport_rect().size.x
		spawn_one_boid(Vector2(randf_range(50, vw - 50), randf_range(50, 200)), true)
