local plr = game.Players.LocalPlayer

plr.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = 100
end)

local Planet = require(game.ReplicatedStorage.SharedModules.Generation2.Planet)

local p = Planet.new(CFrame.new(0, 0, 0), 2000)
local lastPosition = workspace.CurrentCamera.CFrame.Position

game:GetService("RunService").Heartbeat:Connect(function(delta)
    local currentPos = workspace.CurrentCamera.CFrame.Position

    if (currentPos - lastPosition).Magnitude >= 10 then
        lastPosition = currentPos
        p:LOD(currentPos)
    end
end)