extends CanvasLayer


var lockInput: bool = false
@onready var inventory = $Inventory

func replacement_popup(new_spell:Spell) -> Spell:
	return await $ReplacementPopup.open_popup(new_spell)
