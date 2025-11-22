extends Area2D
signal hit

@export var speed = 400
@export var bullet_scene: PackedScene
var screen_size
var has_bullet = true

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	#hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	# to yung aiming logic HAHAHAHA
	look_at(get_global_mouse_position())
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO,screen_size)
	# shooting logic
	if Input.is_action_just_pressed("shoot"):
		print("button pressed") 
		if has_bullet:
			print("have bullet") 
			fire_bullet()
		else:
			print("no bullet")
	#if velocity.x != 0:
		#$AnimatedSprite2D.animation = "walk"
		#$AnimatedSprite2D.flip_v = false
		#$AnimatedSprite2D.flip_h = velocity.x < 0
	#elif velocity.y != 0:
		#$AnimatedSprite2D.animation = "up"
		#$AnimatedSprite2D.flip_v = velocity.y > 0

func fire_bullet():
	if bullet_scene == null:
		print("ERROR: No Bullet Scene assigned in Inspector!")
		return

	var b = bullet_scene.instantiate()
	
	b.global_position = $Muzzle.global_position
	b.rotation = rotation  
	
	get_tree().root.add_child(b)
	
	has_bullet = false

func reload():
	has_bullet = true
	
func _on_body_entered(body):
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled",true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
