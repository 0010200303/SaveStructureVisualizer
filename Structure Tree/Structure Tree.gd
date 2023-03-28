extends Tree

var data_types := { "create new data type":"-1",
					"[bool]":"1",
					"[byte]":"1",
					"[int]":"4",
					"[float]":"4",
					"[string]":"n*1" }

var data_types_string := ",".join(data_types.keys())

var saved := false
var save_path := ""

func _init():
	connect("cell_selected", display_data_types)
	connect("item_edited", on_item_edited)
	
	set_column_clip_content(0, true)
	
	set_column_title(0, "byte_size")
	set_column_title(1, "data_type")
	set_column_title(2, "name")
	set_column_title(3, "description")

func _get_drag_data(_at_position:Vector2) -> Variant:
	set_drop_mode_flags(DROP_MODE_ON_ITEM | DROP_MODE_INBETWEEN)
	
	return get_all_selected()

func _can_drop_data(_at_position:Vector2, data:Variant) -> bool:
	return data.get_typed_class_name() == "TreeItem"

func _drop_data(at_position:Vector2, data:Variant):
	data = data as Array[TreeItem]
	var to_item := get_item_at_position(at_position)
	var shift := get_drop_section_at_position(at_position)
	
	if to_item == null or to_item in data:
		return
	
	if shift == -1:
		for item in data:
			_drop_data_single(to_item, shift, item)
	else:
		for i in range(data.size() - 1, -1, -1):
			_drop_data_single(to_item, shift, data[i])

func _drop_data_single(to_item:TreeItem, shift:int, item:TreeItem):
	if shift == 0:
		var dummy := create_item(to_item)
		item.move_after(dummy)
		dummy.free()
	elif shift == 1:
		var to_item_parent := to_item.get_parent()
		
		if to_item_parent != null:
			item.move_after(to_item)
		else:
			var dummy := create_item(to_item_parent, 0)
			item.move_after(dummy)
			dummy.free()
	elif shift == -1:
		item.move_before(to_item)

func on_item_edited():
	var edited_item := get_edited()
	var edited_column := get_edited_column()
	
	if edited_item.get_cell_mode(1) != TreeItem.CELL_MODE_RANGE or edited_column != 1:
		return
	
	if edited_item.get_range(1) == 0:
#		baaaaad!
		var kek := get_tree().root.get_node("Node2D/CanvasLayer/MenuContainer/DataTypeButton")
		kek.create_data_type()
	
	var byte_size := data_types.values()[edited_item.get_range(1)] as String
	edited_item.set_text(0, byte_size)

func get_all_selected() -> Array[TreeItem]:
	var selected_items := [] as Array[TreeItem]
	var selected_item = null
	
	while true:
		selected_item = get_next_selected(selected_item)
		
		if selected_item != null:
			selected_items.append(selected_item)
		else:
			break
	
	return selected_items

func display_data_types():
	var selected_item := get_selected()
	var selected_column := get_selected_column()
	
	if selected_item == null or selected_column != 1:
		return
	
	if selected_item.get_cell_mode(1) == TreeItem.CELL_MODE_RANGE:
		selected_item.set_text(1, data_types_string)

func add_item(root_item:TreeItem = null, data_type_index:int = 0, item_name:String = "", description = "") -> TreeItem:
	var item := create_item(root_item)
	item.set_text(0, data_types[data_types.keys()[0]])
	
	item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	item.set_editable(1, true)
	item.set_text(1, data_types_string)
	
	item.set_editable(2, true)
	item.set_editable(3, true)
	
	select_data_type(item, data_type_index)
	item.set_text(2, item_name)
	item.set_text(3, description)
	
	return item

func add_item_before():
	var selected_item := get_selected()
	if selected_item == null or selected_item == get_root():
		return
	
	var item := add_item(selected_item.get_parent())
	item.move_before(selected_item)

func add_item_after():
	var selected_item := get_selected()
	if selected_item == null or selected_item == get_root():
		return
	
	var item := add_item(selected_item.get_parent())
	item.move_after(selected_item)

func add_item_below():
	var selected_item := get_selected()
	if selected_item == null:
		return
	
	add_item(selected_item)

func remove_item():
	var selected_item := get_selected()
	if selected_item == null or selected_item == get_root():
		return
	
	selected_item.free()

func remove_data_type_in_tree(data_type:String, item:TreeItem = null):
	if item == null:
		item = get_root()
	
	if data_types.keys()[item.get_range(1)] == data_type:
		item.set_range(1, 0)
		item.set_text(0, data_types[data_types.keys()[0]])
	
	for child in item.get_children():
		remove_data_type_in_tree(data_type, child)

func edit_data_type_in_tree(data_type:String, item:TreeItem = null):
	if item == null:
		item = get_root()
	
	if data_types.keys()[item.get_range(1)] == data_type:
		item.set_text(0, data_types[data_type])
	
	for child in item.get_children():
		edit_data_type_in_tree(data_type, child)

func select_data_type(item:TreeItem, index:int):
	item.set_range(1, index)
	item.set_text(0, data_types.values()[index])

func collapse_all(root:TreeItem, ignore_root:bool = false):
	if ignore_root == false or get_root() != root:
		root.collapsed = true
	
	for child in root.get_children():
		collapse_all(child)

func new_file():
	clear()
	
	var root := create_item(null)
	root.set_text(0, "0")
	root.set_text(1, "root")
	root.disable_folding = true
	
	return root

func save_file(path:String):
	var file := FileAccess.open(path, FileAccess.WRITE)
	var keys := data_types.keys()
	
	file.store_32(keys.size() - 1)
	for i in range(1, keys.size()):
		var key := keys[i] as String

		file.store_pascal_string(key)
		file.store_pascal_string(data_types[key])
	
	var children := get_root().get_children()
	file.store_32(children.size())
	
	for child in children:
		save_tree_item_to_file(file, child)
	
	save_path = path

func save_tree_item_to_file(file:FileAccess, item:TreeItem):
	var children := item.get_children()
	
	file.store_32(children.size())
	
	file.store_32(int(item.get_range(1)))
	file.store_pascal_string(item.get_text(2))
	file.store_pascal_string(item.get_text(3))
	
	for child in children:
		save_tree_item_to_file(file, child)

func load_file(path:String):
	var file := FileAccess.open(path, FileAccess.READ)
	var count := file.get_32()
	
	data_types = { "create new data type":"-1" }
	
	for i in count:
		var key := file.get_pascal_string()
		var value := file.get_pascal_string()
		
		data_types[key] = value
	data_types_string = ",".join(data_types.keys())
	
	var root := new_file()
	
	count = file.get_32()
	for i in count:
		load_tree_from_file(file, root)
	
	collapse_all(get_root(), true)
	
	save_path = path

func load_tree_from_file(file:FileAccess, root:TreeItem):
	var count := file.get_32()
	
	var item := add_item(root)
	select_data_type(item, file.get_32())
	item.set_text(2, file.get_pascal_string())
	item.set_text(3, file.get_pascal_string())
	
	for i in count:
		load_tree_from_file(file, item)
