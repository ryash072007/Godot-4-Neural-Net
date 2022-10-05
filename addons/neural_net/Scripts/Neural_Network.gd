class_name NeuralNetwork

@export var input_nodes: int
@export var hidden_nodes: int 
@export var output_nodes: int

var weights_input_hidden: Matrix
var weights_hidden_output: Matrix

var bias_hidden: Matrix
var bias_output: Matrix

@export var learning_rate: float = 0.15

var activation_function: Callable
var activation_dfunction: Callable

var fitness: float = 0.0

var color: Color = Color(0, 0, 0, 0)

var raycasts: Array[RayCast2D]

#var data_already_set: bool = false

func _init(_input_nodes: int, _hidden_nodes: int, _output_nodes: int, is_set: bool = false) -> void:
	if !is_set:
		randomize()
		input_nodes = _input_nodes;
		hidden_nodes = _hidden_nodes;
		output_nodes = _output_nodes;
		
		weights_input_hidden = Matrix.rand(Matrix.new(hidden_nodes, input_nodes))
		weights_hidden_output = Matrix.rand(Matrix.new(output_nodes, hidden_nodes))
		
		bias_hidden = Matrix.rand(Matrix.new(hidden_nodes, 1))
		bias_output = Matrix.rand(Matrix.new(output_nodes, 1))
	
#	set_learning_rate()
	set_activation_function()
	set_nn_color()

func set_nn_color():
	color = Color(Matrix.average(weights_input_hidden), Matrix.average(weights_hidden_output), Matrix.average(Matrix.product(bias_hidden, bias_output)), 1)
#
#func set_nodes(_input_nodes: int, _hidden_nodes: int, _output_nodes: int) -> void:
#	assert(_input_nodes != 0 or _output_nodes != 0, "The NN's input or output nodes can NOT be set to 0!")
#
#	input_nodes = _input_nodes;
#	hidden_nodes = _hidden_nodes;
#	output_nodes = _output_nodes;
#
#	set_random_color()

#func set_random_color(object = self):
##	seed(randi())
##	randomize()
##	color = Color(randi_range(0, 1), randi_range(0, 1), randi_range(0, 1), 1)
#	color = Color(
#		Matrix.average(object.weights_input_hidden),
#		Matrix.average(object.weights_hidden_output),
#		Matrix.average(object.bias_hidden),
#		Matrix.average(object.bias_output)
#	)

func set_activation_function(callback: Callable = Callable(Activation, "sigmoid"), dcallback: Callable = Callable(Activation, "dsigmoid")) -> void:
	activation_function = callback
	activation_dfunction = dcallback

func predict(input_array: Array[float]) -> Array:
	var inputs = Matrix.from_array(input_array)
	
	var hidden = Matrix.product(weights_input_hidden, inputs)
	hidden = Matrix.add(hidden, bias_hidden)
	hidden = Matrix.map(hidden, activation_function)

	var output = Matrix.product(weights_hidden_output, hidden)
	output = Matrix.add(output, bias_output)
	output = Matrix.map(output, activation_function)

	return Matrix.to_array(output)

func train(input_array: Array, target_array: Array):
	var inputs = Matrix.from_array(input_array)
	var targets = Matrix.from_array(target_array)
	
#	print_debug(weights_input_hidden.data)
#	print_debug(inputs.data)
	
	var hidden = Matrix.product(weights_input_hidden, inputs);
	hidden = Matrix.add(hidden, bias_hidden)
	hidden = Matrix.map(hidden, activation_function)
	
	var outputs = Matrix.product(weights_hidden_output, hidden)
	outputs = Matrix.add(outputs, bias_output)
	outputs = Matrix.map(outputs, activation_function)
	
	var output_errors = Matrix.subtract(targets, outputs)
	
	var gradients = Matrix.map(outputs, activation_dfunction)
	gradients = Matrix.multiply(gradients, output_errors)
	gradients = Matrix.scalar(gradients, learning_rate)
	
	var hidden_t = Matrix.transpose(hidden)
	var weight_ho_deltas = Matrix.product(gradients, hidden_t)
	
	weights_hidden_output = Matrix.add(weights_hidden_output, weight_ho_deltas)
	bias_output = Matrix.add(bias_output, gradients)
	
	var weights_hidden_output_t = Matrix.transpose(weights_hidden_output)
	var hidden_errors = Matrix.product(weights_hidden_output_t, output_errors)
	
	var hidden_gradient = Matrix.map(hidden, activation_dfunction)
	hidden_gradient = Matrix.multiply(hidden_gradient, hidden_errors)
	hidden_gradient = Matrix.scalar(hidden_gradient, learning_rate)
	
	var inputs_t = Matrix.transpose(inputs)
	var weight_ih_deltas = Matrix.product(hidden_gradient, inputs_t)

	weights_input_hidden = Matrix.add(weights_input_hidden, weight_ih_deltas)

	bias_hidden = Matrix.add(bias_hidden, hidden_gradient)

func get_inputs_from_raycasts() -> Array:
	assert(raycasts.size() != 0, "Can not get inputs from RayCasts that are not set!")
	
	var _input_array: Array[float]
	
	for ray in raycasts:
		if is_instance_valid(ray): _input_array.push_front(get_distance(ray))
	
	return _input_array

func get_prediction_from_raycasts(optional_val: Array = []) -> Array[float]:
	assert(raycasts.size() != 0, "Can not get inputs from RayCasts that are not set!")
	
	var _array_ = get_inputs_from_raycasts()
	_array_.append_array(optional_val)
	return predict(_array_)

func get_distance(_raycast: RayCast2D):
	var distance: float = 0.0
	if _raycast.is_colliding():
		var origin: Vector2 = _raycast.global_transform.get_origin()
		var collision: Vector2 = _raycast.get_collision_point()
		
		distance = origin.distance_to(collision)
	else:
		distance = sqrt((pow(_raycast.target_position.x, 2) + pow(_raycast.target_position.y, 2)))
	return distance

static func reproduce(a: NeuralNetwork, b: NeuralNetwork) -> NeuralNetwork:
	var result = NeuralNetwork.new(a.input_nodes, a.hidden_nodes, a.output_nodes)
	result.weights_input_hidden = Matrix.random(a.weights_input_hidden, b.weights_input_hidden)
	result.weights_hidden_output = Matrix.random(a.weights_hidden_output, b.weights_hidden_output)
	result.bias_hidden = Matrix.random(a.bias_hidden, b.bias_hidden)
	result.bias_output = Matrix.random(a.bias_output, b.bias_output)

	return result

static func mutate(nn: NeuralNetwork, callback: Callable = Callable(NeuralNetwork, "mutate_callable_reproduced")) -> NeuralNetwork:
	var result = NeuralNetwork.new(nn.input_nodes, nn.hidden_nodes, nn.output_nodes)
	result.weights_input_hidden = Matrix.map(nn.weights_input_hidden, callback)
	result.weights_hidden_output = Matrix.map(nn.weights_hidden_output, callback)
	result.bias_hidden = Matrix.map(nn.bias_hidden, callback)
	result.bias_output = Matrix.map(nn.bias_output, callback)
#	randomize()
#	result.color = Color(
#		Matrix.average(result.weights_input_hidden),
#		Matrix.average(result.weights_hidden_output),
#		Matrix.average(result.bias_hidden),
#		Matrix.average(result.bias_output)
#	) + Color(randf_range(-0.2, 0.2), randf_range(-0.2, 0.2), randf_range(-0.2, 0.2))
#
#	if result.color.r > 1 or result.color.r < 0:
#		result.color.r = floori(result.color.r)
#	if result.color.g > 1 or result.color.g < 0:
#		result.color.g = floori(result.color.g)
#	if result.color.b > 1 or result.color.b < 0:
#		result.color.b = floori(result.color.b)
#	if result.color.a > 1 or result.color.a < 0:
#		result.color.a = floori(result.color.a)
#	result.color = nn.color + Color(randf_range(-0.2, 0.2), randf_range(-0.2, 0.2), randf_range(-0.2, 0.2))
	return result

static func mutate_callable_reproduced(value, _row, _col):
	seed(randi())
	randomize()
#	if randf_range(0, 1) < 0.7:
	value += randf_range(-0.15, 0.15)
		
	return value

static func copy(nn : NeuralNetwork) -> NeuralNetwork:
	var result = NeuralNetwork.new(nn.input_nodes, nn.hidden_nodes, nn.output_nodes)
	result.weights_input_hidden = Matrix.copy(nn.weights_input_hidden)
	result.weights_hidden_output = Matrix.copy(nn.weights_hidden_output)
	result.bias_hidden = Matrix.copy(nn.bias_hidden)
	result.bias_output = Matrix.copy(nn.bias_output)
	result.color = nn.color
	result.fitness = nn.fitness
#	result.data_already_set = true
	return result

static func mutate_callable(value, _row, _col):
	seed(randi())
	randomize()
#	if randf_range(0, 1) < 0.7:
	value += randf_range(-0.5, 0.5)
		
	return value
