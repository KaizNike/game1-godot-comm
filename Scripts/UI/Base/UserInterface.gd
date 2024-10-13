extends Control
class_name UserInterface
## UserInterface Class: [br]
## A Base UI class to contain common UI features within the game such as:[br]
## - Controller Ui Support
## - viewport Text Reizing (currently requires text size override to be on.).[br]
## - Translation Switching (Unimplemented).

@export_group("Focus Start", "start")

enum FOCUS_START_ENUM 
{
	## Activates when ready function is called.
	ready,
	## Activates when changed to visible.
	visibility_changed,
	## Activates when either ready or visible is called
	both
}

@export var start_on: bool = true
@export var start_focus: Control
@export var start_MODE: FOCUS_START_ENUM
@export_group("Text Resize", "resize")

## Turns Text Resizing on or off.
@export var resize_on:bool = true

enum RESIZE_MODE_ENUM 
{
	## the text will be resized using both the width and the height property.
	both = 0,
	## the text will be resized using th width property.
	width = 2,
	## the height will be resized using the height property.
	height = 1
}

## Setting for how the UserInterface handles font resizing.
@export var resize_MODE: RESIZE_MODE_ENUM = RESIZE_MODE_ENUM.both

## original viewport base size.
@onready var base_size: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"), 
	ProjectSettings.get_setting("display/window/size/viewport_height")
)

## Dictionary to hold nodes with font size overrides
var font_nodes: Dictionary = {}  



func _ready() -> void:
	# Store font size and node
	for node: Node in UtilityFunctions.get_all_Children(self):
		if node is Control:
			if node.has_theme_font_size_override("font_size"):
				font_nodes[node] = node.get("theme_override_font_sizes/font_size")
			elif node.has_theme_font_size("font_size"):
				font_nodes[node] = node.get_theme_font_size("font_size")
	
	get_tree().get_root().size_changed.connect(font_resize)
	font_resize()
	
	if start_on:
		if start_focus != null:
			start_focus.grab_focus()
		else:
			printerr("You do not have a focus node selected in UI class \n turn focus off or select focus node")

## Resizes all of the child nodes fonts acording to the viewport size.
func font_resize() -> void:
	if !resize_on:
		return
		
	var viewport_size = get_viewport().size
	for node: Node in font_nodes.keys():
		var formula: float = 1.0
		match resize_MODE:
			0:  # Resize based on both width and height
				formula = (viewport_size.x / base_size.x + viewport_size.y / base_size.y) / 2.0
			1:  # Resize based on height
				formula = viewport_size.y / base_size.y
			2:  # Resize based on width
				formula = viewport_size.x / base_size.x

		# Apply the new font size to the node
		node.add_theme_font_size_override("font_size", font_nodes[node] * formula)

func _on_visibility_changed() -> void:
	if !start_focus.is_inside_tree():
		return;
	if !start_on:
		return;
	if visible == true:
		if start_focus != null:
			start_focus.grab_focus()
		else:
			printerr("You do not have a focus node selected in UI class \n turn focus off or select focus node")
