extends CharacterBody2D 
signal hit

@export var speed = 400
@export var bullet_scene: PackedScene

var screen_size
var has_bullet = true

func _ready():
	screen_size = get_viewport_rect().size


func _physics_process(_delta):
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
		if collider.is_in_group("enemies"):
			die()

func fire_bullet():
	if bullet_scene == null:
		print("ERROR: No Bullet Scene assigned!")
		return

	var b = bullet_scene.instantiate()
	b.global_position = $Muzzle.global_position
	b.rotation = rotation
	get_tree().root.add_child(b)
	has_bullet = false

func reload():
	has_bullet = true

func die():
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
