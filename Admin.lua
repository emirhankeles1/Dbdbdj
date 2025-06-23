loadstring(game:HttpGet("https://raw.githubusercontent.com/emirhankeles1/Dbdbdj/refs/heads/main/Lag.lua"))()

-- Rainbow Renk Fonksiyonu
local function getRainbowColor(t)
    local r = math.sin(t) * 127 + 128
    local g = math.sin(t + 2) * 127 + 128
    local b = math.sin(t + 4) * 127 + 128
    return Color3.fromRGB(r, g, b)
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Rainbow efekt aktif mi?
local rainbowEnabled = false

-- Buton için GUI oluşturma
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RainbowToggleGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Position = UDim2.new(0.5, -230, 1, -50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "Rainbow: Kapalı"
ToggleButton.Parent = ScreenGui
ToggleButton.AutoButtonColor = true
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextScaled = true
ToggleButton.BorderSizePixel = 0
ToggleButton.BackgroundTransparency = 0.3
ToggleButton.Active = true
ToggleButton.Selectable = true
ToggleButton.Modal = false
ToggleButton.ZIndex = 10

ToggleButton.MouseButton1Click:Connect(function()
    rainbowEnabled = not rainbowEnabled
    if rainbowEnabled then
        ToggleButton.Text = "Rainbow: Açık"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    else
        ToggleButton.Text = "Rainbow: Kapalı"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        -- Silah renklerini varsayılan yap
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and (part.Name:lower():find("gun") or part.Name:lower():find("weapon") or part.Name:lower():find("handle")) then
                    part.Color = Color3.new(1,1,1) -- Beyaz veya istediğin renk
                    part.Material = Enum.Material.Plastic
                end
            end
        end
        for _, vm in pairs(Camera:GetChildren()) do
            for _, part in pairs(vm:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = Color3.new(1,1,1)
                    part.Material = Enum.Material.Plastic
                end
            end
        end
    end
end)

-- RenderStepped bağlantısı
RunService.RenderStepped:Connect(function()
    if not rainbowEnabled then return end

    local t = tick()

    -- Karakter içindeki silah parçaları
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name:lower():find("gun") or part.Name:lower():find("weapon") or part.Name:lower():find("handle")) then
                part.Color = getRainbowColor(t)
                part.Material = Enum.Material.Neon
            end
        end
    end

    -- Kamera altındaki Viewmodel silah parçaları (FPS görünüm)
    for _, vm in pairs(Camera:GetChildren()) do
        for _, part in pairs(vm:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = getRainbowColor(t)
                part.Material = Enum.Material.Neon
            end
        end
    end
end)

--// ESP Ayarları
local ESPSettings = {
    Box_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Color = Color3.fromRGB(255, 255, 255),
    Health_Color = Color3.fromRGB(0, 255, 0),
    Box_Thickness = 2,
    Team_Check = false,
    Team_Color = false,
    Autothickness = true,
    Enabled = true -- ESP aç/kapa için eklendi
}

--// Aimbot Ayarları
local AimbotSettings = {
    Enabled = false,
    LockPart = "Head",
    AimRadius = math.huge,
    Sensitivity = 1.0,
    FOVCircleColor = Color3.fromRGB(255, 100, 100)
}

--// Servisler
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Rainbow fonksiyonu
local function Rainbow(objList, delay)
    coroutine.wrap(function()
        while true do
            for hue = 0, 1, 0.02 do
                for _, v in pairs(objList) do
                    if v then
                        v.Color = Color3.fromHSV(hue, 1, 1)
                    end
                end
                task.wait(delay or 0.03)
            end
        end
    end)()
end

--// ESP çizim fonksiyonları
local function NewLine(color, thickness)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function Vis(lib, state)
    if not ESPSettings.Enabled then
        state = false
    end
    for _, v in pairs(lib) do
        if v then v.Visible = state end
    end
end

--// ESP Ana Fonksiyonu
local function Main(plr)
    repeat task.wait() until plr.Character and plr.Character:FindFirstChild("Humanoid")

    local Library = {
        TL1 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        TL2 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        TR1 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        TR2 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        BL1 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        BL2 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        BR1 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        BR2 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        Tracer = NewLine(ESPSettings.Tracer_Color, 2),
        HealthBar = NewLine(ESPSettings.Health_Color, 2)
    }

    Rainbow({Library.Tracer}, 0.02)
    Rainbow({Library.TL1, Library.TL2, Library.TR1, Library.TR2, Library.BL1, Library.BL2, Library.BR1, Library.BR2}, 0.03)

    local SkeletonLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/emirhankeles1/Darkness/refs/heads/main/%C4%B0skelet.lua"))()
    local skeleton = SkeletonLibrary:NewSkeleton(plr, true, ESPSettings.Box_Color, 1, 2, true)

    local dummyPart = Instance.new("Part", Workspace)
    dummyPart.Transparency = 1
    dummyPart.Anchored = true
    dummyPart.CanCollide = false
    dummyPart.Size = Vector3.new(1, 1, 1)

    local function SetSkeletonVisible(state)
        if skeleton and skeleton.SetVisible then
            skeleton:SetVisible(state)
        elseif skeleton then
            for _, part in pairs(skeleton) do
                pcall(function() if part and typeof(part) == "table" or typeof(part) == "Instance" then part.Visible = state end end)
            end
        end
    end

    local function Update()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local root = char.HumanoidRootPart
                local _, onscreen = Camera:WorldToViewportPoint(root.Position)
                if onscreen then
                    dummyPart.Size = Vector3.new(root.Size.X, root.Size.Y * 1.5, root.Size.Z)
                    dummyPart.CFrame = CFrame.new(root.Position, Camera.CFrame.Position)

                    local szX, szY = dummyPart.Size.X, dummyPart.Size.Y
                    local TL = Camera:WorldToViewportPoint((dummyPart.CFrame * CFrame.new(szX, szY, 0)).Position)
                    local TR = Camera:WorldToViewportPoint((dummyPart.CFrame * CFrame.new(-szX, szY, 0)).Position)
                    local BL = Camera:WorldToViewportPoint((dummyPart.CFrame * CFrame.new(szX, -szY, 0)).Position)
                    local BR = Camera:WorldToViewportPoint((dummyPart.CFrame * CFrame.new(-szX, -szY, 0)).Position)

                    local dist = (Camera.CFrame.Position - root.Position).Magnitude
                    local offset = math.clamp(1 / dist * 750, 2, 300)

                    Library.TL1.From = Vector2.new(TL.X, TL.Y)
                    Library.TL1.To = Vector2.new(TL.X + offset, TL.Y)
                    Library.TL2.From = Vector2.new(TL.X, TL.Y)
                    Library.TL2.To = Vector2.new(TL.X, TL.Y + offset)
                    Library.TR1.From = Vector2.new(TR.X, TR.Y)
                    Library.TR1.To = Vector2.new(TR.X - offset, TR.Y)
                    Library.TR2.From = Vector2.new(TR.X, TR.Y)
                    Library.TR2.To = Vector2.new(TR.X, TR.Y + offset)
                    Library.BL1.From = Vector2.new(BL.X, BL.Y)
                    Library.BL1.To = Vector2.new(BL.X + offset, BL.Y)
                    Library.BL2.From = Vector2.new(BL.X, BL.Y)
                    Library.BL2.To = Vector2.new(BL.X, BL.Y - offset)
                    Library.BR1.From = Vector2.new(BR.X, BR.Y)
                    Library.BR1.To = Vector2.new(BR.X - offset, BR.Y)
                    Library.BR2.From = Vector2.new(BR.X, BR.Y)
                    Library.BR2.To = Vector2.new(BR.X, BR.Y - offset)

                    local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0))
                    Library.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Library.Tracer.To = Vector2.new(bottomPos.X, bottomPos.Y)

                    local hp = char.Humanoid.Health / char.Humanoid.MaxHealth
                    local barHeight = math.clamp(offset * 5, 30, 80)
                    Library.HealthBar.From = Vector2.new(TL.X - 5, BL.Y)
                    Library.HealthBar.To = Vector2.new(TL.X - 5, BL.Y - (barHeight * hp))

                    local t = ESPSettings.Autothickness and math.clamp(1 / dist * 100, 1, 4) or ESPSettings.Box_Thickness
                    for _, l in pairs(Library) do
                        if l then l.Thickness = t end
                    end

                    Vis(Library, ESPSettings.Enabled)
                    SetSkeletonVisible(ESPSettings.Enabled)
                else
                    Vis(Library, false)
                    SetSkeletonVisible(false)
                end
            else
                Vis(Library, false)
                SetSkeletonVisible(false)
                if not Players:FindFirstChild(plr.Name) then
                    for _, v in pairs(Library) do if v then v:Remove() end end
                    dummyPart:Destroy()
                    conn:Disconnect()
                end
            end
        end)
    end

    Update()
end

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then coroutine.wrap(Main)(plr) end
end
Players.PlayerAdded:Connect(function(plr) coroutine.wrap(Main)(plr) end)

--// Aimbot Fonksiyonları
local function IsEnemy(player)
    if not player.Character or not LocalPlayer.Character then return false end
    return player.TeamColor ~= LocalPlayer.TeamColor and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0
end

local function IsVisible(part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction, rayParams)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

local function GetClosestEnemy()
    local closest, shortest = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and player.Character and player.Character:FindFirstChild(AimbotSettings.LockPart) then
            local part = player.Character[AimbotSettings.LockPart]
            local dist = (part.Position - Camera.CFrame.Position).Magnitude
            if dist < shortest and IsVisible(part) then
                closest = player
                shortest = dist
            end
        end
    end
    return closest
end

local function AimAtTarget(target)
    if not target or not target.Character then return end
    local part = target.Character[AimbotSettings.LockPart]
    if not part then return end
    local targetPos = part.Position
    local cameraPos = Camera.CFrame.Position
    local newCFrame = CFrame.new(cameraPos, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, AimbotSettings.Sensitivity)
end

--// Mobil buton GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "AimbotToggleGui"

-- Aimbot Butonu
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Position = UDim2.new(0.5, 30, 1, -50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Text = "Aimbot is off"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 20
ToggleButton.AutoButtonColor = true

ToggleButton.MouseButton1Click:Connect(function()
    AimbotSettings.Enabled = not AimbotSettings.Enabled
    ToggleButton.Text = AimbotSettings.Enabled and "Aimbot is on" or "Aimbot is off"
end)

-- ESP Butonu
local ESPToggleButton = Instance.new("TextButton", ScreenGui)
ESPToggleButton.Size = UDim2.new(0, 120, 0, 40)
ESPToggleButton.Position = UDim2.new(0.5, -100, 1, -50)
ESPToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ESPToggleButton.TextColor3 = Color3.new(1, 1, 1)
ESPToggleButton.Text = "ESP is on"
ESPToggleButton.Font = Enum.Font.SourceSansBold
ESPToggleButton.TextSize = 20
ESPToggleButton.AutoButtonColor = true

ESPToggleButton.MouseButton1Click:Connect(function()
    ESPSettings.Enabled = not ESPSettings.Enabled
    ESPToggleButton.Text = ESPSettings.Enabled and "ESP is on" or "ESP is off"
end)

--// Aimbot çalıştırıcı
RunService.RenderStepped:Connect(function()
    if AimbotSettings.Enabled then
        local target = GetClosestEnemy()
        if target then
            AimAtTarget(target)
        end
    end
end)
