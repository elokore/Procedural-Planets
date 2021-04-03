local QuadSphere = {}
QuadSphere.__index = QuadSphere

---- < Module Imports > ----
local triangleModule = require(game.ReplicatedStorage.SharedModules.Triangles)
local SphereFace = require(game.ReplicatedStorage.SharedModules.PlanetGeneration.SphereFace)

--[[
Creates a new quadsphere
]]
---@param cframe CFrame
---@param radius number
---@class QuadSphere
function QuadSphere.new(cframe, radius)
	local self = setmetatable({}, QuadSphere)

    self.cframe = cframe
    self.radius = radius
    
    self.verticeList = {}
    self.faceList = {}

    local start = tick()
    CalculateCubeVertices(self)
    self:Subdivide(2)
    self:Spherify()
    local cend = tick()

    print("Face Count:", #self.faceList)

    print("Vertice Calculations took:", cend-start)

    return self
end

--[[
    Calculates the 8 vertices of a six sided cube
]]
---@param self QuadSphere
---@private 
function CalculateCubeVertices(self)
    local frontTopLeft = (self.cframe *CFrame.new(-self.radius, self.radius, -self.radius)).Position
    local frontTopRight = (self.cframe *CFrame.new(self.radius, self.radius, -self.radius)).Position
    local backTopLeft = (self.cframe *CFrame.new(-self.radius, self.radius, self.radius)).Position
    local backTopRight = (self.cframe *CFrame.new(self.radius, self.radius, self.radius)).Position

    local frontBottomLeft = (self.cframe *CFrame.new(-self.radius, -self.radius, -self.radius)).Position
    local frontBottomRight = (self.cframe *CFrame.new(self.radius, -self.radius, -self.radius)).Position
    local backBottomLeft = (self.cframe *CFrame.new(-self.radius, -self.radius, self.radius)).Position
    local backBottomRight = (self.cframe *CFrame.new(self.radius, -self.radius, self.radius)).Position

    
    table.insert(self.verticeList, frontTopLeft)--1
    table.insert(self.verticeList, frontTopRight)--2
    table.insert(self.verticeList, backTopLeft)--3
    table.insert(self.verticeList, backTopRight)--4

    table.insert(self.verticeList, frontBottomLeft)--5
    table.insert(self.verticeList, frontBottomRight)--6
    table.insert(self.verticeList, backBottomLeft)--7
    table.insert(self.verticeList, backBottomRight)--8

    local frontTopLeftId = 1
    local frontTopRightId = 2
    local backTopLeftId = 3
    local backTopRightId = 4
    local frontBottomLeftId = 5
    local frontBottomRightId = 6
    local backBottomLeftId = 7
    local backBottomRightId = 8

    self.faceList[1] = SphereFace.new(frontTopLeftId, frontTopRightId, backTopRightId, backTopLeftId, 1)--Top
    self.faceList[2] = SphereFace.new(frontBottomLeftId, frontBottomRightId, frontTopRightId, frontTopLeftId, 2)--Front
    self.faceList[3] = SphereFace.new(frontBottomLeftId, frontBottomRightId, backBottomRightId, backBottomLeftId, 3)--Bottom
    self.faceList[4] = SphereFace.new(backTopLeftId, backTopRightId, backBottomRightId, backBottomLeftId, 4)--Back
    self.faceList[5] = SphereFace.new(backTopLeftId, frontTopLeftId, frontBottomLeftId, backBottomLeftId, 5)--Left
    self.faceList[6] = SphereFace.new(frontTopRightId, backTopRightId, backBottomRightId, frontBottomRightId, 6)--Right
end

function QuadSphere:Subdivide(iterations)
    for i = 1, iterations do
        local faceCount = #self.faceList

        for x = 1, faceCount do
            local face = self.faceList[x]
            face:Subdivide(self.verticeList, self.faceList)
        end
    end
end

--[[
    Turns the cube into a sphere
]]
function QuadSphere:Spherify()
    for index, vert in pairs(self.verticeList) do
        local direction = (vert - self.cframe.Position).Unit
        local newPosition = self.cframe.Position + (direction * self.radius)
        self.verticeList[index] = newPosition
    end
end

function QuadSphere:RenderAllFaces()
    local sphere = Instance.new("Model")
    sphere.Name = "Sphere"
    local p = Instance.new("Part")
    p.Size = Vector3.new(1,1,1)
    p.CanCollide = false
    p.Anchored = true
    p.CFrame = self.cframe
    sphere.PrimaryPart = p
    p.Parent = sphere
    sphere.Parent = workspace

    for x, face in pairs(self.faceList) do
        --[[if x%500 == 0 then
            wait()
        end]]
        local verts = {self.verticeList[face.topLeftVerticeId], self.verticeList[face.topRightVerticeId], self.verticeList[face.bottomRightVerticeId], self.verticeList[face.bottomLeftVerticeId]}

        local f = triangleModule.fillQuadrant(verts)
        f.Parent = sphere
    end
end



return QuadSphere
