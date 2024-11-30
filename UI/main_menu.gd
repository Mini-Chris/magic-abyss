extends PanelContainer


func _process(delta: float) -> void:
	if visible and Input.is_action_pressed("menu"):
		$CenterContainer/VBoxContainer/Quit/ProgressBar.value += 1
		if $CenterContainer/VBoxContainer/Quit/ProgressBar.value == 60:
			get_tree().quit()
	else:
		$CenterContainer/VBoxContainer/Quit/ProgressBar.value -= 1


func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_reset_pressed() -> void:
	get_tree().change_scene_to_file("res://rooms/maps/tutorial_map/tutorial_map.tscn")
	# clear inventory
	hide()

func _on_continue_pressed() -> void:
	hide()
