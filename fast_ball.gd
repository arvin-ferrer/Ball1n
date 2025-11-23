extends "res://Bullet.gd"

@export var pierce_count: int = 3  # Number of enemies it can pierce through
@export var pierce_damage: int = 25  # Damage per hit
var pierced_enemies: Array = []  # Track enemies we've already hit

func _ready():
	
	super._ready()
	# Override parent properties for fast piercing behavior
	speed = 1200  # Much faster than normal bullet
	active = true
	
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, false)
	
	# Initialize velocity with higher speed
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	
	# Don't wait for catchable timer for piercing balls
	modulate = Color(1, 0.5, 0.5)  # Different color to distinguish

func handle_enemy_collision(enemy):
	# Check if we've already hit this enemy
	if enemy in pierced_enemies:
		return
	
	# Apply damage
	if enemy.has_method("die"):
		enemy.die()
	elif enemy.has_method("take_damage"):
		enemy.take_damage(pierce_damage)
	
	# Add to pierced enemies list
	pierced_enemies.append(enemy)
	
	# Check if we should stop piercing
	if pierced_enemies.size() >= pierce_count:
		queue_free()
	
	# Don't bounce - continue straight through
	# Remove the bounce_bullet call from parent behavior

func _physics_process(delta):
	if returning:
		# Handle return logic if needed
		if player_ref != null and is_instance_valid(player_ref):
			var direction = (player_ref.global_position - global_position).normalized()
			velocity = direction * speed * 1.5
			rotation = velocity.angle()
			
			if global_position.distance_to(player_ref.global_position) < 20:
				queue_free()
		else:
			queue_free()
		return
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		
		# Skip player collisions
		if collider.name == "Player" or collider.has_method("reload"):
			return 
		
		# Handle enemy collisions with piercing
		if collider.is_in_group("enemies"):
			handle_enemy_collision(collider)
			# Don't bounce - continue through enemies
		else:
			# Still bounce off walls/obstacles
			bounce_bullet(collision.get_normal())

# Optional: Add visual effects to distinguish piercing ball
func _draw():
	draw_circle(Vector2.ZERO, 8, Color(1, 0.3, 0.3))
	draw_circle(Vector2.ZERO, 4, Color(1, 1, 1))
