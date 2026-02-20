-- 🔥 Minato King Legacy Farm Hub v2.4 (Corrigido + ESP Players Integrado) - Delta OK

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- Kavo UI corrigida (fonte oficial e funcional)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Minato King Legacy Farm v2.4", "DarkTheme")

-- Variáveis
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local farmEnabled = false
local autoBoss = false
local autoQuest = false
local autoRace = false
local flyEnabled = false
local espEnabled = false

-- POSIÇÕES (do seu script original)
local POSICOES = {
    ["Bandit"] = CFrame.new(-3052, 73, 3363),
    ["Gorilla"] = CFrame.new(-1221, 73, 3749),
    ["Snow Bandit"] = CFrame.new(1387, 87, -1298),
    ["Thunder God"] = CFrame.new(-2851, 73, 4392),
    ["Vice Amiral"] = CFrame.new(2859, 73, 4495),
    ["Dough King"] = CFrame.new(5535, 73, -4529),
    ["Luffy Quest"] = CFrame.new(-1230, 73, 3330),
    ["Race V2"] = CFrame.new(-1230, 73, 3330),
    ["Daily"] = CFrame.new(70, 73, 70),
}

-- TABS
local FarmTab = Window:NewTab("Farm")
local BossTab = Window:NewTab("Bosses")
local QuestTab = Window:NewTab("Quests")
local MoveTab = Window:NewTab("Movement")
local ESPTab = Window:NewTab("ESP")  -- Nova tab para ESP

-- Toggles do seu script
FarmTab:NewToggle("Auto Farm Level", "Farma level infinito", function(state)
    farmEnabled = state
end)

FarmTab:NewToggle("Auto Collect Items", "Pega fruits/coins", function(state)
    getgenv().autoCollect = state
end)

FarmTab:NewButton("Teleport Farm", "Vai pro melhor spot", function()
    rootPart.CFrame = POSICOES["Bandit"]
end)

BossTab:NewToggle("Auto Boss Farm", "Mata todos bosses", function(state)
    autoBoss = state
end)

BossTab:NewButton("TP Thunder God", "Boss fácil", function()
    rootPart.CFrame = POSICOES["Thunder God"]
end)

QuestTab:NewToggle("Auto Daily Quests", "Missões diárias", function(state)
    autoQuest = state
end)

QuestTab:NewToggle("Race V2 Auto", "Completa raça V2", function(state)
    autoRace = state
end)

MoveTab:NewToggle("Fly", "Voa livre", function(state)
    flyEnabled = state
end)

MoveTab:NewSlider("Speed", "Velocidade", 500, 16, function(s)
    pcall(function() humanoid.WalkSpeed = s end)
end)

MoveTab:NewButton("Save Pos", "Salva posição", function()
    getgenv().savePos = rootPart.CFrame
end)

MoveTab:NewButton("Load Pos", "Volta posição", function()
    if getgenv().savePos then
        rootPart.CFrame = getgenv().savePos
    end
end)

-- ESP Toggle
ESPTab:NewToggle("ESP Players (Nome, Lv, PvP, Vida)", "Mostra info acima da cabeça", function(state)
    espEnabled = state
    if state then
        enableAllESP()
        print("ESP Ativado")
    else
        disableAllESP()
        print("ESP Desativado")
    end
end)

-- FUNÇÕES (mantidas do seu script)
local function tweenTo(pos, speed)
    speed = speed or 200
    local distance = (rootPart.Position - pos.Position).Magnitude
    local tweenInfo = TweenInfo.new(distance/speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = pos})
    tween:Play()
    tween.Completed:Wait()
end

local function collectItems()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("fruit") or obj.Name:lower():find("drop") or obj.Name:lower():find("coin")) then
            if (obj.Position - rootPart.Position).Magnitude < 100 then
                tweenTo(CFrame.new(obj.Position + Vector3.new(0,10,0)))
                fireclickdetector(obj:FindFirstChildOfClass("ClickDetector"))
            end
        end
    end
end

local function farmMobs()
    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            tweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0,5,-3))
            for i = 1, 10 do
                VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
                wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
            end
            return true
        end
    end
    return false
end

local function farmBosses()
    local bosses = {"Thunder God", "Vice Amiral", "Dough King"}
    for _, bossName in pairs(bosses) do
        for _, boss in pairs(workspace.Enemies:GetChildren()) do
            if boss.Name:find(bossName) and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                tweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0,5,-3))
                return true
            end
        end
    end
    return false
end

-- LOOP PRINCIPAL (mantido)
spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if flyEnabled then
                local bv = rootPart:FindFirstChild("FlyBV") or Instance.new("BodyVelocity")
                bv.Name = "FlyBV"
                bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                bv.Velocity = Vector3.new(0,0,0)
                bv.Parent = rootPart
                
                local cam = workspace.CurrentCamera
                local move = humanoid.MoveDirection
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move + Vector3.new(0,-1,0) end
                bv.Velocity = (cam.CFrame:VectorToWorldSpace(move)) * 50
            end
            
            if farmEnabled then
                if not farmMobs() then
                    tweenTo(POSICOES["Bandit"])
                end
            end
            
            if autoBoss and not farmBosses() then
                tweenTo(POSICOES["Thunder God"])
            end
            
            if getgenv().autoCollect then
                collectItems()
            end
            
            -- Noclip
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- Quest Loop
spawn(function()
    while task.wait(10) do
        pcall(function()
            if autoQuest then
                tweenTo(POSICOES["Daily"])
                wait(2)
                keypress(0x45)
                wait(1)
                keyrelease(0x45)
            end
            
            if autoRace then
                tweenTo(POSICOES["Race V2"])
                wait(3)
            end
        end)
    end
end)

-- Anti-AFK
spawn(function()
    while task.wait(300) do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end
end)

-- Respawn fix
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- ======================================
-- ESP PLAYERS (Nome, Level, PvP, Vida) - com toggle na GUI
-- ======================================

local function createESP(plr)
    if plr == player then return end
    
    local function applyESP(char)
        local head = char:WaitForChild("Head", 5)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not head or not humanoid then return end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "Minato_ESP"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 220, 0, 120)
        billboard.StudsOffset = Vector3.new(0, 5, 0)
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 0
        billboard.MaxDistance = 1200
        billboard.Parent = head
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextStrokeTransparency = 0.4
        text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 15
        text.TextXAlignment = Enum.TextXAlignment.Center
        text.Parent = billboard
        
        spawn(function()
            while billboard.Parent and task.wait(0.4) do
                local levelText = "Lv: ?"
                local pvpText = "PvP: ?"
                local healthText = "Vida: ?/?"
                
                local leaderstats = plr:FindFirstChild("leaderstats")
                if leaderstats then
                    local levelVal = leaderstats:FindFirstChild("Level")
                    if levelVal and levelVal:IsA("IntValue") then
                        levelText = "Lv: " .. levelVal.Value
                    end
                end
                
                local pvpVal = plr:FindFirstChild("PVP") or plr:FindFirstChild("PvPEnabled") or plr:FindFirstChild("InPVP")
                if pvpVal and pvpVal:IsA("BoolValue") then
                    pvpText = "PvP: " .. (pvpVal.Value and "Ativado" or "Desativado")
                elseif pvpVal then
                    pvpText = "PvP: " .. tostring(pvpVal.Value)
                end
                
                healthText = "Vida: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                
                local color = (pvpVal and pvpVal.Value) and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(100, 255, 100)
                text.TextColor3 = color
                
                text.Text = plr.Name .. "\n" .. levelText .. "\n" .. pvpText .. "\n" .. healthText
            end
        end)
    end
    
    if plr.Character then applyESP(plr.Character) end
    plr.CharacterAdded:Connect(applyESP)
end

local function enableAllESP()
    for _, plr in pairs(Players:GetPlayers()) do
        createESP(plr)
    end
end

local function disableAllESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local esp = head:FindFirstChild("Minato_ESP")
                if esp then esp:Destroy() end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    if espEnabled then
        createESP(plr)
    end
end)

print("MINATO FARM HUB v2.4 CORRIGIDO + ESP CARREGADO!")
print("GUI deve abrir agora. Vá na tab ESP para ativar!")
print("Fly: WASD + Space/Shift")
