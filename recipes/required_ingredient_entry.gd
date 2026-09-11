extends ItemThingEntry

func getID() -> String:
	return $idEdit.text

func getValue() -> Array:
	return [ $minEdit.value, $maxEdit.value ] if $minEdit.value<$maxEdit.value else [$minEdit.value]

func setValue(_value:Variant, id:String) -> void:
	if _value && _value is Array:
		$minEdit.value = _value[0]
		$maxEdit.value = _value[1] if _value.size()>1 else _value[0]
	else:
		$minEdit.value = 1.0
		$maxEdit.value = 1.0
	
	$idEdit.text = id


func _on_delete_pressed() -> void:
	queue_free()
