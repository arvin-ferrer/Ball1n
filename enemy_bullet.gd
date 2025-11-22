extends CharacterBody2D
@export var speed = 750
@export var damage = 1
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	
	set_collision_mask_value(2, false) 
	set_collision_mask_value(1, true)
	
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	
	await get_tree().create_timer(0.15).timeout
	modulate = Color(1, 1, 1)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		print(collider)
		if collider.is_in_group("Player"):
			collider.takeDamage(damage)
			queue_free()
		else:
			queue_free()
			return
