extends CharacterBody2D

@export var speed = 750

var active = true
var catchable = false 
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	
	set_collision_mask_value(2, false) 
	
	set_collision_mask_value(1, true)
	
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	
	await get_tree().create_timer(0.15).timeout
	catchable = true
	modulate = Color(1, 1, 1)
func _physics_process(delta):
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

func _on_pickup_area_body_entered(body):
	#print("Something entered the pickup zone: ", body.name)
	
	if not catchable:
		#print("...but the Safety Timer is not done yet!")
		return
		
	if body.has_method("reload"):
		#print("SUCCESS! Reloading Player.")
		body.reload()
		queue_free()
	else:
		print("no reload")
