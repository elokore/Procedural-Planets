local Node = {}
Node.__index = Node

---- < Module Imports > ----
local triangles = require(game.ReplicatedStorage.SharedModules.Triangles)

--[[
    Creates a new node in the PlanetQuadtree
    each node represents a face on the planet, each node also contains its four child faces
]]
---@class Node
---@param topLeftVerticeID integer
---@param topRightVerticeID integer
---@param bottomRightVerticeID integer
---@param bottomLeftVerticeID integer
---@param planet Planet --The list of all the vertices 
---@param depth integer --How deep in the quadtree this node is located
---@param parentNode Node --The parent node of this node
function Node.new(topLeftVerticeID, topRightVerticeID, bottomRightVerticeID, bottomLeftVerticeID, planet, depth, parentNode)
    local self = setmetatable({}, Node)

    self.parentNode = parentNode
    self.depth = depth
    self.planet = planet
    self.hasChildren = false--Indicates of the node has any children nodes, faster than checking if all the child nodes are nil

    self.topLeftVerticeID = topLeftVerticeID
    self.topRightVerticeID = topRightVerticeID
    self.bottomRightVerticeID = bottomRightVerticeID
    self.bottomLeftVerticeID = bottomLeftVerticeID

    self.nodePosition = (planet.vertices[topLeftVerticeID] + planet.vertices[topRightVerticeID] + planet.vertices[bottomRightVerticeID] + planet.vertices[bottomLeftVerticeID])/4

    self.childNode1 = nil
    self.childNode2 = nil
    self.childNode3 = nil
    self.childNode4 = nil

    self.renderedFace = nil

    return self
end

--[[
    Returns the four vertices of the face as a tuple
    in clockwise order starting from the top left corner of the quadrilateral
]]
---@return integer
function Node:GetVerticeIDs()
    return self.topLeftVerticeID, self.topRightVerticeID, self.bottomRightVerticeID, self.bottomLeftVerticeID
end

--[[
    Gets the depth of the node
]]
---@return integer
function Node:GetNodeDepth()
    return self.depth
end

--[[
    Gets the rendered face of this node if it exists
]]
---@return Model
function Node:GetFace()
    return self.renderedFace
end

--[[
    Gets the parent of this node
]]
---@return Node
function Node:GetParentNode()
    return self.parentNode
end

--[[
    Checks if this node has any children
]]
---@return boolean
function Node:HasChildren()
    return self.hasChildren
end

--[[
    Renders the face associated with this node
]]
---@param reusableFace Model --(Optional) A pre-existing face that we can use to render this face
---@return Model
function Node:RenderFace(reusableFace)
    local n1, n2, n3, n4 = self:GetVerticeIDs()
    local v1, v2, v3, v4 = self.planet.vertices[n1], self.planet.vertices[n2], self.planet.vertices[n3], self.planet.vertices[n4]

    self.renderedFace = triangles.fillQuadrant(v1, v2, v3, v4, reusableFace)
    return self.renderedFace
end

--[[
    Subdivides the face into four new faces
    and sets them as children nodes of this node
]]
function Node:Subdivide()
    --Get the position of the four vertices of this node
    local planet = self.planet
    local noiseFilter = self.planet.noiseFilter
    local topLeftPosition = planet.vertices[self.topLeftVerticeID]
    local topRightPosition = planet.vertices[self.topRightVerticeID]
    local bottomRightPosition = planet.vertices[self.bottomRightVerticeID]
    local bottomLeftPosition = planet.vertices[self.bottomLeftVerticeID]

    --Calculate positions of new vertices and then project it onto a sphere
    local topMiddlePosition = ((topLeftPosition + topRightPosition)/2)
    topMiddlePosition = topMiddlePosition.Unit * (self.planet.radius + noiseFilter:EvaluateNoise(topMiddlePosition.Unit * planet.radius))

    local rightMiddlePosition = ((topRightPosition + bottomRightPosition)/2)
    rightMiddlePosition = rightMiddlePosition.Unit * (self.planet.radius + noiseFilter:EvaluateNoise(rightMiddlePosition.Unit * planet.radius))

    local bottomMiddlePosition = ((bottomLeftPosition + bottomRightPosition)/2)
    bottomMiddlePosition = bottomMiddlePosition.Unit * (self.planet.radius + noiseFilter:EvaluateNoise(bottomMiddlePosition.Unit * planet.radius))

    local leftMiddlePosition = ((topLeftPosition + bottomLeftPosition)/2)
    leftMiddlePosition = leftMiddlePosition.Unit * (self.planet.radius + noiseFilter:EvaluateNoise(leftMiddlePosition.Unit * planet.radius))

    local centerPosition = ((topLeftPosition + topRightPosition + bottomRightPosition + bottomLeftPosition)/4)
    centerPosition = centerPosition.Unit * (self.planet.radius + noiseFilter:EvaluateNoise(centerPosition.Unit * planet.radius))



    --Add vertices to the planet
    local topMiddleVerticeID = planet.positionToVerticeID[topMiddlePosition] or planet.nextVerticeID
    planet.vertices[topMiddleVerticeID] = topMiddlePosition
    planet.positionToVerticeID[topMiddlePosition] = topMiddleVerticeID

    local rightMiddleVerticeID = planet.positionToVerticeID[rightMiddlePosition] or planet.nextVerticeID
    planet.vertices[rightMiddleVerticeID] = rightMiddlePosition
    planet.positionToVerticeID[rightMiddlePosition] = rightMiddleVerticeID

    local bottomMiddleVerticeID = planet.positionToVerticeID[bottomMiddlePosition] or planet.nextVerticeID
    planet.vertices[bottomMiddleVerticeID] = bottomMiddlePosition
    planet.positionToVerticeID[bottomMiddlePosition] = bottomMiddleVerticeID

    local leftMiddleVerticeID = planet.positionToVerticeID[leftMiddlePosition] or planet.nextVerticeID
    planet.vertices[leftMiddleVerticeID] = leftMiddlePosition
    planet.positionToVerticeID[leftMiddlePosition] = leftMiddleVerticeID

    local centerVerticeID = planet.positionToVerticeID[centerPosition] or planet.nextVerticeID
    planet.vertices[centerVerticeID] = centerPosition
    planet.positionToVerticeID[centerPosition] = centerVerticeID

    --Create the four new nodes
    self.childNode1 = Node.new(self.topLeftVerticeID, topMiddleVerticeID, centerVerticeID, leftMiddleVerticeID, self.planet, self.depth+1, self)--Top left node
    self.childNode2 = Node.new(topMiddleVerticeID, self.topRightVerticeID, rightMiddleVerticeID, centerVerticeID, self.planet, self.depth+1, self)--Top right node
    self.childNode3 = Node.new(centerVerticeID, rightMiddleVerticeID, self.bottomRightVerticeID, bottomMiddleVerticeID, self.planet, self.depth+1, self)--Bottom right node
    self.childNode4 = Node.new(leftMiddleVerticeID, centerVerticeID, bottomMiddleVerticeID, self.bottomLeftVerticeID, self.planet, self.depth+1, self)--Bottom left node

    self.hasChildren = true
end

return Node