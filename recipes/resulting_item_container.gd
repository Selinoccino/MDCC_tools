extends RequiredThingContainer

func getValue() -> Array:
	var d : Array = []
	
	for child in $vb.get_children():
		if child is ItemThingEntry:
			d.append([ child.getID(), child.getValue() ])
	
	return d

func setToValue(_value:Variant) -> void:
	clear()
	if _value is Array:
		for ar in _value:
			if ar is not Array:
				continue
			if ar.size()<2:
				continue
			
			addNew().setValue(ar[1], ar[0])
		
	

func clear() -> void:
	for node in $vb.get_children():
		node.queue_free()

func addNew() -> Control:
	var t : Control = entryScene.instantiate()
	
	$vb.add_child(t)
	
	return t
