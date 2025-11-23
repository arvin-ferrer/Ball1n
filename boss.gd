extends CharacterBody2D

# --- 1. ADD THE SIGNAL HERE ---
signal boss_died 
# ------------------------------

@export var speed = 300
@export var xp_reward = 100
@export var hp = 5
@export var MaxHp = 5
@export var bullet_scene: PackedScene 
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
	# --- OPTIMIZATION: Add groups once at start, not every frame ---
	add_to_group("enemies") 
	add_to_group("bosses") # Add this so the Main script can count them!
	# ---------------------------------------------------------------

	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.wait_time = fire_rate
	HPBar.max_value = MaxHp
	HPBar.value = hp

func _process(delta):
	if player:
		sprite.look_at(player.global_position)
	add_to_group("enemies")  # Important for bullet collision
	find_player()
	update_HpBar()
	
func find_player():
	# (Your existing find_player logic is fine, kept for brevity)
	if player == null:
		player = get_tree().get_first_node_in_group("Player")
	if player == null:
		player = get_tree().current_scene.get_node_or_null("Player")
	
	if player:
		look_at(player.global_position)
		currDistance = global_position.distance_to(player.global_position)
		
		# --- SHOOTING LOGIC FIX ---
		if currDistance <= distanceForTarget and is_shooting == false:
			shoot_timer.start()
			is_shooting = true
		elif currDistance > distanceForTarget and is_shooting == true:
			shoot_timer.stop() # Stop shooting when player runs away
			is_shooting = false
		# --------------------------

func _on_shoot_timer_timeout():
	if player and is_shooting: # Double check we are allowed to shoot
		shoot()

func shoot():
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.global_rotation = global_rotation
	get_tree().current_scene.add_child(bullet_instance)
	
func die():
	hp -= 1
	
	# Play Hit Sound
	if hp > 0:
		if is_instance_valid(player) and player.has_method("playBossHSound"):
			player.playBossHSound()
			
	# Death Logic
	if hp <= 0: # Use <= just to be safe
		if is_instance_valid(player):
			if player.has_method("gain_xp"):
				player.gain_xp(xp_reward)
			if player.has_method("playBossDSound"):
				player.playBossDSound()
		
		# --- 2. EMIT THE SIGNAL ---
		boss_died.emit() # Tell the Main Game "I am dead!"
		# --------------------------
		
		queue_free()
		
func update_HpBar():
	HPBar.value = hp
	# Simplified visibility logic
	HPBar.visible = (hp < MaxHp)
