extends CharacterBody2D
@export var speed = 750
var active = true
var catchable = false 
var screen_size
var returning = false
var player_ref = null

func _ready():
	screen_size = get_viewport_rect().size
	
	set_collision_mask_value(2, false) 
	set_collision_mask_value(1, true)
	
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	
	# Find and store player reference
	player_ref = get_tree().get_first_node_in_group("player")
	if player_ref == null:
		player_ref = get_tree().get_current_scene().get_node_or_null("Player")
	
	await get_tree().create_timer(0.15).timeout
	catchable = true
	modulate = Color(1, 1, 1)

func _physics_process(delta):
	if returning:
		# Move towards player
		if player_ref != null and is_instance_valid(player_ref):
			var direction = (player_ref.global_position - global_position).normalized()
			velocity = direction * speed * 1.5  # Faster return
			rotation = velocity.angle()
			
			# Check if close enough to player
			if global_position.distance_to(player_ref.global_position) < 20:
				queue_free()
		else:
			queue_free()
		return
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		
		if collider.name == "Player" or collider.has_method("reload"):
			return 
		if collider.is_in_group("enemies"):
			collider.die()
			bounce_bullet(collision.get_normal())
		else:
			bounce_bullet(collision.get_normal())
	
	if position.x < 0:
		position.x = 0
		bounce_bullet(Vector2.RIGHT)
	elif position.x > screen_size.x:
		position.x = screen_size.x
		bounce_bullet(Vector2.LEFT)
	if position.y < 0:
		position.y = 0
		bounce_bullet(Vector2.DOWN)
	elif position.y > screen_size.y:
		position.y = screen_size.y
		bounce_bullet(Vector2.UP)

func bounce_bullet(normal_vector):
	velocity = velocity.bounce(normal_vector)
	rotation = velocity.angle()

func return_to_player():
	returning = true
	catchable = false
	set_collision_mask_value(1, false)  # Disable collisions while returning

func _on_pickup_area_body_entered(body):
	if not catchable:
		return
		
	if body.has_method("reload"):
		body.reload()
		queue_free()
	else:
		print("no reload")
