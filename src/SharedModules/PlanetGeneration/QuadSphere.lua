local QuadSphere = {}
QuadSphere.__index = QuadSphere

---- < Module Imports > ----
local triangleModule = require(game.ReplicatedStorage.SharedModules.Triangles)
local SphereFace = require(game.ReplicatedStorage.SharedModules.PlanetGeneration.SphereFace)
local misc = require(game.ReplicatedStorage.SharedModules.Misc)

---- < Metatables > ----
local vertFaceMapMetatable = {
    __index = function(t, key)
        t[key] = {}
        return t[key]
    end
}

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
    self.verticeToFaceMap = setmetatable({}, vertFaceMapMetatable)
    self.verticeIds = {}
    self.subdivisionCount = 6
    self.renderedFaces = {}


    local start = tick()
    CalculateCubeVertices(self)
    self:Subdivide(self.subdivisionCount)
    self:MapVerticesToFaces()
    self:Spherify()
    local cend = tick()

    print("Face Count:", #self.faceList)
    print("Vertice Count:", #self.verticeList)
    print("Vertice Calculations took:", cend-start)

    local vert = game.ReplicatedStorage.Vertice:Clone()
    vert.BrickColor = BrickColor.Blue()
    vert.Position = self.verticeList[388]
    vert.Parent = workspace

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
    self.verticeIds[tostring(frontTopLeft)] = 1
    self.verticeIds[tostring(frontTopRight)] = 2
    self.verticeIds[tostring(backTopLeft)] = 3
    self.verticeIds[tostring(backTopRight)] = 4

    table.insert(self.verticeList, frontBottomLeft)--5
    table.insert(self.verticeList, frontBottomRight)--6
    table.insert(self.verticeList, backBottomLeft)--7
    table.insert(self.verticeList, backBottomRight)--8
    self.verticeIds[tostring(frontBottomLeft)] = 5
    self.verticeIds[tostring(frontBottomRight)] = 6
    self.verticeIds[tostring(backBottomLeft)] = 7
    self.verticeIds[tostring(backBottomRight)] = 8

    local frontTopLeftId = 1
    local frontTopRightId = 2
    local backTopLeftId = 3
    local backTopRightId = 4
    local frontBottomLeftId = 5
    local frontBottomRightId = 6
    local backBottomLeftId = 7
    local backBottomRightId = 8

    self.faceList[1] = SphereFace.new(frontTopLeftId, frontTopRightId, backTopRightId, backTopLeftId, 1, self.verticeList, self.faceList, self.verticeIds)--Top
    self.faceList[2] = SphereFace.new(frontBottomLeftId, frontBottomRightId, frontTopRightId, frontTopLeftId, 2, self.verticeList, self.faceList, self.verticeIds)--Front
    self.faceList[3] = SphereFace.new(frontBottomLeftId, frontBottomRightId, backBottomRightId, backBottomLeftId, 3, self.verticeList, self.faceList, self.verticeIds)--Bottom
    self.faceList[4] = SphereFace.new(backTopLeftId, backTopRightId, backBottomRightId, backBottomLeftId, 4, self.verticeList, self.faceList, self.verticeIds)--Back
    self.faceList[5] = SphereFace.new(backTopLeftId, frontTopLeftId, frontBottomLeftId, backBottomLeftId, 5, self.verticeList, self.faceList, self.verticeIds)--Left
    self.faceList[6] = SphereFace.new(frontTopRightId, backTopRightId, backBottomRightId, frontBottomRightId, 6, self.verticeList, self.faceList, self.verticeIds)--Right
end

function QuadSphere:Subdivide(iterations)
    for i = 1, iterations do
        local faceCount = #self.faceList

        for x = 1, faceCount do
            local face = self.faceList[x]
            face:Subdivide()
        end
    end
end

--[[
    Fills a hashmap indicating which faces each vertice is apart of
]]
function QuadSphere:MapVerticesToFaces()
    for id, face in pairs(self.faceList) do
        table.insert(self.verticeToFaceMap[face.topLeftVerticeId], id)
        table.insert(self.verticeToFaceMap[face.topRightVerticeId], id)
        table.insert(self.verticeToFaceMap[face.bottomLeftVerticeId], id)
        table.insert(self.verticeToFaceMap[face.bottomRightVerticeId], id)
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

        --Update vertice position
        self.verticeIds[tostring(vert)] = nil
        self.verticeIds[tostring(newPosition)] = index
    end
end

--[[
    Gets the vertice ID of the vertice that is closest to the given position
]]
---@param position Vector3
function QuadSphere:GetClosestVerticeID(position)
    local squaresPerFace = 4^self.subdivisionCount
    local squaresPerAxis = math.sqrt(squaresPerFace)
    local squareSize = (self.radius*2)/squaresPerAxis

    --Find the closest position on the cube
    local corner = self.cframe *CFrame.new(self.radius, self.radius, self.radius)
    local objectSpace = corner:PointToObjectSpace(position)

    local xCoord = math.clamp(math.ceil(objectSpace.X/squareSize) * squareSize, -self.radius*2, 0)
    local yCoord = math.clamp(math.ceil(objectSpace.Y/squareSize) * squareSize, -self.radius*2, 0)
    local zCoord = math.clamp(math.ceil(objectSpace.Z/squareSize) * squareSize, -self.radius*2, 0)

    local clampedGridPosition = Vector3.new(xCoord, yCoord, zCoord)
    local verticePosition = (corner *CFrame.new(clampedGridPosition)).Position

    --Project the vertice position onto a sphere
    local direction = (verticePosition - self.cframe.Position).Unit
    verticePosition = self.cframe.Position + (direction * self.radius)
    
    return self.verticeIds[tostring(verticePosition)]
end

function QuadSphere:RenderFacesNearPosition(position)
    local verticeID = self:GetClosestVerticeID(position)

    local layers = 20
    local facesToRender = {}
    local facesToCheck = {}
    local finishedRender = {}

    for _, faceID in pairs(self.verticeToFaceMap[verticeID]) do
        --[[local face = self.faceList[faceID]
        facesToRender[faceID] = face
        table.insert(facesToCheck, face)]]
        --Make sure the face is not already in our render list
        local faceFromVert = self.faceList[faceID]

        if not facesToRender[faceID] and not finishedRender[faceID] then
            --Reuse this face if its already rendered
            if self.renderedFaces[faceID] then
                finishedRender[faceID] = faceFromVert
                self.renderedFaces[faceID] = nil
                table.insert(facesToCheck, faceFromVert)
            else
                facesToRender[faceID] = faceFromVert
                table.insert(facesToCheck, faceFromVert)
            end
        end  
    end

    local faceCheckStart = 1

    --Get a certain number of layers from the position given
    for l = 1, layers-1 do
        local facesToCheckCount = #facesToCheck

        --Loop over the faces to check
        for x = faceCheckStart, facesToCheckCount do
            local face = facesToCheck[x]

            --Check all the vertices of the face
            for _, vertID in pairs(face:GetVertices()) do
                local facesFromVert = self.verticeToFaceMap[vertID]

                for _, faceIDFromVert in pairs(facesFromVert) do
                    --Make sure the face is not already in our render list
                    local faceFromVert = self.faceList[faceIDFromVert]

                    if not facesToRender[faceIDFromVert] and not finishedRender[faceIDFromVert] then
                        --Reuse this face if its already rendered
                        if self.renderedFaces[faceIDFromVert] then
                            finishedRender[faceIDFromVert] = faceFromVert
                            self.renderedFaces[faceIDFromVert] = nil
                            table.insert(facesToCheck, faceFromVert)
                        else
                            facesToRender[faceIDFromVert] = faceFromVert
                            table.insert(facesToCheck, faceFromVert)
                        end
                    end
                end
            end
        end

        faceCheckStart = facesToCheckCount
    end

    --[[for faceId, face in pairs(self.renderedFaces) do
        if facesToRender[faceId] then
            facesToRender[faceId] = nil
            self.renderedFaces[faceId] = nil
            self.finishedRender[faceId] = face
        end
    end]]

    for faceId, face in pairs(facesToRender) do
        local existingFaceId, existingFace = next(self.renderedFaces)

        if existingFaceId then
            local faceModel = existingFace.renderedFace
            existingFace.renderedFace = nil
            self.renderedFaces[existingFaceId] = nil
            

            face:RenderFace(workspace, faceModel)--Tell the system to render and reuse this model
            finishedRender[faceId] = face
        else
            face:RenderFace(workspace)
            finishedRender[faceId] = face
        end
    end

    --Remove any leftovers
    for remainingFaceId, remainingFace in pairs(self.renderedFaces) do
        remainingFace.renderedFace:Destroy()
        remainingFace.renderedFace = nil

        self.renderedFaces[remainingFaceId] = nil
    end

    self.renderedFaces = finishedRender
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
        
        local topLeft = self.verticeList[face.topLeftVerticeId]
        local topRight = self.verticeList[face.topRightVerticeId]
        local bottomRight = self.verticeList[face.bottomRightVerticeId]
        local bottomLeft = self.verticeList[face.bottomLeftVerticeId]

        local f = triangleModule.fillQuadrant(topLeft, topRight, bottomRight, bottomLeft)
        f.Parent = sphere
    end
end



return QuadSphere
