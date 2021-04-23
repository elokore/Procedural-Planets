local QuadtreeManager = {}
QuadtreeManager.__index = QuadtreeManager

--[[
    Creates a quadtree of faces of the planet
    A quadtree is a data structure where each node has 4 child nodes

    The starting parent nodes should be the six faces of the cube that the planet is made from
]]
---@param planetCFrame CFrame
---@param planetRadius number
---@param parentNodes table --The six faces of the cube the planet is made of
---@class QuadtreeManager
function QuadtreeManager.new(planetCFrame, planetRadius, parentNodes)
    local self = setmetatable({}, QuadtreeManager)

    self.planetCFrame = planetCFrame
    self.planetRadius = planetRadius
    self.parentNodes = parentNodes

    return self
end

--[[
    Subdivides the node the provided number of times
]]
---@param node Node --The node to subdivide
---@param subCount integer --The number of times to subdivide the face
function QuadtreeManager:SubdivideNode(node, subCount)
    node:Subdivide()
    subCount = subCount - 1

    if subCount > 0 then
        self:SubdivideNode(node.childNode1, subCount-1)
        self:SubdivideNode(node.childNode2, subCount-1)
        self:SubdivideNode(node.childNode3, subCount-1)
        self:SubdivideNode(node.childNode4, subCount-1)
    end
end

return QuadtreeManager