local function trimDecimals(n: number, decmimalPlaces: number)
	local factor = math.pow(10, decmimalPlaces)
	return math.floor(n * factor) / factor
end

-- Calculates the time it took `callback` to complete, in milliseconds.
local function stopwatch(callback: () -> ())
	local startTime = os.clock()
	callback()
	return trimDecimals((os.clock() - startTime) * 1000, 3)
end

return stopwatch
