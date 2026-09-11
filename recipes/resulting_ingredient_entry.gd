extends ItemThingEntry

func getID() -> String:
	return $idEdit.text

func getValue() -> float:
	return $amountEdit.value

func setValue(_value:Variant, id:String) -> void:
	if _value && _value is float:
		$amountEdit.value = _value
	else:
		$amountEdit.value = 1.0
	
	$idEdit.text = id


func _on_delete_pressed() -> void:
	queue_free()
