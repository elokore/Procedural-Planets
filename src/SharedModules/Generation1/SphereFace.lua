local SphereFace = {}
SphereFace.__index = SphereFace

---- < Module Imports > ----
local triangles = require(game.ReplicatedStorage.SharedModules.Triangles)

---@param topLeftVerticeId integer
---@param topRightVerticeId integer
---@param bottomRightVerticeId integer
---@param bottomLeftVerticeId integer
---@param faceID integer
function SphereFace.new(topLeftVerticeId, topRightVerticeId, bottomRightVerticeId, bottomLeftVerticeId, faceID, verticeList, faceList, verticeIDs)
    local self = setmetatable({}, SphereFace)

    self.topLeftVerticeId = topLeftVerticeId
    self.topRightVerticeId = topRightVerticeId
    self.bottomRightVerticeId = bottomRightVerticeId
    self.bottomLeftVerticeId = bottomLeftVerticeId

    self.verticeList = verticeList
    self.faceList = faceList
    self.verticeIDs = verticeIDs
    
    self.faceID = faceID

    return self
end

function SphereFace:GetVertices()
    return {self.topLeftVerticeId, self.topRightVerticeId, self.bottomRightVerticeId, self.bottomLeftVerticeId}
end

--[[
    Splits the current face into 4 faces
]]
function SphereFace:Subdivide()
    local topLeftVertice = self.verticeList[self.topLeftVerticeId]
    local topRightVertice = self.verticeList[self.topRightVerticeId]
    local bottomLeftVertice = self.verticeList[self.bottomLeftVerticeId]
    local bottomRightVertice = self.verticeList[self.bottomRightVerticeId]

    --Create new vertices at the midpoints of all the edges and one at the center of the face
    local topMiddleVertice = (topLeftVertice + topRightVertice)/2
    local leftMiddleVertice = (topLeftVertice + bottomLeftVertice)/2
    local rightMiddleVertice = (topRightVertice + bottomRightVertice)/2
    local bottomMiddleVertice = (bottomLeftVertice + bottomRightVertice)/2
    local centerVertice = (topLeftVertice + topRightVertice + bottomLeftVertice + bottomRightVertice)/4

    --Insert new vertices into vertice list
    local topMiddleVerticeId = self.verticeIDs[tostring(topMiddleVertice)] or #self.verticeList+1
    self.verticeList[topMiddleVerticeId] = topMiddleVertice
    self.verticeIDs[tostring(topMiddleVertice)] = topMiddleVerticeId

    local leftMiddleVerticeId = self.verticeIDs[tostring(leftMiddleVertice)] or #self.verticeList+1
    self.verticeList[leftMiddleVerticeId] = leftMiddleVertice
    self.verticeIDs[tostring(leftMiddleVertice)] = leftMiddleVerticeId

    local rightMiddleVerticeId = self.verticeIDs[tostring(rightMiddleVertice)] or #self.verticeList+1
    self.verticeList[rightMiddleVerticeId] = rightMiddleVertice
    self.verticeIDs[tostring(rightMiddleVertice)] = rightMiddleVerticeId

    local bottomMiddleVerticeId = self.verticeIDs[tostring(bottomMiddleVertice)] or #self.verticeList+1
    self.verticeList[bottomMiddleVerticeId] = bottomMiddleVertice
    self.verticeIDs[tostring(bottomMiddleVertice)] = bottomMiddleVerticeId

    local centerVerticeId = self.verticeIDs[tostring(centerVertice)] or #self.verticeList+1
    self.verticeList[centerVerticeId] = centerVertice
    self.verticeIDs[tostring(centerVertice)] = centerVerticeId


    -- < Create the three new faces > --
    local fListLength = #self.faceList
    local topRightFaceId = fListLength+1
    local bottomRightFaceId = fListLength+2
    local bottomLeftFaceId = fListLength+3

    local topRightFace = SphereFace.new(topMiddleVerticeId, self.topRightVerticeId, rightMiddleVerticeId, centerVerticeId, topRightFaceId, self.verticeList, self.faceList, self.verticeIDs)
    local bottomRightFace = SphereFace.new(centerVerticeId, rightMiddleVerticeId, self.bottomRightVerticeId, bottomMiddleVerticeId, bottomRightFaceId, self.verticeList, self.faceList, self.verticeIDs)
    local bottomLeftFace = SphereFace.new(leftMiddleVerticeId, centerVerticeId, bottomMiddleVerticeId, self.bottomLeftVerticeId, bottomLeftFaceId, self.verticeList, self.faceList, self.verticeIDs)

    --Put new faces into the faces list
    self.faceList[topRightFaceId] = topRightFace
    self.faceList[bottomRightFaceId] = bottomRightFace
    self.faceList[bottomLeftFaceId] = bottomLeftFace


    --The current face becomes the top left face
    self.topRightVerticeId = topMiddleVerticeId
    self.bottomLeftVerticeId = leftMiddleVerticeId
    self.bottomRightVerticeId = centerVerticeId
end

--[[
    Renders the face and puts it in the designated parent
]]
---@param parent Instance
function SphereFace:RenderFace(parent, faceToReuse)
    local topLeftVert = self.verticeList[self.topLeftVerticeId]
    local topRightVert = self.verticeList[self.topRightVerticeId]
    local bottomRightVert = self.verticeList[self.bottomRightVerticeId]
    local bottomLeftVert = self.verticeList[self.bottomLeftVerticeId]

    self.renderedFace = triangles.fillQuadrant(topLeftVert, topRightVert, bottomRightVert, bottomLeftVert, faceToReuse)
    self.renderedFace.Parent = parent

    return self.renderedFace
end

return SphereFace