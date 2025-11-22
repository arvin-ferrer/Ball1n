extends CharacterBody2D

@export var speed = 200
@export var xp_reward = 20 

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
	if player != null and player.has_method("gain_xp"):
		player.gain_xp(xp_reward)
	queue_free()
