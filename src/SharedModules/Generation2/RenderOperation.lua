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
    table.insert(self.nodesToRender, node)
end

--[[
    If this node already has a rendered face then mark it as rendered
]]
function RenderOperation:MarkNodeAsRendered(node)
    self.rendered[node.nodePosition] = node
end

--[[
    Starts rendering all the provided nodes
]]
function RenderOperation:BeginOperation()
    print("Faces to Render:", #self.nodesToRender)
    local num = math.ceil(#self.nodesToRender/2)

    self.frameEvent = runService.Heartbeat:Connect(function(delta)
        local nodeCountToRender = num--math.min(200, #self.nodesToRender)

        --Render x amount of faces
        for x = 1, nodeCountToRender do
            local nodeIndex = #self.nodesToRender
            local node = self.nodesToRender[nodeIndex]

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

                --local newFace = node:RenderFace(reusableFace)
                --newFace.Parent = workspace.Planet

                table.remove(self.nodesToRender, nodeIndex)
                self.rendered[node.nodePosition] = node
            end
        end

        if #self.nodesToRender <= 0 then
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