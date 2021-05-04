local RenderOperation = {}
RenderOperation.__index = RenderOperation

---- < Roblox Services > ----
local runService = game:GetService("RunService")

--[[
    Creates a new render operation, given
    all the nodes it needs to render it will render them
    spread out over multiple frames to reduce lag
]]
---@param planet Planet
function RenderOperation.new(planet)
    local self = setmetatable({}, RenderOperation)

    self.renderListLength = 0
    self.nodesToRender = {}
    self.rendered = {}

    self.planet = planet
    self.completed = false
    self.frameEvent = nil

    return self
end


--[[
    Adds a node to the list of nodes that need to be rendered
]]
---@param node Node
function RenderOperation:AddNodeToRenderList(node)
    self.nodesToRender[node.nodePosition] = node
    self.renderListLength = self.renderListLength + 1
end

--[[
    If this node already has a rendered face then mark it as rendered
]]
function RenderOperation:MarkNodeAsRendered(node)
    self.rendered[node.nodePosition] = node
end

--[[
    Renders the next node in the render list
    or a specific node, if specified in function parameters
]]
---@param optionalNode Node --A specific node to render, if nil then a random node from the "nodesToRender" list will be chosen
function RenderOperation:RenderNode(optionalNode)
    local nodePosition, node

    if optionalNode then
        node = optionalNode
        nodePosition = optionalNode.nodePosition
    else
        nodePosition, node = next(self.nodesToRender)
    end

    if node then
        --Find a face to reuse
        local otherNodePosition, reusableNode = next(self.planet.renderedNodes)
        local reusableFace

        --If a reusable face was found then take it and use it to make the new face we need
        if otherNodePosition then
            self.planet.renderedNodes[otherNodePosition] = nil
            reusableFace = reusableNode.renderedFace
            reusableNode.renderedFace = nil
        end


        local newFace = node:RenderFace(reusableFace)
        newFace.Parent = workspace.Planet

        self.nodesToRender[nodePosition] = nil
        self.rendered[node.nodePosition] = node

        self.renderListLength = self.renderListLength - 1

        if reusableNode then
            --If the parent or children of the reusable node is supposed to be rendered then we need to render that node to stop flickering when the reusable node is moved
            if reusableNode.parentNode and self.nodesToRender[reusableNode.parentNode.nodePosition] then
                self:RenderNode(reusableNode.parentNode)
            elseif reusableNode:HasChildren() then
                if self.nodesToRender[reusableNode.childNode1.nodePosition] then
                    self:RenderNode(reusableNode.childNode1)
                end

                if self.nodesToRender[reusableNode.childNode2.nodePosition] then
                    self:RenderNode(reusableNode.childNode2)
                end

                if self.nodesToRender[reusableNode.childNode3.nodePosition] then
                    self:RenderNode(reusableNode.childNode3)
                end

                if self.nodesToRender[reusableNode.childNode4.nodePosition] then
                    self:RenderNode(reusableNode.childNode4)
                end
            end
        end
    end
end

--[[
    Starts rendering all the provided nodes
]]
function RenderOperation:BeginOperation()
    print("Faces to Render:", self.renderListLength)
    --local num = math.ceil(#self.nodesToRender/2)

    self.frameEvent = runService.Heartbeat:Connect(function(delta)
        local nodeCountToRender = math.min(35, self.renderListLength)

        --Render x amount of faces
        for x = 1, nodeCountToRender do
            self:RenderNode()
        end

        if self.renderListLength <= 0 then
            for key, node in pairs(self.planet.renderedNodes) do
                node.renderedFace:Destroy()
                node.renderedFace = nil
                self.planet.renderedNodes[key] = nil
            end

            self.planet.renderedNodes = self.rendered

            self.frameEvent:Disconnect()
            self.completed = true
        end
    end)
end

return RenderOperation