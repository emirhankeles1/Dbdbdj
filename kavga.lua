-- Tüm servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local PlayerGui = player:WaitForChild("PlayerGui")

-- GLOBAL Değişken
local detectActive = false
_G_AutoBlockActive = false

-- GUI: Dark Hub
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "MainGUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 220, 0, 160)
frame.Position = UDim2.new(0.5, -110, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Dark Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.new(1, 1, 1)

-- Rainbow başlık animasyonu
local rainbowTime = 0
RunService.RenderStepped:Connect(function(dt)
    rainbowTime += dt
    title.TextColor3 = Color3.fromHSV((rainbowTime % 5) / 5, 1, 1)
end)

-- Sürükleme sistemi
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    local newX = math.clamp(startPos.X.Offset + delta.X, 0, camera.ViewportSize.X - frame.AbsoluteSize.X)
    local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, camera.ViewportSize.Y - frame.AbsoluteSize.Y)
    frame.Position = UDim2.new(0, newX, 0, newY)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        dragInput = input
    end
end)
frame.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Buton Oluşturucu
local function createButton(text, position)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 17
    btn.BorderSizePixel = 0
    btn.Text = text
    return btn
end

local lockBtn = createButton("En Yakına Kilitlen", UDim2.new(0, 10, 0, 35))
local comboBtn = createButton("Oto Kombo (Yakın)", UDim2.new(0, 10, 0, 85))

-- LOCK ve ESP
local locked = false
local lockedTarget = nil
local espBox = nil

local function getClosestPlayer(maxDistance)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local closest, shortest = nil, maxDistance or math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            if dist <= shortest then
                closest = plr
                shortest = dist
            end
        end
    end
    return closest
end

local function getRainbowColor(t)
    return Color3.fromHSV((t % 5) / 5, 1, 1)
end

local function createESPBox(part)
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 2)
    box.Transparency = 0.3
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = part
    box.Parent = part
    box.Name = "ESPBox"
    return box
end

local function removeESPBox()
    if espBox then
        espBox:Destroy()
        espBox = nil
    end
end

RunService.RenderStepped:Connect(function(dt)
    if locked and lockedTarget then
        local myChar = player.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            local myHRP = myChar.HumanoidRootPart
            if lockedTarget.Character and lockedTarget.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = lockedTarget.Character.HumanoidRootPart
                myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(targetHRP.Position.X, myHRP.Position.Y, targetHRP.Position.Z))
                rainbowTime += dt
                if espBox then espBox.Color3 = getRainbowColor(rainbowTime) end
            else
                locked = false
                lockedTarget = nil
                removeESPBox()
                lockBtn.Text = "En Yakına Kilitlen"
            end
        end
    end
end)

lockBtn.MouseButton1Click:Connect(function()
    if locked then
        locked = false
        lockedTarget = nil
        removeESPBox()
        lockBtn.Text = "En Yakına Kilitlen"
    else
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            locked = true
            lockedTarget = target
            espBox = createESPBox(target.Character.HumanoidRootPart)
            lockBtn.Text = "Kilitli: " .. target.Name
        else
            lockBtn.Text = "Hedef Yok"
        end
    end
end)

-- KOMBO (otomatik kombo ve auto block kontrolü)
local comboRunning = false
local function executeCombo()
    local Backpack = player:WaitForChild("Backpack")
    local Communicate = player.Character:WaitForChild("Communicate")
    
    -- Kombo başlarken Auto Block kapatılır
    local prevAutoBlock = _G_AutoBlockActive
    _G_AutoBlockActive = false
    
    local function fireMove(toolName, waitTime)
        local tool = Backpack:FindFirstChild(toolName)
        if tool then
            Communicate:FireServer({Tool = tool, Goal = "Console Move"})
        end
        task.wait(waitTime)
    end
    
    fireMove("Head First", 4)
    fireMove("Bullet Barrage", 4)
    fireMove("Whirlwind Drop", 2)
    fireMove("Vanishing Kick", 1)
    
    -- Kombo bittikten sonra Auto Block önceki haline döner
    task.delay(0.5, function()
        _G_AutoBlockActive = prevAutoBlock
    end)
end

comboBtn.MouseButton1Click:Connect(function()
    if comboRunning then
        comboRunning = false
        comboBtn.Text = "Oto Kombo (Yakın)"
    else
        comboRunning = true
        comboBtn.Text = "Kombo Açık"
        task.spawn(function()
            while comboRunning do
                local target = getClosestPlayer(3)
                if target then
                    executeCombo()
                    task.wait(17)
                else
                    task.wait(0.5)
                end
            end
        end)
    end
end)

-- Aşağıdaki kısım animasyon tespiti ve Auto Block sistemi

local function addCorner(inst, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = inst
end

-- Auto Block GUI ve ayarları

local detectGui = Instance.new("ScreenGui", PlayerGui)
detectGui.Name = "DetectAnimGui"
detectGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 150)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true
addCorner(mainFrame)
mainFrame.Parent = detectGui

local toggleDetect = Instance.new("TextButton", mainFrame)
toggleDetect.Size = UDim2.new(0.7, 0, 0, 30)
toggleDetect.Position = UDim2.new(0, 0, 0, 0)
toggleDetect.Text = "Auto Block: OFF"
toggleDetect.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleDetect.TextColor3 = Color3.new(1, 1, 1)
toggleDetect.Font = Enum.Font.SourceSansBold
toggleDetect.TextScaled = true
addCorner(toggleDetect)

local openBtn = Instance.new("TextButton", mainFrame)
openBtn.Size = UDim2.new(0.3, 0, 0, 30)
openBtn.Position = UDim2.new(0.7, 0, 0, 0)
openBtn.Text = ">"
openBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Font = Enum.Font.SourceSansBold
openBtn.TextScaled = true
addCorner(openBtn)

local settingFrame = Instance.new("Frame", mainFrame)
settingFrame.Size = UDim2.new(1, 0, 0, 140)
settingFrame.Position = UDim2.new(0, 0, 0, 30)
settingFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
settingFrame.Visible = false
addCorner(settingFrame)
settingFrame.Parent = mainFrame

openBtn.MouseButton1Click:Connect(function()
    settingFrame.Visible = not settingFrame.Visible
    openBtn.Text = settingFrame.Visible and "<" or ">"
end)

local bubble = Instance.new("TextButton", detectGui)
bubble.Size = UDim2.new(0, 32, 0, 32)
bubble.Position = UDim2.new(0, 5, 0.5, -80)
bubble.Text = "🗿"
bubble.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
bubble.TextColor3 = Color3.new(1, 1, 1)
bubble.Font = Enum.Font.SourceSansBold
bubble.TextScaled = true
bubble.Active = true
bubble.Draggable = true
addCorner(bubble)

bubble.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Ayar kutuları oluşturma fonksiyonu
local function makeBox(size, pos, placeholder)
    local box = Instance.new("TextBox")
    box.Size = size
    box.Position = pos
    box.PlaceholderText = placeholder
    box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.SourceSans
    box.TextScaled = true
    addCorner(box)
    return box
end

local normalBox = makeBox(UDim2.new(0.45, 0, 0, 25), UDim2.new(0.05, 0, 0, 0), "M1")
local specialBox = makeBox(UDim2.new(0.45, 0, 0, 25), UDim2.new(0.5, 0, 0, 0), "Dash Q")
local skillBox = makeBox(UDim2.new(0.45, 0, 0, 25), UDim2.new(0.05, 0, 0, 30), "Skill")
local skillDelayBox = makeBox(UDim2.new(0.45, 0, 0, 25), UDim2.new(0.5, 0, 0, 30), "Hold Skill")

normalBox.Parent = settingFrame
specialBox.Parent = settingFrame
skillBox.Parent = settingFrame
skillDelayBox.Parent = settingFrame

local normalRange, specialRange, skillRange = 30, 50, 50
local skillDelay = 1.2
skillDelayBox.Text = tostring(skillDelay)

normalBox.FocusLost:Connect(function()
    local v = tonumber(normalBox.Text)
    if v then normalRange = v end
end)
specialBox.FocusLost:Connect(function()
    local v = tonumber(specialBox.Text)
    if v then specialRange = v end
end)
skillBox.FocusLost:Connect(function()
    local v = tonumber(skillBox.Text)
    if v then skillRange = v end
end)
skillDelayBox.FocusLost:Connect(function()
    local v = tonumber(skillDelayBox.Text)
    if v and v > 0 then skillDelay = v end
end)

local function createSquareToggle(name, posY)
    local label = Instance.new("TextLabel", mainFrame)
    label.Text = name
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Position = UDim2.new(0.05, 0, 0, posY)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true

    local button = Instance.new("TextButton", mainFrame)
    button.Size = UDim2.new(0, 25, 0, 25)
    button.Position = UDim2.new(1, -30, 0, posY)
    button.Text = "OFF"
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextScaled = true
    addCorner(button)

    return button
end

local m1AfterBtn = createSquareToggle("M1 After Block", 80)
local m1CatchBtn = createSquareToggle("M1 Catch", 110)

local m1AfterEnabled = false
m1AfterBtn.MouseButton1Click:Connect(function()
    m1AfterEnabled = not m1AfterEnabled
    m1AfterBtn.Text = m1AfterEnabled and "ON" or "OFF"
end)

local m1CatchEnabled = false
m1CatchBtn.MouseButton1Click:Connect(function()
    m1CatchEnabled = not m1CatchEnabled
    m1CatchBtn.Text = m1CatchEnabled and "ON" or "OFF"
end)

local function fireRemote(goal, mobile)
    local args = {{
        Goal = goal,
        Key = (goal == "KeyPress" or goal == "KeyRelease") and Enum.KeyCode.F or nil,
        Mobile = mobile or nil
    }}
    player.Character:WaitForChild("Communicate"):FireServer(unpack(args))
end

local function doAfterBlock(hrp)
    if m1AfterEnabled and hrp and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = (hrp.Position - root.Position).Magnitude
            if dist <= 10 then
                fireRemote("LeftClick", true)
                task.delay(0.3, function()
                    local newDist = (hrp.Position - root.Position).Magnitude
                    if newDist <= 10 then
                        fireRemote("LeftClickRelease", true)
                    end
                end)
            end
        end
    end
end

local lastCatch = 0

local comboIDs = {10480793962, 10480796021}
local allIDs = {
    Saitama = {10469493270, 10469630950, 10469639222, 10469643643, special = 10479335397},
    Garou = {13532562418, 13532600125, 13532604085, 13294471966, special = 10479335397},
    Cyborg = {13491635433, 13296577783, 13295919399, 13295936866, special = 10479335397},
    Sonic = {13370310513, 13390230973, 13378751717, 13378708199, special = 13380255751},
    Metal = {14004222985, 13997092940, 14001963401, 14136436157, special = 13380255751},
    Blade = {15259161390, 15240216931, 15240176873, 15162694192, special = 13380255751},
    Tatsumaki = {16515503507, 16515520431, 16515448089, 16552234590, special = 10479335397},
    Dragon = {17889458563, 17889461810, 17889471098, 17889290569, special = 10479335397},
    Tech = {123005629431309, 100059874351664, 104895379416342, 134775406437626, special = 10479335397}
}

local skillIDs = {
    [10468665991] = true, [10466974800] = true, [10471336737] = true, [12510170988] = true,
    [12272894215] = true, [12296882427] = true, [12307656616] = true,
    [101588604872680] = true, [105442749844047] = true, [109617620932970] = true,
    [131820095363270] = true, [135289891173395] = true, [125955606488863] = true,
    [12534735382] = true, [12502664044] = true, [12509505723] = true, [12618271998] = true, [12684390285] = true,
    [13376869471] = true, [13294790250] = true, [13376962659] = true, [13501296372] = true, [13556985475] = true,
    [145162735010] = true, [14046756619] = true, [14299135500] = true, [14351441234] = true,
    [15290930205] = true, [15145462680] = true, [15295895753] = true, [15295336270] = true,
    [16139108718] = true, [16515850153] = true, [16431491215] = true, [16597322398] = true, [16597912086] = true,
    [17799224866] = true, [17838006839] = true, [17857788598] = true, [18179181663] = true,
    [113166426814229] = true, [116753755471636] = true, [116153572280464] = true, [114095570398448] = true, [77509627104305] = true
}

local function checkAnims()
    for _, playerCheck in pairs(Players:GetPlayers()) do
        if playerCheck ~= player and playerCheck.Character and playerCheck.Character.Parent == workspace:FindFirstChild("Live") then
            local char = playerCheck.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hum and myHRP then
                local dist = (hrp.Position - myHRP.Position).Magnitude
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then
                    local anims = {}
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        local id = tonumber(track.Animation.AnimationId:match("%d+"))
                        if id then anims[id] = true end
                    end

                    local comboCount = 0
                    for _, id in ipairs(comboIDs) do
                        if anims[id] then comboCount += 1 end
                    end

                    for _, group in pairs(allIDs) do
                        local normalHits, special = 0, anims[group.special]
                        for i = 1, 4 do
                            if anims[group[i]] then normalHits += 1 end
                        end

                        if comboCount == 2 and normalHits >= 2 and dist <= specialRange then
                            -- Kombo başladığında Auto Block kapat
                            detectActive = false
                            _G_AutoBlockActive = false
                            fireRemote("KeyPress")
                            task.wait(0.7)
                            fireRemote("KeyRelease")
                            -- Kombo bittikten sonra Auto Block tekrar açılır
                            task.delay(1, function()
                                detectActive = true
                                _G_AutoBlockActive = true
                            end)
                            break
                        elseif normalHits > 0 and dist <= normalRange then
                            fireRemote("KeyPress")
                            task.wait(0.15)
                            fireRemote("KeyRelease")
                            doAfterBlock(hrp)
                            break
                        elseif special and dist <= specialRange and not m1CatchEnabled then
                            fireRemote("KeyPress")
                            task.delay(1, function()
                                fireRemote("KeyRelease")
                            end)
                            break
                        end
                    end

                    for animId in pairs(anims) do
                        if skillIDs[animId] and dist <= skillRange then
                            fireRemote("KeyPress")
                            task.delay(skillDelay, function()
                                fireRemote("KeyRelease")
                            end)
                            break
                        end
                    end
                end
            end
        end
    end
end

local function checkM1Catch()
    if not m1CatchEnabled then return end

    for _, playerCheck in ipairs(Players:GetPlayers()) do
        if playerCheck ~= player and playerCheck.Character and playerCheck.Character.Parent == workspace:FindFirstChild("Live") then
            local char = playerCheck.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hum and myHRP then
                local dist1 = (hrp.Position - myHRP.Position).Magnitude
                if dist1 <= 30 then
                    local animator = hum:FindFirstChildOfClass("Animator")
                    if animator then
                        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                            local id = tonumber(track.Animation.AnimationId:match("%d+"))
                            if id == 10479335397 then
                                task.delay(0.1, function()
                                    local dist2 = (hrp.Position - myHRP.Position).Magnitude
                                    if dist2 < dist1 - 0.5 and tick() - lastCatch >= 5 then
                                        lastCatch = tick()
                                        fireRemote("LeftClick", true)
                                        task.delay(0.2, function()
                                            fireRemote("LeftClickRelease", true)
                                        end)
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                                        task.delay(1, function()
                                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
                                        end)
                                    end
                                end)
                                return
                            end
                        end
                    end
                end
            end
        end
    end
end

toggleDetect.MouseButton1Click:Connect(function()
    detectActive = not detectActive
    _G_AutoBlockActive = detectActive
    toggleDetect.Text = detectActive and "Auto Block: ON" or "Auto Block: OFF"
    toggleDetect.BackgroundColor3 = detectActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
end)

RunService.Heartbeat:Connect(function()
    if detectActive then
        pcall(checkAnims)
        pcall(checkM1Catch)
    end
end)