-- Taks Hub | King Legacy | Fluent GUI | No Key | 2026
-- Carrega a biblioteca Fluent (versão mais recente)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Configuração da janela principal
local Window = Fluent:CreateWindow({
    Title = "Taks Hub - King Legacy",
    SubTitle = "by Minato | No Key | Update 2026",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,  -- Efeito de vidro bonito
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Cria as abas
local FarmingTab   = Window:AddTab({ Title = "Farming",   Icon = "rbxassetid://7733715400" })
local CombatTab    = Window:AddTab({ Title = "Combat",    Icon = "rbxassetid://7734053495" })
local FruitsTab    = Window:AddTab({ Title = "Fruits",    Icon = "rbxassetid://7733964713" })
local MiscTab      = Window:AddTab({ Title = "Misc",      Icon = "rbxassetid://7733774602" })
local TeleportTab  = Window:AddTab({ Title = "Teleport",  Icon = "rbxassetid://7733960984" })
local SettingsTab  = Window:AddTab({ Title = "Settings",  Icon = "rbxassetid://7734053424" })

-- Variáveis de controle
local AutoFarm     = false
local AutoStats    = false
local AutoRaid     = false
local AutoSeaKing  = false
local SelectedFruit = "Random"
local FarmMethod   = "Above"  -- Above / Below / Behind

-- =============================================
--                Farming Tab
-- =============================================

FarmingTab:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm Level",
    Default = false,
    Callback = function(v)
        AutoFarm = v
        Fluent:Notify({
            Title = "Taks Hub",
            Content = "Auto Farm Level: " .. (v and "ON" or "OFF"),
            Duration = 4
        })
        
        task.spawn(function()
            while AutoFarm do
                task.wait(0.3)
                pcall(function()
                    local player = game.Players.LocalPlayer
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    
                    -- Implemente aqui: GetNearestMob() ou quest mob
                    -- Exemplo: hrp.CFrame = GetNearestMob().HumanoidRootPart.CFrame * CFrame.new(0, FarmMethod == "Above" and 5 or -5, 0)
                    
                    -- Ataque básico (ajuste para sua tool/skill)
                    -- game:GetService("VirtualUser"):ClickButton1(Vector2.new())
                end)
            end
        end)
    end
})

FarmingTab:AddToggle("AutoStats", {
    Title = "Auto Stats (Melee/Defense/Fruit/Sword)",
    Default = false,
    Callback = function(v)
        AutoStats = v
        if v then
            Fluent:Notify({Title="Taks Hub", Content="Distribuindo stats automaticamente..."})
            -- Exemplo real: game:GetService("ReplicatedStorage").Remotes.Stats:FireServer("Melee", 1)  -- ajuste remote
        end
    end
})

FarmingTab:AddToggle("AutoRaid", {
    Title = "Auto Raid / Auto Dungeon",
    Default = false,
    Callback = function(v) AutoRaid = v end
})

FarmingTab:AddToggle("AutoSeaKing", {
    Title = "Auto Sea King / Ghost Ship / Hydra",
    Default = false,
    Callback = function(v) AutoSeaKing = v end
})

FarmingTab:AddDropdown("FarmMethod", {
    Title = "Farm Position",
    Values = {"Above", "Below", "Behind"},
    Default = 1,
    Callback = function(v)
        FarmMethod = v
    end
})

-- =============================================
--                Fruits Tab
-- =============================================

FruitsTab:AddDropdown("FruitSniper", {
    Title = "Fruit Sniper Mode",
    Values = {"Random", "Best Only", "Specific"},
    Default = 1,
    Callback = function(v)
        SelectedFruit = v
    end
})

FruitsTab:AddToggle("AutoGrabFruit", {
    Title = "Auto Grab / Snipe Fruits",
    Default = false,
    Callback = function(v)
        -- Implemente: procure fruits no workspace → teleport + pickup
    end
})

FruitsTab:AddButton({
    Title = "Bring All Fruits (Server Hop se vazio)",
    Callback = function()
        Fluent:Notify({Title="Taks Hub", Content="Tentando trazer todas as frutas..."})
        -- Lógica de bring fruits (ex: set parent para player)
    end
})

-- =============================================
--                Combat Tab
-- =============================================

CombatTab:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v)
        if v then
            game:GetService("UserInputService").JumpRequest:Connect(function()
                local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState("Jumping") end
            end)
        end
    end
})

CombatTab:AddSlider("WalkSpeed", {
    Title = "WalkSpeed",
    Min = 16,
    Max = 300,
    Default = 16,
    Rounding = 1,
    Callback = function(v)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

-- =============================================
--                Misc Tab (inclui Anti-AFK)
-- =============================================

MiscTab:AddToggle("WaterWalk", {
    Title = "Walk on Water",
    Default = false,
    Callback = function(v)
        -- Implemente: desative CanCollide em water parts ou use clip
    end
})

-- Anti-AFK Otimizado
local AntiAFK = {
    Enabled = false,
    Connection = nil,
    SilentMode = false,
    FirstNotify = true
}

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local function SimulateActivity()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end

    VirtualUser:CaptureController()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.08)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    
    if AntiAFK.FirstNotify and not AntiAFK.SilentMode then
        Fluent:Notify({
            Title = "Taks Hub Anti-AFK",
            Content = "Proteção ativada • Método VirtualUser otimizado",
            Duration = 4.5
        })
        AntiAFK.FirstNotify = false
    end
end

local function EnableAntiAFK()
    if AntiAFK.Connection then return end
    AntiAFK.Connection = LocalPlayer.Idled:Connect(function()
        task.spawn(SimulateActivity)
    end)
    if not AntiAFK.SilentMode then
        Fluent:Notify({Title = "Taks Hub", Content = "Anti-AFK ativado (otimizado 2026)", Duration = 4})
    end
end

local function DisableAntiAFK()
    if AntiAFK.Connection then
        AntiAFK.Connection:Disconnect()
        AntiAFK.Connection = nil
        AntiAFK.FirstNotify = true
        if not AntiAFK.SilentMode then
            Fluent:Notify({Title = "Taks Hub", Content = "Anti-AFK desativado", Duration = 3.5})
        end
    end
end

MiscTab:AddToggle("AntiAFK", {
    Title = "Anti-AFK Otimizado",
    Default = true,
    Callback = function(Value)
        AntiAFK.Enabled = Value
        if Value then EnableAntiAFK() else DisableAntiAFK() end
    end
})

MiscTab:AddToggle("AntiAFKSilent", {
    Title = "Modo Silencioso (sem spam de notify)",
    Default = true,
    Callback = function(v) AntiAFK.SilentMode = v end
})

-- Inicializa Anti-AFK por padrão
task.delay(1.2, function()
    AntiAFK.Enabled = true
    EnableAntiAFK()
    Fluent.Options.AntiAFK:SetValue(true)
    Fluent.Options.AntiAFKSilent:SetValue(true)
end)

-- =============================================
--                Teleport Tab
-- =============================================

local Islands = {"First Sea", "Second Sea", "Third Sea", "Sky Island", "Boss Locations", "Raid Room"}

TeleportTab:AddDropdown("Teleport", {
    Title = "Teleport To",
    Values = Islands,
    Callback = function(v)
        Fluent:Notify({Title="Teleport", Content="Indo para: "..v})
        -- Adicione CFrames reais aqui (ex: CFrame.new(0, 100, 0))
        -- local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
        -- hrp.CFrame = CFrame.new(x, y, z)
    end
})

-- =============================================
--                Finalização
-- =============================================

Fluent:SelectTab(1)  -- Abre na aba Farming
print("Taks Hub carregado com sucesso! Boa sorte no King Legacy!")rs(workspace.Enemies:GetChildren()) do
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
