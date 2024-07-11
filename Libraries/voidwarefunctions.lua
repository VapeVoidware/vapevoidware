local RenderFunctions = {WhitelistLoaded = false, whitelistTable = {}, localWhitelist = {}, configUsers = {}, whitelistSuccess = false, playerWhitelists = {}, commands = {}, playerTags = {}, entityTable = {}}
local RenderLibraries = {}
local RenderConnections = {}
local players = game:GetService('Players')
local tweenService = game:GetService('TweenService')
local httpService = game:GetService('HttpService')
local textChatService = game:GetService('TextChatService')
local lplr = players.LocalPlayer
local GuiLibrary = (shared and shared.GuiLibrary)
local rankTable = {DEFAULT = 0, STANDARD = 1, BOOSTER = 1.5, BETA = 1.6, INF = 2, OWNER = 3}
local httprequest = (http and http.request or http_request or fluxus and fluxus.request or request or function() return {Body = '[]', StatusCode = 404, StatusText = 'bad exploit'} end)

local RenderFunctions = setmetatable(RenderFunctions, {
    __newindex = function(tab, i, v) 
        if getgenv().RenderFunctions and rawget(tab, i) then 
            for i,v in pairs, ({}) do end
        end
        rawset(tab, i, v) 
    end,
    __tostring = function(tab) 
        return 'Critical render table object.'
    end
})

RenderFunctions.playerWhitelists = setmetatable({}, {
    __newindex = function(tab, i, v) 
        if getgenv().RenderFunctions then 
            for i,v in pairs, ({}) do end
        end
        rawset(tab, i, v) 
    end,
    __tostring = function(tab) 
        return 'Render whitelist table object.'
    end
})

RenderFunctions.commands = setmetatable({}, {
    __newindex = function(tab, i, v) 
        if type(v) ~= 'function' then 
            for i,v in pairs, ({}) do end
        end
        rawset(tab, i, v) 
    end,
    __tostring = function(tab) 
        return 'Render whitelist command functions.'
    end
})

rankTable = setmetatable(rankTable, {
    __newindex = function(tab, i, v) 
        if getgenv().RenderFunctions then 
            for i,v in pairs, ({}) do end
        end
        rawset(tab, i, v) 
    end
})

RenderFunctions.hashTable = {rendermoment = 'Render', renderlitemoment = 'Render Lite', redrendermoment = 'Render Red'}

local isfile = isfile or function(file)
    local success, filecontents = pcall(function() return readfile(file) end)
    return success and type(filecontents) == 'string'
end

local function errorNotification(title, text, duration)
    pcall(function()
         local notification = GuiLibrary.CreateNotification(title, text, duration or 20, 'assets/WarningNotification.png')
         notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
         notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
    end)
end

function RenderFunctions:GithubHash(repo, owner)
    local html = httprequest({Url = 'https://github.com/'..(owner or 'Erchobg')..'/'..(repo or 'vapevoidware')}).Body -- had to use this cause "Arceus X" is absolute bs LMFAO
	for i,v in next, html:split("\n") do 
	    if v:find('commit') and v:find('fragment') then 
	       local str = v:split("/")[5]
	       local success, commit = pcall(function() return str:sub(0, v:split('/')[5]:find('"') - 1) end) 
           if success and commit then 
               return commit 
           end
	    end
	end
    return (repo == 'vapevoidware' and 'source' or 'main')
end

function RenderFunctions:CreateLocalDirectory(directory)
    local splits = tostring(directory:gsub('vape/Libraries/', '')):split('/')
    local last = ''
    for i,v in next, splits do 
        if not isfolder('vape/Libraries') then 
            makefolder('vape/Libraries') 
        end
        if i ~= #splits then 
            last = ('/'..last..'/'..v)
            makefolder('vape/Libraries'..last)
        end
    end 
    return directory
end

--[[function RenderFunctions:RefreshLocalEnv()
    local signal = Instance.new('BindableEvent')
    local start = tick()
    local coreinstalled = 0
    for i,v in next, ({'Universal.lua', 'MainScript.lua', 'NewMainScript.lua', 'GuiLibrary.lua'}) do 
        task.spawn(function()
            local contents = game:HttpGet('https://raw.githubusercontent.com/Erchobg/vapevoidware/main/'..RenderFunctions:GithubHash()..v)
            if contents ~= '404: Not Found' then 
                contents = (tostring(contents:split('\n')[1]):find('Voidware Custom Vape Signed File') and contents or '-- Voidware Custom Vape Signed File\n'..contents)
                if isfolder('vape') then 
                    RenderFunctions:DebugWarning('vape/', v, 'has been overwritten due to updates.')
                    writefile('vape/'..v, contents) 
                    coreinstalled = (coreinstalled + 1)
                end
            end 
        end)
    end
    for i,v in next, ({'6872274481.lua', '6872265039.lua'}) do 
        task.spawn(function()
            local contents = game:HttpGet('https://raw.githubusercontent.com/Erchobg/vapevoidware/main/CustomModules/'..RenderFunctions:GithubHash()..v)
            if contents ~= '404: Not Found' then 
                contents = (tostring(contents:split('\n')[1]):find('Voidware Custom Vape Signed File') and contents or '-- Voidware Custom Vape Signed File\n'..contents)
                if isfolder('vape') then 
                    RenderFunctions:DebugWarning('vape/', v, 'has been overwritten due to updates.')
                    writefile('vape/'..v, contents) 
                    coreinstalled = (coreinstalled + 1)
                end
            end 
        end)
    end
    return signal
end--]]

local cachederrors = {}
function RenderFunctions:GetFile(file, onlineonly, custompath, customrepo)
    if not file or type(file) ~= 'string' then 
        return ''
    end
    customrepo = customrepo or 'vapevoidware'
    local filepath = (custompath and custompath..'/'..file or 'vape/Libraries')..'/'..file
    if not isfile(filepath) or onlineonly then 
        local Rendercommit = RenderFunctions:GithubHash(customrepo)
        local success, body = pcall(function() return game:HttpGet('https://raw.githubusercontent.com/Erchobg/'..customrepo..'/'..Rendercommit..'/'..file, true) end)
        if success and body ~= '404: Not Found' and body ~= '400: Invalid request' then 
            local directory = RenderFunctions:CreateLocalDirectory(filepath)
            body = file:sub(#file - 3, #file) == '.lua' and body:sub(1, 35) ~= 'Voidware Custom Vape Signed File' and '-- Voidware Custom Vape Signed File /n'..body or body
            if not onlineonly then 
                writefile(directory, body)
            end
            return body
        else
            task.spawn(error, '[Voidware] Failed to Download '..filepath..(body and ' | '..body or ''))
            if table.find(cachederrors, file) == nil then 
                errorNotification('Voidware', 'Failed to Download '..filepath..(body and ' | '..body or ''), 30)
                table.insert(cachederrors, file)
            end
        end
    end
    return isfile(filepath) and readfile(filepath) or task.wait(9e9)
end

local announcegui
local lastannouncement
function RenderFunctions:Announcement(tab)
	if lastannouncement then 
		lastannouncement:Remove() 
		lastannouncement = nil 
	end
	tab = (type(tab) == 'table' and tab or {})
	local announceframe = Instance.new('TextButton', GuiLibrary and GuiLibrary.MainGui or announcegui)
	if announceframe.Parent == nil and announcegui == nil then 
		announcegui = Instance.new('ScreenGui', GuiLibrary and GuiLibrary.MainGui or lplr.PlayerGui)
	    pcall(function() announcegui.Parent = (gethui and gethui() or game:GetService('CoreGui')) end) 
		announceframe.Parent = announcegui
	end
	announceframe.Size = UDim2.new(0, 1664, 0, 55)
	announceframe.Position = UDim2.new(0.035, 0, 0, 0)
	announceframe.Text = ''
	announceframe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local announcegradient = Instance.new('UIGradient', announceframe)
	local announcestroke = Instance.new('UIStroke', announceframe)
	local announcestrokgradient = Instance.new('UIGradient', announcestroke)
	local announcetext = Instance.new('TextLabel', announceframe)
	announcegradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 127)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 176))})
	announcestroke.Thickness = 2.3
	announcestroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	announcestroke.Color = Color3.fromRGB(255, 255, 255)
	announcestrokgradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 14, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(1, 69, 255))})
	announcetext.Text = (tab.Text or '')
	announcetext.TextColor3 = Color3.fromRGB(255, 255, 255)
	announcetext.BackgroundTransparency = 1
	announcetext.Position = UDim2.new(0.446, 0, 0.095, 0)
	announcetext.TextSize = 25
	announcetext.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold)
	announcetext.Size = UDim2.new(0.502, 0, 0.794, 0)
    local announcetextconstraint = Instance.new('UITextSizeConstraint', announcetext)
    announcetextconstraint.MinTextSize = 1
    announcetextconstraint.MaxTextSize = 25
    Instance.new('UIAspectRatioConstraint', announceframe).AspectRatio = 27.841
	Instance.new('UICorner', announceframe).CornerRadius = UDim.new(0, 20) 
	tweenService:Create(announceframe, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0.035, 0, 0.081, 0)}):Play()
	task.delay(tab.duration or 20, function()
		announceframe:Remove()
		lastannouncement = nil
	end)
	announceframe.MouseButton1Click:Connect(function()
		announceframe:Remove()
		lastannouncement = nil
	end)
	return announceframe
end

--RenderFunctions:Announcement({Text = 'hi, just testing new annc system ok', Duration = 5})
local function playerfromID(id) -- players:GetPlayerFromUserId() didn't work for some reason :bruh:
    for i,v in next, players:GetPlayers() do 
        if v.UserId == tonumber(id) then 
            return v 
        end
    end
end

local function playerfromName(name)
    for i,v in next, players:GetPlayers() do 
        if v.Name:lower() == name:lower() then 
            return v 
        end
    end
end

local cachedjson
function RenderFunctions:UpdateWhitelist()
    local success, whitelistTable = pcall(function() 
        return cachedjson or httpService:JSONDecode(game.HttpGetAsync(game, 'https://raw.githubusercontent.com/Erchobg/whitelist/main/whitelist.json'))
    end)
    if success and type(whitelistTable) == 'table' then 
        cachedjson = whitelistTable
        for i,v in next, whitelistTable do 
            if type(v.Accounts) == 'table' then 
                for i2, v2 in next, v.Accounts do 
                    local plr = (playerfromID(v2) or playerfromName(v2))
                    if plr then 
                        v2 = tostring(plr.UserId)
                        rawset(RenderFunctions.playerWhitelists, v2, v)
                        RenderFunctions.playerWhitelists[v2].Priority = (rankTable[v.Rank or 'STANDARD'] or 1)
                        RenderFunctions.playerWhitelists[v2].Priority = (rankTable[v.Rank or 'STANDARD'] or 1)
                        if not v.TagHidden then 
                            RenderFunctions:CreatePlayerTag(plr, v.TagText, v.TagColor)
                        end
                    end
                end
            end 
        end
    end
    local selftab = (RenderFunctions.playerWhitelists[lplr] or {Priority = 1})
    for i,v in next, RenderFunctions.playerWhitelists do 
        if selftab.Priority >= v.Priority then 
            rawset(v, 'Attackable', true)
        end 
    end
    return success
end

table.insert(RenderConnections, players.PlayerAdded:Connect(function()
    repeat task.wait() until RenderFunctions.WhitelistLoaded
    RenderFunctions:UpdateWhitelist()
end))

function RenderFunctions:GetPlayerType(position, plr)
    plr = plr or lplr
    local positionTable = {'Rank', 'Attackable', 'Priority', 'TagText', 'TagColor', 'TagHidden'}
    local defaultTab = {'STANDARD', true, 1, 'SPECIAL USER', 'FFFFFF', true, 0, 'ABCDEFGH'}
    local tab = RenderFunctions.playerWhitelists[tostring(plr.UserId)]
    if tab then 
        return tab[positionTable[tonumber(position or 1)]]
    end
    return defaultTab[tonumber(position or 1)]
end

function RenderFunctions:SpecialNearPosition(maxdistance, bypass, booster)
    maxdistance = maxdistance or 30
    local specialtable = {}
    for i,v in next, RenderFunctions:GetAllSpecial(booster and true) do 
        if v == lplr then 
            continue
        end
        if RenderFunctions:GetPlayerType(3, v) < 2 then 
            continue
        end
        if RenderFunctions:GetPlayerType(2, v) and not bypass then 
            continue
        end
        if not lplr.Character or not lplr.Character.PrimaryPart then 
            continue
        end 
        if not v.Character or not v.Character.PrimaryPart then 
            continue
        end
        local magnitude = (lplr.Character.PrimaryPart - v.Character.PrimaryPart).Magnitude
        if magnitude <= maxdistance then 
            table.insert(specialtable, v)
        end
    end
    return #specialtable > 1 and specialtable or nil
end

function RenderFunctions:SpecialInGame(booster)
    return #RenderFunctions:GetAllSpecial(booster) > 0
end

function RenderFunctions:DebugPrint(...)
    if RenderDebug then 
        task.spawn(print, table.concat({...}, ' ')) 
    end
end

function RenderFunctions:DebugWarning(...)
    if RenderDebug then 
        task.spawn(warn, table.concat({...}, ' ')) 
    end
end

function RenderFunctions:DebugError(...)
    if RenderDebug then
        task.spawn(error, table.concat({...}, ' '))
    end
end

function RenderFunctions:SelfDestruct()
    table.clear(RenderFunctions)
    RenderFunctions = nil 
    getgenv().RenderFunctions = nil 
    if RenderStore then 
        table.clear(RenderStore)
        getgenv().RenderStore = nil 
    end
    for i,v in next, RenderConnections do 
        pcall(function() v:Disconnect() end)
        pcall(function() v:disconnect() end)
    end
end

task.spawn(function()
	for i,v in next, ({'Hex2Color3', 'encodeLib'}) do 
		--task.spawn(function() RenderLibraries[v] = loadstring(RenderFunctions:GetFile('Libraries/'..v..'.lua'))() end)
	end
end)

function RenderFunctions:RunFromLibrary(tablename, func, ...)
	if RenderLibraries[tablename] == nil then 
        repeat task.wait() until RenderLibraries[tablename]
    end 
	return RenderLibraries[tablename][func](...)
end

function RenderFunctions:CreatePlayerTag(plr, text, color)
    plr = plr or lplr 
    RenderFunctions.playerTags[plr] = {}
    RenderFunctions.playerTags[plr].Text = text 
    RenderFunctions.playerTags[plr].Color = color 
    pcall(function() shared.vapeentity.fullEntityRefresh() end)
    return RenderFunctions.playerTags[plr]
end

local loadtime = 0
task.spawn(function()
    repeat task.wait() until shared.VapeFullyLoaded
    loadtime = tick()
end)

function RenderFunctions:LoadTime()
    return loadtime ~= 0 and (tick() - loadtime) or 0
end

function RenderFunctions:AddEntity(ent)
    local tabpos = (#RenderFunctions.entityTable + 1)
    table.insert(RenderFunctions.entityTable, {Name = ent.Name, DisplayName = ent.Name, Character = ent})
    return tabpos
end

function RenderFunctions:GetAllSpecial(nobooster)
    local special = {}
    local prio = (nobooster and 1.5 or 1)
    for i,v in next, players:GetPlayers() do 
        if v ~= lplr and RenderFunctions:GetPlayerType(3, v) > prio then 
            table.insert(special, v)
        end
    end 
    return special
end

function RenderFunctions:RemoveEntity(position)
    RenderFunctions.entityTable[position] = nil
end

function RenderFunctions:AddCommand(name, func)
    rawset(RenderFunctions.commands, name, func or function() end)
end

function RenderFunctions:RemoveCommand(name) 
    rawset(RenderFunctions.commands, name, nil)
end

task.spawn(function()
    local whitelistsuccess, response = pcall(function() return RenderFunctions:UpdateWhitelist() end)
    RenderFunctions.whitelistSuccess = whitelistsuccess
    RenderFunctions.WhitelistLoaded = true
    if not whitelistsuccess or not response then 
        if RenderDeveloper or RenderPrivate then 
            errorNotification('Render', 'Failed to create the whitelist table. | '..(response or 'Failed to Decode JSON'), 10) 
        end
    end
end)

task.spawn(function()
    repeat task.wait() until RenderStore
    table.insert(RenderConnections, RenderStore.MessageReceived.Event:Connect(function(plr, text)
        text = text:gsub('/w '..lplr.Name, '')
        local args = text:split(' ')
        local first, second = tostring(args[1]), tostring(args[2])
        if first:sub(1, 6) == ';cmds' and plr == lplr and RenderFunctions:GetPlayerType(3) > 1 and RenderFunctions:GetPlayerType() ~= 'BETA' then 
            task.wait(0.1)
            for i,v in next, RenderFunctions.commands do 
                if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then 
                    textChatService.ChatInputBarConfiguration.TargetTextChannel:DisplaySystemMessage(i)
                else 
                    game:GetService('StarterGui'):SetCore('ChatMakeSystemMessage', {Text = i,  Color = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, FontSize = Enum.FontSize.Size24})
                end
            end
        end
        for i,v in next, RenderFunctions.hashTable do 
            if text:find(i) and table.find(RenderFunctions.configUsers, plr) == nil then 
                repeat task.wait() until RenderFunctions.WhitelistLoaded
                print('Render - '..plr.DisplayName..' is using '..v..'!')
                local allowed = (RenderFunctions:GetPlayerType(3) > 1 and RenderFunctions:GetPlayerType(3, plr) < RenderFunctions:GetPlayerType(3)) 
                if not allowed then return end 
                if GuiLibrary then 
                    pcall(GuiLibrary.CreateNotification, 'Render', plr.DisplayName..' is using '..v..'!', 100) 
                end
                if RenderFunctions:GetPlayerType(6, plr) then 
                    RenderFunctions:CreatePlayerTag(plr, 'VOIDWARE USER', 'B95CF4') 
                end
                table.insert(RenderFunctions.configUsers, plr)
            end
        end
        if RenderFunctions:GetPlayerType(3, plr) < 1.5 or RenderFunctions:GetPlayerType(3, plr) <= RenderFunctions:GetPlayerType(3) then 
            return 
        end
        for i, command in next, RenderFunctions.commands do 
            if first:sub(1, #i + 1) == ';'..i and (second:lower() == RenderFunctions:GetPlayerType():lower() or lplr.Name:lower():find(second:lower()) or second:lower() == 'all') then 
                pcall(command, args, plr)
                break
            end
        end
    end))
end)


getgenv().RenderFunctions = RenderFunctions
return RenderFunctions
