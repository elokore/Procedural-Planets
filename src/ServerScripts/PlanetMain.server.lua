local Planet = require(game.ReplicatedStorage.SharedModules.Generation2.Planet)



workspace:WaitForChild("Elocore")

wait(5)
local p = Planet.new(CFrame.new(0, 0, 0), 2000)

workspace.Marker.Changed:Connect(function()
    local s = tick()
    p:LOD(workspace.Marker.Position)
    local e = tick()
    print(e-s, "seconds to update")
end)

local lastPosition = workspace.Elocore.PrimaryPart.Position

game:GetService("RunService").Heartbeat:Connect(function()
    local currentPos = workspace.Elocore.PrimaryPart.Position

    if (currentPos - lastPosition).Magnitude >= 30 then
        lastPosition = currentPos
        p:LOD(currentPos)
    end
end)

--p:RenderAllFaces()