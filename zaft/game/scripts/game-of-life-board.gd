class_name GameOfLifeBoard extends Node2D

@export var life : GameOfLife

var data_size := Globals.WIDTH * Globals.HEIGHT
var cells : Array = range(data_size)

func on_change_at_index(index:int=0,sum:int=0,alive:=false):
  var cell : GameOfLifeCell = cells[index]
  cell.sum = sum
  var will_change = cell.alive != alive
  cell.alive = alive
  if will_change:
    cell.render()

func connect_signals():
  life.sig_changed_at_index.connect(on_change_at_index)

func _init() -> void:
  for index in data_size:
    var x := GameOfLife.static_index_to_x(index)
    var y := GameOfLife.static_index_to_y(index)
    var cell := GameOfLifeCell.new()
    cell.x = x
    cell.y = y
    cell.index = index
    cell.name = "cell_at_x_%s_y_%s_index_%s" % [x,y,index]
    cell.setup()
    cells[index] = cell

func _ready() -> void:
  if not life: life = GameOfLife.resolve_using(self)
  for index in data_size:
    add_child(cells[index])
  connect_signals()

static func resolve_using(node_in_tree:Node) -> GameOfLifeBoard:
  return node_in_tree.get_tree().get_first_node_in_group(Globals.GROUP_GAME_OF_LIFE_BOARD)

func _enter_tree() -> void:
  add_to_group(Globals.GROUP_GAME_OF_LIFE_BOARD)

