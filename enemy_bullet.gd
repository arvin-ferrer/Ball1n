extends CharacterBody2D
@export var speed = 750


func _ready():
	#set_collision_mask_value(2, false) 
	#set_collision_mask_value(1, true)
	
	velocity = Vector2.RIGHT.rotated(global_rotation) * speed
	
	await get_tree().create_timer(0.15).timeout
	modulate = Color(1, 1, 1)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		queue_free()
