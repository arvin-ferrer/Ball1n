extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var activation_distance: float = 800.0  # Distance to activate spawner
@export var enabled: bool = true  # Toggle spawner on/off

var player: CharacterBody2D

func _ready():
	add_to_group("enemies")  # Important for bullet collision
	# Find player reference
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		player = get_tree().current_scene.get_node_or_null("Player")
	
	# Create and start the timer
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

func _on_timer_timeout():
	# Check if spawner is enabled
	if not enabled:
		return
	
	# Check if player exists
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return
	
	# Check if player is within activation distance
	var distance = global_position.distance_to(player.global_position)
	if distance > activation_distance:
		print("Player too far from spawner (distance: ", distance, ")")
		return
	
	# Check if enemy scene is assigned
	if enemy_scene == null:
		print("ERROR: No enemy scene assigned in Inspector!")
		return
	
	# Spawn enemy at this node's position
	var enemy = enemy_scene.instantiate()
	
	if enemy == null:
		print("ERROR: Failed to instantiate enemy!")
		return
	
	# Add to parent first, then set position
	get_parent().add_child(enemy)
	enemy.global_position = global_position
	
	print("Enemy spawned at: ", global_position)
