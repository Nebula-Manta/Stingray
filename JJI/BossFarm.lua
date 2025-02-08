repeat task.wait() until game:GetService("Players").LocalPlayer
task.wait(1)
pcall(function()
    --local M = Instance.new("Message",game:GetService("CoreGui"))
    --Message.Text = "Script is in maintenance in preparation for the new update\nFarming during this time is not recommended"
    game:GetService("Players").LocalPlayer:Kick("Security Kick")
    if true then
        return 0
    end
end)

task.wait(0.5)

pcall(function()
    if not getgenv().Key then
        getgenv().Key = readfile("Stingray_Key.txt")
    else
        writefile("Stingray_Key.txt",getgenv().Key)
    end
end)

if not getgenv().Key then
    setclipboard("https://discord.gg/hwnxYCUBf8")
    game.Players.LocalPlayer:Kick("\n\nInvalid Key, Discord copied to clipboard\nUse /pray to get a key\n")
    return 0
end

local Script = [[
    print("Post request failure")
]]

local S,E = pcall(function()
    Script = request({
        Url = "http://stingray-digital.online/script/jji",
        Headers = {
            ['Content-Type'] = 'application/json'
        },
        Body = game:GetService("HttpService"):JSONEncode({
            key = tostring(getgenv().Key),
            hwid = game:GetService("RbxAnalyticsService"):GetClientId(),
            username = game:GetService("Players").LocalPlayer.Name
        }),
        Method = "POST"
    }).Body
end)

task.wait(1)

if #Script <= 20000 or (not S) then
    print(#Script) 
end

loadstring(Script)()
