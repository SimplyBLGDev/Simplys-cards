extends Node

const PORT = 1234
var players = []

func _ready():
	get_tree().connect("connected_to_server", self, "_connected")

func _host_game():
	var host = NetworkedMultiplayerENet.new()
	
	host.create_server(PORT, 4) #Max players = 4
	get_tree().set_network_peer(host)

func _join_game(ip):
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, PORT)
	get_tree().set_network_peer(host)

func _connected():
	rpc("register_player", get_tree().get_network_unique_id())
	register_player(get_tree().get_network_unique_id())

remote func register_player(player_id):
	print("player registered")
	if get_tree().get_network_unique_id() == 1: #If I'm server
		if player_id != 1:
			for i in players:
				rpc_id(player_id, "register_player", i)
	players.append(player_id)
