extends Sprite

export(Texture) var attacking
export(Texture) var selecting

func _ready():
	add_to_group(str(Enums.COLLIDER.MAP))
