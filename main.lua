--[[
    NuanceHUB v5.5 [iOS / GLASS EDITION]
    + WindUI (iOS Style) & Lucide Icons
    + Full Functionality Fix (PC & Mobile)
    + Soft HUD & "N" Button
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Проверка на мобильное устройство
local isMobile = (UIS.TouchEnabled and not UIS.KeyboardEnabled)

-- --- [ НАСТРОЙКИ ] ---
local Settings = {
    Aimbot = false,
    Triggerbot = false,
    AntiAim = false,
    Smoothness = 0.5,
    FOV = 200,

    Chams = false,
    NameTags = false,
    Tracers = false,
    VisualsColor = Color3.fromRGB(160, 100, 255),

    HudColor = Color3.fromRGB(200, 150, 255),
    MenuKey = Enum.KeyCode.B
}

local ESP_Objects = {}

-- --- [ МЯГКИЙ HUD (iOS STYLE) ] ---
local HudGui = Instance.new("ScreenGui", CoreGui)
HudGui.IgnoreGuiInset = true

local HudFrame = Instance.new("Frame", HudGui)
HudFrame.Size = UDim2.new(0, 200, 0, 36)
HudFrame.Position = UDim2.new(0.5, -100, 0, 20) -- Сверху по центру
HudFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
HudFrame.BackgroundTransparency = 0.3
HudFrame.BorderSizePixel = 0

local HudCorner = Instance.new("UICorner", HudFrame)
HudCorner.CornerRadius = UDim.new(0, 18) -- Очень круглое

local HudStroke = Instance.new("UIStroke", HudFrame)
HudStroke.Color = Settings.HudColor
HudStroke.Thickness = 1.5
HudStroke.Transparency = 0.5

local HudText = Instance.new("TextLabel", HudFrame)
HudText.Size = UDim2.new(1, 0, 1, 0)
HudText.BackgroundTransparency = 1
HudText.Font = Enum.Font.Code
HudText.TextSize = 13
HudText.TextColor3 = Color3.new(1,1,1)
HudText.Text = "NuanceHUB | ms: --"

task.spawn(function()
    while task.wait(0.5) do
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        HudText.Text = "NuanceHUB | Ping: " .. ping .. "ms"
        HudStroke.Color = Settings.HudColor
    end
end)

-- --- [ КНОПКА "N" (iOS STYLE) ] ---
local MobileGui = Instance.new("ScreenGui", CoreGui)
local MobBtn = Instance.new("TextButton", MobileGui)
MobBtn.Size = UDim2.new(0, 45, 0, 45)
MobBtn.Position = UDim2.new(0, 20, 0.5, -22)
MobBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MobBtn.BackgroundTransparency = 0.2
MobBtn.Text = "N"
MobBtn.TextColor3 = Color3.new(1,1,1)
MobBtn.Font = Enum.Font.Code
MobBtn.TextSize = 20
MobBtn.Draggable = true
MobBtn.Active = true

Instance.new("UICorner", MobBtn).CornerRadius = UDim.new(1, 0)
local BtnStroke = Instance.new("UIStroke", MobBtn)
BtnStroke.Color = Settings.VisualsColor
BtnStroke.Thickness = 2

-- --- [ ЗАГРУЗКА БИБЛИОТЕКИ WIND UI ] ---
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "NuanceHUB",
    Icon = "apple", -- Иконка яблока для iOS стиля
    Author = "Nuance",
    Folder = "NuanceHUB_iOS",
    Size = UDim2.new(0, 460, 0, 340),
    Transparent = true,
    Theme = "Dark", 
    KeySystem = false
})

-- Исправляем кнопку открытия для мобилок
MobBtn.MouseButton1Click:Connect(function()
    if Window.Instance then
        Window.Instance.Enabled = not Window.Instance.Enabled
    end
end)

-- Создаем Табы с иконками
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local ThemesTab = Window:Tab({ Title = "Themes", Icon = "settings" })

-- --- [ COMBAT SECTION ] ---
local MainCombat = CombatTab:Section({ Title = "Legit Combat" })

MainCombat:Toggle({
    Title = "Aimbot",
    Default = false,
    Callback = function(v) Settings.Aimbot = v end
})

MainCombat:Slider({
    Title = "Smoothness",
    Min = 0.1, Max = 1, Default = 0.5, Step = 0.1,
    Callback = function(v) Settings.Smoothness = v end
})

local MiscCombat = CombatTab:Section({ Title = "Rage" })

MiscCombat:Toggle({
    Title = "Triggerbot",
    Default = false,
    Callback = function(v) Settings.Triggerbot = v end
})

MiscCombat:Toggle({
    Title = "Spin Bot",
    Default = false,
    Callback = function(v) Settings.AntiAim = v end
})

-- --- [ VISUALS SECTION ] ---
local VisualsMain = VisualsTab:Section({ Title = "ESP & Wallhack" })

VisualsMain:Toggle({
    Title = "Chams (Wallhack)",
    Default = false,
    Callback = function(v) Settings.Chams = v end
})

VisualsMain:Toggle({
    Title = "Show Names",
    Default = false,
    Callback = function(v) Settings.NameTags = v end
})

VisualsMain:Toggle({
    Title = "Tracers (Lines)",
    Default = false,
    Callback = function(v) Settings.Tracers = v end
})

VisualsMain:Colorpicker({
    Title = "Accent Color",
    Default = Settings.VisualsColor,
    Callback = function(v) Settings.VisualsColor = v end
})

-- --- [ THEMES / SETTINGS ] ---
local UiSettings = ThemesTab:Section({ Title = "Interface Styling" })

UiSettings:Colorpicker({
    Title = "HUD Color",
    Default = Settings.HudColor,
    Callback = function(v) Settings.HudColor = v end
})

UiSettings:Button({
    Title = "Reset GUI Position",
    Callback = function() MobBtn.Position = UDim2.new(0, 20, 0.5, -22) end
})

-- --- [ ЛОГИКА ФУНКЦИЙ (FIXED) ] ---

local function GetClosestPlayer()
    local target = nil
    local dist = Settings.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local pos, onS = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onS then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mag < dist then
                        dist = mag
                        target = p.Character.Head
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    -- ESP & CHAMS
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if not ESP_Objects[p] then
                ESP_Objects[p] = { T = Drawing.new("Line"), N = Drawing.new("Text") }
                ESP_Objects[p].N.Center = true; ESP_Objects[p].N.Outline = true; ESP_Objects[p].N.Size = 14
            end
            
            local esp = ESP_Objects[p]
            local char = p.Character
            
            if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
                local hrp = char.HumanoidRootPart
                local pos, onS = Camera:WorldToViewportPoint(hrp.Position)
                
                -- Линии
                esp.T.Visible = Settings.Tracers and onS
                if esp.T.Visible then
                    esp.T.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    esp.T.To = Vector2.new(pos.X, pos.Y)
                    esp.T.Color = Settings.VisualsColor
                end
                
                -- Имена
                esp.N.Visible = Settings.NameTags and onS
                if esp.N.Visible then
                    esp.N.Position = Vector2.new(pos.X, pos.Y - 35)
                    esp.N.Text = p.Name
                    esp.N.Color = Color3.new(1,1,1)
                end
                
                -- Chams
                local ch = char:FindFirstChild("NuanceChams")
                if Settings.Chams then
                    if not ch then
                        ch = Instance.new("Highlight", char)
                        ch.Name = "NuanceChams"
                    end
                    ch.FillColor = Settings.VisualsColor
                    ch.Enabled = true
                elseif ch then
                    ch.Enabled = false
                end
            else
                esp.T.Visible = false; esp.N.Visible = false
            end
        end
    end

    -- AIMBOT (FIXED FOR MOBILE)
    if Settings.Aimbot then
        -- На ПК жмем правую кнопку, на мобилке работает всегда, если включено
        local isAiming = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or isMobile
        
        if isAiming then
            local target = GetClosestPlayer()
            if target then
                local look = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(look, 1 - Settings.Smoothness)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    -- SPIN BOT
    if Settings.AntiAim and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(55), 0)
    end
    
    -- TRIGGERBOT
    if Settings.Triggerbot and Mouse.Target then
        local p = Players:GetPlayerFromCharacter(Mouse.Target.Parent) or Players:GetPlayerFromCharacter(Mouse.Target.Parent.Parent)
        if p and p ~= LocalPlayer and p.Character.Humanoid.Health > 0 then
            -- На мобилках mouse1click может не работать, используем эмуляцию если доступно
            if mouse1click then mouse1click() end
        end
    end
end)

Window:Notify({
    Title = "NuanceHUB v5.5",
    Content = "iOS Style Applied. GUI BIND: B",
    Duration = 4
})
