local ServerList = game:GetService("ReplicatedStorage").ServerList:GetChildren()
table.sort(ServerList,function(A,B) 
    A,B = tonumber(A.PlayerCount.Value),tonumber(B.PlayerCount.Value)
    return A<B and A*B~=0 
end)
game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,ServerList[1].JobId.Value)
