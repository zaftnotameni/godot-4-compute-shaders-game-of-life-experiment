class_name GameOfLifeUI extends VBoxContainer

enum AUTO_MODE { Off = 0, On }

@export var life : GameOfLife
@export var globals : Globals
@export var auto_mode : AUTO_MODE = AUTO_MODE.Off

@onready var btn_clear := Button.new()
@onready var btn_next := Button.new()
@onready var btn_auto := Button.new()
@onready var btn_stop := Button.new()

@onready var slider_under := HSlider.new()
@onready var slider_over := HSlider.new()

var buttons = ['next', 'clear', 'auto', 'stop']
var sliders = [
  ['under', Globals.UNDERPOPULATION_THRESHOLD, 'Cell will die if it has less than this many neighbors alive', 'underpopulation_threshold', 'sig_underpopulation_threshold_changed'],
  ['over', Globals.OVERPOPULATION_THRESHOLD, 'Cell will die if it has more than this many neighbors alive', 'overpopulation_threshold', 'sig_overpopulation_threshold_changed']]

var auto_mode_tween : Tween
var auto_mode_max_fps := 4
var auto_mode_delay := 1.0 / auto_mode_max_fps

func prepare_auto_mode_tween():
  kill_auto_mode_tween()
  auto_mode_tween = create_tween().set_loops()

func kill_auto_mode_tween():
  if auto_mode_tween and auto_mode_tween.is_running(): auto_mode_tween.kill()
  auto_mode_tween = null

func auto_mode_check_for_stop():
  if auto_mode != AUTO_MODE.On:
    kill_auto_mode_tween()

func on_stop():
  auto_mode = AUTO_MODE.Off
  kill_auto_mode_tween()

func on_auto():
  auto_mode = AUTO_MODE.On
  prepare_auto_mode_tween()
  auto_mode_tween.tween_interval(auto_mode_delay)
  auto_mode_tween.tween_callback(auto_mode_check_for_stop)
  auto_mode_tween.tween_callback(on_next)

func on_next():
  life.compute_next_frame()

func on_clear():
  life.mass_extinction()

func valid_slider_named(base_name:String="example for slider_example") -> HSlider:
  assert(base_name, 'must provide a base name')
  assert(not base_name.is_empty(), 'must provide a base name')
  return get('slider_%s' % base_name.to_snake_case())

func valid_button_named(base_name:String="example for btn_example") -> Button:
  assert(base_name, 'must provide a base name')
  assert(not base_name.is_empty(), 'must provide a base name')
  return get('btn_%s' % base_name.to_snake_case())

func connect_button(base_name:String="example for btn_example"):
  valid_button_named(base_name).pressed.connect(Callable.create(self, 'on_%s' % base_name.to_snake_case()))

func setup_slider_proxy(truple:Array):
  setup_slider.callv(truple)

func setup_slider(base_name:String="example for btn_example",default_value:int=2,tooltip:="",prop:="xxxpopulation_threshold",sig:="sig_xxxpopulation_changed"):
  var label := Label.new()
  label.name = "LabelFor%s" % base_name.to_pascal_case()
  label.text = "%s: %s" % [base_name.to_pascal_case(), default_value]
  label.tooltip_text = tooltip
  var slider := valid_slider_named(base_name)
  slider.name = base_name.to_pascal_case()
  slider.rounded = true
  slider.step = 1
  slider.min_value = 1
  slider.max_value = 8
  slider.tick_count = 7
  slider.value = default_value
  slider.tooltip_text = tooltip
  add_child(label)
  add_child(slider)
  globals.connect(sig, func (new_value, _old_value): label.text = "%s: %s" % [base_name.to_pascal_case(), new_value])
  slider.value_changed.connect(func (new_value): globals.set(prop, new_value))

func setup_button(base_name:String="example for btn_example"):
  var btn := valid_button_named(base_name)
  btn.text = base_name.to_pascal_case()
  btn.name = base_name.to_pascal_case()
  add_child(btn)

func _ready() -> void:
  if not life: life = GameOfLife.resolve_using(self)
  if not globals: globals = await Globals.instance_for(self)
  buttons.any(setup_button)
  buttons.any(connect_button)
  sliders.any(setup_slider_proxy)
  custom_minimum_size = Vector2(Globals.UI_MENU_SIZE, 0)
  set_anchors_and_offsets_preset(Control.LayoutPreset.PRESET_RIGHT_WIDE, Control.LayoutPresetMode.PRESET_MODE_KEEP_WIDTH)
