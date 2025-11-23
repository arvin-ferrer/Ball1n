extends Node2D

@onready var win_label = $CanvasLayer/WinLabel 
var boss_count = 0

func _ready():
	var bosses = get_tree().get_nodes_in_group("bosses")
	boss_count = bosses.size()
	
	print("Game Started. Bosses remaining: ", boss_count)
	
	for boss in bosses:
		boss.boss_died.connect(_on_boss_died)

func _on_boss_died():
	boss_count -= 13
	print("Boss Defeated! Remaining: ", boss_count)
	
	if boss_count <= 0:
		win_game()
func win_game():
	print("YOU WIN!")
	
	# 1. Show the Win Text
	if win_label:
		win_label.visible = true
		

	get_tree().paused = true
	
	var timer = get_tree().create_timer(3.0)
	timer.set_time_left(3.0) 

	#await get_tree().create_timer(3.0, false, false, true).timeout
	#
	#await get_tree().create_timer(3.0, true, false, true).timeout
	#get_tree().paused = false
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene()	
