extends Control

func _on_ConnectToLobby_button_up():
	ConnectionController._join_game(find_node("txtIPAddress").text)

func _on_CreateLobby_button_up():
	ConnectionController._host_game()
