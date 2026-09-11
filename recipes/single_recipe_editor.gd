extends PanelContainer

var recipe : Dictionary = {}

signal idChanged(newID:String)

func updateEditor(id:String, rec:Dictionary) -> void:
	recipe = rec
	$sc/vb/nameHB/nameEdit.text = rec.get("name", "")
	$sc/vb/idHB/idedit.text = id
	$sc/vb/itemDisplayHB/itemEdit.text = rec.get("finalItemsDisplay", "")
	$sc/vb/ingDisplayHB/ingEdit.text = rec.get("finalIngsDisplay", "")
	$sc/vb/tagsHB/tagsEdit.text = "\n".join(rec.get("tags", []))
	$sc/vb/craftCallHB/craftEdit.text = rec.get("craftCallback", "")
	$sc/vb/qualityCallHB/qualityEdit.text = rec.get("qualityCallback", "")
	
	$sc/vb/reqIngs/RequiredIngredientContainer.setToValue(rec.get("requiredIngredients", {}))
	$sc/vb/reqItems/RequiredItemContainer.setToValue(rec.get("requiredItems", {}))
	
	$sc/vb/resIngs/ResultingIngredientContainer.setToValue(rec.get("resultingIngredients", []))
	$sc/vb/resItems/ResultingItemContainer.setToValue(rec.get("resultingItems", []))


func _on_idedit_text_submitted(new_text: String) -> void:
	idChanged.emit(new_text)

func updateDictionary() -> Dictionary:
	recipe["name"] = $sc/vb/nameHB/nameEdit.text
	recipe["finalItemsDisplay"] = $sc/vb/itemDisplayHB/itemEdit.text
	recipe["finalIngsDisplay"] = $sc/vb/ingDisplayHB/ingEdit.text
	recipe["tags"] = $sc/vb/tagsHB/tagsEdit.text.split("\n", false)
	recipe["craftCallback"] = $sc/vb/craftCallHB/craftEdit.text
	recipe["qualityCallback"] = $sc/vb/qualityCallHB/qualityEdit.text
	
	recipe["requiredIngredients"] = $sc/vb/reqIngs/RequiredIngredientContainer.getValue()
	recipe["requiredItems"] = $sc/vb/reqItems/RequiredItemContainer.getValue()
	
	recipe["resultingIngredients"] = $sc/vb/resIngs/ResultingIngredientContainer.getValue()
	recipe["resultingItems"] = $sc/vb/resItems/ResultingItemContainer.getValue()
	
	return recipe
