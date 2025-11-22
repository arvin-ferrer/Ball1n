extends Path2D

@export var spawn_rate : float = 2.0
@export var enemy : PackedScene
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	$SpawnTimer.start(spawn_rate)

func _on_spawn_timer_timeout() -> void:
	var percent_position = rng.randf_range(0.0, 1.0);
	var pos = curve.sample_baked(percent_position*curve.get_baked_length());
	
	print("spawn at: ")
	print(pos + global_position)
	
	var enemy_instance = enemy.instantiate()
	enemy_instance.position = pos+global_position
	get_parent().add_child(enemy_instance)
