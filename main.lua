--[[
    NuanceHUB v6.0 [VISIONARY UPDATE]
    + High-Precision Raycast Triggerbot
    + Center-Point Aimbot with FOV Circle
    + Health Bars & Distance ESP
    + iOS Glassmorphism UI
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
    Smoothness = 0.4,
    FOV = 150,
    ShowFOV = true,
    
    Triggerbot = false,
    TriggerDelay = 0.02,

    Chams = false,
    Names = false,
    HealthBar = false,
    Distance = false,
    VisualsColor = Color3.fromRGB(180, 100, 255),

    HudColor = Color3.fromRGB(255, 255, 255),
    MenuKey = Enum.KeyCode.B
}

local ESP_Objects = {}
local isMobile = (UIS.TouchEnabled and not UIS.KeyboardEnabled)

-- FOV Circle Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Radius = Settings.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Settings.VisualsColor

-- --- [ МЯГКИЙ HUD ] ---
local HudGui = Instance.new("ScreenGui", CoreGui)
local HudFrame = Instance.new("Frame", HudGui)
HudFrame.Size = UDim2.new(0, 210, 0, 38)
HudFrame.Position = UDim2.new(0.5, -105, 0, 25)
HudFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
HudFrame.BackgroundTransparency = 0.2
Instance.new("UICorner", HudFrame).CornerRadius = UDim.new(0, 19)

local HudStroke = Instance.new("UIStroke", HudFrame)
HudStroke.Color = Color3.new(1,1,1)
HudStroke.Transparency = 0.7

local HudText = Instance.new("TextLabel", HudFrame)
HudText.Size = UDim2.new(1, 0, 1, 0)
HudText.BackgroundTransparency = 1
HudText.Font = Enum.Font.Code
HudText.TextColor3 = Color3.new(1,1,1)
HudText.TextSize = 13
HudText.Text = "NuanceHUB v6.0 | Ping: --"

-- Кнопка "N"
local MobileGui = Instance.new("ScreenGui", CoreGui)
local MobBtn = Instance.new("TextButton", MobileGui)
MobBtn.Size = UDim2.new(0, 50, 0, 50)
MobBtn.Position = UDim2.new(0, 15, 0.5, -25)
MobBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MobBtn.Text = "N"
MobBtn.TextColor3 = Color3.new(1,1,1)
MobBtn.Font = Enum.Font.Code
MobBtn.TextSize = 22
Instance.new("UICorner", MobBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", MobBtn).Color = Settings.VisualsColor

-- --- [ WIND UI (iOS STYLE) ] ---
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "NuanceHUB",
    Icon = "target",
    Author = "Nuance",
    Size = UDim2.new(0, 480, 0, 360),
    Transparent = true,
    Theme = "Dark"
})

MobBtn.MouseButton1Click:Connect(function()
    if Window.Instance then Window.Instance.Enabled = not Window.Instance.Enabled end
end)

local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- Секции Combat
local AimSec = CombatTab:Section({ Title = "Advanced Aimbot" })
AimSec:Toggle({ Title = "Enable Aimbot", Default = false, Callback = function(v) Settings.Aimbot = v end })
AimSec:Slider({ Title = "Smoothness", Min = 0.1, Max = 1, Default = 0.4, Step = 0.1, Callback = function(v) Settings.Smoothness = v end })
AimSec:Slider({ Title = "FOV Radius", Min = 30, Max = 500, Default = 150, Step = 10, Callback = function(v) Settings.FOV = v end })
AimSec:Toggle({ Title = "Show FOV Circle", Default = true, Callback = function(v) Settings.ShowFOV = v end })

local TrigSec = CombatTab:Section({ Title = "Triggerbot (Raycast)" })
TrigSec:Toggle({ Title = "Enable Triggerbot", Default = false, Callback = function(v) Settings.Triggerbot = v end })

-- Секции Visuals
local EspSec = VisualsTab:Section({ Title = "Elite ESP" })
EspSec:Toggle({ Title = "Player Chams", Default = false, Callback = function(v) Settings.Chams = v end })
EspSec:Toggle({ Title = "Health Bars", Default = false, Callback = function(v) Settings.HealthBar = v end })
EspSec:Toggle({ Title = "Show Distance", Default = false, Callback = function(v) Settings.Distance = v end })
EspSec:Toggle({ Title = "Tracers", Default = false, Callback = function(v) Settings.Tracers = v end })
EspSec:Colorpicker({ Title = "Visuals Color", Default = Settings.VisualsColor, Callback = function(v) Settings.VisualsColor = v end })

-- --- [ ЛОГИКА ФУНКЦИЙ ] ---

local function GetClosestToCenter()
    local target = nil
    local maxDist = Settings.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local pos, onS = Camera:WorldToViewportPoint(head.Position)
                if onS then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < maxDist then
                        maxDist = dist
                        target = head
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    -- Update Ping & FOV Circle
    local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    HudText.Text = "NuanceHUB v6.0 | Ping: " .. ping .. "ms"
    
    FOVCircle.Visible = Settings.ShowFOV and Settings.Aimbot
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Color = Settings.VisualsColor

    -- ESP Logic
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if not ESP_Objects[p] then
                ESP_Objects[p] = {
                    Tracer = Drawing.new("Line"),
                    Name = Drawing.new("Text"),
                    HealthBarBack = Drawing.new("Square"),
                    HealthBarMain = Drawing.new("Square")
                }
            end
            local esp = ESP_Objects[p]
            local char = p.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local hrp = char.HumanoidRootPart
                local hum = char.Humanoid
                local pos, onS = Camera:WorldToViewportPoint(hrp.Position)
                
                -- Tracer
                esp.Tracer.Visible = Settings.Tracers and onS
                if esp.Tracer.Visible then
                    esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                    esp.Tracer.Color = Settings.VisualsColor
                end

                -- Name & Distance
                esp.Name.Visible = Settings.Names or Settings.Distance
                if onS then
                    local dist = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - 40)
                    esp.Name.Text = (Settings.Names and p.Name or "") .. (Settings.Distance and " ["..dist.."m]" or "")
                    esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Size = 14; esp.Name.Color = Color3.new(1,1,1)
                else esp.Name.Visible = false end

                -- Health Bar
                esp.HealthBarBack.Visible = Settings.HealthBar and onS
                esp.HealthBarMain.Visible = Settings.HealthBar and onS
                if esp.HealthBarMain.Visible then
                    local barSize = Vector2.new(4, 40)
                    local barPos = Vector2.new(pos.X - 25, pos.Y - 20)
                    esp.HealthBarBack.Size = barSize
                    esp.HealthBarBack.Position = barPos
                    esp.HealthBarBack.Color = Color3.new(0,0,0)
                    esp.HealthBarBack.Filled = true

                    local healthPercent = hum.Health / hum.MaxHealth
                    esp.HealthBarMain.Size = Vector2.new(4, 40 * healthPercent)
                    esp.HealthBarMain.Position = Vector2.new(barPos.X, barPos.Y + (40 * (1 - healthPercent)))
                    esp.HealthBarMain.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1) -- От красного к зеленому
                    esp.HealthBarMain.Filled = true
                end

                -- Chams
                local ch = char:FindFirstChild("NuanceV6")
                if Settings.Chams then
                    if not ch then ch = Instance.new("Highlight", char); ch.Name = "NuanceV6" end
                    ch.FillColor = Settings.VisualsColor; ch.Enabled = true
                elseif ch then ch.Enabled = false end
            else
                esp.Tracer.Visible = false; esp.Name.Visible = false; esp.HealthBarMain.Visible = false; esp.HealthBarBack.Visible = false
            end
        end
    end

    -- AIMBOT (Fixed)
    if Settings.Aimbot and (UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or isMobile) then
        local target = GetClosestToCenter()
        if target then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local moveX = (targetPos.X - mousePos.X) * (1 - Settings.Smoothness)
            local moveY = (targetPos.Y - mousePos.Y) * (1 - Settings.Smoothness)
            
            -- Плавное движение камеры через CFrame Lerp
            local lookAt = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, 1 - Settings.Smoothness)
        end
    end
end)

-- TRIGGERBOT (Raycast Fix)
RunService.Heartbeat:Connect(function()
    if Settings.Triggerbot then
        local rayOrigin = Camera.CFrame.Position
        local rayDirection = Camera.CFrame.LookVector * 500 -- Дистанция луча 500 метров
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        
        local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        if result and result.Instance then
            local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
            if hitModel and hitModel:FindFirstChild("Humanoid") then
                local player = Players:GetPlayerFromCharacter(hitModel)
                if player and player ~= LocalPlayer and hitModel.Humanoid.Health > 0 then
                    task.wait(Settings.TriggerDelay)
                    if mouse1click then mouse1click() end
                end
            end
        end
    end
end)
