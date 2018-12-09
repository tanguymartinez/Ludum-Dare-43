extends GridContainer

signal move_clicked()
signal attack_clicked()
signal teleport_clicked()


func _on_Move_pressed():
	emit_signal("move_clicked")


func _on_Attack_pressed():
	emit_signal("attack_clicked")

func _on_Teleport_pressed():
	emit_signal("teleport_clicked")