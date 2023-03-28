extends AcceptDialog

@onready var DataType := $VBoxContainer/DataType
@onready var ByteSize := $VBoxContainer/ByteSize

signal finished

var data_type := ""
var byte_size := ""

func _ready():
	connect("confirmed", on_confirm)

func on_confirm():
	data_type = DataType.text
	byte_size = ByteSize.text
	
	DataType.text = ""
	ByteSize.text = ""
	
	emit_signal("finished")
