getgenv().rconsoletitle = nil
getgenv().rconsoleprint = nil
getgenv().rconsolewarn = nil
getgenv().rconsoleinfo = nil
getgenv().rconsolerr = nil

getrenv().print = function(...) return end
getrenv().warn = function(...) return end
getrenv().error = function(...) return end

getgenv().print = function(...) return end
getgenv().warn = function(...) return end
getgenv().error = function(...) return end
getgenv().clonefunction = function(...) return end

game.CoreGui.ChildAdded:Connect(function(c)
    if(string.lower(c.Name) == 'devconsolemaster') then
        task.wait(0.1)
        c:Destroy()
    end
end)


local oldNamecall
oldNamecall = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if(string.lower(method) == 'rconsoleprint') then
        return task.wait(9e9)
    end
    
    if(string.lower(method) == 'rconsoleinfo') then
        return task.wait(9e9)
    end

    if(string.lower(method) == 'rconsolewarn') then
        return task.wait(9e9)
    end

    if(string.lower(method) == 'rconsoleerr') then
        return task.wait(9e9)
    end

    if(string.lower(method) == 'print') then
        return
    end

    if(string.lower(method) == 'warn') then
        return
    end

    if(string.lower(method) == 'error') then
        return
    end

    if(string.lower(method) == 'rendernametag') then
        return 
    end

    return oldNamecall(self, ...)
end))

task.spawn(function()
    game:GetService('RunService').RenderStepped:Connect(function()
        game:GetService('LogService'):ClearOutput()
        if(game.CoreGui:FindFirstChild('DevConsoleMaster')) then
            game.CoreGui:FindFirstChild('DevConsoleMaster'):Destroy()
        end
    end)
end)