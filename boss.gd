extends CharacterBody2D

@export var speed = 300
@export var xp_reward = 100
@export var hp = 5
@export var MaxHp = 5
@export var bullet_scene: PackedScene # Drag your bullet scene here in the Inspector
@export var fire_rate: float = 0.5
@export var distanceForTarget: float = 700

@onready var muzzle: Marker2D = $Muzzle
@onready var shoot_timer: Timer = $ShootTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var HPBar: ProgressBar = $HPBar

var player = null
var currDistance
var is_shooting = false

func _ready():
	# Connect the timeout signal from ShootTimer
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.wait_time = fire_rate
	HPBar.max_value = MaxHp
	HPBar.value = hp

func _process(delta):
	sprite.rotation = -global_rotation
	add_to_group("enemies")  # Important for bullet collision
	find_player()
	update_HpBar()
	
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
		currDistance = global_position.distance_to(player.global_position)
		if currDistance<=distanceForTarget and is_shooting == false:
			shoot_timer.start()
			is_shooting = true
		elif currDistance>distanceForTarget and is_shooting == true:
			shoot_timer.start()
			is_shooting = false
	

func _on_shoot_timer_timeout():
	if player:
		shoot()

func shoot():
	# Instantiate the bullet and add it to the scene root (or a bullet container)
	var bullet_instance = bullet_scene.instantiate()
	
	# Set the bullet's position and rotation to the muzzle's position and rotation
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.global_rotation = global_rotation
	get_tree().current_scene.add_child(bullet_instance)
	
func die():
	hp -= 1
	if hp != 0:
		if player != null and is_instance_valid(player) and player.has_method("gain_xp"):
			player.playBossHSound()
	if hp == 0:
		if player != null and is_instance_valid(player) and player.has_method("gain_xp"):
			player.gain_xp(xp_reward)
			player.playBossDSound()
		queue_free()
		
func update_HpBar():
	HPBar.value = hp
	if hp >= MaxHp:
		HPBar.visible = false
	else:
		HPBar.visible = true
	
