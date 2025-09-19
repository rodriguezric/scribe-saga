extends CanvasLayer

signal option_selected(index: int, text: String)

@onready var window: Panel = $Root/Window
@onready var margin: MarginContainer = $Root/Window/Margin
@onready var list: VBoxContainer = $Root/Window/Margin/List

func clear() -> void:
    for c in list.get_children():
        list.remove_child(c)
        c.queue_free()

func set_options(options: PackedStringArray) -> void:
    clear()
    var idx: int = 0
    for t in options:
        var b := Button.new()
        b.text = t
        b.custom_minimum_size = Vector2(200, 48)
        b.focus_mode = Control.FOCUS_ALL
        var i := idx
        b.pressed.connect(func(): option_selected.emit(i, t))
        list.add_child(b)
        idx += 1
    # Focus first button
    if list.get_child_count() > 0:
        (list.get_child(0) as Button).grab_focus()
    _resize_to_content()

func _resize_to_content() -> void:
    await get_tree().process_frame
    var sep: int = list.get_theme_constant("separation")
    var max_w: float = 0.0
    var total_h: float = 0.0
    var count: int = list.get_child_count()
    for i in count:
        var ch := list.get_child(i) as Control
        if ch == null:
            continue
        var ms: Vector2 = ch.get_combined_minimum_size()
        max_w = max(max_w, ms.x)
        total_h += ms.y
        if i < count - 1:
            total_h += sep
    var pad_l: int = margin.get_theme_constant("margin_left")
    var pad_r: int = margin.get_theme_constant("margin_right")
    var pad_t: int = margin.get_theme_constant("margin_top")
    var pad_b: int = margin.get_theme_constant("margin_bottom")
    var target: Vector2 = Vector2(max_w + float(pad_l + pad_r), total_h + float(pad_t + pad_b))
    window.custom_minimum_size = target
