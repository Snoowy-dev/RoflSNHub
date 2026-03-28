--[[
    NuanceHUB v5.2 [GUI CONTENT & MOBILE FIX]
    + Added Sections (Fixes empty GUI issue)
    + Stabilized Mobile Toggle
    + Combat, Visuals, Themes Categories
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

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

-- --- [ HUD & MOBILE BUTTON ] ---
local HudGui = Instance.new("ScreenGui", CoreGui)
HudGui.Name = "NuanceHUB_Watermark"
HudGui.IgnoreGuiInset = true

local HudFrame = Instance.new("Frame", HudGui)
HudFrame.Size = UDim2.new(0, 180, 0, 30)
HudFrame.Position = UDim2.new(0, 20, 0, 50) -- Чуть ниже, чтобы не мешать мобильной кнопке
HudFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
HudFrame.BorderSizePixel = 1
HudFrame.BorderColor3 = Settings.HudColor

local HudText = Instance.new("TextLabel", HudFrame)
HudText.Size = UDim2.new(1, 0, 1, 0)
HudText.BackgroundTransparency = 1
HudText.Font = Enum.Font.Code
HudText.TextSize = 14
HudText.TextColor3 = Settings.HudColor
HudText.Text = "NuanceHUB | Ping: --"

task.spawn(function()
    while task.wait(1) do
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        HudText.Text = "NuanceHUB | Ping: " .. ping .. "ms"
        HudFrame.BorderColor3 = Settings.HudColor
        HudText.TextColor3 = Settings.HudColor
    end
end)

-- --- [ ЗАГРУЗКА БИБЛИОТЕКИ ] ---
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "NuanceHUB v5.2",
    Icon = "rbxassetid://10618928818", 
    Author = "Nuance",
    Folder = "NuanceHUB",
    Size = UDim2.new(0, 450, 0, 320),
    Transparent = true,
    Theme = "Dark",
    KeySystem = false
})

-- Создаем Табы
local CombatTab = Window:Tab({ Title = "Combat", Icon = "swords" })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local ThemesTab = Window:Tab({ Title = "Themes", Icon = "palette" })

-- --- [ КАТЕГОРИЯ: COMBAT ] ---
local AimSection = CombatTab:Section({ Title = "Aimbot Settings" })

AimSection:Toggle({
    Title = "Enable Aimbot (RMB)",
    Default = false,
    Callback = function(state) Settings.Aimbot = state end
})

AimSection:Slider({
    Title = "Smoothness",
    Min = 0.01,
    Max = 0.95,
    Default = 0.5,
    Step = 0.01,
    Callback = function(v) Settings.Smoothness = v end
})

local MiscCombat = CombatTab:Section({ Title = "Miscellaneous" })

MiscCombat:Toggle({
    Title = "Triggerbot",
    Default = false,
    Callback = function(state) Settings.Triggerbot = state end
})

MiscCombat:Toggle({
    Title = "Anti-Aim (Spin)",
    Default = false,
    Callback = function(state) Settings.AntiAim = state end
})

-- --- [ КАТЕГОРИЯ: VISUALS ] ---
local EspSection = VisualsTab:Section({ Title = "ESP Functions" })

EspSection:Toggle({
    Title = "Box Chams",
    Default = false,
    Callback = function(state) Settings.Chams = state end
})

EspSection:Toggle({
    Title = "Names",
    Default = false,
    Callback = function(state) Settings.NameTags = state end
})

EspSection:Toggle({
    Title = "Tracers",
    Default = false,
    Callback = function(state) Settings.Tracers = state end
})

local ColorSection = VisualsTab:Section({ Title = "Customization" })

ColorSection:Colorpicker({
    Title = "Visual Color",
    Default = Settings.VisualsColor,
    Callback = function(color) Settings.VisualsColor = color end
})

-- --- [ КАТЕГОРИЯ: THEMES ] ---
local ThemeSection = ThemesTab:Section({ Title = "UI Appearance" })

ThemeSection:Colorpicker({
    Title = "HUD Accent Color",
    Default = Settings.HudColor,
    Callback = function(color) Settings.HudColor = color end
})

ThemeSection:Button({
    Title = "Unload Script",
    Callback = function() 
        HudGui:Destroy()
        -- Тут можно добавить очистку ESP объектов при желании
    end
})

-- --- [ МОБИЛЬНАЯ КНОПКА (ФИКС) ] ---
local MobileGui = Instance.new("ScreenGui", CoreGui)
local MobBtn = Instance.new("TextButton", MobileGui)
MobBtn.Size = UDim2.new(0, 50, 0, 50)
MobBtn.Position = UDim2.new(0.5, -25, 0, 10)
MobBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MobBtn.Text = "HUB"
MobBtn.TextColor3 = Color3.new(1,1,1)
MobBtn.Draggable = true
MobBtn.Active = true
Instance.new("UICorner", MobBtn).CornerRadius = UDim.new(1, 0)

MobBtn.MouseButton1Click:Connect(function()
    -- WindUI хранит ScreenGui внутри своего объекта Window
    -- Пытаемся переключить видимость через встроенный метод или напрямую
    if Window.Instance then
        Window.Instance.Enabled = not Window.Instance.Enabled
    end
end)

Window:Notify({
    Title = "NuanceHUB v5.2",
    Content = "Loaded with Sections. Press B or HUB button.",
    Duration = 5
})

-- --- [ ЛОГИКА ] ---
RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not ESP_Objects[p] then 
                ESP_Objects[p] = { T = Drawing.new("Line"), N = Drawing.new("Text") } 
                ESP_Objects[p].N.Color = Color3.new(1,1,1); ESP_Objects[p].N.Center = true; ESP_Objects[p].N.Outline = true
            end
            local esp = ESP_Objects[p]
            local char = p.Character
            esp.T.Color = Settings.VisualsColor

            if char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
                local hrp = char.HumanoidRootPart
                local pos, onS = Camera:WorldToViewportPoint(hrp.Position)
                
                esp.T.Visible = Settings.Tracers and onS
                if esp.T.Visible then 
                    esp.T.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); esp.T.To = Vector2.new(pos.X, pos.Y) 
                end
                
                esp.N.Visible = Settings.NameTags and onS
                if esp.N.Visible then 
                    esp.N.Position = Vector2.new(pos.X, pos.Y - 30); esp.N.Text = p.Name
                end
                
                local ch = char:FindFirstChild("CyberH")
                if Settings.Chams then
                    if not ch then ch = Instance.new("Highlight", char); ch.Name = "CyberH" end
                    ch.FillColor = Settings.VisualsColor; ch.Enabled = true
                elseif ch then ch.Enabled = false end
            else
                esp.T.Visible = false; esp.N.Visible = false
            end
        end
    end

    -- AIMBOT
    if Settings.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = nil; local dist = Settings.FOV
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
    if Settings.AntiAim and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(65), 0)
    end
end)
