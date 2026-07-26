extends Node

const ConfigPathsKey : String = "PATHS"
const ConfigOptionsKey : String = "OPTIONS"

signal optionsChanged(option:String)

var paths : Dictionary[String, String] = {
	# id: path
}

var options : Dictionary[String, String] = {
	"nativeFiles":"false",
}

var cacheData : Dictionary[String, Variant] = {
	# id: data (handled separately?)
}

func addPath(id:String, path:String) -> void:
	paths[id]=path

func getOption(option:String) -> String:
	return options.get(option, "")

func _ready():
	loadFromConfigFile("user://recent.ini")

func loadFromConfigFile(configPath:String="user://recent.ini") -> void:
	var conf := ConfigFile.new()
	
	for path in getDefaultPaths():
		addPath(path, "")
		
	
	if conf.load(configPath)!=OK:
		return
	
	for key in conf.get_section_keys(ConfigPathsKey):
		addPath(key, conf.get_value(ConfigPathsKey, key, ""))
	
	for key in conf.get_section_keys(ConfigOptionsKey):
		addOption(key, conf.get_value(ConfigOptionsKey, key, ""))

func addOption(key:String, val:String) -> void:
	options[key]=val
	optionsChanged.emit(key)

## returns success saving
func saveToConfigFile(configFile:String="user://recent.ini") -> bool:
	var conf := ConfigFile.new()
	
	for id in paths.keys():
		conf.set_value(ConfigPathsKey, id, paths[id])
	
	return conf.save(configFile)==OK

func getDefaultPaths() -> PackedStringArray:
	var r : PackedStringArray = [
		"plants",
		"recipes",
		"ingredients",
		"inmate_profiles",
	]
	
	return r

func getPath(id:String) -> String:
	return paths.get(id, "")

func loadFromJsonFile(path:String, type:Variant.Type, nullv:Variant=null) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	if !f:
		return nullv
	
	var test_json_conv = JSON.new()
	
	if test_json_conv.parse(f.get_as_text())!=OK:
		f.close()
		return nullv
	
	var result : Variant = test_json_conv.get_data()
	
	if typeof(result) != type:
		f.close()
		return nullv
	
	f.close()
	return result
