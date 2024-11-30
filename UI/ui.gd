extends CanvasLayer


var lockInput: bool = false
@onready var inventory = $Inventory

func pickup_popup(source):
	$PickupPopup.open_popup(source)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		if $PickupPopup.visible:
			$PickupPopup._cancel()
		else:
			$MainMenu.show()
	
	var interaction = InstanceManager.player.most_recent_interactable
	if interaction:
		$ControlHints/GridContainer/Interact.text = interaction.get_interact_text()
	else:
		$ControlHints/GridContainer/Interact.text = ""
	if InstanceManager.player.lifted_object:
		$ControlHints/GridContainer/Throw.text = "F: Throw Object"
	else:
		$ControlHints/GridContainer/Throw.text = ""
