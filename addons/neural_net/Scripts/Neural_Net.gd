extends Node2D

@export var AI_Scene: PackedScene

@export var Batch_Size: int = 50

@export var Generation_Delay: int = 10

#@export var spawn_position: Vector2 = Vector2.ZERO

signal gen_changed(_generation: int)
signal true_batch_size(_size: int)


var freeing: bool = false

@export var input_nodes: int
@export var hidden_nodes: int
@export var output_nodes: int

@export var random_population: int = 20

@export var use_reproduction: bool = false

@export var reproduced_population: int = 5

var top_value_cutoff

var generation: int = 0

var best_nn: NeuralNetwork

var current_generation_freed: int = 0

var first_gen_spawn_size
var timer: Timer = Timer.new()

#var getting_ready: bool = true

var best_10_nn: Array[NeuralNetwork]

func _ready():
	assert(ceil(Batch_Size / 2) <= reproduced_population, "reproduced_population must be set higher or equal to the Half of the Batch Size as some weird bug arises!")
	top_value_cutoff = reproduced_population * 2
	first_gen_spawn_size = Batch_Size + 1 + random_population
	if use_reproduction:
		assert(Batch_Size >= 10, "Batch Size can not go below or be 10 as some weird bug arises!")
		first_gen_spawn_size += reproduced_population
	top_value_cutoff += 1
	add_child(timer)
	child_exiting_tree.connect(Callable(self, "on_ai_exit_tree"))
	timer.wait_time = Generation_Delay
	timer.timeout.connect(Callable(self, "reload_generation"))
	

	best_nn = NeuralNetwork.new(input_nodes, hidden_nodes, output_nodes)
	
	spawn()

func spawn():
	gen_changed.emit(generation)
	print("Generation: ", generation)
	var spawn_population: Array = []

	
	if generation == 0:
		for i in range(first_gen_spawn_size):
			randomize()
			var new_ai = AI_Scene.instantiate()
			new_ai.nn = NeuralNetwork.new(input_nodes, hidden_nodes, output_nodes)
			spawn_population.append(new_ai)
	else:
		for i in range(Batch_Size):
			var new_ai = AI_Scene.instantiate()
			new_ai.nn =  NeuralNetwork.copy(NeuralNetwork.mutate(best_nn))
#			new_ai.nn.data_already_set = true
			spawn_population.append(new_ai)
		
		for i in range(random_population):
			randomize()
			var new_ai = AI_Scene.instantiate()
			new_ai.nn = NeuralNetwork.new(input_nodes, hidden_nodes, output_nodes)
			spawn_population.append(new_ai)
			
		var new_ai = AI_Scene.instantiate()
		new_ai.nn = NeuralNetwork.copy(best_nn)
#		new_ai.nn.data_already_set = true
		spawn_population.append(new_ai)
	
		if use_reproduction:
			var first_array: Array[NeuralNetwork]
			var second_array: Array[NeuralNetwork]
			
			randomize()
			for i in range(best_10_nn.size()):
				var random_choice = randi_range(0, best_10_nn.size() - 1)
				if i % 2 == 0:
					first_array.append(best_10_nn[random_choice])
				else:
					second_array.append(best_10_nn[random_choice])
				best_10_nn.remove_at(random_choice)
			
			for i in range(first_array.size()):
				if first_array.size() == second_array.size():
					var _new_ai = AI_Scene.instantiate()
					_new_ai.nn =  NeuralNetwork.copy(NeuralNetwork.mutate(NeuralNetwork.reproduce(first_array[i], second_array[i])))
					spawn_population.append(_new_ai)
				else:
					for i2 in range(reproduced_population):
						randomize()
						var _new_ai = AI_Scene.instantiate()
						_new_ai.nn = NeuralNetwork.new(input_nodes, hidden_nodes, output_nodes)
						spawn_population.append(_new_ai)
	
	for ai in spawn_population:
		add_child(ai)
	
	timer.start(Generation_Delay)
	true_batch_size.emit(spawn_population.size())
	generation += 1
	best_10_nn = []



func on_ai_exit_tree(node: Node):
#	if getting_ready: return
	if node is Timer: return
#	if generation == 1:
#		best_10_nn.push_front(NeuralNetwork.copy(node.nn))
	if use_reproduction: best_10_nn.append(NeuralNetwork.copy(node.nn))
	if node.nn.fitness > best_nn.fitness:
		best_nn = NeuralNetwork.copy(node.nn)
#		best_10_nn.append(NeuralNetwork.copy(node.nn))
#	else:
#		if best_10_nn.size() - 2 > 0: best_10_nn.insert(best_10_nn.size() - 2, NeuralNetwork.copy(node.nn))
#		else: best_10_nn.push_front(NeuralNetwork.copy(node.nn))
	
#	print_debug(best_10_nn.size())
	
	if freeing: return
	current_generation_freed += 1
#	print(current_generation_freed)
	if current_generation_freed == Batch_Size:
#		print("reloaded")
		reload_generation()

func reload_generation():
	best_10_nn.sort_custom(Callable(self, "custom_sort"))
#	print(best_10_nn.size() == Batch_Size)
#	best_10_nn = best_10_nn[best_10_nn.size() - top_value_cutoff]
#	print(best_10_nn.size())
	if use_reproduction: best_10_nn = best_10_nn.slice(best_10_nn.size() - top_value_cutoff, -1)
	
#	print(best_10_nn)
	
	freeing = true
	timer.stop()
	
	for i in get_children():
		if !(i is Timer): i.queue_free()
	
	spawn()
	freeing = false
#	await get_tree().create_timer(1).timeout

func custom_sort(a, b):
	return a.fitness < b.fitness
