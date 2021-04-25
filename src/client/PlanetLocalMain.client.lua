local Planet = require(game.ReplicatedStorage.SharedModules.Generation2.Planet)



workspace:WaitForChild("Elocore")
local p = Planet.new(CFrame.new(0, 0, 0), 2000)
local lastPosition = workspace.Elocore.PrimaryPart.Position

game:GetService("RunService").Heartbeat:Connect(function(delta)
    local currentPos = workspace.CurrentCamera.CFrame.Position

    if (currentPos - lastPosition).Magnitude >= 10 then
        lastPosition = currentPos
        p:LOD(currentPos)
    end
end)