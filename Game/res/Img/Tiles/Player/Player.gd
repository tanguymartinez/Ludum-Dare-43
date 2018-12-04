extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal player_clicked(pos)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and Input.is_action_pressed("ui_click"):
		emit_signal("player_clicked")
		
