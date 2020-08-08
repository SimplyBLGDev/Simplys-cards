extends Control

func _on_btnSingleplayer_pressed():
	GameController.animate_screen_tint(null, Color(1, 1, 1, 1), 1.1, self, "spawn_game_selection")

func spawn_game_selection():
	GameController.set_game("Game Selection")
	GameController.animate_screen_tint(null, Color(1, 1, 1, 0), 1.1)
	queue_free()

func _on_btnMultiplayer_pressed():
	pass
