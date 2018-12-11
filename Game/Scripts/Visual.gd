# Typical lobby implementation, imagine this being in /root/lobby

extends Node2D

const SERVER_PORT = 1337
# Connect all functions

#Entities
var entities = [] #[id,node]

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(Variables.IpAddress, SERVER_PORT)
	get_tree().set_network_peer(peer)
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _connected_fail():
	print("Failed to connect...")
	
func _server_disconnected():
	print("Server kicked us...")
	
func _connected_ok():
	print("Connected to server...")
	rpc_id(1, "store_ip_address", IP.get_local_addresses()[0])

func end_turn():
	get_tree().paused = true
	rpc_id(1, "cli_turn")

func exception(exception):
	rpc_id(1, "print_exception", exception)

func sync_world():
	rpc_id(1, "sync_world", $"World".references)

#Transmit command to child node for treatment
#PARAM command : Command
remote func receive_command(command):
	get_tree().paused = false
	$"World".player_turn(command)