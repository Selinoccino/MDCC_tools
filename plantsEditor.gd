extends HBoxContainer


var cached : Dictionary = {
	# id : Dictionary
}

var selected : String = ""

enum itemTypes {
	ITEM,
	INGREDIENT,
}

onready var editor = $sc/pc/actualEditor
onready var plantButtons = $allvb/buttons/pc/vb
onready var ings = $sc/pc/actualEditor/ingsc/pc/vb
onready var items = $sc/pc/actualEditor/itemsc/pc/vb

func populate() -> void:
	selectPlant("")
	for button in plantButtons.get_children():
		button.free()
	
	for id in cached.keys():
		addPlantButton(id, cached[id].get("name", "Plant"))

func addPlantButton(id:String, display:String="Plant") -> void:
	var nb := Button.new()
	nb.text = display
	nb.name = id
	plantButtons.add_child(nb)
	nb.connect("pressed", self, "selectPlant", [id])

func loadFromJsonFile() -> bool:
	var path : String = Manager.getPath("plants")
	var f := File.new()
	if f.open(path, File.READ)!=OK:
		return false
	
	var result : JSONParseResult = JSON.parse(f.get_as_text())
	
	if result.error!=OK:
		f.close()
		return false
	
	var d = result.result
	if typeof(d) != TYPE_DICTIONARY:
		f.close()
		return false
	
	cached = d
	f.close()
	return true

func saveToJsonFile() -> bool:
	var f := File.new()
	if f.open(Manager.getPath("plants"), File.WRITE)!=OK:
		return false
	
	var p : String = JSON.print(cached, "\t")
	
	f.store_string(p)
	
	return true

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
	
	for type in itemTypes.values():
		populateItems(type)

func _on_dayssb_value_changed(value):
	setSelectedValue("growthTime", int(value))


func _on_nameedit_text_changed(new_text):
	setSelectedValue("name", new_text)
	var n = plantButtons.get_node_or_null(selected)
	if n:
		n.text = new_text

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
		nt.connect(itemSignal, self, "rebuildSelectedItems", [type])
	
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
		var n = plantButtons.get_node_or_null(selected)
		n.name = nid
		n.text = cached[nid].get("name", "Plant")
		n.disconnect("pressed", self, "selectPlant")
		n.connect("pressed", self, "selectPlant", [nid])
		
		selectPlant(nid)


func _on_addItem_pressed():
	addItem(itemTypes.ITEM)


func _on_addIngredient_pressed():
	addItem(itemTypes.INGREDIENT)


func _on_reload_pressed():
	loadFromJsonFile()
	populate()

func saveToFile() -> bool:
	var f := File.new()
	var p : String = Manager.getPath("plants")
	
	if f.open(p, File.WRITE)!=OK:
		return false
	
	var d : String = JSON.print(cached, "\t")
	
	f.store_string(d)
	f.close()
	
	return true


func _on_delete_pressed():
	var n = plantButtons.get_node_or_null(selected)
	if n:
		n.free()
	
	cached.erase(selected)
	selectPlant("")


func _on_create_pressed():
	var i : int = 0
	while "plant%s" % i in cached.keys():
		i += 1
	
	cached["plant%s" % i] = {
		"growthTime":1,
		"maxHarvests":1,
		"name":"Plant",
		"description":"",
		"maxUnwateredLifespan":1,
		"harvestingCooldown":1,
		"rarity":1,
	}
	
	for type in itemTypes.values():
		cached["plant%s" % i][getItemKey(type)] = []
	
	addPlantButton("plant%s" % i, "Plant")
