extends MenuButton

@onready var tree := $"../../Tree"

func _ready():
	get_popup().connect("index_pressed", on_index_pressed)

func on_index_pressed(index:int):
	var action := get_popup().get_item_text(index)
	
	match (action):
		"Add": tree.create_new_data_type()
		"Remove": tree.remove_data_type()
		"Edit": tree.edit_data_type()
