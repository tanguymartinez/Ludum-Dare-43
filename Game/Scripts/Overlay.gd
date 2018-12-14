extends Sprite

export(Texture) var attacking

func _ready():
	add_to_group(str(Enums.COLLIDER.MAP))
