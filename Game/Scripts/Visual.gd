# Typical lobby implementation, imagine this being in /root/lobby

extends Container


const SERVER_PORT = 1337
# Connect all functions

func _ready():
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(Variables.IpAddress, SERVER_PORT)
	get_tree().set_network_peer(peer)

func _connected_fail():
	print("Failed to connect...")
	
func _server_disconnected():
	print("Server kicked us...")

remote func send_text(text):
	print(text)