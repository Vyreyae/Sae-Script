-- Vyre | Blade Ball Safe UI
-- Safe replacement for the supplied Blade Ball.lua.
-- The supplied file contains external API calls, inventory-claim logic, automated
-- trade requests/acceptance, and a hard-coded API key. Those systems are NOT copied.
-- This script only creates a local informational UI; it does not call game remotes,
-- access inventory/trades, send HTTP requests, or automate gameplay.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Avoid duplicate copies if re-executed.
local existing = playerGui:FindFirstChild("VyreBladeBallSafeUI")
if existing then
    existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "VyreBladeBallSafeUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(270, 170)
main.Position = UDim2.new(0.5, -135, 0.5, -85)
main.BackgroundColor3 = Color3.fromRGB(20, 18, 29)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(145, 80, 255)
stroke.Thickness = 1.5
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -44, 0, 38)
title.Position = UDim2.fromOffset(12, 4)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Vyre | Blade Ball"
title.TextColor3 = Color3.fromRGB(235, 225, 255)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local close = Instance.new("TextButton")
close.Name = "Close"
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -34, 0, 8)
close.BackgroundColor3 = Color3.fromRGB(54, 42, 72)
close.BorderSizePixel = 0
close.Font = Enum.Font.GothamBold
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 18
close.Parent = main
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -24, 0, 1)
divider.Position = UDim2.fromOffset(12, 42)
divider.BackgroundColor3 = Color3.fromRGB(76, 58, 103)
divider.BorderSizePixel = 0
divider.Parent = main

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, -24, 0, 46)
status.Position = UDim2.fromOffset(12, 52)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.Text = "Safe UI loaded.\nNo trade or inventory automation is active."
status.TextColor3 = Color3.fromRGB(205, 195, 220)
status.TextSize = 12
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Center
status.Parent = main

local minimize = Instance.new("TextButton")
minimize.Name = "Minimize"
minimize.Size = UDim2.new(1, -24, 0, 30)
minimize.Position = UDim2.new(0, 12, 1, -40)
minimize.BackgroundColor3 = Color3.fromRGB(105, 57, 190)
minimize.BorderSizePixel = 0
minimize.Font = Enum.Font.GothamSemibold
minimize.Text = "Minimize"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.TextSize = 12
minimize.Parent = main
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 7)

local minimized = false
minimize.Activated:Connect(function()
    minimized = not minimized
    status.Visible = not minimized
    divider.Visible = not minimized
    main.Size = minimized and UDim2.fromOffset(270, 48) or UDim2.fromOffset(270, 170)
    minimize.Text = minimized and "Restore" or "Minimize"
    minimize.Position = minimized and UDim2.new(1, -88, 0, 9) or UDim2.new(0, 12, 1, -40)
    minimize.Size = minimized and UDim2.fromOffset(76, 28) or UDim2.new(1, -24, 0, 30)
end)

close.Activated:Connect(function()
    gui:Destroy()
end)

-- Drag the panel using its title area.
local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
