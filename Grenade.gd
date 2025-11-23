extends RigidBody2D

@export var damage = 3
@export var explosion_force = 500

func _ready():
	
	$Timer.timeout.connect(explode)
	var player = get_tree().current_scene.find_child("Player")
	
	if player:
		add_collision_exception_with(player)
func explode():
	
	linear_velocity = Vector2.ZERO
	sleeping = true 
	$Sprite2D.visible = false 
	
	
	var bodies = $BlastRadius.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("enemies"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
			elif body.has_method("die"):
				body.die()
				
	spawn_explosion_particles()
	await get_tree().create_timer(0.6).timeout
	queue_free()
func spawn_explosion_particles():
	# Check if the node exists
	if has_node("CPUParticles2D"):
		var particles = $CPUParticles2D
		
	
		remove_child(particles)
		get_tree().root.add_child(particles)
		
		
		particles.global_position = global_position
		
		
		particles.emitting = true
		
	
		await get_tree().create_timer(1.0).timeout
		particles.queue_free()
	else:
		print("Error: No CPUParticles2D node found!")
