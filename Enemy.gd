extends CharacterBody2D

@export var speed = 150
var player = null

func _ready():
	player = get_parent().get_node_or_null("Player")

func _physics_process(delta):
	if player != null:
		look_at(player.global_position)
		
		var direction = global_position.direction_to(player.global_position)
		
		velocity = direction * speed
		move_and_slide()
		
	
func die():
	queue_free() 
