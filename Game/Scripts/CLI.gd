extends Container

const SERVER_PORT = 1337
const MAX_PLAYERS = 1

# Player info, associate ID to data
var player_info = {}

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)

func _player_connected(id):
	print("Player connected...") # Will go unused, not useful here

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
