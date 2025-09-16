extends Node2D

@export var grid_w: int = 15
@export var grid_h: int = 21
@export var cell: int = 24
@export var wall_width: float = 3.0

@onready var back_button: Button = $UI/BackControl/BackButton

var walls_h: Array = [] # (grid_h + 1) x grid_w
var walls_v: Array = [] # grid_h x (grid_w + 1)
var visited: Array = [] # grid_h x grid_w

var player_x: int = 0
var player_y: int = 0

func _ready() -> void:
    back_button.pressed.connect(_on_back)
    _init_grids()
    _carve_maze()
    queue_redraw()

func _init_grids() -> void:
    walls_h = []
    for y in grid_h + 1:
        var row: Array = []
        for x in grid_w:
            row.append(true)
        walls_h.append(row)
    walls_v = []
    for y in grid_h:
        var row2: Array = []
        for x in grid_w + 1:
            row2.append(true)
        walls_v.append(row2)
    visited = []
    for y in grid_h:
        var r: Array = []
        for x in grid_w:
            r.append(false)
        visited.append(r)
    player_x = 0
    player_y = 0

func _carve_maze() -> void:
    var rng := RandomNumberGenerator.new()
    rng.randomize()
    _dfs(0, 0, rng)

func _dfs(cx: int, cy: int, rng: RandomNumberGenerator) -> void:
    visited[cy][cx] = true
    var dirs: Array = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
    # Shuffle directions
    for i in dirs.size():
        var j: int = rng.randi_range(0, dirs.size() - 1)
        var tmp = dirs[i]
        dirs[i] = dirs[j]
        dirs[j] = tmp
    for d in dirs:
        var nx: int = cx + d.x
        var ny: int = cy + d.y
        if nx < 0 or nx >= grid_w or ny < 0 or ny >= grid_h:
            continue
        if visited[ny][nx]:
            continue
        # remove wall between (cx,cy) and (nx,ny)
        if d.x == 1:
            walls_v[cy][cx + 1] = false
        elif d.x == -1:
            walls_v[cy][cx] = false
        elif d.y == 1:
            walls_h[cy + 1][cx] = false
        elif d.y == -1:
            walls_h[cy][cx] = false
        _dfs(nx, ny, rng)

func _draw() -> void:
    var vs: Vector2 = get_viewport_rect().size
    var maze_w: float = float(grid_w * cell)
    var maze_h: float = float(grid_h * cell)
    var origin: Vector2 = Vector2((vs.x - maze_w) * 0.5, (vs.y - maze_h) * 0.5)
    # Floor
    draw_rect(Rect2(origin, Vector2(maze_w, maze_h)), Color(0.08, 0.08, 0.1))
    var white := Color(1,1,1)
    # Horizontal walls
    for y in walls_h.size():
        for x in walls_h[y].size():
            if walls_h[y][x]:
                var a := origin + Vector2(x * cell, y * cell)
                var b := origin + Vector2((x + 1) * cell, y * cell)
                draw_line(a, b, white, wall_width)
    # Vertical walls
    for y in walls_v.size():
        for x in walls_v[y].size():
            if walls_v[y][x]:
                var a2 := origin + Vector2(x * cell, y * cell)
                var b2 := origin + Vector2(x * cell, (y + 1) * cell)
                draw_line(a2, b2, white, wall_width)
    # Player
    var pc: Vector2 = origin + Vector2(player_x * cell + cell * 0.5, player_y * cell + cell * 0.5)
    draw_circle(pc, cell * 0.3, Color(1.0, 0.85, 0.2))

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        var dx: int = 0
        var dy: int = 0
        match event.keycode:
            KEY_RIGHT, KEY_D:
                dx = 1
            KEY_LEFT, KEY_A:
                dx = -1
            KEY_DOWN, KEY_S:
                dy = 1
            KEY_UP, KEY_W:
                dy = -1
            _:
                return
        _try_move(dx, dy)

func _try_move(dx: int, dy: int) -> void:
    var nx: int = clampi(player_x + dx, 0, grid_w - 1)
    var ny: int = clampi(player_y + dy, 0, grid_h - 1)
    if nx == player_x and ny == player_y:
        return
    # Check walls
    if dx == 1 and walls_v[player_y][player_x + 1]:
        return
    if dx == -1 and walls_v[player_y][player_x]:
        return
    if dy == 1 and walls_h[player_y + 1][player_x]:
        return
    if dy == -1 and walls_h[player_y][player_x]:
        return
    player_x = nx
    player_y = ny
    queue_redraw()

func _on_back() -> void:
    get_tree().change_scene_to_file("res://scenes/Town.tscn")

