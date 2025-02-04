repeat task.wait() until game:GetService("Players").LocalPlayer
task.wait(1)

if 1 then
    return 0
end

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
    repeat
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
        task.wait(2)
    until #Script >= 20000
else 
    print(#Script) 
end

loadstring(Script)()
