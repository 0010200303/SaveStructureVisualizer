extends AcceptDialog

@onready var tree := $"../../Tree"
@onready var DataType := $VBoxContainer/DataType
@onready var ByteSize := $VBoxContainer/ByteSize

signal finished

var data_type := ""
var byte_size := ""

func _ready():
	update_data_types()
	
	connect("confirmed", on_confirm)

func update_data_types():
	DataType.clear()
	
	var data_types := tree.data_types.keys() as Array[String]
	
	for i in range(1, data_types.size()):
		DataType.add_item(data_types[i], i)
	
	DataType.selected = 0

func on_confirm():
	data_type = DataType.text
	byte_size = ByteSize.text
	
	DataType.text = ""
	ByteSize.text = ""
	
	emit_signal("finished")
