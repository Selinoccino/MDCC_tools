extends Node

const ConfigPathsKey : String = "PATHS"

var paths : Dictionary = {
	# id: path
}

var cacheData : Dictionary = {
	# id: data (handled separately?)
}

func addPath(id:String, path:String) -> void:
	paths[id]=path

func _ready():
	loadFromConfigFile("")

func loadFromConfigFile(configPath:String) -> void:
	var conf := ConfigFile.new()
	
	for path in getDefaultPaths():
		addPath(path, "")
		
	
	if conf.load(configPath)!=OK:
		return
	
	for key in conf.get_section_keys(ConfigPathsKey):
		addPath(key, conf.get_value(ConfigPathsKey, key, ""))

## returns success saving
func saveToConfigFile(configFile:String) -> bool:
	var conf := ConfigFile.new()
	
	for id in paths.keys():
		conf.set_value(ConfigPathsKey, id, paths[id])
	
	return conf.save(configFile)==OK

func getDefaultPaths() -> PoolStringArray:
	var r : PoolStringArray = [
		"plants",
		"recipes",
		"ingredients",
		"inmate_profiles",
	]
	
	return r

func getPath(id:String) -> String:
	return paths.get(id, "")
