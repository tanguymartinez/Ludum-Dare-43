extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var prevent_first_click = true
signal player_clicked(pos)
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(str(Enums.COLLIDER.ALLY))

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and Input.is_action_pressed("ui_click"):
		if not prevent_first_click:
			emit_signal("player_clicked")
		else:
			prevent_first_click = false
		
