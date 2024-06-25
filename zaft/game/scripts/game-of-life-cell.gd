class_name GameOfLifeCell extends ColorRect

@export var life: GameOfLife
@export var x : int = 0
@export var y : int = 0
@export var index : int = 0
@export var sum : int = Globals.DEAD
@export var alive : bool = false

func _gui_input(event: InputEvent) -> void:
  if event.is_action_pressed(&'give-life'):
    give_life()
    get_viewport().set_input_as_handled()
  elif event.is_action_pressed(&'take-life'):
    take_life()
    get_viewport().set_input_as_handled()

func on_mouse_enter():
  color.a = 0.5

func on_mouse_exit():
  color.a = 1.0

func connect_signals():
  mouse_entered.connect(on_mouse_enter)
  mouse_exited.connect(on_mouse_exit)

func give_life():
  life.alive_coords(x,y)

func take_life():
  life.kill_coords(x,y)

func setup():
  custom_minimum_size = Vector2(Globals.CELL_WIDTH, Globals.CELL_HEIGHT)
  set_anchors_and_offsets_preset(Control.LayoutPreset.PRESET_TOP_LEFT, Control.LayoutPresetMode.PRESET_MODE_MINSIZE)
  offset_top = y_for_rect(y)
  offset_left = x_for_rect(x)
  render()

func _enter_tree() -> void:
  add_to_group(Globals.GROUP_GAME_OF_LIFE_CELL)

func x_for_rect(_x:int=0) -> int:
  return _x * Globals.CELL_WIDTH

func y_for_rect(_y:int=0) -> int:
  return _y * Globals.CELL_HEIGHT

func rect_for_xy(_x:int=0,_y:int=0) -> Rect2i:
  return Rect2i(x_for_rect(_x), y_for_rect(_y), Globals.CELL_WIDTH, Globals.CELL_HEIGHT)

func render():
  if alive: render_alive()
  else: render_dead()

func render_dead():
  color = Globals.CELL_DEAD_COLOR

func render_alive():
  color = Globals.CELL_ALIVE_COLOR

func _ready() -> void:
  if not life: life = GameOfLife.resolve_using(self)
  connect_signals()
