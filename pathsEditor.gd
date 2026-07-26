extends Control

onready var pathc = $vb/sc/vb

func populatePaths() -> void:
	for n in pathc.get_children():
		n.free()
	
	for path in Manager.paths.keys():
		addPath(path, Manager.getPath(path))
	

func addPath(id:String, path:String) -> void:
	var hb := HBoxContainer.new()
	hb.name = id
	hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var idl := Label.new()
	idl.text = id.capitalize()
	
	var ledit := LineEdit.new()
	ledit.placeholder_text = "Path..."
	ledit.text = path
	ledit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	ledit.connect("text_changed", self, "pathEdited", [id])
	
	var lbrowse := Button.new()
	lbrowse.text = "Browse"
	lbrowse.connect("pressed", self, "browsePath", [id])
	
	
	hb.add_child(idl)
	hb.add_child(ledit)
	hb.add_child(lbrowse)
	
	pathc.add_child(hb)
	

func browsePath(id:String) -> void:
	$FileDialog.popup_centered_ratio()
	var new : String = yield($FileDialog, "file_selected")
	
#	Manager.addPath(id, new)
	var n = pathc.get_node_or_null(id)
	if n:
		n.get_child(1).text = new
		pathEdited(new, id)

func pathEdited(new_path:String, id:String) -> void:
	Manager.addPath(id, new_path)
	Manager.saveToConfigFile()

func _ready():
	populatePaths()
