extends RefCounted
class_name Field


var data : Array[String] = []

signal dataAdded(new:String)
signal dataRemoved(idx:int)

signal refreshRequested

func setData(idx:int, new:String) -> void:
	if idx>=data.size():
		refreshRequested.emit()
		return
	
	data[idx]=new

func getDataForAccessLevel(al:int=0) -> String:
	if !data:
		return ""
	return data[mini(al, data.size()-1)]

func addData(d:String) -> void:
	data.append(d)
	dataAdded.emit(d)

func removeData(d:String) -> void:
	var idx = data.find(d)
	if idx!=-1:
		removeDataIndex(idx)

func removeDataIndex(idx:int) -> void:
	data.remove_at(idx)
	dataRemoved.emit(idx)

func getData() -> Array[String]:
	return data

func clearData() -> void:
	data.clear()
	refreshRequested.emit()
