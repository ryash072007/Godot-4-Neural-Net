class_name NeuralNetworkAdvanced

var layers: Array
var number_of_layers: int = 0

var ACTIVATIONS: Dictionary = {
	"SIGMOID": {
		"function": Callable(Activation, "sigmoid"),
		"derivative": Callable(Activation, "dsigmoid")
	},
	"RELU": {
		"function": Callable(Activation, "relu"),
		"derivative": Callable(Activation, "drelu")
	},
	"TANH": {
		"function": Callable(Activation, "tanh_"),
		"derivative": Callable(Activation, "dtanh")
	},
	"ARCTAN": {
		"function": Callable(Activation, "arcTan"),
		"derivative": Callable(Activation, "darcTan")
	},
	"PRELU": {
		"function": Callable(Activation, "prelu"),
		"derivative": Callable(Activation, "dprelu")
	},
	"ELU": {
		"function": Callable(Activation, "elu"),
		"derivative": Callable(Activation, "delu")
	},
	"SOFTPLUS": {
		"function": Callable(Activation, "softplus"),
		"derivative": Callable(Activation, "dsoftplus")
	}
}

var input_nodes: int
var previous_layer_nodes: int

var learning_rate: float = 0.1

func add_layer(nodes: int, activation: Dictionary = ACTIVATIONS.SIGMOID):
	
	if number_of_layers == 0:
		previous_layer_nodes = nodes
		input_nodes = nodes
		number_of_layers += 1
		return
		
	var layer_data: Dictionary = {
		"weights": Matrix.rand(Matrix.new(nodes, previous_layer_nodes)),
		"bias": Matrix.rand(Matrix.new(nodes, 1)),
		"activation": activation
	}
	layers.push_back(layer_data)
	previous_layer_nodes = nodes
	number_of_layers += 1

func predict(input_array: Array) -> Array:
	assert(input_array.size() == input_nodes)
	var inputs: Matrix = Matrix.from_array(input_array)
	for layer in layers:
#		print("----------------------------------------------------")
#		print("Input: ", inputs.rows," - ", inputs.cols)
#		print("Weights: ", layer.weights.rows," - ", layer.weights.cols)
		var product: Matrix = Matrix.dot_product(layer.weights, inputs)
		var sum: Matrix = Matrix.add(product, layer.bias)
		var map: Matrix = Matrix.map(sum, layer.activation.function)
#		print(Matrix.to_array(map))
		inputs = map
	return Matrix.to_array(inputs)

func train(input_array: Array, target_array: Array):
	var inputs: Matrix = Matrix.from_array(input_array)
	var targets: Matrix = Matrix.from_array(target_array)

	var outputs: Array # stored in reverse
	var layer_inputs: Matrix = inputs
	for layer in layers:
		var product: Matrix = Matrix.dot_product(layer.weights, layer_inputs)
		var sum: Matrix = Matrix.add(product, layer.bias)
		var map: Matrix = Matrix.map(sum, layer.activation.function)
		layer_inputs = map
		outputs.append(map)
		
#	var output_layer_error: Matrix = Matrix.subtract(targets, outputs[-1])
#	var output_layer_gradient: Matrix = Matrix.map(outputs[-1], )

	var is_output_layer: bool = true
	for layer_index in range(layers.size() - 1, -1, -1):
		var layer: Dictionary = layers[layer_index]
		var output: Matrix = outputs[layer_index]
		if is_output_layer:
			#output layer code
			return
		#hidden layer code

