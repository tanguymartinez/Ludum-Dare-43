extends Container

const SERVER_PORT = 1337
const MAX_PLAYERS = 1

# Player info, associate ID to data
var text = []

func _ready():
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	# Called when the node is added to the scene for the first time.
	# Initialization here
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	print(IP.get_local_addresses())
	text.append("Server's ip address: ")
	for address in IP.get_local_addresses():
		if(not ":" in address):
			text.append(address)
	refresh()

func _player_connected(id):
	print("Player connected...") # Will go unused, not useful here

func _player_disconnected(id):
	print("Player disconnected...") # Erase player from info

func refresh():
	var string = ""
	for line in text:
		string += line + "\n"
	$"CLI".text = string

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
