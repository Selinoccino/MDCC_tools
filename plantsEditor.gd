extends Control


var cached : Dictionary = {
	# id : Dictionary
}

var selected : String = ""

enum itemTypes {
	ITEM,
	INGREDIENT,
}

@onready var editor = $sc/pc/actualEditor
@onready var plantButtons = $allvb/buttons/pc/vb
@onready var ings = $sc/pc/actualEditor/ingsc/pc/vb
@onready var items = $sc/pc/actualEditor/itemsc/pc/vb

func populate() -> void:
	selectPlant("")
	for button in plantButtons.get_children():
		button.free()
	
	for id in cached.keys():
		addPlantButton(id, cached[id].get("name", "Plant"))

func addPlantButton(id:String, display:String="Plant") -> void:
	var nb := Button.new()
	setPlantButtonText(nb, display)
	nb.name = id
	plantButtons.add_child(nb)
	nb.connect("pressed", Callable(self, "selectPlant").bind(id))

func safeGetPlantButton(id:String) -> Button:
	return plantButtons.get_node_or_null(id)

func setPlantButtonText(butt:Button, new_text:String) -> void:
	butt.text = new_text if new_text else "(unnamed)"
	butt.add_theme_color_override(&"font_color", Color.WHITE if new_text else Color.WEB_GRAY)

func safeEditButtonText(id:String, new_text:String) -> Button:
	var n = safeGetPlantButton(id)
	if n:
		setPlantButtonText(n, new_text)
		return n
	
	return null
	

func loadFromJsonFile() -> Error:
	var path : String = Manager.getPath("plants")
	var f := FileAccess.open(path, FileAccess.READ)
	if !f:
		return FileAccess.get_open_error()
	
	var test_json_conv = JSON.new()
	
	if test_json_conv.parse(f.get_as_text())!=OK:
		f.close()
		return FAILED
	
	var result : Dictionary = test_json_conv.get_data()
	
	if typeof(result) != TYPE_DICTIONARY:
		f.close()
		return FAILED
	
	cached = result
	f.close()
	return OK

func saveToJsonFileAccess() -> Error:
	var f := FileAccess.open(Manager.getPath("plants"), FileAccess.WRITE)
	if !f:
		return FileAccess.get_open_error()
	
	var p : String = JSON.stringify(cached, "\t")
	
	f.store_string(p)
	
	return OK

func selectPlant(id:String) -> void:
	selected = id
	updateEditor()

func getEditorElement(element:String) -> Control:
	return editor.get_node_or_null(element)

func updateEditor() -> void:
	getEditorElement("idhb/idedit").text = selected
	getEditorElement("idhb/currentId").text = "Current: %s" % selected
	
	getEditorElement("namehb/nameedit").text = getSelectedValue("name", "")
	
	getEditorElement("deschb/descedit").text = getSelectedValue("description", "")
	
	getEditorElement("growthhb/dayssb").value = int(getSelectedValue("growthTime", 1))
	
	getEditorElement("neglecthb/neglectsb").value = int(getSelectedValue("maxUnwateredLifespan", 1))
	
	getEditorElement("harvestshb/harvestssb").value = int(getSelectedValue("maxHarvests", 1))
	
	getEditorElement("cooldownhb/cooldownsb").value = int(getSelectedValue("harvestingCooldown", 1))
	
	getEditorElement("rarityhb/raritysb").value = int(getSelectedValue("rarity", 1))
	
	getEditorElement("plantablehb/plantableButton").button_pressed = bool(getSelectedValue("plantable", true))
	
	for type in itemTypes.values():
		populateItems(type)

func _on_dayssb_value_changed(value):
	setSelectedValue("growthTime", int(value))


func _on_nameedit_text_changed(new_text):
	setSelectedValue("name", new_text)
	safeEditButtonText(selected, new_text)

func setSelectedValue(key:String, value) -> void:
	if cached.has(selected):
		cached[selected][key] = value

func getSelectedValue(key:String, nullv=null):
	if !cached.has(selected):
		return nullv
	return cached[selected].get(key, nullv)

func _on_descedit_text_changed():
	setSelectedValue("description", getEditorElement("deschb/descedit").text)


func _on_raritysb_value_changed(value):
	setSelectedValue("rarity", int(value))
	

func _on_neglectsb_value_changed(value):
	setSelectedValue("maxUnwateredLifespan", int(value))


func _on_harvestssb_value_changed(value):
	setSelectedValue("maxHarvests", int(value))


func _on_cooldownsb_value_changed(value):
	setSelectedValue("harvestingCooldown", int(value))

func getItemContainer(type:int=0) -> Container:
	return ings if type==itemTypes.INGREDIENT else items

func clearItemContainer(type:int=0):
	for child in getItemContainer(type).get_children():
		child.queue_free()

func addItem(type:int=0, id:String="", amount:int=1, dorebuild:bool=true) -> void:
	var nt := PlantItem.new()
	getItemContainer(type).add_child(nt)
	nt.setId(id)
	nt.setAmount(amount)
	
	for itemSignal in ["idChanged", "amountChanged", "deleted"]:
		nt.connect(itemSignal, Callable(self, "rebuildSelectedItems").bind(type))
	
	if dorebuild:
		rebuildSelectedItems(type)

func getItemKey(type:int=0) -> String:
	return "resultingIngredients" if type==itemTypes.INGREDIENT else "resultingItems"

func rebuildSelectedItems(type:int=0) -> void:
	var c := getItemContainer(type)
	var key : String = getItemKey(type)
	
	var newval : Array = []
	
	for plantitem in c.get_children():
		if plantitem is PlantItem:
			newval.append([
				plantitem.getId(), plantitem.getAmount()
			])
	
	setSelectedValue(key, newval)
	

func populateItems(type:int=0) -> void:
	clearItemContainer(type)
	for itemEntry in getSelectedValue(getItemKey(type), []):
		if typeof(itemEntry)!=TYPE_ARRAY or itemEntry.size()<2:
			continue
		var id = itemEntry[0]
		var amount = itemEntry[1]
		addItem(type, id, amount, false)

func _on_idedit_text_entered(new_text):
	var nid = new_text
	if cached.has(selected) && nid && !cached.keys().has(nid):
		cached[nid] = cached[selected]
		cached.erase(selected)
		var n := safeEditButtonText(selected, cached[nid].get("name",""))
		if n:
			n.name = nid
			
			n.pressed.disconnect(selectPlant)
			n.pressed.connect(selectPlant.bind(nid))
		
		selectPlant(nid)


func _on_addItem_pressed():
	addItem(itemTypes.ITEM)


func _on_addIngredient_pressed():
	addItem(itemTypes.INGREDIENT)


func _on_reload_pressed():
	loadFromJsonFile()
	populate()

func saveToFile() -> bool:
	var p : String = Manager.getPath("plants")
	var f := FileAccess.open(p, FileAccess.WRITE)
	
	
	if !f:
		return false
	
	var d : String = JSON.stringify(cached, "\t")
	
	f.store_string(d)
	f.close()
	
	return true


func _on_delete_pressed():
	var n = safeGetPlantButton(selected)
	if n:
		n.free()
	
	cached.erase(selected)
	selectPlant("")


func _on_create_pressed():
	var i : int = 0
	var nid : String = "plant%s" % i
	while nid in cached.keys():
		i += 1
	
	cached[nid] = {
		"growthTime":1,
		"maxHarvests":1,
		"name":"Plant",
		"description":"",
		"maxUnwateredLifespan":1,
		"harvestingCooldown":1,
		"rarity":1,
		"plantable": true,
	}
	
	for type in itemTypes.values():
		cached[nid][getItemKey(type)] = []
	
	addPlantButton(nid, "Plant")


func _on_plantable_button_toggled(toggled_on: bool) -> void:
	setSelectedValue("plantable", toggled_on)
