extends Area2D

signal player_clicked(pos)

func _ready():
	add_to_group(str(Enums.COLLIDER.ALLY))

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and Input.is_action_pressed("ui_click"):
		emit_signal("player_clicked")
		
