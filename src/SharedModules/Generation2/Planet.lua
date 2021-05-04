local Planet = {}
Planet.__index = Planet

---- < Module Imports > ----
local Node = require(game.ReplicatedStorage.SharedModules.Generation2.Node)
local triangles = require(game.ReplicatedStorage.SharedModules.Triangles)
local PlanetNoise = require(game.ReplicatedStorage.SharedModules.Generation2.PlanetNoise)
local RenderOperation = require(game.ReplicatedStorage.SharedModules.Generation2.RenderOperation)

---@class Planet
function Planet.new(cframe, radius)
    local self = setmetatable({}, Planet)

    --This makes the "nextVerticeID" variable automatically increase each time a new vertice is added
    local verticeListMetatable = {
        __newindex = function(t, index, value)
            rawset(t, index, value)
            self.nextVerticeID = self.nextVerticeID + 1
        end
    }

    self.planetNoise = PlanetNoise.new(self)

    self.cframe = cframe
    self.radius = radius
    self.maxSubLimit = 6
    self.currentSubLimit = self.maxSubLimit

    self.vertices = setmetatable({}, verticeListMetatable)
    self.positionToVerticeID = {}
    self.nextVerticeID = 1

    self.quadtree = self:GeneratePlanetCube()

    self.renderedNodes = {}

    self:LOD(Vector3.new(0, 2005, 0))
    --self:RenderAllFaces()

    return self
end

--[[
    Generates the cube that the planet will be made from
]]
function Planet:GeneratePlanetCube()
    --Calculate where the 8 vertices will be
    --All positions are in localspace

    --Top 4 vertices
    local topFrontLeftPosition = (CFrame.new(Vector3.new(), Vector3.new(-1, 1, 1)) *CFrame.new(0, 0, -self.radius)).Position
    local topFrontLeftVerticeID = self.nextVerticeID
    self.vertices[self.nextVerticeID] = topFrontLeftPosition
    self.positionToVerticeID[topFrontLeftPosition] = topFrontLeftVerticeID

    local topFrontRightPosition = (CFrame.new(Vector3.new(), Vector3.new(1, 1, 1)) *CFrame.new(0, 0, -self.radius)).Position
    local topFrontRightVerticeID = self.nextVerticeID
    self.vertices[self.nextVerticeID] = topFrontRightPosition
    self.positionToVerticeID[topFrontRightPosition] = topFrontRightVerticeID

    local topBackRightPosition = (CFrame.new(Vector3.new(), Vector3.new(1, 1, -1)) *CFrame.new(0, 0, -self.radius)).Position
    local topBackRightVerticeID = self.nextVerticeID
    self.vertices[self.nextVerticeID] = topBackRightPosition
    self.positionToVerticeID[topBackRightPosition] = topBackRightVerticeID

    local topBackLeftPosition = (CFrame.new(Vector3.new(), Vector3.new(-1, 1, -1)) *CFrame.new(0, 0, -self.radius)).Position
    local topBackLeftVerticeID = self.nextVerticeID
    self.vertices[self.nextVerticeID] = topBackLeftPosition
    self.positionToVerticeID[topBackLeftPosition] = topBackLeftVerticeID

    --Bottom 4 vertices
    local bottomFrontLeftPosition = (CFrame.new(Vector3.new(), Vector3.new(-1, -1, 1)) *CFrame.new(0, 0, -self.radius)).Position
    local bottomFrontLeftVerticeID = self.nextVerticeID
    self.vertices[self.nextVerticeID] = bottomFrontLeftPosition
    self.positionToVerticeID[bottomFrontLeftPosition] = bottomFrontLeftVerticeID

    local bottomFrontRightPosition = (CFrame.new(Vector3.new(), Vector3.new(1, -1, 1)) *CFrame.new(0, 0, -self.radius)).Position
    local bottomFrontRightVerticeID = self.nextVerticeID
    self.vertices[self.nextVerticeID] = bottomFrontRightPosition
    self.positionToVerticeID[bottomFrontRightPosition] = bottomFrontRightVerticeID

    local bottomBackRightPosition = (CFrame.new(Vector3.new(), Vector3.new(1, -1, -1)) *CFrame.new(0, 0, -self.radius)).Position
    local bottomBackRightVerticeID = self.nextVerticeID
    self.vertices[self.nextVerticeID] = bottomBackRightPosition
    self.positionToVerticeID[bottomBackRightPosition] = bottomBackRightVerticeID

    local bottomBackLeftPosition = (CFrame.new(Vector3.new(), Vector3.new(-1, -1, -1)) *CFrame.new(0, 0, -self.radius)).Position
    local bottomBackLeftVerticeID = self.nextVerticeID
    self.vertices[self.nextVerticeID] = bottomBackLeftPosition
    self.positionToVerticeID[bottomBackLeftPosition] = bottomBackLeftVerticeID

    --Create a node for each face
    local topFaceNode = Node.new(topFrontLeftVerticeID, topFrontRightVerticeID, topBackRightVerticeID, topBackLeftVerticeID, self, 0)
    local bottomFaceNode = Node.new(bottomFrontLeftVerticeID, bottomFrontRightVerticeID, bottomBackRightVerticeID, bottomBackLeftVerticeID, self, 0)
    local frontFaceNode = Node.new(topFrontRightVerticeID, topFrontLeftVerticeID, bottomFrontLeftVerticeID, bottomFrontRightVerticeID, self, 0)
    local backFaceNode = Node.new(topBackLeftVerticeID, topBackRightVerticeID, bottomBackRightVerticeID, bottomBackLeftVerticeID, self, 0)
    local leftFaceNode = Node.new(topFrontLeftVerticeID, topBackLeftVerticeID, bottomBackLeftVerticeID, bottomFrontLeftVerticeID, self, 0)
    local rightFaceNode = Node.new(topBackRightVerticeID, topFrontRightVerticeID, bottomFrontRightVerticeID, bottomBackRightVerticeID, self, 0)
    
    return {topFaceNode, bottomFaceNode, frontFaceNode, backFaceNode, leftFaceNode, rightFaceNode}
end

--[[
    Recalculates the position of all vertices with current noise filters
    should only be used for testing/debugging purposes
]]
function Planet:RecalculateVertices()
    for vid, verticePosition in pairs(self.vertices) do
        local newPosition = verticePosition.Unit * (self.radius + self.noiseFilter:EvaluateNoise(verticePosition.Unit*self.radius))
        self.vertices[vid] = newPosition

        self.positionToVerticeID[verticePosition] = nil
        self.positionToVerticeID[newPosition] = vid
    end
end

--[[
    Gets the position of a vertice in global space
]]
---@param vid integer --The ID of the vertice
function Planet:GetVerticeGlobalSpace(vid)
    return (self.cframe *CFrame.new(self.vertices[vid])).Position
end

--[[
    Gets the position of a vertice in local space
]]
---@param vid integer the ID of the vertice
function Planet:GetVerticeLocalSpace(vid)
    return self.vertices[vid]
end

--[[
    Mainly just for debugging/testing, this will be too expensive to do in a real game at full scale
]]
function Planet:RenderAllFaces()
    workspace.Planet:ClearAllChildren()

    local function renderNode(node)
        if node:HasChildren() then
            renderNode(node.childNode1)
            renderNode(node.childNode2)
            renderNode(node.childNode3)
            renderNode(node.childNode4)
        else
            local n1, n2, n3, n4 = node:GetVerticeIDs()
            local face1 = triangles.fillQuadrant(self:GetVerticeGlobalSpace(n1), self:GetVerticeGlobalSpace(n2), self:GetVerticeGlobalSpace(n3), self:GetVerticeGlobalSpace(n4))
            face1.Parent = workspace.Planet
        end
    end

    for _, coreNode in ipairs(self.quadtree) do
        renderNode(coreNode)
    end
end

--[[
    Checks if the node needs to be rendered and if needed,
    will add the node to the render list
]]
function Planet:DetermineNodeRenderWorthy(node)
    local nodeRendered = node.renderedFace

    if nodeRendered then
        self.renderedNodes[node.nodePosition] = nil
        self.currentRenderOperation:MarkNodeAsRendered(node)
    else
        self.currentRenderOperation:AddNodeToRenderList(node)
    end
end

--[[
    Calculates the resolution of the node given the targetPosition
]]
---@param node Node
---@param viewCFrame CFrame
---@param targetPosition Vector3
function Planet:CalculateNodeResolution(node, viewCFrame, targetPosition)
    local v1 = self.vertices[node.topLeftVerticeID]
    local nodePosition = node.nodePosition--(v1+v2+v3+v4)/4

    --Dont subdivide past the limit
    if node.depth < self.currentSubLimit then
        local nodePositionViewLocal = viewCFrame:PointToObjectSpace(nodePosition)

        --Dont do anything to this node if its not in view of the player
        if nodePositionViewLocal.Z <= 0 or node.depth < 2 then
            local halfWidthEstimate = (v1-nodePosition).Magnitude--Very rough estimate of the width of the node

            if (targetPosition - nodePosition).Magnitude <= halfWidthEstimate*20 then
                if not node:HasChildren() then
                    node:Subdivide()
                end

                self:CalculateNodeResolution(node.childNode1, viewCFrame, targetPosition)
                self:CalculateNodeResolution(node.childNode2, viewCFrame, targetPosition)
                self:CalculateNodeResolution(node.childNode3, viewCFrame, targetPosition)
                self:CalculateNodeResolution(node.childNode4, viewCFrame, targetPosition)
            else
                self:DetermineNodeRenderWorthy(node)
            end
        end
    else
        self:DetermineNodeRenderWorthy(node)
    end
end

--[[
    adjusts the quadtree to increase in resolution depending on where the given position is
]]
---@param position Vector3 --Position in global space
function Planet:LOD(position)
    if not self.currentRenderOperation or self.currentRenderOperation.completed then
        self.currentRenderOperation = RenderOperation.new(self)

        local posDirection = (position - self.cframe.Position).Unit
        local distanceFromSurface = (position - self.cframe.Position).Magnitude - self.radius
        local viewCFrame = CFrame.new(self.cframe.Position + posDirection * (self.radius - ((self.radius*30)^0.5 + (distanceFromSurface*150)^0.5)), self.cframe.Position + posDirection * self.radius)

        local subLimit = math.min(self.maxSubLimit - (distanceFromSurface/self.radius), 2)
        subLimit = math.max(subLimit, self.maxSubLimit)
        self.currentSubLimit = subLimit

        local s = os.clock()

        --Calculate the appropriate resolution of all the nodes
        for _, node in pairs(self.quadtree) do
            self:CalculateNodeResolution(node, viewCFrame, position)
        end

        local e = os.clock()
        --print("Time:", e-s)
        
        self.currentRenderOperation:BeginOperation()
    end
end

return Planet