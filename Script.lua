-- 🔥 Minato NTT-Inspired Hub v6.0 for King Legacy - Delta OK (2026 style)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Rayfield UI (moderna, como muitos hubs NTT usam)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Minato NTT-Style Hub v6 - King Legacy",
   LoadingTitle = "Carregando...",
   LoadingSubtitle = "Inspired by NTT Hub",
   ConfigurationSaving = {Enabled = true, FolderName = "MinatoNTT", FileName = "Config"},
   KeySystem = false
})

Rayfield:Notify({
   Title = "Hub Carregado!",
   Content = "Use INSERT para abrir/fechar | Ative features na GUI",
   Duration = 5
})

-- Configs
local cfgs = {
   farmEnabled = false,
   collectEnabled = false,
   bossEnabled = false,
   flyEnabled = false,
   noclipEnabled = false,
   espEnabled = false,
   speed = 100,
   infJump = false
}

-- Tabs (estilo NTT: Farm, Combat, Visual, Movement, Misc)
local FarmTab = Window:CreateTab("Farm")
local CombatTab = Window:CreateTab("Combat")
local VisualTab = Window:CreateTab("Visual/ESP")
local MoveTab = Window:CreateTab("Movement")
local MiscTab = Window:CreateTab("Misc")

-- Farm Tab
FarmTab:CreateToggle({
   Name = "Auto Farm Level",
   CurrentValue = false,
   Callback = function(v) cfgs.farmEnabled = v end
})

FarmTab:CreateToggle({
   Name = "Auto Collect Fruits/Items",
   CurrentValue = false,
   Callback = function(v) cfgs.collectEnabled = v end
})

FarmTab:CreateToggle({
   Name = "Auto Boss Farm",
   CurrentValue = false,
   Callback = function(v) cfgs.bossEnabled = v end
})

-- Movement Tab
MoveTab:CreateToggle({
   Name = "Fly (WASD + Space/Shift)",
   CurrentValue = false,
   Callback = function(v) cfgs.flyEnabled = v end
})

MoveTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(v) cfgs.noclipEnabled = v end
})

MoveTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(v) cfgs.infJump = v end
})

MoveTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 500},
   Increment = 10,
   CurrentValue = 100,
   Callback = function(v)
      cfgs.speed = v
      humanoid.WalkSpeed = v
   end
})

-- Visual/ESP Tab
VisualTab:CreateToggle({
   Name = "ESP Players (Name, Lv, PvP, Health)",
   CurrentValue = false,
   Callback = function(v)
      cfgs.espEnabled = v
      if v then enableAllESP() else disableAllESP() end
   end
})

-- Misc Tab
MiscTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId) end
})

-- Funções Fly/Noclip/Anti-AFK (mantidas)
RunService.Heartbeat:Connect(function()
   pcall(function()
      humanoid.WalkSpeed = cfgs.speed
      
      if cfgs.noclipEnabled then
         for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
         end
      end
      
      if cfgs.flyEnabled then
         local bv = rootPart:FindFirstChild("FlyBV") or Instance.new("BodyVelocity", rootPart)
         bv.Name = "FlyBV"
         bv.MaxForce = Vector3.new(1e9,1e9,1e9)
         bv.Velocity = Vector3.new()
         local cam = workspace.CurrentCamera
         local dir = humanoid.MoveDirection
         if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
         if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir += Vector3.new(0,-1,0) end
         bv.Velocity = cam.CFrame:VectorToWorldSpace(dir) * 60
      end
   end)
end)

UserInputService.JumpRequest:Connect(function()
   if cfgs.infJump then humanoid:ChangeState("Jumping") end
end)

spawn(function()
   while task.wait(300) do
      VirtualUser:CaptureController()
      VirtualUser:ClickButton2(Vector2.new())
   end
end)

player.CharacterAdded:Connect(function(new)
   character = new
   humanoid = new:WaitForChild("Humanoid")
   rootPart = new:WaitForChild("HumanoidRootPart")
end)

-- ESP (como no NTT: player info com cor PvP)
local function createESP(plr)
   if plr == player then return end
   
   local function apply(char)
      local head = char:WaitForChild("Head")
      local hum = char:WaitForChild("Humanoid")
      
      local bb = Instance.new("BillboardGui", head)
      bb.Name = "MinatoESP"
      bb.Adornee = head
      bb.Size = UDim2.new(0,220,0,120)
      bb.StudsOffset = Vector3.new(0,5,0)
      bb.AlwaysOnTop = true
      bb.MaxDistance = 1200
      
      local txt = Instance.new("TextLabel", bb)
      txt.Size = UDim2.new(1,0,1,0)
      txt.BackgroundTransparency = 1
      txt.TextColor3 = Color3.new(1,1,1)
      txt.TextStrokeTransparency = 0.4
      txt.TextStrokeColor3 = Color3.new(0,0,0)
      txt.Font = Enum.Font.GothamBold
      txt.TextSize = 15
      txt.TextXAlignment = Enum.TextXAlignment.Center
      
      spawn(function()
         while bb.Parent do
            task.wait(0.4)
            local lvl = "Lv: ?"
            local pvp = "PvP: ?"
            local hp = "HP: ?/?"
            
            if plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Level") then
               lvl = "Lv: " .. plr.leaderstats.Level.Value
            end
            
            local pvpV = plr:FindFirstChild("PVP") or plr:FindFirstChild("PvPEnabled")
            if pvpV and pvpV:IsA("BoolValue") then
               pvp = "PvP: " .. (pvpV.Value and "ON" or "OFF")
            end
            
            hp = "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
            
            txt.TextColor3 = pvpV and pvpV.Value and Color3.new(1,0.3,0.3) or Color3.new(0.4,1,0.4)
            txt.Text = plr.Name .. "\n" .. lvl .. "\n" .. pvp .. "\n" .. hp
         end
      end)
   end
   
   if plr.Character then apply(plr.Character) end
   plr.CharacterAdded:Connect(apply)
end

local function enableAllESP()
   for _, p in Players:GetPlayers() do createESP(p) end
end

local function disableAllESP()
   for _, p in Players:GetPlayers() do
      if p.Character then
         local h = p.Character:FindFirstChild("Head")
         if h then local e = h:FindFirstChild("MinatoESP") if e then e:Destroy() end end
      end
   end
end

Players.PlayerAdded:Connect(function(p)
   if cfgs.espEnabled then createESP(p) end
end)

print("Minato NTT-Style Hub v6 carregado! Abra com INSERT")    ["Race V2"] = CFrame.new(-1230, 73, 3330),
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
