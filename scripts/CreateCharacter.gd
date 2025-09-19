extends Control


@onready var message_panel: Panel = $MessageWindow
@onready var yes_btn: Button = $Center/Panel/VBox/ChoiceButtons/YesBtn
@onready var no_btn: Button = $Center/Panel/VBox/ChoiceButtons/NoBtn
@onready var choice_buttons: HBoxContainer = $Center/Panel/VBox/ChoiceButtons

@onready var choice_center: CenterContainer = $ChoiceCenter
@onready var yes_center: Button = $ChoiceCenter/ChoiceHBox/YesCenter
@onready var no_center: Button = $ChoiceCenter/ChoiceHBox/NoCenter

@onready var name_prompt: HBoxContainer = $Center/Panel/VBox/NamePrompt
@onready var name_entry: LineEdit = $Center/Panel/VBox/NamePrompt/NameEntry
@onready var name_ok: Button = $Center/Panel/VBox/NamePrompt/NameOk

@onready var name_center: CenterContainer = $NameCenter
@onready var name_entry2: LineEdit = $NameCenter/NameHBox2/NameEntry2
@onready var name_ok2: Button = $NameCenter/NameHBox2/NameOk2


var _state: String = "class_list"
var _selected_class: String = ""
var _temp_name: String = ""

func _ready() -> void:
    # Hide old controls from earlier UI
    for n in [
        $Center/Panel/VBox/NameHBox,
        $Center/Panel/VBox/ClassHBox,
        $Center/Panel/VBox/Desc,
        $Center/Panel/VBox/StatsGrid,
        $Center/Panel/VBox/Buttons
    ]:
        (n as Node).visible = false


    yes_btn.pressed.connect(_on_yes)
    no_btn.pressed.connect(_on_no)
    yes_center.pressed.connect(_on_yes)
    no_center.pressed.connect(_on_no)
    name_ok.pressed.connect(_on_name_ok)
    name_entry.text_submitted.connect(func(_t): _on_name_ok())
    name_ok2.pressed.connect(_on_name_ok2)
    name_entry2.text_submitted.connect(func(_t): _on_name_ok2())

    # Connect message window done signal
    if message_panel.has_signal("continue_available"):
        message_panel.connect("continue_available", Callable(self, "_on_window_continue_available"))

    _show_class_list()

func _show_class_list() -> void:
    _state = "class_list"
    message_panel.start_with(PackedStringArray(["Choose the class"]))
    choice_buttons.visible = false
    name_prompt.visible = false
    # Show reusable centered menu overlay
    _uib().show_menu(PackedStringArray(["Warrior","Templar","Rogue","Taoist","Mage"]), func(idx, text):
        _pick_class(text)
    )

func _pick_class(cn: String) -> void:
    _selected_class = cn
    _uib().play_select()
    _uib().hide_menu()
    choice_buttons.visible = false
    name_prompt.visible = false
    message_panel.start_with_title(cn, PackedStringArray([_gd().get_class_desc(cn)]))
    _state = "confirm_class"

func _on_window_continue_available(available: bool) -> void:
    if not available:
        return
    if _state == "confirm_class":
        var more: bool = bool(message_panel.call("has_more"))
        if more:
            message_panel.call("advance")
        else:
            _uib().show_prompt(func(): _on_yes(), func(): _on_no())
    elif _state == "confirm_character":
        # For confirm screen we don't use the message window; ignore continue
        pass

func _on_yes() -> void:
    if _state == "confirm_class":
        # Close any prompt and move to name entry state
        _uib().hide_prompt()
        _state = "enter_name"
        choice_center.visible = false
        # Show a prompt in the message window and center the input
        message_panel.start_with(PackedStringArray(["Enter the name"]))
        name_prompt.visible = false
        name_center.visible = true
        name_entry2.text = ""
        name_entry2.grab_focus()
        choice_buttons.visible = false
    elif _state == "confirm_character":
        _gd().create_character(_temp_name, _selected_class)
        get_tree().change_scene_to_file("res://scenes/Tavern.tscn")

func _on_no() -> void:
    if _state == "confirm_class":
        choice_center.visible = false
        _show_class_list()
    elif _state == "confirm_character":
        # Back to class selection
        _show_class_list()

func _on_name_ok() -> void:
    var nm: String = name_entry.text.strip_edges()
    if nm == "":
        return
    _temp_name = nm
    name_prompt.visible = false
    # Show confirm stats screen instead of message window
    _show_confirm_stats()
    _state = "confirm_character"

func _on_name_ok2() -> void:
    var nm: String = name_entry2.text.strip_edges()
    if nm == "":
        return
    _temp_name = nm
    name_center.visible = false
    _show_confirm_stats()
    _state = "confirm_character"

func _show_confirm_stats() -> void:
    var st: Dictionary = _gd().get_class_stats(_selected_class)
    message_panel.visible = false
    var cs: Control = $Center/Panel/VBox/ConfirmStats
    cs.visible = true
    ($Center/Panel/VBox/ConfirmStats/Name as Label).text = _temp_name
    ($Center/Panel/VBox/ConfirmStats/Class as Label).text = _selected_class
    ($Center/Panel/VBox/ConfirmStats/Cols/Left/HP as Label).text = "HP: " + str(st.get("HP", 0))
    ($Center/Panel/VBox/ConfirmStats/Cols/Left/MP as Label).text = "MP: " + str(st.get("MP", 0))
    ($Center/Panel/VBox/ConfirmStats/Cols/Left/STR as Label).text = "Strength: " + str(st.get("Strength", 0))
    ($Center/Panel/VBox/ConfirmStats/Cols/Left/DEX as Label).text = "Dexterity: " + str(st.get("Dexterity", 0))
    ($Center/Panel/VBox/ConfirmStats/Cols/Right/INT as Label).text = "Intelligence: " + str(st.get("Intelligence", 0))
    ($Center/Panel/VBox/ConfirmStats/Cols/Right/WIL as Label).text = "Will: " + str(st.get("Will", 0))
    ($Center/Panel/VBox/ConfirmStats/Cols/Right/VIT as Label).text = "Vitality: " + str(st.get("Vitality", 0))
    ($Center/Panel/VBox/ConfirmStats/Cols/Right/AGI as Label).text = "Agility: " + str(st.get("Agility", 0))
    ($Center/Panel/VBox/ConfirmStats/Cols/Right/SPD as Label).text = "Speed: " + str(st.get("Speed", 0))
    # Use centered Yes/No prompt window for confirmation
    _uib().show_prompt(func(): _on_yes_confirm(), func(): _on_no_confirm())

func _on_yes_confirm() -> void:
    _gd().create_character(_temp_name, _selected_class)
    get_tree().change_scene_to_file("res://scenes/Tavern.tscn")

func _on_no_confirm() -> void:
    ($Center/Panel/VBox/ConfirmStats as Control).visible = false
    _show_class_list()

func _gd() -> Node:
    return get_node("/root/GameData")

func _uib() -> Node:
    return get_node("/root/UIBus")
