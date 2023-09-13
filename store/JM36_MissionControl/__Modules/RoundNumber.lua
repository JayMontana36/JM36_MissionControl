local math_modf, math_abs = math.modf, math.abs
return function(value, alwaysReturnPositive)
	local negative = value < 0
	local integral, fractional = math_modf(math_abs(value))
	value = (fractional >= 0.5 and integral + 1) or integral
	return ((not alwaysReturnPositive and negative and -value) or value), negative
end