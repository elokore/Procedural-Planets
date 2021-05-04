local module = {}

module.Hills = {
    roughness = 1/400,
    scale = 120,

    Evaluate = function(vector)
        vector = vector * module.Hills.roughness
        return math.abs(math.noise(vector.X, vector.Y, vector.Z))
    end
}

module.Plains = {
    roughness = 1/500,
    scale = 60,

    Evaluate = function(vector)
        vector = vector * module.Plains.roughness
        return math.pow(math.noise(vector.X, vector.Y, vector.Z), 2)
    end
}

module.LargeMesa = {
    roughness = 1,
    scale = 300,

    Evaluate = function(vector)
        return 1
    end
}

module.ScatteredMessas = {
    roughness = 1/400,
    scale = 250,

    Evaluate = function(vector)
        local v = vector * module.ScatteredMessas.roughness
        local n = math.noise(v.X, v.Y, v.Z)

        if n < 0 then
            return 0
        else
            return 1
        end
    end
}

module.Mountains = {
    roughness = 1/500,
    scale = 200,
    persistence = 0.8,
    frequencyScalar = 100,
    layers = 4,

    Evaluate = function(vector)
        local noiseValue = 0

        local amplitude = 1
        local frequency = module.Mountains.roughness
        local persistence = module.Mountains.persistence
        local frequencyScalar = module.Mountains.frequencyScalar

        local v = vector * frequency
        noiseValue = math.abs(math.noise(v.X, v.Y, v.Z) * amplitude)

        for x = 1, 4 do
            v = vector * frequency
            local n = math.abs(math.noise(v.X, v.Y, v.Z) * amplitude)

            noiseValue = noiseValue + n

            if n < 0.5 then
                break
            end
            amplitude = amplitude * persistence
            frequency = frequency * frequencyScalar
        end

        return noiseValue
    end
}

return module