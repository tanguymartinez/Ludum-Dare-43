extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var group
# Called when the node enters the scene tree for the first time.
func _ready():
	group = Classes.group.new("NonBlocking")
	print(group.get_group())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
