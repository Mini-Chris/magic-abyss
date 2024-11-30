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
