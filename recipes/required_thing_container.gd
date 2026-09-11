extends VBoxContainer
class_name RequiredThingContainer

@export var entryScene : PackedScene = preload("res://recipes/required_ingredient_entry.tscn")

func getValue() -> Variant:
	return null

func addNew() -> Control:
	return entryScene.instantiate()

func clear() -> void:
	return

func setToValue(_value:Variant) -> void:
	return
