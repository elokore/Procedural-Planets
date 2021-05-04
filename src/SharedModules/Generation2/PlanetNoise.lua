local PlanetNoise = {}
PlanetNoise.__index = PlanetNoise
local Biomes = require(game.ReplicatedStorage.SharedModules.Generation2.Biomes)

--[[
    Creates a noise filter for planets
    with various properties you can change
]]
function PlanetNoise.new(planet)
    local self = setmetatable({}, PlanetNoise)

    self.planet = planet

    self.roughness = 1/1500
    self.scale = 700
    self.minimum = 0

    return self
end

--[[
    Evaluates a noise value with the given input vector
]]
---@param vector Vector3
function PlanetNoise:EvaluateNoise(vector)
    --Decide where continents are
    local noiseValue = 0

    local amplitude = 1
    local frequency = self.roughness
    local v = vector * frequency
    noiseValue = math.noise(v.X, v.Y, v.Z)


    if noiseValue < 0 then
        noiseValue = 0
    else
        noiseValue = 50
    end

    local biomeNoise = self:GetBiomeNoise(vector)

    if noiseValue == 50 then
        if biomeNoise < 0 then
            --Now add biomes on top of the continents
            noiseValue = noiseValue + (Biomes.Hills.Evaluate(vector) * Biomes.Hills.scale)
        elseif biomeNoise >= 0.1 then
            noiseValue = noiseValue + (Biomes.Plains.Evaluate(vector) * Biomes.Plains.scale)
        end
    end

    return noiseValue
end

--[[
    Gets the noise value that determines what biome a position is located
    inside of
]]
---@param vector Vector3
function PlanetNoise:GetBiomeNoise(vector)
    local frontVector = self.planet.cframe.LookVector
    local flatNodeDirection = Vector3.new(vector.X, 0, vector.Z).Unit
    local nodeDirection = vector.Unit

    local yAngle = math.acos(frontVector:Dot(flatNodeDirection))
    local xAngle = math.acos(flatNodeDirection:Dot(nodeDirection))

    return math.noise(xAngle*1/5, yAngle*1/5)
end

return PlanetNoise