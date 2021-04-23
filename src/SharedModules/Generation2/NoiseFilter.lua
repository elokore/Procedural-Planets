local NoiseFilter = {}
NoiseFilter.__index = NoiseFilter


--[[
    Creates a noise filter for planets
    with various properties you can change
]]
function NoiseFilter.new()
    local self = setmetatable({}, NoiseFilter)

    self.roughness = 1/200
    self.scale = 200
    self.minimum = 0

    return self
end

--[[
    Evaluates a noise value with the given input vector
]]
---@param vector Vector3
function NoiseFilter:EvaluateNoise(vector)
    vector = vector * self.roughness
    local noiseValue = (1 - math.abs(math.noise(vector.X, vector.Y, vector.Z))) * self.scale

    return noiseValue
end

return NoiseFilter