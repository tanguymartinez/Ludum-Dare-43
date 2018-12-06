extends Area2D

#Signal emitted when a hint is clicked
#PARAM pos : Vector2
signal hint_clicked(pos)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and Input.is_action_pressed("ui_click"):
		emit_signal("hint_clicked", self.get_node("../").position)
