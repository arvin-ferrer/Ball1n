extends "res://Bullet.gd"  # Make sure this path matches your bullet script location

@export var knockback_force = 500
@export var knockback_duration = 0.3

func _ready():
	super()  # Call parent's _ready() function
	# Visual changes to distinguish special bullet
	modulate = Color(1, 0.5, 0.2)  # Orange color
	scale = Vector2(1.3, 1.3)  # Larger size

func handle_enemy_collision(enemy):
	# Apply knockback to enemy
	var knockback_direction = (enemy.global_position - global_position).normalized()
	if enemy.has_method("apply_knockback"):
		enemy.apply_knockback(knockback_direction, knockback_force, knockback_duration)
