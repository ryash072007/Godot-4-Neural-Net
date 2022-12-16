class_name Activation

static func sigmoid(value: float, _row: int, _col: int) -> float:
	return 1 / (1 + exp(-value))

static func dsigmoid(value: float, _row: int, _col: int) -> float:
	return value * (1 - value)

static func relu(value: float, _row: int, _col: int) -> float:
	return max(0.0, value)

static func drelu(value: float, _row: int, _col: int) -> float:
	return 0.0 if value <= 0 else 1.0

static func tanh(value: float, _row: int, _col: int) -> float:
	
	var eX: float = exp(value)
	var eNegX: float = exp(-value)
	
	return (eX - eNegX) / (eX + eNegX)

static func dtanh(value: float, _row: int, _col: int) -> float:
	return 1 - pow(tanh(value), 2)
