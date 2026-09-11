extends RequiredThingContainer

func getValue() -> Dictionary:
	var d : Dictionary = {}
	
	for child in $vb.get_children():
		if child is ItemThingEntry:
			d[child.getID()] = child.getValue()
	
	return d

func setToValue(_value:Variant) -> void:
	clear()
	if _value is Dictionary:
		for key in _value:
			addNew().setValue(_value[key], key)
		
	

func clear() -> void:
	for node in $vb.get_children():
		node.queue_free()

func addNew() -> Control:
	var t : Control = entryScene.instantiate()
	
	$vb.add_child(t)
	
	return t
