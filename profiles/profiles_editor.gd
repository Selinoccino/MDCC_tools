extends HSplitContainer

var cached : Dictionary[String, Profile] = {}

@onready var profsc : Tree = $left/profsTree

@onready var editor : Container = $pc/sc/editor/fields
@onready var nonfields : Container = $pc/sc/editor/nonfields


func newBasicProfile(id:String) -> Profile:
	var p : Profile = Profile.new()
	p.createDefaults()
	
	cached[id]=p
	addProfileButton(p)
	
	return p

func populate() -> void:
	profsc.clear()
	
	profsc.create_item() ## root
	
	
	for prof in cached.values():
		addProfileButton(prof)

func addProfileButton(p:Profile) -> TreeItem:
	var nb := profsc.create_item()
	setProfButtName(nb, p.nonfields.get("name", ""))
	
	return nb

func getSelectedProfile() -> Profile:
	var sel = profsc.get_selected()
	
	if !sel:
		return null
	
	var s : int = sel.get_index()
	if s>=cached.size():
		return null
	
	return cached.values()[s]

func updateNonFields() -> void:
	var p : Profile = getSelectedProfile()
	if !p:
		return
	
	for nf : String in p.nonfields.keys():
		var newnam : String = nf.validate_node_name()
		var n = nonfields.get_node_or_null(newnam)
		if n:
			n.get_child(1).text = p.nonfields[nf]
			continue
		
		var nd := HBoxContainer.new()
		nd.name = newnam
		
		var l := Label.new()
		l.text = nf.capitalize()
		
		nd.add_child(l)
		
		var ledit := LineEdit.new()
		ledit.text = p.nonfields[nf]
		ledit.text_changed.connect(setNonfield.bind(nf))
		ledit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nd.add_child(ledit)
		
		nonfields.add_child(nd)
		

func onProfileSelected() -> void:
	var s : int = profsc.get_selected().get_index()
	if s>=cached.size():
		return
	
	#clearEditor()
	
	var pid : String = cached.keys()[s]
	var p : Profile = cached[pid]
	
	var fields = p.fields.keys()
	for default in Profile.getAllDefaultFieldTypes():
		if default in fields:
			continue
		fields.append(default)
	
	for fieldid : String in fields:
		var newnam : String = fieldid.validate_node_name()
		var n = editor.get_node_or_null(newnam)
		if n && n is ProfileFieldContainer:
			n.field = p.getField(fieldid)
			continue
		
		var nd : ProfileFieldContainer = preload("res://profiles/profile_field_container.tscn").instantiate()
		
		nd.fold()
		nd.name = newnam
		nd.setLabel(fieldid.capitalize())
		editor.add_child(nd)
		var f = p.getField(fieldid)
		if !f:
			f = p.createField(fieldid)
		nd.field = f
	
	updateNonFields()

func clearEditor() -> void:
	for node in editor.get_children():
		node.free()

func loadFromJson(path:String=Manager.getPath("inmate_profiles")) -> void:
	var data : Array = Manager.loadFromJsonFile(path, TYPE_ARRAY, [])
	
	var unki : int = 0
	cached.clear()
	for rawp in data:
		if rawp.has("inmate id"):
			cached[rawp["inmate id"]] = Profile.dict2prof(rawp)
		else:
			cached["prof%s" % unki] = Profile.dict2prof(rawp)
			unki += 1
	
	populate()


func _on_add_pressed() -> void:
	newBasicProfile("prof%s" % profsc.get_root().get_child_count())

func setProfButtName(pb:TreeItem, n:String) -> void:
	pb.set_custom_color(0, Color.WHITE if n else Color.WEB_GRAY)
	pb.set_text(0, n if n else "(unnamed)")

func setNonfield(new:String, nf:String) -> void:
	var p : Profile = getSelectedProfile()
	if p:
		p.setNonField(nf, new)
	
	if nf=="name":
		var s = profsc.get_selected()
		setProfButtName(s, new)

func deleteSelected() -> void:
	var pb = profsc.get_selected()
	cached.erase(cached.keys()[pb.get_index()])
	pb.free()


func _on_reload_pressed() -> void:
	loadFromJson()
	#populate()

func saveToJson(path:String=Manager.getPath("inmate_profiles")) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if !f:
		return
	
	var far : Array = []
	for profile in cached.values():
		far.append(Profile.prof2dict(profile))
	
	var finald : String = JSON.stringify(far, "\t")
	
	f.store_string(finald)

func _ready() -> void:
	populate()

func _on_save_pressed() -> void:
	saveToJson()


func _on_copy_pressed() -> void:
	var sel : Profile = getSelectedProfile()
	if !sel:
		return
	
	var p = Profile.dict2prof(Profile.prof2dict(sel))
	var nid = "prof%s" % profsc.get_root().get_child_count()
	p.setNonField("charid", nid)
	cached[nid] = p
	addProfileButton(p)
