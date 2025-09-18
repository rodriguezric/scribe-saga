extends Control

@onready var create_button: Button = $Center/VBox/CreateButton
@onready var back_button: Button = $Center/VBox/BackButton
@onready var roster_list: VBoxContainer = $Center/VBox/RosterScroll/RosterList

func _ready() -> void:
    create_button.pressed.connect(func(): _uib().play_select(); get_tree().change_scene_to_file("res://scenes/CreateCharacter.tscn"))
    back_button.pressed.connect(func(): _uib().play_select(); get_tree().change_scene_to_file("res://scenes/Town.tscn"))
    _refresh_roster()

func _gd() -> Node:
    return get_node("/root/GameData")

func _refresh_roster() -> void:
    # Clear existing
    for c in roster_list.get_children():
        roster_list.remove_child(c)
        c.queue_free()
    # Populate from GameData
    var gd: Node = _gd()
    if gd == null:
        return
    var roster_val = gd.get("roster")
    var roster: Array = roster_val if typeof(roster_val) == TYPE_ARRAY else []
    for ch in roster:
        var name_val = (ch as Object).get("name")
        var class_val = (ch as Object).get("klass")
        var name: String = String(name_val) if typeof(name_val) != TYPE_NIL else "Unnamed"
        var klass: String = String(class_val) if typeof(class_val) != TYPE_NIL else ""
        var label := Label.new()
        label.text = name + " (" + klass + ")"
        roster_list.add_child(label)

func _uib() -> Node:
    return get_node("/root/UIBus")
