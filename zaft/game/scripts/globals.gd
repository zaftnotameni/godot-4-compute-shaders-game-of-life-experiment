class_name Globals extends Node

const OVERPOPULATION_THRESHOLD := 3
const UNDERPOPULATION_THRESHOLD := 2

signal sig_overpopulation_threshold_changed(new_value:int,old_value:int)
signal sig_underpopulation_threshold_changed(new_value:int,old_value:int)

var overpopulation_threshold : int = OVERPOPULATION_THRESHOLD :
  set(v):
    if v != overpopulation_threshold:
      var prev = overpopulation_threshold
      overpopulation_threshold = v
      sig_overpopulation_threshold_changed.emit(v, prev)

var underpopulation_threshold : int = UNDERPOPULATION_THRESHOLD :
  set(v):
    if v != underpopulation_threshold:
      var prev = underpopulation_threshold
      underpopulation_threshold = v
      sig_underpopulation_threshold_changed.emit(v, prev)

const CELL_WIDTH := 8
const CELL_HEIGHT := 8

const CELL_ALIVE_COLOR := Color.CYAN
const CELL_DEAD_COLOR := Color.WEB_PURPLE

const GROUP_GAME_OF_LIFE := &'game-of-life'
const GROUP_GAME_OF_LIFE_BOARD := &'game-of-life-board'
const GROUP_GAME_OF_LIFE_SHADER := &'game-of-life-shader'
const GROUP_GAME_OF_LIFE_CELL := &'game-of-life-cell'

const DEAD := 0
const ALIVE := 1

const WIDTH := 128;
const HEIGHT := 128;

const UI_MENU_SIZE := 200;

static var _instance : Globals

static func instance_for(node_in_tree:Node):
  if _instance: return _instance
  _instance = Globals.new()
  _instance.name = "ManagedGlobals"
  node_in_tree.get_tree().root.add_child.call_deferred(_instance)
  await _instance.ready
  return _instance

