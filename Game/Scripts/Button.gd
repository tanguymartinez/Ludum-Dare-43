extends Container



func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Exit_pressed():
	get_tree().quit()

func _on_CLI_pressed():
	get_tree().change_scene("res://Scenes/CLI.tscn")

func _on_Visual_pressed():
	get_tree().change_scene("res://Scenes/Connect.tscn")


func _on_Connect_pressed():
	if $"Address".text.is_valid_ip_address():
		Variables.IpAddress = $"Address".text
		get_tree().change_scene("res://Scenes/Visual.tscn")


func _on_Button_pressed():
	pass # Replace with function body.
