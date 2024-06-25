class_name GameOfLife extends Node

signal sig_changed_at_coords(x:int,y:int,sum:int,alive:bool)
signal sig_changed_at_index(index:int,sum:int,alive:bool)

var data_size := Globals.WIDTH * Globals.HEIGHT

@export var globals : Globals
@export var board : GameOfLifeBoard
@export var shader : GameOfLifeComputeShader

## Single array of WIDTH * HEIGHT proportions, contains data of the previous frame
var prev : PackedInt32Array

## Single array of WIDTH * HEIGHT proportions, contains data of the current frame
var curr : PackedInt32Array

static func resolve_using(node_in_tree:Node) -> GameOfLife:
  return node_in_tree.get_tree().get_first_node_in_group(Globals.GROUP_GAME_OF_LIFE)

static func static_index_to_y(index:int=0) -> int:
  @warning_ignore(&'integer_division')
  return index / Globals.WIDTH

func compute_next_frame():
  prev = curr.duplicate()
  curr = shader.calculate(curr)
  for index in data_size:
    if curr[index] >= globals.overpopulation_threshold:
      curr[index] = Globals.DEAD
    elif curr[index] >= globals.underpopulation_threshold:
      curr[index] = Globals.ALIVE
    else:
      curr[index] = Globals.DEAD
    if curr[index] != prev[index]:
      notify_change_at_index(index)

func mass_extinction():
  for index in data_size:
    kill_index(index)

func index_to_y(index:int=0) -> int:
  assert_valid_index(index)
  return static_index_to_y(index)

static func static_index_to_x(index:int=0) -> int:
  return index % Globals.WIDTH

func index_to_x(index:int=0) -> int:
  assert_valid_index(index)
  return static_index_to_x(index)

func y_to_index(y:int=0) -> int:
  assert_valid_y(y)
  return y * Globals.WIDTH

func x_to_index(x:int=0) -> int:
  assert_valid_x(x)
  return x % Globals.WIDTH

func xy_to_index(x:int=0,y:int=0) -> int:
  assert_valid_xy(x,y)
  return x_to_index(x) + y_to_index(y)

func is_dead_at_index(index:int=0) -> bool:
  assert_valid_index(index)
  return value_at_index(index) <= Globals.DEAD

func value_at_index(index:int=0) -> int:
  assert_valid_index(index)
  return curr[index]

func value_at_coords(x:int=0,y:int=0) -> int:
  assert_valid_xy(x,y)
  return curr[xy_to_index(x,y)]

func kill_index(index:int):
  assert_valid_index(index)
  kill_coords(index_to_x(index),index_to_y(index))

func alive_index(index:int):
  assert_valid_index(index)
  alive_coords(index_to_x(index),index_to_y(index))

func notify_change_at_index(idx:int):
  assert_valid_index(idx)
  sig_changed_at_coords.emit(index_to_x(idx),index_to_y(idx),curr[idx],curr[idx]>Globals.DEAD)
  sig_changed_at_index.emit(idx,curr[idx],curr[idx]>Globals.DEAD)

func kill_coords(x:int,y:int):
  assert_valid_xy(x,y)
  var idx := xy_to_index(x,y)
  var changed := curr[idx] != Globals.DEAD
  curr[idx] = Globals.DEAD
  if changed: notify_change_at_index(idx)

func alive_coords(x:int,y:int):
  assert_valid_xy(x,y)
  var idx := xy_to_index(x,y)
  var changed := curr[idx] != Globals.ALIVE
  curr[idx] = Globals.ALIVE
  if changed: notify_change_at_index(idx)

func add_to_coords(x:int,y:int,sum:int=1):
  assert_valid_xy(x,y)
  var idx := xy_to_index(x,y)
  curr[idx] = curr[idx] + sum
  notify_change_at_index(idx)

func _init() -> void:
  var initial_data := range(data_size)
  initial_data.fill(Globals.DEAD)
  prev = PackedInt32Array(initial_data)
  curr = PackedInt32Array(initial_data)

func resolve_board():
  if board: return
  board = GameOfLifeBoard.resolve_using(self)
  if board: return
  assert(owner, "%s must provide a board or have an owner" % get_path())
  create_default_board()

func create_default_board():
  board = GameOfLifeBoard.new()
  board.name = "ManagedGameOfLifeBoard"
  owner.add_child.call_deferred(board)

func resolve_globals():
  if globals: return
  globals = await Globals.instance_for(self)

func resolve_shader():
  if shader: return
  shader = GameOfLifeComputeShader.resolve_using(self)
  if shader: return
  create_default_shader()

func create_default_shader():
  shader = GameOfLifeComputeShader.new()
  shader.name = "ManagedGameOfLifeShader"
  add_child(shader)

func _enter_tree() -> void:
  add_to_group(Globals.GROUP_GAME_OF_LIFE)

func _ready() -> void:
  resolve_board()
  resolve_shader()
  resolve_globals()
  assert(board, "%s must provide a board" % get_path())
  assert(shader, "%s must provide a shader" % get_path())

func assert_valid_index(index:int=0):
  assert(index >= 0, "%s index must be >= 0" % get_path())
  assert(index < data_size, "%s y must be < %s" % [get_path(), data_size])

func assert_valid_x(x:int=0):
  assert(x >= 0, "%s x must be >= 0" % get_path())
  assert(x < Globals.WIDTH, "%s x must be < %s" % [get_path(), Globals.WIDTH])

func assert_valid_y(y:int=0):
  assert(y >= 0, "%s y must be >= 0" % get_path())
  assert(y < Globals.HEIGHT, "%s y must be < %s" % [get_path(), Globals.HEIGHT])

func assert_valid_xy(x:int=0,y:int=0):
  assert_valid_x(x)
  assert_valid_y(y)

