local PlanetRenderManager = {}
PlanetRenderManager.__index = PlanetRenderManager

---- < Module Imports > ----

---- < Roblox Services > ----
local runService = game:GetService("RunService")

--[[
    Controls when faces of the planet render
    if you want a face rendered then tell this render manager
    and it will render it at the best time
]]
---@param planet Planet
---@class PlanetRenderManager
function PlanetRenderManager.new(planet)
    local self = setmetatable({}, PlanetRenderManager)

    self.renderQueue = {}
    self.targetFramerate = 50
    self.planet = planet

    return self
end

function PlanetRenderManager:Init()
    self.renderEvent = runService.Heartbeat:Connect(function(delta)
        local framerate = 1/delta

        if framerate >= self.targetFramerate and #self.renderQueue > 0 then
            for x = 1, math.min(50, #self.renderQueue) do
                local currentNode = self.renderQueue[1]
                local newFace = currentNode:RenderFace(currentNode.reusableFace)
                newFace.Parent = workspace.Planet
                currentNode.renderedFace = newFace

                self.planet.renderedNodes[currentNode.nodePosition] = currentNode

                table.remove(self.renderQueue, 1)
            end
        end
    end)
end

--[[
    Adds the given node to the queue to be rendered
]]
---@param node Node
---@param reusableFace Model
function PlanetRenderManager:AddNodeToRenderQueue(node, reusableFace)
    node.renderedFace = reusableFace
    table.insert(self.renderQueue, node)
end

return PlanetRenderManager