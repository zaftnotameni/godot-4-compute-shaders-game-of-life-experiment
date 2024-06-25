class_name GameOfLifeComputeShader extends Node

@export var shader_file:RDShaderFile

var data_size := Globals.WIDTH * Globals.HEIGHT

var rd: RenderingDevice
var shader_spirv: RDShaderSPIRV
var shader: RID

var input: PackedInt32Array
var input_bytes: PackedByteArray
var output: PackedInt32Array
var output_bytes: PackedByteArray

var buffer_id_input: RID
var buffer_id_output: RID

var uniform_input : RDUniform
var uniform_output : RDUniform
var uniform_set_input: RID
var uniform_set_output: RID

var pipeline: RID
var compute_list: int

static func resolve_using(node_in_tree:Node) -> GameOfLifeComputeShader:
  return node_in_tree.get_tree().get_first_node_in_group(Globals.GROUP_GAME_OF_LIFE_SHADER)

func _enter_tree() -> void:
  add_to_group(Globals.GROUP_GAME_OF_LIFE_SHADER)

func prepare_data(data:PackedInt32Array):
  assert(data.size() == data_size, "data must match size %s determined in the compute shader" % data_size)
  input = data
  input_bytes = input.to_byte_array()
  output = data
  output_bytes = output.to_byte_array()

func create_rendering_device():
  rd = RenderingServer.create_local_rendering_device()

func create_shader():
  if not shader_file:
    shader_file = load('res://zaft/game/shaders/test.glsl')
  print('--- SHADER ERRORS (empty = no errors) ---')
  shader_spirv = shader_file.get_spirv()
  printerr("base:" + shader_file.base_error)
  printerr("vertex:" + shader_spirv.compile_error_vertex)
  printerr("compute:" + shader_spirv.compile_error_compute)
  printerr("frag:" + shader_spirv.compile_error_fragment)
  printerr("ctrl:" + shader_spirv.compile_error_tesselation_control)
  printerr("eval:" + shader_spirv.compile_error_tesselation_evaluation)
  print('------------------------------------')
  shader = rd.shader_create_from_spirv(shader_spirv)

func create_buffer(data:PackedInt32Array):
  assert(data.size() == data_size, "data must match size %s determined in the compute shader" % data_size)
  prepare_data(data)
  buffer_id_input = rd.storage_buffer_create(input_bytes.size(), input_bytes)
  buffer_id_output = rd.storage_buffer_create(output_bytes.size(), output_bytes)

func update_buffer(data:PackedInt32Array):
  assert(data.size() == data_size, "data must match size %s determined in the compute shader" % data_size)
  prepare_data(data)
  rd.buffer_update(buffer_id_input, 0, input_bytes.size(), input_bytes)
  rd.buffer_update(buffer_id_output, 0, output_bytes.size(), output_bytes)

func create_uniform():
  uniform_input = RDUniform.new()
  uniform_input.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
  uniform_input.binding = 0
  uniform_input.add_id(buffer_id_input)
  uniform_set_input = rd.uniform_set_create([uniform_input], shader, 0)
  printt("buffer_input:", buffer_id_input)
  printt("uniform_input:", uniform_input)
  printt("uniform_set_input:", uniform_set_input)

  uniform_output = RDUniform.new()
  uniform_output.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
  uniform_output.binding = 0
  uniform_output.add_id(buffer_id_output)
  uniform_set_output = rd.uniform_set_create([uniform_output], shader, 1)
  printt("buffer_output:", buffer_id_output)
  printt("uniform_output:", uniform_output)
  printt("uniform_set_output:", uniform_set_output)

func create_pipeline():
  pipeline = rd.compute_pipeline_create(shader)

func start_compute_list():
  compute_list = rd.compute_list_begin()

func bind_compute_list():
  rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
  rd.compute_list_bind_uniform_set(compute_list, uniform_set_input, 0)
  rd.compute_list_bind_uniform_set(compute_list, uniform_set_output, 1)

func dispatch_compute_list():
  rd.compute_list_dispatch(compute_list, input.size(), 1, 1)

func end_compute_list():
  rd.compute_list_end()

func prepare_compute_list():
  start_compute_list()
  bind_compute_list()
  dispatch_compute_list()
  end_compute_list()

func read_output():
  output_bytes = rd.buffer_get_data(buffer_id_output)
  output = output_bytes.to_int32_array()

func calculate(data:PackedInt32Array) -> PackedInt32Array:
  assert(data.size() == data_size, "data must match size %s determined in the compute shader" % data_size)
  update_buffer(data)
  prepare_compute_list()
  rd.submit()
  # await get_tree().create_timer(0.01).timeout
  rd.sync()
  read_output()
  return output

func _ready() -> void:
  create_rendering_device()
  create_shader()
  create_buffer(PackedInt32Array(range(Globals.WIDTH * Globals.HEIGHT)))
  create_uniform()
  create_pipeline()

