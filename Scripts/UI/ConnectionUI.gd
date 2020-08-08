extends Control

func _ready():
	print(IP.get_local_addresses())

func _on_btnConnect_pressed():
	ConnectionController._join_game(find_node("txtIPAddress").text)

func _on_btnCreateLobby_pressed():
	ConnectionController._host_game()
