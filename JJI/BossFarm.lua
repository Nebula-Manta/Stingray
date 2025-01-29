repeat task.wait() until game:GetService("Players").LocalPlayer
game:GetService("Players").LocalPlayer:Kick("\n\nScript in maintenance\nI didn't expect so many people to use it at once\nGoing to increase stability, check #important for details")
task.wait(0.5)

pcall(function()
    if not getgenv().Key then
        getgenv().Key = readfile("Stingray_Key.txt")
    else
        writefile("Stingray_Key.txt",getgenv().Key)
    end
end)

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
