extends AcceptDialog

signal discard

func _ready():
	add_button("No", true, "discard")
	connect("custom_action", on_custom_action)

func on_custom_action(action:String):
	if action == "discard":
		emit_signal("discard")
