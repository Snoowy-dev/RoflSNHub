--[[
    NuanceHUB v5.0 [WIND UI EDITION]
    + WindUI Integration
    + Categories: Combat, Visuals, Themes
    + Custom HUD with Ping Tracker
    + Mobile UI Toggle & Color Pickers
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local VIM = game:GetService("VirtualInputManager")
local Mouse = LocalPlayer:GetMouse()

-- --- [ НАСТРОЙКИ ] ---
local Settings = {
    Aimbot = false,
    Triggerbot = false,
    AntiAim = false,
    Smoothness = 0.5,
    FOV = 250,

    Chams = false,
    NameTags = false,
    Tracers = false,
    VisualsColor = Color3.fromRGB(140, 60, 255),

    HudColor = Color3.fromRGB(140, 60, 255),
    MenuKey = Enum.KeyCode.B
}

local ESP_Objects = {}

-- --- [ СОЗДАНИЕ HUD (WATERMARK) И MOBILE BUTTON ] ---
local CoreGui = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- HUD
local HudGui = Instance.new("ScreenGui", CoreGui)
HudGui.Name = "NuanceHUD_Watermark"
HudGui.IgnoreGuiInset = true

local HudFrame = Instance.new("Frame", HudGui)
HudFrame.Size = UDim2.new(0, 180, 0, 30)
HudFrame.Position = UDim2.new(0, 20, 0, 20)
HudFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
HudFrame.BorderSizePixel = 1
HudFrame.BorderColor3 = Settings.HudColor

local HudText = Instance.new("TextLabel", HudFrame)
HudText.Size = UDim2.new(1, 0, 1, 0)
HudText.BackgroundTransparency = 1
HudText.Font = Enum.Font.Code
HudText.TextSize = 14
HudText.TextColor3 = Settings.HudColor
HudText.Text = "NuanceHUB | Ping: -- ms"

task.spawn(function()
    while task.wait(1) do
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        HudText.Text = "NuanceHUB | Ping: " .. ping .. "ms"
        HudFrame.BorderColor3 = Settings.HudColor
        HudText.TextColor3 = Settings.HudColor
    end
end)

-- Mobile Toggle Button
local MobileGui = Instance.new("ScreenGui", CoreGui)
MobileGui.Name = "NuanceHUB_MobileBtn"

local MobBtn = Instance.new("TextButton", MobileGui)
MobBtn.Size = UDim2.new(0, 45, 0, 45)
MobBtn.Position = UDim2.new(0.5, 0, 0, 20)
MobBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MobBtn.Text = "HUB"
MobBtn.TextColor3 = Color3.new(1,1,1)
MobBtn.Font = Enum.Font.Code
MobBtn.TextSize = 12
MobBtn.Active = true
MobBtn.Draggable = true -- Можно таскать по экрану
Instance.new("UICorner", MobBtn).CornerRadius = UDim.new(1, 0)

MobBtn.MouseButton1Click:Connect(function()
    -- Имитируем нажатие кнопки B для мобилок, чтобы открыть/закрыть WindUI
    VIM:SendKeyEvent(true, Settings.MenuKey, false, game)
    VIM:SendKeyEvent(false, Settings.MenuKey, false, game)
end)

-- --- [ ЗАГРУЗКА WIND UI ] ---
-- Загружаем саму библиотеку (стандартный сурс Footagesus)
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "NuanceHUB v5.0",
    Icon = "rbxassetid://10618928818", 
    Author = "Nuance",
    Folder = "NuanceHUB",
    Size = UDim2.new(0, 500, 0, 350),
    Transparent = true,
    Theme = "Dark",
    KeySystem = false
})

-- Нотификация при старте
Window:Notify({
    Title = "Injection Success",
    Content = "GUI BINDED ON B",
    Duration = 5,
})

-- Создаем категории (Табы)
local CombatTab = Window:Tab({ Title = "Combat", Icon = "swords" })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local ThemesTab = Window:Tab({ Title = "Themes", Icon = "palette" })

-- --- [ КАТЕГОРИЯ: COMBAT ] ---
CombatTab:Toggle({
    Title = "Aimbot (Hold RMB)",
    Default = false,
    Callback = function(state) Settings.Aimbot = state end
})

CombatTab:Slider({
    Title = "Aim Smoothness",
    Min = 0.01,
    Max = 0.95,
    Default = 0.5,
    Step = 0.01,
    Callback = function(value) Settings.Smoothness = value end
})

CombatTab:Toggle({
    Title = "Triggerbot",
    Default = false,
    Callback = function(state) Settings.Triggerbot = state end
})

CombatTab:Toggle({
    Title = "Anti-Aim (Spin Bot)",
    Default = false,
    Callback = function(state) Settings.AntiAim = state end
})

-- --- [ КАТЕГОРИЯ: VISUALS ] ---
VisualsTab:Toggle({
    Title = "Chams (ESP Fill)",
    Default = false,
    Callback = function(state) Settings.Chams = state end
})

VisualsTab:Toggle({
    Title = "Name Tags",
    Default = false,
    Callback = function(state) Settings.NameTags = state end
})

VisualsTab:Toggle({
    Title = "Tracers",
    Default = false,
    Callback = function(state) Settings.Tracers = state end
})

VisualsTab:Colorpicker({
    Title = "Visuals Accent Color",
    Default = Settings.VisualsColor,
    Callback = function(color) Settings.VisualsColor = color end
})

-- --- [ КАТЕГОРИЯ: THEMES ] ---
ThemesTab:Colorpicker({
    Title = "HUD (Watermark) Color",
    Default = Settings.HudColor,
    Callback = function(color) Settings.HudColor = color end
})

-- --- [ ЛОГИКА ЧИТА ] ---

RunService.RenderStepped:Connect(function()
    -- ВИЗУАЛЫ
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not ESP_Objects[p] then 
                ESP_Objects[p] = { T = Drawing.new("Line"), N = Drawing.new("Text") } 
                ESP_Objects[p].N.Color = Color3.new(1,1,1)
                ESP_Objects[p].N.Center = true
                ESP_Objects[p].N.Outline = true
            end
            
            local esp = ESP_Objects[p]
            local char = p.Character
            
            -- Динамическое обновление цвета (берется из ColorPicker)
            esp.T.Color = Settings.VisualsColor

            if char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local hrp = char.HumanoidRootPart
                local pos, onS = Camera:WorldToViewportPoint(hrp.Position)
                
                -- Линии (Трейсеры)
                esp.T.Visible = Settings.Tracers and onS
                if esp.T.Visible then 
                    esp.T.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    esp.T.To = Vector2.new(pos.X, pos.Y) 
                end
                
                -- Имена
                esp.N.Visible = Settings.NameTags and onS
                if esp.N.Visible then 
                    esp.N.Position = Vector2.new(pos.X, pos.Y - 30)
                    esp.N.Text = p.Name .. " [" .. math.floor(char.Humanoid.Health) .. "]"
                end
                
                -- Подсветка (Chams)
                local ch = char:FindFirstChild("CyberH")
                if Settings.Chams then
                    if not ch then ch = Instance.new("Highlight", char); ch.Name = "CyberH" end
                    ch.FillColor = Settings.VisualsColor -- Цвет из ColorPicker
                    ch.Enabled = true
                elseif ch then 
                    ch.Enabled = false 
                end
            else
                esp.T.Visible = false; esp.N.Visible = false
            end
        end
    end

    -- АИМБОТ
    if Settings.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = nil
        local dist = Settings.FOV
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                local p3d, onS = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onS then
                    local m = (Vector2.new(p3d.X, p3d.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if m < dist then dist = m; target = p.Character.Head end
                end
            end
        end
        if target then 
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 1 - Settings.Smoothness) 
        end
    end
end)

RunService.Heartbeat:Connect(function()
    -- ANTI-AIM (SPIN BOT)
    if Settings.AntiAim and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(60), 0)
    end

    -- TRIGGERBOT
    if Settings.Triggerbot and Mouse.Target then
        local p = Players:GetPlayerFromCharacter(Mouse.Target.Parent) or Players:GetPlayerFromCharacter(Mouse.Target.Parent.Parent)
        if p and p ~= LocalPlayer and p.Character.Humanoid.Health > 0 then 
            if mouse1click then mouse1click() end 
        end
    end
end)

-- Очистка кэша визуалов при выходе игроков
Players.PlayerRemoving:Connect(function(player)
    if ESP_Objects[player] then
        ESP_Objects[player].T:Remove()
        ESP_Objects[player].N:Remove()
        ESP_Objects[player] = nil
    end
end)

print("NuanceHUB v5.0 (WindUI Edition) Injected Successfully!")
