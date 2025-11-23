extends CharacterBody2D

@export var speed = 200
@export var xp_reward = 20 

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

var player = null

func _ready():
	add_to_group("enemies")  # Important for bullet collision
	find_player()

func find_player():
	# Try multiple methods to find the player
	player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		player = get_tree().current_scene.get_node_or_null("Player")
	
	if player == null:
		# Search through parent's children
		var parent = get_parent()
		if parent:
			player = parent.get_node_or_null("Player")
	
	if player == null:
		print("WARNING: Enemy couldn't find player!")
		
func _physics_process(delta):
	if player == null or not is_instance_valid(player):
		find_player()
		return
	#if player.global_position.x < global_position.x:
	#	$AnimatedSprite2D.flip_h = true 
	#else:
	#	$AnimatedSprite2D.flip_h = false
	var direction = global_position.direction_to(player.global_position)

	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
	else:
		velocity = direction * speed
	
	move_and_slide()
	
	look_at(player.global_position)

func apply_knockback(direction: Vector2, force: float, knockback_duration: float):
	knockback = direction * force
	knockback_timer = knockback_duration

func die():
	if player != null and is_instance_valid(player) and player.has_method("gain_xp"):
		player.gain_xp(xp_reward)
		player.playEnemyDSound()
	
	queue_free()
