repeat task.wait() until game:GetService("Players").LocalPlayer

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
        Url = "http://stingray-digital.online/script/jji/investigation",
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
