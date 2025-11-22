extends CharacterBody2D 
signal hit
@export var speed = 400
@export var bullet_scene: PackedScene
var screen_size
var has_bullet = true
var max_health: int = 3
var current_health = max_health
var heart_list : Array[TextureRect]
var damage_cooldown = 1
var time_since_hit = 0.0
var current_bullet = null  # Track the current bullet
var xp: int = 0
var level: int = 1
var xp_to_next_level: int = 100


func gain_xp(amount):
	xp += amount
	print("Gained XP! Total: ", xp, "/", xp_to_next_level)
	
	# Check for Level Up
	if xp >= xp_to_next_level:
		level_up()
	
	update_exp(xp)
	
func level_up():
	xp -= xp_to_next_level  
	level += 1
	xp_to_next_level = int(xp_to_next_level * 1.5)
	
	speed += 50 
	print("LEVEL UP! You are now Level ", level)
	
	update_exp(xp)
	

func update_exp(xp):
	var exp_var = get_tree().get_current_scene().get_node("Bars/ExpBar")
	
	exp_var.value = xp
	exp_var.max_value = xp_to_next_level
func _ready():
	screen_size = get_viewport_rect().size
	var heart_container = get_tree().get_current_scene().get_node("Bars/HBoxContainer")
	for child in heart_container.get_children():
		heart_list.append(child)
	
	update_healthbar()	
	update_exp(xp)

func _physics_process(_delta):
	time_since_hit += _delta
	# Movement Logic
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	
	look_at(get_global_mouse_position())
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	move_and_slide()
	
	# Shooting
	if Input.is_action_just_pressed("shoot"):
		if has_bullet:
			fire_bullet()
		else:
			print("no bullet")
	
	# Enemy Collision Check
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("enemies") and time_since_hit >= damage_cooldown:
			take_damage(1)
			time_since_hit = 0.0
			
func fire_bullet():
	if bullet_scene == null:
		print("ERROR: No Bullet Scene assigned!")
		return
	var b = bullet_scene.instantiate()
	b.global_position = $Muzzle.global_position
	b.rotation = rotation
	get_tree().root.add_child(b)
	current_bullet = b  # Track the bullet
	has_bullet = false

func reload():
	has_bullet = true
	current_bullet = null  # Clear bullet reference

func take_damage(amount):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	update_healthbar()
	
	if current_health <= 0:
		die()
	
func update_healthbar():
	for i in range(heart_list.size()):
		heart_list[i].visible = i < current_health
		
func die():
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Return bullet to player before restarting
	if current_bullet != null and is_instance_valid(current_bullet):
		current_bullet.return_to_player()
		await get_tree().create_timer(0.5).timeout  # Wait for bullet to return
	else:
		await get_tree().create_timer(1.5).timeout  # Normal death delay
	
	get_tree().reload_current_scene()
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
