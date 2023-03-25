extends MenuButton

@onready var tree := $"../../Tree"

func _ready():
	get_popup().connect("index_pressed", on_index_pressed)

func on_index_pressed(index:int):
	var action := get_popup().get_item_text(index)
	
	match (action):
		"New": tree.new_file_if_saved()
		"Save": tree.save_file_dialog()
		"Load": tree.load_file_dialog()
