local Planet = require(game.ReplicatedStorage.SharedModules.Generation2.Planet)



workspace:WaitForChild("Elocore")
local p = Planet.new(CFrame.new(0, 0, 0), 2000)
local lastPosition = workspace.Elocore.PrimaryPart.Position

local counter = 1

game:GetService("RunService").Heartbeat:Connect(function(delta)
    counter = counter + 1
    local currentPos = workspace.Elocore.PrimaryPart.Position

    if (currentPos - lastPosition).Magnitude >= 10 then
        lastPosition = currentPos
        p:LOD(currentPos)
    end

    if counter%20 == 0 then
        print("FPS:", 1/delta)
    end
end)