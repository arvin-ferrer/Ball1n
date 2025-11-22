extends CharacterBody2D

@export var speed = 300
@export var xp_reward = 100
@export var hp = 3
@export var bullet_scene: PackedScene # Drag your bullet scene here in the Inspector
@export var rotation_speed: float = 2.0
@export var fire_rate: float = 0.5

@onready var muzzle: Marker2D = $Muzzle
@onready var detection_area: Area2D = $DetectionArea
@onready var shoot_timer: Timer = $ShootTimer
var player = null

func _ready():
	# Connect signals from DetectionArea
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	# Connect the timeout signal from ShootTimer
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.wait_time = fire_rate

func _process(delta):
	add_to_group("enemies")  # Important for bullet collision
	find_player()
func find_player():
	## Try multiple methods to find the player
	player = get_tree().get_first_node_in_group("Player")
	if player == null:
		player = get_tree().current_scene.get_node_or_null("Player")
	#
	if player == null:
		## Search through parent's children
		var parent = get_parent()
		if parent:
			player = parent.get_node_or_null("Player")
	if player == null:
		print("WARNING: Enemy couldn't find player!")
	if player:
		look_at(player.global_position)

func _on_detection_area_body_entered(body):
	# Check if the entered body is the player by checking its group
	if player:
		shoot_timer.start()

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		shoot_timer.stop()

func _on_shoot_timer_timeout():
	if player:
		shoot()

func shoot():
	# Instantiate the bullet and add it to the scene root (or a bullet container)
	var bullet_instance = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet_instance)
	
	# Set the bullet's position and rotation to the muzzle's position and rotation
	bullet_instance.global_position = muzzle.global_position
	
func die():
	hp -= 1
	if hp == 0:
		if player != null and is_instance_valid(player) and player.has_method("gain_xp"):
			player.gain_xp(xp_reward)
		queue_free()
	# Optional: Call a function on the bullet to set its direction/velocity if needed
	#if "set_direction" in bullet_instance:
		#bullet_instance.set_direction(Boss.transform.global_rotation)
#
#func _ready():
	#add_to_group("enemies")  # Important for bullet collision
	#find_player()
#
#func find_player():
	## Try multiple methods to find the player
	#player = get_tree().get_first_node_in_group("player")
	#
	#if player == null:
		#player = get_tree().current_scene.get_node_or_null("Player")
	#
	#if player == null:
		## Search through parent's children
		#var parent = get_parent()
		#if parent:
			#player = parent.get_node_or_null("Player")
	#
	#if player == null:
		#print("WARNING: Enemy couldn't find player!")
#
#func _physics_process(delta):
	## If we still don't have a player reference, try to find it
	#if player == null or not is_instance_valid(player):
		#find_player()
		#return
	#
	#look_at(player.global_position)
	#
	#var direction = global_position.direction_to(player.global_position)
	#
	#velocity = direction * speed
	#move_and_slide()
#
