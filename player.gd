extends CharacterBody2D
signal hit

@export var speed = 400
@export var bullet_scene: PackedScene
@export var knockback_bullet_scene: PackedScene

@export var dash_speed = 1200  
@export var dash_duration = 0.2 
@export var knockback_cooldown = 5.0
@export var dash_cooldown = 0.8
@onready var dash_particles = $DashParticles
@onready var bullet_tracker = $BulletTracker 
var is_dashing = false
var can_dash = true
var screen_size
var has_bullet = true
var knockback_bullet_ready = true


@export var level_label: Label
@export var popup_label: Label
@export var knockback_ready_label: Label

var max_health: int = 3
var current_health = max_health
var heart_list : Array[TextureRect] = []
var damage_cooldown = 1
var time_since_hit = 0.0
var current_bullet = null
var xp: int = 0
var level: int = 1
var xp_to_next_level: int = 100

func _ready():
	screen_size = get_viewport_rect().size
	
	print("Level Up Popup Label:", popup_label != null)
	print("Knockback Ready Label:", knockback_ready_label != null)
	
	if level_label: level_label.text = "Level " + str(level)

	if level_label and is_instance_valid(level_label): 
		level_label.text = "Level " + str(level)
		
	var heart_container = get_tree().get_current_scene().get_node("Bars/HBoxContainer")
	
	
	if heart_container: 
		for child in heart_container.get_children():
			
			if child is TextureRect:
				heart_list.append(child)
				 
	update_healthbar()      
	update_exp(xp) 

func update_exp(expe):
	var exp_var = get_tree().get_current_scene().get_node("Bars/ExpBar")
	
	# Safety check for exp_var
	if exp_var:
		exp_var.value = expe
		exp_var.max_value = xp_to_next_level
		
func gain_xp(amount):
	xp += amount
	
	update_exp(xp)
	
	if xp >= xp_to_next_level:
		level_up()

func level_up():
	xp -= xp_to_next_level
	level += 1
	xp_to_next_level = int(xp_to_next_level * 1.5)
	

	if level_label and is_instance_valid(level_label):
		level_label.text = "Level " + str(level)
		
	update_exp(xp)
	
	show_level_up_popup()

func show_knockback_ready_popup():
	#if not knockback_ready_label or not is_instance_valid(knockback_ready_label):
		#return
	#
	#knockback_ready_label.visible = true
	#knockback_ready_label.modulate.a = 1.0
	#
	#var tween = create_tween()
	#
	#knockback_ready_label.text = "Knockback Bullet Ready"
	#tween.tween_property(knockback_ready_label, "position", knockback_ready_label.position + Vector2(0, -100), 2.0)
	#tween.parallel().tween_property(knockback_ready_label, "modulate:a", 0.0, 2.0)
	#
	#await tween.finished
	#knockback_ready_label.visible = false
	#knockback_ready_label.modulate.a = 1.0 
	#knockback_ready_label.position.y += 100 # Reset position down
	
		# Check if label is assigned before animating
	if not popup_label or not is_instance_valid(popup_label):
		return
		
	popup_label.visible = true
	popup_label.modulate.a = 1.0 # Ensure full visibility at start
	
	var tween = create_tween()
	
	popup_label.text = "Knockback Bullet Ready"
	tween.tween_property(popup_label, "position", popup_label.position + Vector2(0, -100), 2.0)
	tween.parallel().tween_property(popup_label, "modulate:a", 0.0, 2.0)
	
	await tween.finished
	popup_label.visible = false
	popup_label.modulate.a = 1.0 
	popup_label.position.y += 100 # Reset position down
	
func show_level_up_popup():
	# Check if label is assigned before animating
	if not popup_label or not is_instance_valid(popup_label):
		return
		
	popup_label.visible = true
	popup_label.modulate.a = 1.0 # Ensure full visibility at start
	
	var tween = create_tween()
	
	popup_label.text = "Leveled Up!"
	tween.tween_property(popup_label, "position", popup_label.position + Vector2(0, -100), 2.0)
	tween.parallel().tween_property(popup_label, "modulate:a", 0.0, 2.0)
	
	await tween.finished
	popup_label.visible = false
	popup_label.modulate.a = 1.0 
	popup_label.position.y += 100 # Reset position down
	
func update_bullet_tracker():
	
	bullet_tracker.global_position = global_position 

	if current_bullet == null or not is_instance_valid(current_bullet):
		bullet_tracker.visible = false
		return
		
	var dist = global_position.distance_to(current_bullet.global_position)
	
	if dist < 400: 
		bullet_tracker.visible = false
	else:
		bullet_tracker.visible = true
		bullet_tracker.look_at(current_bullet.global_position)
		
func _physics_process(_delta):
	time_since_hit += _delta
	look_at(get_global_mouse_position())
	update_bullet_tracker()
	
	if is_dashing:
		move_and_slide()
		
		if dash_particles:
			dash_particles.emitting = false
		return  
		
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()

	move_and_slide()

	if Input.is_action_just_pressed("shoot"):
		if has_bullet:
			fire_bullet()
	
	if Input.is_action_just_pressed("knockback_bullet") and knockback_bullet_ready:
		fire_knockback_bullet()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("enemies") and time_since_hit >= damage_cooldown:
			take_damage(1)
			time_since_hit = 0.0
			
func start_dash():
	is_dashing = true
	can_dash = false
	
	if dash_particles:
		dash_particles.emitting = true  
	
	if velocity == Vector2.ZERO:
		velocity = Vector2.RIGHT.rotated(rotation) * dash_speed
	else:
		velocity = velocity.normalized() * dash_speed
		
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
	velocity = Vector2.ZERO  
	
	if dash_particles:
		dash_particles.emitting = false # Stop particles after dash duration
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
	
func fire_bullet():
	if bullet_scene == null:
		print("ERROR: No Bullet Scene assigned!")
		return
	var b = bullet_scene.instantiate()
	b.global_position = $Muzzle.global_position
	b.rotation = rotation
	get_tree().root.add_child(b)
	current_bullet = b 
	has_bullet = false

func fire_knockback_bullet():
	if knockback_bullet_scene == null:
		print("No Special Bullet Assigned")
		return
	
	if not has_bullet:
		return
	
	var special_bullet = knockback_bullet_scene.instantiate()
	special_bullet.global_position = $Muzzle.global_position
	special_bullet.rotation = rotation
	get_tree().root.add_child(special_bullet)
	
	
	knockback_bullet_ready = false
	await get_tree().create_timer(knockback_cooldown).timeout
	show_knockback_ready_popup()
	knockback_bullet_ready = true
	
func reload():
	has_bullet = true
	current_bullet = null 
	
func take_damage(amount):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	update_healthbar()
	if current_health >0:
		$PlayerHitMusic.play()
	if current_health <= 0:
		die()
	
func update_healthbar():
	for i in range(heart_list.size()):
		heart_list[i].visible = i < current_health
		
func die():
	$PlayerDeathMusic.play()
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
	
	if current_bullet != null and is_instance_valid(current_bullet):
		current_bullet.queue_free()
		current_bullet = null  
		
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()	
	has_bullet = true 
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func playEnemyDSound():
	$EnemyDeathMusic.play()

func playBossHSound():
	$BossHitMusic.play()
	
func playBossDSound():
	$BossDeathMusic.play()
