local SphereFace = {}
SphereFace.__index = SphereFace

---@param topLeftVerticeId integer
---@param topRightVerticeId integer
---@param bottomRightVerticeId integer
---@param bottomLeftVerticeId integer
---@param faceID integer
function SphereFace.new(topLeftVerticeId, topRightVerticeId, bottomRightVerticeId, bottomLeftVerticeId, faceID)
    local self = setmetatable({}, SphereFace)

    self.topLeftVerticeId = topLeftVerticeId
    self.topRightVerticeId = topRightVerticeId
    self.bottomRightVerticeId = bottomRightVerticeId
    self.bottomLeftVerticeId = bottomLeftVerticeId
    
    self.faceID = faceID

    return self
end

function SphereFace:Subdivide(verticeList, faceList)
    local topLeftVertice = verticeList[self.topLeftVerticeId]
    local topRightVertice = verticeList[self.topRightVerticeId]
    local bottomLeftVertice = verticeList[self.bottomLeftVerticeId]
    local bottomRightVertice = verticeList[self.bottomRightVerticeId]

    local topMiddleVertice = (topLeftVertice + topRightVertice)/2
    local leftMiddleVertice = (topLeftVertice + bottomLeftVertice)/2
    local rightMiddleVertice = (topRightVertice + bottomRightVertice)/2
    local bottomMiddleVertice = (bottomLeftVertice + bottomRightVertice)/2
    local centerVertice = (topLeftVertice + topRightVertice + bottomLeftVertice + bottomRightVertice)/4

    --Get new vertice IDs
    local vListLength = #verticeList
    local topMiddleVerticeId = vListLength+1
    local leftMiddleVerticeId = vListLength+2
    local rightMiddleVerticeId = vListLength+3
    local bottomMiddleVerticeId = vListLength+4
    local centerVerticeId = vListLength+5

    --Insert new vertices into vertice list
    verticeList[topMiddleVerticeId] = topMiddleVertice
    verticeList[leftMiddleVerticeId] = leftMiddleVertice
    verticeList[rightMiddleVerticeId] = rightMiddleVertice
    verticeList[bottomMiddleVerticeId] = bottomMiddleVertice
    verticeList[centerVerticeId] = centerVertice


    -- < Create the three new faces > --
    local fListLength = #faceList
    local topRightFaceId = fListLength+1
    local bottomRightFaceId = fListLength+2
    local bottomLeftFaceId = fListLength+3

    local topRightFace = SphereFace.new(topMiddleVerticeId, self.topRightVerticeId, rightMiddleVerticeId, centerVerticeId, topRightFaceId)
    local bottomRightFace = SphereFace.new(centerVerticeId, rightMiddleVerticeId, self.bottomRightVerticeId, bottomMiddleVerticeId, bottomRightFaceId)
    local bottomLeftFace = SphereFace.new(leftMiddleVerticeId, centerVerticeId, bottomMiddleVerticeId, self.bottomLeftVerticeId, bottomLeftFaceId)

    --Put new faces into the faces list
    faceList[topRightFaceId] = topRightFace
    faceList[bottomRightFaceId] = bottomRightFace
    faceList[bottomLeftFaceId] = bottomLeftFace


    --The current face becomes the top left face
    self.topRightVerticeId = topMiddleVerticeId
    self.bottomLeftVerticeId = leftMiddleVerticeId
    self.bottomRightVerticeId = centerVerticeId
end

return SphereFace