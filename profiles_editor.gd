extends HSplitContainer

var cached : Dictionary[String, Profile] = {}

var selected : int = 0

@onready var profsc : Tree = $left/profsTree

class Field:
	var data : Array[String] = []
	
	func getDataForAccessLevel(al:int=0) -> String:
		if !data:
			return ""
		return data[mini(al, data.size()-1)]
	
	func addData(d:String) -> void:
		data.append(d)
	
	func removeData(d:String) -> void:
		data.erase(d)
	
	func removeDataIndex(idx:int) -> void:
		data.remove_at(idx)
	
	func getData() -> Array[String]:
		return data
	
	func clearData() -> void:
		data.clear()
	

func getAllDefaultFieldTypes() -> Array[String]:
	var r : Array[String] = [
		"origin", "age", "inmate type", "crimes", "gender", "species", "description", "height", "weight", "detainment procs",
	]
	
	return r

class Profile:
	var name : String = ""
	var charid : String = ""
	var inmateId : String = ""
	var flagId : String = ""
	var moduleId : String = ""
	
	var fields : Dictionary[String, Field] = {}
	
	func createField(id:String) -> Field:
		var f : Field = Field.new()
		
		fields[id] = f
		return f
	
	func removeField(id:String) -> void:
		fields.erase(id)
	
	func getField(id:String) -> Field:
		return fields.get(id, null)
	
	func clearFields() -> void:
		fields.clear()
	

func newBasicProfile(id:String) -> Profile:
	var p : Profile = Profile.new()
	for key in getAllDefaultFieldTypes():
		p.createField(key)
	
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
	nb.set_text(0, p.name)
	
	return nb

func removeProfileId(id:String) -> void:
	cached.erase(id)

func loadFromJson(path:String=Manager.getPath("inmate_profiles")) -> void:
	var data : Array = Manager.loadFromJsonFile(path, TYPE_ARRAY, [])
	
	var unki : int = 0
	cached.clear()
	for rawp in data:
		if rawp.has("charid"):
			cached[rawp["charid"]] = dict2prof(rawp)
		else:
			cached["prof%s" % unki] = dict2prof(rawp)
			unki += 1
	
	populate()

func dict2prof(dict:Dictionary) -> Profile:
	var p : Profile = Profile.new()
	for key in getAllDefaultFieldTypes():
		var data = dict.get(key, [])
		if typeof(data)==TYPE_ARRAY:
			for x in data:
				p.createField(key).addData(x)
		else:
			p.createField(key).addData(data)
	
	
	p.name = dict.get("name", "")
	p.moduleId = dict.get("module id", "")
	p.flagId = dict.get("flag id", "")
	p.charid = dict.get("charid", "")
	p.inmateId = dict.get("name", "inmate id")
	
	return p

func _ready() -> void:
	Manager.addPath("inmate_profiles", "user://InmateProfiles.json")
	loadFromJson()
