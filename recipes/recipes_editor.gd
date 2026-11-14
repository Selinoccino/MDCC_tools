extends HSplitContainer

@onready var rectree : Tree = $options/recipesTree

var recipes : Dictionary = {}

var lastItem : TreeItem = null

func getRecipe(recid:String) -> Dictionary:
	return recipes.get(recid, {})

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rectree.set_column_title(0, "Recipe ID")
	rectree.set_column_title(1, "Name")
	
	$singleRecipeEditor.idChanged.connect(tryRename)

func tryRename(newID:String) -> void:
	var ti : TreeItem = rectree.get_selected()
	if !ti:
		return
	
	var recid : String = ti.get_metadata(0) as String
	if !recid:
		return
	
	var idx : int = 0
	var finalID : String = newID
	while finalID in recipes:
		idx += 1
		finalID = newID + str(idx).pad_zeros(2)
	
	recipes[finalID] = getRecipe(recid)
	recipes.erase(recid)
	
	updateItemForRecipe(ti, finalID, recipes[finalID])

func loadFromJson() -> void:
	recipes = Manager.loadFromJsonFile(Manager.getPath("recipes"), TYPE_DICTIONARY, {})
	
	populate()

func populate() -> void:
	rectree.clear()
	rectree.create_item()
	
	for recid in recipes:
		addNewRecipeItem(recid)

func addNewRecipeItem(recid:String) -> TreeItem:
	var it : TreeItem = rectree.create_item()
	
	updateItemForRecipe(it, recid)
	
	return it

func updateItemForRecipe(item:TreeItem, recid:String, recipe=null) -> void:
	var nstr : String = (getRecipe(recid) if recipe==null else recipe).get("name", "")
	item.set_text(1, nstr if nstr else "(unnamed)")
	item.set_text(0, recid)
	
	var finalColor : Color = Color.WHITE if nstr else Color.WEB_GRAY
	for col in rectree.columns:
		item.set_custom_color(col, finalColor)
	item.set_metadata(0, recid)

func _on_recipes_tree_item_activated() -> void:
	print("asdas")
	if lastItem:
		var lastRecid : String = lastItem.get_metadata(0) as String
		if lastRecid:
			recipes[lastRecid] = $singleRecipeEditor.updateDictionary()
			updateItemForRecipe(lastItem, lastRecid, recipes[lastRecid])
		
	
	var ti : TreeItem = rectree.get_selected()
	if !ti:
		print("noo")
		return
	
	var recid : String = ti.get_metadata(0) as String
	if !recid:
		print("aa")
		return
	
	var rec : Dictionary = getRecipe(recid)
	if !rec:
		print("norec"+recid)
		return
	
	lastItem = ti
	$singleRecipeEditor.updateEditor(recid, rec)

func saveToFile() -> bool:
	var p : String = Manager.getPath("recipes")
	var f := FileAccess.open(p, FileAccess.WRITE)
	
	recipes[rectree.get_selected().get_metadata(0)] = $singleRecipeEditor.updateDictionary()
	
	if !f:
		return false
	
	var d : String = JSON.stringify(recipes, "\t")
	
	f.store_string(d)
	f.close()
	
	return true

func _on_delete_pressed() -> void:
	var ti : TreeItem = rectree.get_selected()
	if !ti:
		return
	
	var recid : String = ti.get_metadata(0) as String
	if !recid:
		return
	
	recipes.erase(recid)
	rectree.get_root().remove_child(ti)
	ti.free()


func _on_add_pressed() -> void:
	var idx : int = recipes.size()
	var newID : String = "recipe%s" % str(idx).pad_zeros(2)
	while newID in recipes:
		idx += 1
		newID = "recipe%s" % str(idx).pad_zeros(2)
	
	recipes[newID] = {"name":"Recipe"}
	
	rectree.set_selected(addNewRecipeItem(newID), 0)
