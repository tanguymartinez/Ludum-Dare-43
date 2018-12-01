extends VBoxContainer



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

func _on_Play_pressed():
	print("bleh")