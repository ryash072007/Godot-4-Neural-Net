extends Node2D

var nnas: NeuralNetworkAdvanced = NeuralNetworkAdvanced.new()

func _ready() -> void:
	nnas.add_layer(2)
	nnas.add_layer(4)
	nnas.add_layer(1)

#	print(nnas.predict([1, 1]))
	
	nnas.train([1, 1], [0])
