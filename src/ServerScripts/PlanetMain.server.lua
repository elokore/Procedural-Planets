local Planet = require(game.ReplicatedStorage.SharedModules.Generation2.Planet)




local p = Planet.new(CFrame.new(0, 0, 0), 2000)
local lastPosition = workspace.Marker.Position

workspace.Marker.Changed:Connect(function()
    local pos = workspace.Marker.Position

    if (pos - lastPosition).Magnitude >= 10 then
        p:LOD(workspace.Marker.Position)
    end
end)

--[[local lastPosition = workspace.Elocore.PrimaryPart.Position

game:GetService("RunService").Heartbeat:Connect(function()
    local currentPos = workspace.Elocore.PrimaryPart.Position

    if (currentPos - lastPosition).Magnitude >= 30 then
        lastPosition = currentPos
        p:LOD(currentPos)
    end
end)]]

--p:RenderAllFaces()