-- Ссылка на Библиотеку
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Tuturial_UI_Library/main/UI_Template_1"))()

-- ============ ПЕРЕМЕННЫЕ ============
local isSpeed = false
local OriginalSpeed = 16 -- Настоящая стандартная скорость (НЕ МЕНЯЕТСЯ)
local SliderSpeed = 16
local KeybindsEnabled = false
local NoclipEnabled = false
local InfiniteJumpEnabled = false
local NoclipConnection = nil

-- Получаем настоящую стандартную скорость один раз
local player = game.Players.LocalPlayer
if player.Character and player.Character:FindFirstChild("Humanoid") then
    OriginalSpeed = player.Character.Humanoid.WalkSpeed
    SliderSpeed = OriginalSpeed
end

-- Отслеживаем появление персонажа (НО НЕ МЕНЯЕМ OriginalSpeed)
player.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    if character:FindFirstChild("Humanoid") then
        if isSpeed then
            character.Humanoid.WalkSpeed = SliderSpeed
        else
            character.Humanoid.WalkSpeed = OriginalSpeed
        end
    end
    
    -- Восстанавливаем noclip после перерождения
    if NoclipEnabled then
        task.wait(0.1)
        local playerChar = player.Character
        if playerChar then
            for _, part in ipairs(playerChar:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- FIND PLAYER 
local function FindPlayerCharacter(playerName)
    if not playerName or playerName == "" then return nil end
    
    local searchName = playerName:lower()
    
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name:lower() == searchName and child:FindFirstChild("HumanoidRootPart") then
            return child
        end
    end
    
    local targetPlayer = game.Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return targetPlayer.Character
    end
    
    local allObjects = game:GetDescendants()
    for _, obj in ipairs(allObjects) do
        if obj.Name:lower() == searchName and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") then
            return obj
        end
    end
    
    return nil
end

-- ============ ФУНКЦИЯ NOCLIP ============
local function ToggleNoclip(state)
    NoclipEnabled = state
    
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    if state then
        NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
            local playerChar = player.Character
            if playerChar then
                for _, part in ipairs(playerChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        print("Noclip ON")
    else
        local playerChar = player.Character
        if playerChar then
            for _, part in ipairs(playerChar:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
        print("Noclip OFF")
    end
end

-- ============ ФУНКЦИЯ INFINITE JUMP ============
local function ToggleInfiniteJump(state)
    InfiniteJumpEnabled = state
    print("Infinite Jump " .. (state and "ON" or "OFF"))
end

-- Обработка бесконечного прыжка
local UserInputService = game:GetService("UserInputService")
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local playerChar = player.Character
        local humanoid = playerChar and playerChar:FindFirstChild("Humanoid")
        if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ============ UI ============
local Window = Library.CreateLib("UNH 0.1-beta", "RJTheme3")

local Tab = Window:NewTab("Player")
local TabTP = Window:NewTab("Teleport")
local TabESP = Window:NewTab("ESP")
local TabBIND = Window:NewTab("Bind")


local TabINFO = Window:NewTab("Info")

local Section = Tab:NewSection("Movement")
local SectionTP = TabTP:NewSection("Teleport Section")
local SectionESP = TabESP:NewSection("ESP Section")
local SectionBIND = TabBIND:NewSection("Keybinds")




local SectionInfo = TabINFO:NewSection("Script Information:")

-- Цветная метка через HTML теги
SectionInfo:NewLabel("<font color='#86d9ab'>Current version: 0.1-beta</font>")

SectionInfo:NewLabel("<font color='#83c1cc'>Author: UnNoZere? </font>")


--SectionInfo:NewLabel("<font color='#4488ff'>💬 Discord: discord.gg/xxx</font>")
-- ============ PLAYER TAB ============

-- Переключатель скорости
Section:NewToggle("Toggle Walk Speed", "Enable/disable custom speed", function(state)
    isSpeed = state
    local playerChar = game.Players.LocalPlayer.Character
    if playerChar and playerChar:FindFirstChild("Humanoid") then
        if state then
            playerChar.Humanoid.WalkSpeed = SliderSpeed
            print("Speed mode ON, speed: " .. SliderSpeed)
        else
            playerChar.Humanoid.WalkSpeed = OriginalSpeed
            print("Speed reset to: " .. OriginalSpeed)
        end
    end
end)

-- Слайдер скорости
Section:NewSlider("Walk Speed", "Change walk speed", 500, 0, function(s)
    SliderSpeed = s
    if isSpeed then
        local playerChar = game.Players.LocalPlayer.Character
        if playerChar and playerChar:FindFirstChild("Humanoid") then
            playerChar.Humanoid.WalkSpeed = s
        end
    else
        print("Toggle speed mode ON first!")
    end
end)

-- Слайдер гравитации
Section:NewSlider("Gravity", "Change game gravity", 500, 0, function(s)
    game.Workspace.Gravity = s
    print("Gravity set to: " .. s)
end)

-- Кнопка сброса скорости
Section:NewButton("Reset Speed", "Reset walk speed to default", function()
    local playerChar = game.Players.LocalPlayer.Character
    if playerChar and playerChar:FindFirstChild("Humanoid") then
        playerChar.Humanoid.WalkSpeed = OriginalSpeed
        isSpeed = false
        SliderSpeed = OriginalSpeed
        print("Speed reset to: " .. OriginalSpeed)
    end
end)

-- Infinite Jump тоггл
Section:NewToggle("Infinite Jump", "Jump infinitely", function(state)
    ToggleInfiniteJump(state)
end)






-- Autokill
local Section = Tab:NewSection("Model Functions")

-- Noclip тоггл
Section:NewToggle("Noclip", "Walk through walls", function(state)
    ToggleNoclip(state)
end)

Section:NewButton("Auto Kill", "Kill yourself (respawn)", function()
    local player = game.Players.LocalPlayer
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
            print("Вы убили себя!")
        end
    end
end)

-- ============ TELEPORT TAB ============

SectionTP:NewTextBox("Teleport to: ", "Enter player name", function(txt)
    local target = nil
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player.Name:lower() == txt:lower() then
            target = player
            break
        end
    end
    
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        print("Игрок не найден!")
        return
    end
    
    local player = game.Players.LocalPlayer
    local targetPos = target.Character.HumanoidRootPart.CFrame
    
    for i = 1, 20 do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = targetPos
            task.wait(0.05)
        end
    end
    
    print("Телепортирован к " .. target.Name)
end)

SectionTP:NewButton("Teleport to Center", "Go to map center", function()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        print("Teleported to center")
    end
end)

-- ============ BIND TAB ============

SectionBIND:NewToggle("Use Keybinds", "Enable/disable all keybinds", function(state)
    KeybindsEnabled = state
    if state then
        print("Keybinds ENABLED")
    else
        print("Keybinds DISABLED")
    end
end)
local SectionBIND = TabBIND:NewSection("Movement")
SectionBIND:NewKeybind("Toggle walk speed", "Toggle custom speed", Enum.KeyCode.None, function()
    if not KeybindsEnabled then return end
    
    isSpeed = not isSpeed  
    local playerChar = game.Players.LocalPlayer.Character
    
    if playerChar and playerChar:FindFirstChild("Humanoid") then
        if isSpeed then
            playerChar.Humanoid.WalkSpeed = SliderSpeed
            print("Speed mode ON, speed: " .. SliderSpeed)
        else
            playerChar.Humanoid.WalkSpeed = OriginalSpeed
            print("Speed reset to: " .. OriginalSpeed)
        end
    end
end)





-- Бинд для Infinite Jump
SectionBIND:NewKeybind("Toggle Infinite Jump", "Enable/disable infinite jump", Enum.KeyCode.None, function()
    if not KeybindsEnabled then return end
    ToggleInfiniteJump(not InfiniteJumpEnabled)
end)
local SectionBIND = TabBIND:NewSection("Model Functions")
-- Бинд для Noclip
SectionBIND:NewKeybind("Toggle Noclip", "Enable/disable noclip", Enum.KeyCode.None, function()
    if not KeybindsEnabled then return end
    ToggleNoclip(not NoclipEnabled)
end)

local SectionBIND = TabBIND:NewSection("Teleport")
SectionBIND:NewKeybind("Teleport to Center", "Teleport to center", Enum.KeyCode.None, function()
    if not KeybindsEnabled then return end
    
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        print("Teleported to center")
    end
end)
-- ============ ESP TAB ============

local ESPEnabled = false
local ESPHighlights = {}

local function AddHighlight(player)
    if not player.Character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = player.Character
    
    ESPHighlights[player.Name] = highlight
end

local function RemoveHighlight(player)
    if ESPHighlights[player.Name] then
        ESPHighlights[player.Name]:Destroy()
        ESPHighlights[player.Name] = nil
    end
end

local function ToggleESP(state)
    ESPEnabled = state
    local localPlayer = game.Players.LocalPlayer
    
    if state then
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= localPlayer then
                if player.Character then
                    AddHighlight(player)
                end
                
                player.CharacterAdded:Connect(function(char)
                    if ESPEnabled and player ~= localPlayer then
                        task.wait(0.5)
                        AddHighlight(player)
                    end
                end)
            end
        end
    else
        for _, highlight in pairs(ESPHighlights) do
            highlight:Destroy()
        end
        ESPHighlights = {}
    end
end

game.Players.PlayerRemoving:Connect(function(player)
    if ESPHighlights[player.Name] then
        ESPHighlights[player.Name]:Destroy()
        ESPHighlights[player.Name] = nil
    end
end)

SectionESP:NewToggle("ESP Highlight", "Highlight players with outline", function(state)
    ToggleESP(state)
end)

local colors = {"Red", "Blue", "Green", "Yellow"}
local colorIndex = 1

SectionESP:NewButton("Change Highlight Color", "Cycle through colors", function()
    colorIndex = colorIndex % #colors + 1
    local color = colors[colorIndex]
    
    for _, highlight in pairs(ESPHighlights) do
        if color == "Red" then
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
        elseif color == "Blue" then
            highlight.FillColor = Color3.fromRGB(0, 0, 255)
        elseif color == "Green" then
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
        elseif color == "Yellow" then
            highlight.FillColor = Color3.fromRGB(255, 255, 0)
        end
    end
    print("ESP color changed to: " .. color)
end)

-- ============ ОБНОВЛЕНИЕ СКОРОСТИ (Heartbeat) ============
local RunService = game:GetService("RunService")
local lastSpeedCheck = 0

RunService.Heartbeat:Connect(function(deltaTime)
    local playerChar = game.Players.LocalPlayer.Character
    if not playerChar then return end
    
    local humanoid = playerChar:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Обновляем скорость реже (раз в 0.2 секунды)
    lastSpeedCheck = lastSpeedCheck + deltaTime
    if lastSpeedCheck < 0.2 then return end
    lastSpeedCheck = 0
    
    if isSpeed then
        if humanoid.WalkSpeed ~= SliderSpeed then
            humanoid.WalkSpeed = SliderSpeed
        end
    else
        if humanoid.WalkSpeed ~= OriginalSpeed then
            humanoid.WalkSpeed = OriginalSpeed
        end
    end
end)

print("UNH 0.1-beta loaded!")