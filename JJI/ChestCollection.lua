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
local RS, TS, TP, Debris, HTTP = game:GetService("ReplicatedStorage"), game:GetService("TweenService"),
game:GetService("TeleportService"), game:GetService("Debris"), game:GetService("HttpService")
local ServerRemotes = RS:WaitForChild("Remotes"):WaitForChild("Server")
local ClientRemotes = RS:WaitForChild("Remotes"):WaitForChild("Client")

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


-- Constants
local LuckTable = {
    Cats = {
        [1] = "Polished Beckoning Cat",
        [2] = "Wooden Beckoning Cat",
        [3] = "Withered Beckoning Cat"
    },
    OneTime = {
        [1] = "Fortune Gourd",
        [2] = "Snake Charm",
        [3] = "Luck Vial",
        [4] = "Dumplings"
    }
}


local QueueSuccess = "False"
if Toggle == "ON" then
    local Queued, QueueFail = pcall(function()
        queue_on_teleport('loadstring(game:HttpGet("http://www.stingray-digital.online/script/jji"))()')()
    end)
    if not Queued then
        print("Put this script inside your auto-execution folder:", QueueFail)
        QueueSuccess = QueueFail
    else
        print("Queue success")
        QueueSuccess = "True"
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
local function OpenChest()
    for i, v in ipairs(Drops:GetChildren()) do
        if v:FindFirstChild("Collect") then
            fireproximityprompt(v.Collect)
        end
    end
end

local function DetermineLuckBoosts()
    local Boosts = {}
    local Inventory = LocalPlayer.ReplicatedData.inventory
    if LocalPlayer.ReplicatedData.luckBoost.duration.Value==0 then
        for i,v in LuckTable.Cats do
            if Inventory:FindFirstChild(v) then
                if Inventory[v].Value>5 then
                    table.insert(Boosts,v)
                    break
                end
            end
        end
    end
    for i,v in LuckTable.OneTime do
        if Inventory:FindFirstChild(v) then
            if Inventory[v].Value>5 then
                table.insert(Boosts,v)
            end
        end
    end
    return Boosts
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

repeat task.wait() until Mobs:FindFirstChildWhichIsA("Model")
local Boss = Mobs:FindFirstChildWhichIsA("Model").Name

-- Use boosts --
task.spawn(function()
    local LuckBoosts = DetermineLuckBoosts()
    for i,v in pairs(LuckBoosts) do
        ServerRemotes:WaitForChild("Data"):WaitForChild("EquipItem"):InvokeServer(v)
        print("Used Luck Boost",v)
        task.wait()
    end
    local S, E = pcall(function()
        writefile("JJI_LastBoss.txt", Boss)
    end)
    if not S then
        print("Last boss config saving failed:", E)
    end
end)


repeat
    task.wait()
until Drops:FindFirstChild("Chest") -- Could have used WaitForChild here, but I felt it feels cursed not assigning WaitForChild to a variable, then I don't want an unusused variable...

local Items = "| "
game:GetService("ReplicatedStorage").Remotes.Client.Notify.OnClientEvent:Connect(function(Message)
    local Item = string.match(Message, '">(.-)</font>')
    if not (string.find(Item,"Stat Point") or string.find(Item,"Level")) then
        if table.find(Highlight,Item) then
            Item = "**"..Item.."**"
        end
        Items = Items .. Item .. " | "
    end
end)

-- Overwrite chest collection function --
local Items, HasGoodDrops, ChestsCollected = {}, false, 0
local ChestsCollected = 0
local S, E = pcall(function()
    ClientRemotes.CollectChest.OnClientInvoke = function(Chest, Loots)
        if Chest then
            ChestsCollected = ChestsCollected + 1
            for _, Item in pairs(Loots) do
                if table.find({"Special Grade", "Unique"}, Item[1]) then
                    HasGoodDrops = true
                    Item[2] = "**" .. Item[2] .. "**"
                end
                table.insert(Items, Item[2])
            end
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
local S, E = pcall(function()
    if getgenv().Webhook then
        local Executor = (identifyexecutor() or "None Found")
        local Content = ""
        if HasGoodDrops and DiscordPing ~= "None Found" then
            Content = Content .. DiscordPing
        end
        Content = Content .. "\n-# [Debug Data] " .. "Executor: " .. Executor .. " | Script Loading Time: " ..
                      tostring(ScriptLoading) .. " | Luck Boosts: (" .. tostring(table.concat(LuckBoosts,", ")) ..
                      ") | Chests Collected: " .. tostring(ChestsCollected) ..
                      " | Send a copy of this data to Manta if there's any issues"
        print("Sending webhook")
        task.wait()
        local embed = {
            ["title"] = LocalPlayer.Name .. " has defeated " .. Boss .. " in " ..
                tostring(math.floor((tick() - StartTime) * 10) / 10) .. " seconds",
            ['description'] = "Collected Items: " .. table.concat(Items, " | "),
            ["color"] = tonumber(000000)
        }
        request({
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
        task.wait()
        print("Webhook sent")
    end
end)


-- Click replay --
task.wait()
    for i = 1, 10, 1 do
        Click(Replay)
        task.wait(1)
    end
end
