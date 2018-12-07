extends Node2D
#Constants
const SERVER_PORT = 1337
const MAX_PLAYERS = 1

#CLI related
var text = []

#Player related
var player_id
var player_ip_address

#Game related
var playing

func _ready():
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	# Called when the node is added to the scene for the first time.
	# Initialization here
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	
	get_tree().set_network_peer(peer)
	text.append("Server's ip address: ")
	for address in IP.get_local_addresses():
		if(not ":" in address):
			text.append(address)
	refresh()

func _player_connected(id):
	player_id = id
	print_text("Player "+ str(id) +" is connected...")

func _player_disconnected(id):
	print_text("Player disconnected...") # Erase player from info

func refresh():
	var string = ""
	for line in text:
		string += line + "\n"
	$"GUI/CLI".text = string

func print_text(string):
	text.append(string)
	refresh()

func _on_Button_pressed():
	var string = $"GUI/LineEdit".text
	print_text(string)
	rpc_id(player_id, "receive_command", string)
	$"GUI/LineEdit".clear()

func _process(delta):
	if(Input.is_action_just_pressed("ui_accept")):
		_on_Button_pressed()

remote func store_ip_address(address):
	player_ip_address = address
	text[text.size()-1] += " with ip address " + player_ip_address + "..."
	refresh()

remote func cli_turn():
	return