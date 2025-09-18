extends Node

var _prompt_instance: Node = null
var _sfx_player: AudioStreamPlayer = null
var _sfx_select: AudioStream = preload("res://sfx/sfx_ui_select.ogg")

func _get_message_window() -> Node:
    var root: Node = get_tree().current_scene
    if root == null:
        return null
    # Find node named "MessageWindow" anywhere in scene
    return root.find_child("MessageWindow", true, false)

func show_text(entries: PackedStringArray, title: String = "") -> Node:
    var mw := _get_message_window()
    if mw == null:
        return null
    if title.strip_edges() != "":
        mw.start_with_title(title, entries)
    else:
        mw.start_with(entries)
    return mw

func ensure_prompt() -> Node:
    if _prompt_instance and is_instance_valid(_prompt_instance):
        _prompt_instance.queue_free()
        _prompt_instance = null
    var scene: PackedScene = load("res://scenes/ui/CenteredPrompt.tscn")
    _prompt_instance = scene.instantiate()
    get_tree().current_scene.add_child(_prompt_instance)
    return _prompt_instance

func _ensure_sfx_player() -> void:
    if _sfx_player and is_instance_valid(_sfx_player):
        return
    _sfx_player = AudioStreamPlayer.new()
    add_child(_sfx_player)
    _sfx_player.bus = "Master"

func play_select() -> void:
    _ensure_sfx_player()
    if _sfx_player.playing:
        _sfx_player.stop()
    _sfx_player.stream = _sfx_select
    _sfx_player.play()

func show_prompt(on_yes: Callable, on_no: Callable) -> void:
    var p := ensure_prompt()
    p.visible = true
    var yes: Button = p.get_node("Root/Window/Margin/Content/HBox/Yes")
    var no: Button = p.get_node("Root/Window/Margin/Content/HBox/No")
    yes.grab_focus()
    yes.pressed.connect(func():
        play_select()
        hide_prompt()
        if on_yes.is_valid():
            on_yes.call()
    )
    no.pressed.connect(func():
        play_select()
        hide_prompt()
        if on_no.is_valid():
            on_no.call()
    )

func hide_prompt() -> void:
    if _prompt_instance and is_instance_valid(_prompt_instance):
        _prompt_instance.visible = false
