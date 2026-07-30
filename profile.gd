extends RefCounted
class_name Profile

var nonfields : Dictionary[String, String] = {
}

var fields : Dictionary[String, Field] = {}

static func getDefaultNonfields() -> Array[String]:
	var r : Array[String] = [
		"name",
		"charid",
		"inmate id",
		"flag id",
		"module id",
	]
	return r

func createDefaults() -> void:
	for nf in getDefaultNonfields():
		nonfields[nf] = ""
	for field in getAllDefaultFieldTypes():
		createField(field)
	

static func getAllDefaultFieldTypes() -> Array[String]:
	var r : Array[String] = [
			"origin", "age", "inmate type", "crimes", "gender", "anatomy", "species", "description", "height", "weight", "detainment procs",
		]
	
	return r

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

func setNonField(nf:String, new:String) -> void:
	nonfields[nf] = new

static func dict2prof(dict:Dictionary) -> Profile:
	var p : Profile = Profile.new()
	for key in getAllDefaultFieldTypes():
		var data = dict.get(key, [])
		if typeof(data)==TYPE_ARRAY:
			for x in data:
				p.createField(key).addData(x)
		else:
			p.createField(key).addData(data)
	
	for nf in getDefaultNonfields():
		p.nonfields[nf] = dict.get(nf, "")
	
	return p

static func prof2dict(p:Profile) -> Dictionary[String, Variant]:
	var d : Dictionary[String, Variant] = {}
	
	for nf in p.nonfields.keys():
		d[nf] = p.nonfields[nf]
	
	for field in p.fields.keys():
		var data = p.getField(field).getData()
		d[field] = data
	
	return d
