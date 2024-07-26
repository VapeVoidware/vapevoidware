local GuiLibrary = shared.GuiLibrary
local VoidwareFunctions = {WhitelistLoaded = false, WhitelistRefreshEvent = Instance.new("BindableEvent"), WhitelistSucceeded = false, WhitelistLoadTime = tick()}
local VoidwareLibraries = {}
local startTime = tick()
local timeTaken = tick() - startTime
local vapeGithubRequest = shared.vapeGithubRequest
local RenderFunctions = loadstring(vapeGithubRequest("Libraries/voidwarefunctions.lua"))()
local VoidwareWhitelistStore = {
	Hash = "voidwaremoment",
	BlacklistTable = {},
	Tab = {},
	Rank = "Standard",
	Priority = {
		DEFAULT = 0,
		STANDARD = 1,
		BETA = 1.5,
		INF = 2,
		OWNER = 3
	},
	RankChangeEvent = Instance.new("BindableEvent"),
	chatstrings = {
		voidwaremoment = "Voidware",
		blackwaremoment = "Blackware",
		voidwarelitemoment = "Voidware Lite"
	},
	LocalPlayer = {Rank = "STANDARD", Attackable = true, Priority = 1, TagText = "VOIDWARE USER", TagColor = "0000FF", TagHidden = true, HWID = "ABCDEFG", Accounts = {}, BlacklistedProducts = {}, UID = 0},
	Players = {}
}
local tags = {}
local VoidwareStore = {
	maindirectory = "vape",
	VersionInfo = {
        MainVersion = "3.3",
        PatchVersion = "0",
        Nickname = "Universal Update V2",
		BuildType = "Stable",
		VersionID = "3.3"
    },
	FolderTable = {"vape/Voidware", "vape/Voidware/data"},
	SystemFiles = {"vape/NewMainScript.lua", "vape/MainScript.lua", "vape/GuiLibrary.lua", "vape/Universal.lua"},
	watermark = function(text) return ("[Voidware] "..text) end,
	Tweening = false,
	TimeLoaded = tick(),
	CurrentPing = 0,
	HumanoidDied = Instance.new("BindableEvent"),
	MobileInUse = (platform == Enum.Platform.Android or platform == Enum.Platform.IOS) and true or false,
	vapePrivateCommands = {},
	Enums = {},
	jumpTick = tick(),
	entityIDs = shared.VoidwareStore and type(shared.VoidwareStore.entityIDs) == "table" and shared.VoidwareStore.entityIDs or {fakeIDs = {}},
	bedtable = {},
	oldchatTabs = {
		oldchanneltab = nil,
		oldchannelfunc = nil,
		oldchanneltabs = {}
	},
	AverageFPS = 60,
	FrameRate = 60,
	AliveTick = tick(),
	DeathFunction = nil,
	vapeupdateroutine = nil,
	entityTable = {},
	objectraycast = RaycastParams.new()
}
local playersService = game:GetService("Players")
local textService = game:GetService("TextService")
local lightingService = game:GetService("Lighting")
local textChatService = game:GetService("TextChatService")
local inputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local TweenService = tweenService
local collectionService = game:GetService("CollectionService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local replicatedStorageService = replicatedStorage
local gameCamera = workspace.CurrentCamera
local cam = gameCamera
local lplr = playersService.LocalPlayer
local vapeConnections
if shared.vapeConnections and type(shared.vapeConnections) == "table" then vapeConnections = shared.vapeConnections else vapeConnections = {} shared.vapeConnections = vapeConnections end
local vapeCachedAssets = {}
local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new("BindableEvent")
		return self[index]
	end
})
local vapeTargetInfo = shared.VapeTargetInfo
local vapeInjected = true

local bedwars = {}
local store = {
	attackReach = 0,
	attackReachUpdate = tick(),
	blocks = {},
	blockPlacer = {},
	blockPlace = tick(),
	blockRaycast = RaycastParams.new(),
	equippedKit = "none",
	forgeMasteryPoints = 0,
	forgeUpgrades = {},
	grapple = tick(),
	switchdelay = tick(),
	inventories = {},
	localInventory = {
		inventory = {
			items = {},
			armor = {}
		},
		hotbar = {}
	},
	localHand = {},
	matchState = 0,
	matchStateChanged = tick(),
	pots = {},
	queueType = "bedwars_test",
	scythe = tick(),
	statistics = {
		beds = 0,
		kills = 0,
		lagbacks = 0,
		lagbackEvent = Instance.new("BindableEvent"),
		reported = 0,
		universalLagbacks = 0
	},
	whitelist = {
		chatStrings1 = {helloimusinginhaler = "vape"},
		chatStrings2 = {vape = "helloimusinginhaler"},
		clientUsers = {},
		oldChatFunctions = {}
	},
	zephyrOrb = 0
}

local sendmessage = function() end
sendmessage = function(text)
	if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(text)
	else
		replicatedStorageService.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, 'All')
	end
end

local newcolor = function() return {Hue = 0, Sat = 0, Value = 0} end

void = {}

void.round = function(x : Number)
	return x % 0.1 >= 0.05 and x + (0.1 - x % 0.1) or x - x % 0.1;
end

void.version = VoidwareStore.VersionInfo.MainVersion

void.load = tick()

store.blockRaycast.FilterType = Enum.RaycastFilterType.Include
local AutoLeave = {Enabled = false}
local function GetBedTeam(bedtomark)
    for i,v in pairs(game.Teams:GetChildren()) do
        if bedtomark.Blanket.BrickColor == v.TeamColor then
	        VoidwareStore.bedtable[bedtomark] = v.Name
	       break
      end
    end
end

local function isAlive(plr, healthblacklist)
	plr = plr or lplr
	local alive = false 
	if plr.Character and plr.Character.PrimaryPart and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then 
		alive = true
	end
	if not healthblacklist and alive and plr.Character.Humanoid.Health and plr.Character.Humanoid.Health <= 0 then 
		alive = false
	end
	return alive
end

local gethighestblock = function() return nil end

gethighestblock = function(position, smart, raycast, customvector)
	if not position then 
		return nil 
	end
	if raycast and not workspace:Raycast(position, Vector3.new(0, -2000, 0), store.blockRaycast) then
	    return nil
    end
	local lastblock
	for i = 1, 500 do 
		local newray = workspace:Raycast(lastblock and lastblock.Position or position, customvector or Vector3.new(0.55, 9e9, 0.55), store.blockRaycast)
		local smartest = newray and smart and workspace:Raycast(lastblock and lastblock.Position or position, Vector3.new(0, 5.5, 0), store.blockRaycast) or not smart
		if newray and smartest then
			lastblock = newray
		else
			break
		end
	end
	return lastblock
end

table.insert(vapeConnections, collectionService:GetInstanceAddedSignal("bed"):Connect(function(bed)
	task.spawn(GetBedTeam, bed)
end))

task.spawn(function()
	pcall(function()
		for i,v in pairs(collectionService:GetTagged("bed")) do
		pcall(GetBedTeam, v)
		end
	end)
end)

table.insert(vapeConnections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA("Camera")
end))
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local networkownerswitch = tick()
--ME WHEN THE MOBILE EXPLOITS ADD A DISFUNCTIONAL ISNETWORKOWNER (its for compatability I swear!!)
local isnetworkowner = function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, "NetworkOwnershipRule") end)
	if suc and res == Enum.NetworkOwnership.Manual then
		sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end
local getcustomasset = getsynasset or getcustomasset or function(location) return "rbxasset://"..location end
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end
local synapsev3 = syn and syn.toast_notification and "V3" or ""
local worldtoscreenpoint = function(pos)
	if synapsev3 == "V3" then
		local scr = worldtoscreen({pos})
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0
	end
	return gameCamera.WorldToScreenPoint(gameCamera, pos)
end
local worldtoviewportpoint = function(pos)
	if synapsev3 == "V3" then
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return gameCamera.WorldToViewportPoint(gameCamera, pos)
end

local function downloadVapeAsset(path)
	if not isfile(path) then
		task.spawn(function()
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = "Downloading "..path
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = GuiLibrary.MainGui
			--repeat task.wait() until isfile(path)
			task.wait(0.2)
			textlabel:Destroy()
		end)
		local suc, req = pcall(function() return vapeGithubRequest(path:gsub("vape/assets", "assets")) end)
        if suc and req then
		    writefile(path, req)
        else
            return ""
        end
	end
	if not vapeCachedAssets[path] then vapeCachedAssets[path] = getcustomasset(path) end
	return vapeCachedAssets[path]
end

-- old warning notification
--[[local function warningNotification(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/WarningNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
		return frame
	end)
	return (suc and res)
end--]]

local function warningNotification(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/InfoNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
		return frame
	end)
	return (suc and res)
end

local function InfoNotification(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title or "Voidware", text or "Successfully called function", delay or 7, "assets/InfoNotification.png")
		return frame
	end)
	return (suc and res)
end

local function isFriend(plr, recolor)
	if GuiLibrary.ObjectsThatCanBeSaved["Use FriendsToggle"].Api.Enabled then
		local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectList, plr.Name)
		friend = friend and GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectListEnabled[friend]
		if recolor then
			friend = friend and GuiLibrary.ObjectsThatCanBeSaved["Recolor visualsToggle"].Api.Enabled
		end
		return friend
	end
	return nil
end

local function isTarget(plr)
	local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectList, plr.Name)
	friend = friend and GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectListEnabled[friend]
	return friend
end

local function isVulnerable(plr)
	return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, "ForceField")
end

local function getPlayerColor(plr)
	if isFriend(plr, true) then
		return Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Value)
	end
	return tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color
end

local function LaunchAngle(v, g, d, h, higherArc)
	local v2 = v * v
	local v4 = v2 * v2
	local root = -math.sqrt(v4 - g*(g*d*d + 2*h*v2))
	return math.atan((v2 + root) / (g * d))
end

local function LaunchDirection(start, target, v, g)
	local horizontal = Vector3.new(target.X - start.X, 0, target.Z - start.Z)
	local h = target.Y - start.Y
	local d = horizontal.Magnitude
	local a = LaunchAngle(v, g, d, h)

	if a ~= a then
		return g == 0 and (target - start).Unit * v
	end

	local vec = horizontal.Unit * v
	local rotAxis = Vector3.new(-horizontal.Z, 0, horizontal.X)
	return CFrame.fromAxisAngle(rotAxis, a) * vec
end

local physicsUpdate = 1 / 60

local function predictGravity(playerPosition, vel, bulletTime, targetPart, Gravity)
	local estimatedVelocity = vel.Y
	local rootSize = (targetPart.Humanoid.HipHeight + (targetPart.RootPart.Size.Y / 2))
	local velocityCheck = (tick() - targetPart.JumpTick) < 0.2
	vel = vel * physicsUpdate

	for i = 1, math.ceil(bulletTime / physicsUpdate) do
		if velocityCheck then
			estimatedVelocity = estimatedVelocity - (Gravity * physicsUpdate)
		else
			estimatedVelocity = 0
			playerPosition = playerPosition + Vector3.new(0, -0.03, 0) -- bw hitreg is so bad that I have to add this LOL
			rootSize = rootSize - 0.03
		end

		local floorDetection = workspace:Raycast(playerPosition, Vector3.new(vel.X, (estimatedVelocity * physicsUpdate) - rootSize, vel.Z), store.blockRaycast)
		if floorDetection then
			playerPosition = Vector3.new(playerPosition.X, floorDetection.Position.Y + rootSize, playerPosition.Z)
			local bouncepad = floorDetection.Instance:FindFirstAncestor("gumdrop_bounce_pad")
			if bouncepad and bouncepad:GetAttribute("PlacedByUserId") == targetPart.Player.UserId then
				estimatedVelocity = 130 - (Gravity * physicsUpdate)
				velocityCheck = true
			else
				estimatedVelocity = targetPart.Humanoid.JumpPower - (Gravity * physicsUpdate)
				velocityCheck = targetPart.Jumping
			end
		end

		playerPosition = playerPosition + Vector3.new(vel.X, velocityCheck and estimatedVelocity * physicsUpdate or 0, vel.Z)
	end

	return playerPosition, Vector3.new(0, 0, 0)
end

local entityLibrary = shared.vapeentity
local whitelist = shared.vapewhitelist
local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = runService.Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = runService.Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

shared.RunLoops = RunLoops

GuiLibrary.SelfDestructEvent.Event:Connect(function()
	vapeInjected = false
	for i, v in pairs(vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
	for i, v in pairs(shared.vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
	shared.RunLoops = nil
	shared.vapeConnections = nil
	shared.GlobalStore = nil
end)

local function getItem(itemName, inv)
	for slot, item in pairs(inv or store.localInventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end

local function getItemNear(itemName, inv)
	for slot, item in pairs(inv or store.localInventory.inventory.items) do
		if item.itemType == itemName or item.itemType:find(itemName) then
			return item, slot
		end
	end
	return nil
end

local function getHotbarSlot(itemName)
	for slotNumber, slotTable in pairs(store.localInventory.hotbar) do
		if slotTable.item and slotTable.item.itemType == itemName then
			return slotNumber - 1
		end
	end
	return nil
end

local function getShieldAttribute(char)
	local returnedShield = 0
	for attributeName, attributeValue in pairs(char:GetAttributes()) do
		if attributeName:find("Shield") and type(attributeValue) == "number" then
			returnedShield = returnedShield + attributeValue
		end
	end
	return returnedShield
end

local function getPickaxe()
	return getItemNear("pick")
end

local function getAxe()
	local bestAxe, bestAxeSlot = nil, nil
	for slot, item in pairs(store.localInventory.inventory.items) do
		if item.itemType:find("axe") and item.itemType:find("pickaxe") == nil and item.itemType:find("void") == nil then
			bextAxe, bextAxeSlot = item, slot
		end
	end
	return bestAxe, bestAxeSlot
end

local function getSword()
	local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
	for slot, item in pairs(store.localInventory.inventory.items) do
		local swordMeta = bedwars.ItemTable[item.itemType].sword
		if swordMeta then
			local swordDamage = swordMeta.damage or 0
			if swordDamage > bestSwordDamage then
				bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
			end
		end
	end
	return bestSword, bestSwordSlot
end

local function getBow()
	local bestBow, bestBowSlot, bestBowStrength = nil, nil, 0
	for slot, item in pairs(store.localInventory.inventory.items) do
		if item.itemType:find("bow") then
			local tab = bedwars.ItemTable[item.itemType].projectileSource
			local ammo = tab.projectileType("arrow")
			local dmg = bedwars.ProjectileMeta[ammo].combat.damage
			if dmg > bestBowStrength then
				bestBow, bestBowSlot, bestBowStrength = item, slot, dmg
			end
		end
	end
	return bestBow, bestBowSlot
end

local function getWool()
	local wool = getItemNear("wool")
	return wool and wool.itemType, wool and wool.amount
end

local function getBlock()
	for slot, item in pairs(store.localInventory.inventory.items) do
		if bedwars.ItemTable[item.itemType].block then
			return item.itemType, item.amount
		end
	end
end

local function attackValue(vec)
	return {value = vec}
end

local function getSpeed()
	local speed = 0
	if lplr.Character then
		local SpeedDamageBoost = lplr.Character:GetAttribute("SpeedBoost")
		if SpeedDamageBoost and SpeedDamageBoost > 1 then
			speed = speed + (8 * (SpeedDamageBoost - 1))
		end
		if store.grapple > tick() then
			speed = speed + 90
		end
		if store.scythe > tick() then
			speed = speed + 5
		end
		if lplr.Character:GetAttribute("GrimReaperChannel") then
			speed = speed + 20
		end
		local armor = store.localInventory.inventory.armor[3]
		if type(armor) ~= "table" then armor = {itemType = ""} end
		if armor.itemType == "speed_boots" then
			speed = speed + 12
		end
		if store.zephyrOrb ~= 0 then
			speed = speed + 12
		end
	end
	return speed
end

local Reach = {Enabled = false}
local blacklistedblocks = {
	bed = true,
	ceramic = true
}
local cachedNormalSides = {}
for i,v in pairs(Enum.NormalId:GetEnumItems()) do if v.Name ~= "Bottom" then table.insert(cachedNormalSides, v) end end
local updateitem = Instance.new("BindableEvent")
local inputobj = nil
local tempconnection
tempconnection = inputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		inputobj = input
		tempconnection:Disconnect()
	end
end)
table.insert(vapeConnections, updateitem.Event:Connect(function(inputObj)
	if inputService:IsMouseButtonPressed(0) then
		game:GetService("ContextActionService"):CallFunction("block-break", Enum.UserInputState.Begin, inputobj)
	end
end))

local function getPlacedBlock(pos)
	local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local oldpos = Vector3.zero

local function getScaffold(vec, diagonaltoggle)
	local realvec = Vector3.new(math.floor((vec.X / 3) + 0.5) * 3, math.floor((vec.Y / 3) + 0.5) * 3, math.floor((vec.Z / 3) + 0.5) * 3)
	local speedCFrame = (oldpos - realvec)
	local returedpos = realvec
	if entityLibrary.isAlive then
		local angle = math.deg(math.atan2(-entityLibrary.character.Humanoid.MoveDirection.X, -entityLibrary.character.Humanoid.MoveDirection.Z))
		local goingdiagonal = (angle >= 130 and angle <= 150) or (angle <= -35 and angle >= -50) or (angle >= 35 and angle <= 50) or (angle <= -130 and angle >= -150)
		if goingdiagonal and ((speedCFrame.X == 0 and speedCFrame.Z ~= 0) or (speedCFrame.X ~= 0 and speedCFrame.Z == 0)) and diagonaltoggle then
			return oldpos
		end
	end
    return realvec
end

local function getBestTool(block)
	local tool = nil
	local blockmeta = bedwars.ItemTable[block]
	local blockType = blockmeta.block and blockmeta.block.breakType
	if blockType then
		local best = 0
		for i,v in pairs(store.localInventory.inventory.items) do
			local meta = bedwars.ItemTable[v.itemType]
			if meta.breakBlock and meta.breakBlock[blockType] and meta.breakBlock[blockType] >= best then
				best = meta.breakBlock[blockType]
				tool = v
			end
		end
	end
	return tool
end

local function switchItem(tool)
	if lplr.Character.HandInvItem.Value ~= tool then
		bedwars.Client:Get(bedwars.EquipItemRemote):CallServerAsync({
			hand = tool
		})
		local started = tick()
		repeat task.wait() until (tick() - started) > 0.3 or lplr.Character.HandInvItem.Value == tool
	end
end

local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if tool and (entityLibrary.isAlive and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value ~= tool.tool) then
		if legit then
			if getHotbarSlot(tool.itemType) then
				bedwars.ClientStoreHandler:dispatch({
					type = "InventorySelectHotbarSlot",
					slot = getHotbarSlot(tool.itemType)
				})
				vapeEvents.InventoryChanged.Event:Wait()
				updateitem:Fire(inputobj)
				return true
			else
				return false
			end
		end
		switchItem(tool.tool)
	end
end

local function isBlockCovered(pos)
	local coveredsides = 0
	for i, v in pairs(cachedNormalSides) do
		local blockpos = (pos + (Vector3.FromNormalId(v) * 3))
		local block = getPlacedBlock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #cachedNormalSides
end

local function GetPlacedBlocksNear(pos, normal)
	local blocks = {}
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) and (not blacklistedblocks[extrablock.Name]) then
				table.insert(blocks, extrablock.Name)
			end
			lastfound = extrablock
			if not covered then
				break
			end
		else
			break
		end
	end
	return blocks
end

local function getLastCovered(pos, normal)
	local lastfound, lastpos = nil, nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock, extrablockpos = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			lastfound, lastpos = extrablock, extrablockpos
			if not covered then
				break
			end
		else
			break
		end
	end
	return lastfound, lastpos
end

local function getBestBreakSide(pos)
	local softest, softestside = 9e9, Enum.NormalId.Top
	for i,v in pairs(cachedNormalSides) do
		local sidehardness = 0
		for i2,v2 in pairs(GetPlacedBlocksNear(pos, v)) do
			local blockmeta = bedwars.ItemTable[v2].block
			sidehardness = sidehardness + (blockmeta and blockmeta.health or 10)
            if blockmeta then
                local tool = getBestTool(v2)
                if tool then
                    sidehardness = sidehardness - bedwars.ItemTable[tool.itemType].breakBlock[blockmeta.breakType]
                end
            end
		end
		if sidehardness <= softest then
			softest = sidehardness
			softestside = v
		end
	end
	return softestside, softest
end

local function EntityNearPosition(distance, ignore, overridepos)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
				if overridepos and mag > distance then
					mag = (overridepos - v.RootPart.Position).magnitude
				end
                if mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, mag
                end
            end
        end
		if not ignore then
			for i, v in pairs(collectionService:GetTagged("Monster")) do
				if v.PrimaryPart and v:GetAttribute("Team") ~= lplr:GetAttribute("Team") then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "DiamondGuardian", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "GolemBoss", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("Drone")) do
				if v.PrimaryPart and tonumber(v:GetAttribute("PlayerUserId")) ~= lplr.UserId then
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then continue end
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = "Drone", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
		end
	end
	return closestEntity
end

local function EntityNearMouse(distance)
	local closestEntity, closestMagnitude = nil, distance
    if entityLibrary.isAlive then
		local mousepos = inputService.GetMouseLocation(inputService)
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local vec, vis = worldtoscreenpoint(v.RootPart.Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
                if vis and mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, v.Target and -1 or mag
                end
            end
        end
    end
	return closestEntity
end

local function AllNearPosition(distance, amount, sortfunction, prediction)
	local returnedplayer = {}
	local currentamount = 0
    if entityLibrary.isAlive then
		local sortedentities = {}
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
                if mag <= distance then
					table.insert(sortedentities, v)
                end
            end
        end
		for i, v in pairs(collectionService:GetTagged("Monster")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
					if v:GetAttribute("Team") == lplr:GetAttribute("Team") then continue end
                    table.insert(sortedentities, {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645), GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "DiamondGuardian", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "GolemBoss", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("Drone")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
					if tonumber(v:GetAttribute("PlayerUserId")) == lplr.UserId then continue end
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then continue end
                    table.insert(sortedentities, {Player = {Name = "Drone", UserId = 1443379645}, GetAttribute = function() return "none" end, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(store.pots) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "Pot", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = {Health = 100, MaxHealth = 100}})
                end
			end
		end
		if sortfunction then
			table.sort(sortedentities, sortfunction)
		end
		for i,v in pairs(sortedentities) do
			table.insert(returnedplayer, v)
			currentamount = currentamount + 1
			if currentamount >= amount then break end
		end
	end
	return returnedplayer
end

--pasted from old source since gui code is hard
local function CreateAutoHotbarGUI(children2, argstable)
	local buttonapi = {}
	buttonapi["Hotbars"] = {}
	buttonapi["CurrentlySelected"] = 1
	local currentanim
	local amount = #children2:GetChildren()
	local sortableitems = {
		{itemType = "swords", itemDisplayType = "diamond_sword"},
		{itemType = "pickaxes", itemDisplayType = "diamond_pickaxe"},
		{itemType = "axes", itemDisplayType = "diamond_axe"},
		{itemType = "shears", itemDisplayType = "shears"},
		{itemType = "wool", itemDisplayType = "wool_white"},
		{itemType = "iron", itemDisplayType = "iron"},
		{itemType = "diamond", itemDisplayType = "diamond"},
		{itemType = "emerald", itemDisplayType = "emerald"},
		{itemType = "bows", itemDisplayType = "wood_bow"},
	}
	local items = bedwars.ItemTable
	if items then
		for i2,v2 in pairs(items) do
			if (i2:find("axe") == nil or i2:find("void")) and i2:find("bow") == nil and i2:find("shears") == nil and i2:find("wool") == nil and v2.sword == nil and v2.armor == nil and v2["dontGiveItem"] == nil and bedwars.ItemTable[i2] and bedwars.ItemTable[i2].image then
				table.insert(sortableitems, {itemType = i2, itemDisplayType = i2})
			end
		end
	end
	local buttontext = Instance.new("TextButton")
	buttontext.AutoButtonColor = false
	buttontext.BackgroundTransparency = 1
	buttontext.Name = "ButtonText"
	buttontext.Text = ""
	buttontext.Name = argstable["Name"]
	buttontext.LayoutOrder = 1
	buttontext.Size = UDim2.new(1, 0, 0, 40)
	buttontext.Active = false
	buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
	buttontext.TextSize = 17
	buttontext.Font = Enum.Font.SourceSans
	buttontext.Position = UDim2.new(0, 0, 0, 0)
	buttontext.Parent = children2
	local toggleframe2 = Instance.new("Frame")
	toggleframe2.Size = UDim2.new(0, 200, 0, 31)
	toggleframe2.Position = UDim2.new(0, 10, 0, 4)
	toggleframe2.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	toggleframe2.Name = "ToggleFrame2"
	toggleframe2.Parent = buttontext
	local toggleframe1 = Instance.new("Frame")
	toggleframe1.Size = UDim2.new(0, 198, 0, 29)
	toggleframe1.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	toggleframe1.BorderSizePixel = 0
	toggleframe1.Name = "ToggleFrame1"
	toggleframe1.Position = UDim2.new(0, 1, 0, 1)
	toggleframe1.Parent = toggleframe2
	local addbutton = Instance.new("ImageLabel")
	addbutton.BackgroundTransparency = 1
	addbutton.Name = "AddButton"
	addbutton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	addbutton.Position = UDim2.new(0, 93, 0, 9)
	addbutton.Size = UDim2.new(0, 12, 0, 12)
	addbutton.ImageColor3 = Color3.fromRGB(5, 133, 104)
	addbutton.Image = downloadVapeAsset("vape/assets/AddItem.png")
	addbutton.Parent = toggleframe1
	local children3 = Instance.new("Frame")
	children3.Name = argstable["Name"].."Children"
	children3.BackgroundTransparency = 1
	children3.LayoutOrder = amount
	children3.Size = UDim2.new(0, 220, 0, 0)
	children3.Parent = children2
	local uilistlayout = Instance.new("UIListLayout")
	uilistlayout.Parent = children3
	uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		children3.Size = UDim2.new(1, 0, 0, uilistlayout.AbsoluteContentSize.Y)
	end)
	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, 5)
	uicorner.Parent = toggleframe1
	local uicorner2 = Instance.new("UICorner")
	uicorner2.CornerRadius = UDim.new(0, 5)
	uicorner2.Parent = toggleframe2
	buttontext.MouseEnter:Connect(function()
		tweenService:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(79, 78, 79)}):Play()
	end)
	buttontext.MouseLeave:Connect(function()
		tweenService:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(38, 37, 38)}):Play()
	end)
	local ItemListBigFrame = Instance.new("Frame")
	ItemListBigFrame.Size = UDim2.new(1, 0, 1, 0)
	ItemListBigFrame.Name = "ItemList"
	ItemListBigFrame.BackgroundTransparency = 1
	ItemListBigFrame.Visible = false
	ItemListBigFrame.Parent = GuiLibrary.MainGui
	local ItemListFrame = Instance.new("Frame")
	ItemListFrame.Size = UDim2.new(0, 660, 0, 445)
	ItemListFrame.Position = UDim2.new(0.5, -330, 0.5, -223)
	ItemListFrame.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListFrame.Parent = ItemListBigFrame
	local ItemListExitButton = Instance.new("ImageButton")
	ItemListExitButton.Name = "ItemListExitButton"
	ItemListExitButton.ImageColor3 = Color3.fromRGB(121, 121, 121)
	ItemListExitButton.Size = UDim2.new(0, 24, 0, 24)
	ItemListExitButton.AutoButtonColor = false
	ItemListExitButton.Image = downloadVapeAsset("vape/assets/ExitIcon1.png")
	ItemListExitButton.Visible = true
	ItemListExitButton.Position = UDim2.new(1, -31, 0, 8)
	ItemListExitButton.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListExitButton.Parent = ItemListFrame
	local ItemListExitButtonround = Instance.new("UICorner")
	ItemListExitButtonround.CornerRadius = UDim.new(0, 16)
	ItemListExitButtonround.Parent = ItemListExitButton
	ItemListExitButton.MouseEnter:Connect(function()
		tweenService:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(60, 60, 60), ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)
	ItemListExitButton.MouseLeave:Connect(function()
		tweenService:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(26, 25, 26), ImageColor3 = Color3.fromRGB(121, 121, 121)}):Play()
	end)
	ItemListExitButton.MouseButton1Click:Connect(function()
		ItemListBigFrame.Visible = false
		GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = true
	end)
	local ItemListFrameShadow = Instance.new("ImageLabel")
	ItemListFrameShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	ItemListFrameShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	ItemListFrameShadow.Image = downloadVapeAsset("vape/assets/WindowBlur.png")
	ItemListFrameShadow.BackgroundTransparency = 1
	ItemListFrameShadow.ZIndex = -1
	ItemListFrameShadow.Size = UDim2.new(1, 6, 1, 6)
	ItemListFrameShadow.ImageColor3 = Color3.new(0, 0, 0)
	ItemListFrameShadow.ScaleType = Enum.ScaleType.Slice
	ItemListFrameShadow.SliceCenter = Rect.new(10, 10, 118, 118)
	ItemListFrameShadow.Parent = ItemListFrame
	local ItemListFrameText = Instance.new("TextLabel")
	ItemListFrameText.Size = UDim2.new(1, 0, 0, 41)
	ItemListFrameText.BackgroundTransparency = 1
	ItemListFrameText.Name = "WindowTitle"
	ItemListFrameText.Position = UDim2.new(0, 0, 0, 0)
	ItemListFrameText.TextXAlignment = Enum.TextXAlignment.Left
	ItemListFrameText.Font = Enum.Font.SourceSans
	ItemListFrameText.TextSize = 17
	ItemListFrameText.Text = "    New AutoHotbar"
	ItemListFrameText.TextColor3 = Color3.fromRGB(201, 201, 201)
	ItemListFrameText.Parent = ItemListFrame
	local ItemListBorder1 = Instance.new("Frame")
	ItemListBorder1.BackgroundColor3 = Color3.fromRGB(40, 39, 40)
	ItemListBorder1.BorderSizePixel = 0
	ItemListBorder1.Size = UDim2.new(1, 0, 0, 1)
	ItemListBorder1.Position = UDim2.new(0, 0, 0, 41)
	ItemListBorder1.Parent = ItemListFrame
	local ItemListFrameCorner = Instance.new("UICorner")
	ItemListFrameCorner.CornerRadius = UDim.new(0, 4)
	ItemListFrameCorner.Parent = ItemListFrame
	local ItemListFrame1 = Instance.new("Frame")
	ItemListFrame1.Size = UDim2.new(0, 112, 0, 113)
	ItemListFrame1.Position = UDim2.new(0, 10, 0, 71)
	ItemListFrame1.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	ItemListFrame1.Name = "ItemListFrame1"
	ItemListFrame1.Parent = ItemListFrame
	local ItemListFrame2 = Instance.new("Frame")
	ItemListFrame2.Size = UDim2.new(0, 110, 0, 111)
	ItemListFrame2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ItemListFrame2.BorderSizePixel = 0
	ItemListFrame2.Name = "ItemListFrame2"
	ItemListFrame2.Position = UDim2.new(0, 1, 0, 1)
	ItemListFrame2.Parent = ItemListFrame1
	local ItemListFramePicker = Instance.new("ScrollingFrame")
	ItemListFramePicker.Size = UDim2.new(0, 495, 0, 220)
	ItemListFramePicker.Position = UDim2.new(0, 144, 0, 122)
	ItemListFramePicker.BorderSizePixel = 0
	ItemListFramePicker.ScrollBarThickness = 3
	ItemListFramePicker.ScrollBarImageTransparency = 0.8
	ItemListFramePicker.VerticalScrollBarInset = Enum.ScrollBarInset.None
	ItemListFramePicker.BackgroundTransparency = 1
	ItemListFramePicker.Parent = ItemListFrame
	local ItemListFramePickerGrid = Instance.new("UIGridLayout")
	ItemListFramePickerGrid.CellPadding = UDim2.new(0, 4, 0, 3)
	ItemListFramePickerGrid.CellSize = UDim2.new(0, 51, 0, 52)
	ItemListFramePickerGrid.Parent = ItemListFramePicker
	ItemListFramePickerGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ItemListFramePicker.CanvasSize = UDim2.new(0, 0, 0, ItemListFramePickerGrid.AbsoluteContentSize.Y * (1 / GuiLibrary["MainRescale"].Scale))
	end)
	local ItemListcorner = Instance.new("UICorner")
	ItemListcorner.CornerRadius = UDim.new(0, 5)
	ItemListcorner.Parent = ItemListFrame1
	local ItemListcorner2 = Instance.new("UICorner")
	ItemListcorner2.CornerRadius = UDim.new(0, 5)
	ItemListcorner2.Parent = ItemListFrame2
	local selectedslot = 1
	local hoveredslot = 0

	local refreshslots
	local refreshList
	refreshslots = function()
		local startnum = 144
		local oldhovered = hoveredslot
		for i2,v2 in pairs(ItemListFrame:GetChildren()) do
			if v2.Name:find("ItemSlot") then
				v2:Remove()
			end
		end
		for i3,v3 in pairs(ItemListFramePicker:GetChildren()) do
			if v3:IsA("TextButton") then
				v3:Remove()
			end
		end
		for i4,v4 in pairs(sortableitems) do
			local ItemFrame = Instance.new("TextButton")
			ItemFrame.Text = ""
			ItemFrame.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
			ItemFrame.Parent = ItemListFramePicker
			ItemFrame.AutoButtonColor = false
			local ItemFrameIcon = Instance.new("ImageLabel")
			ItemFrameIcon.Size = UDim2.new(0, 32, 0, 32)
			ItemFrameIcon.Image = bedwars.getIcon({itemType = v4.itemDisplayType}, true)
			ItemFrameIcon.ResampleMode = (bedwars.getIcon({itemType = v4.itemDisplayType}, true):find("rbxasset://") and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemFrameIcon.Position = UDim2.new(0, 10, 0, 10)
			ItemFrameIcon.BackgroundTransparency = 1
			ItemFrameIcon.Parent = ItemFrame
			local ItemFramecorner = Instance.new("UICorner")
			ItemFramecorner.CornerRadius = UDim.new(0, 5)
			ItemFramecorner.Parent = ItemFrame
			ItemFrame.MouseButton1Click:Connect(function()
				for i5,v5 in pairs(buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"]) do
					if v5.itemType == v4.itemType then
						buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(i5)] = nil
					end
				end
				buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(selectedslot)] = v4
				refreshslots()
				refreshList()
			end)
		end
		for i = 1, 9 do
			local item = buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(i)]
			local ItemListFrame3 = Instance.new("Frame")
			ItemListFrame3.Size = UDim2.new(0, 55, 0, 56)
			ItemListFrame3.Position = UDim2.new(0, startnum - 2, 0, 380)
			ItemListFrame3.BackgroundTransparency = (selectedslot == i and 0 or 1)
			ItemListFrame3.BackgroundColor3 = Color3.fromRGB(35, 34, 35)
			ItemListFrame3.Name = "ItemSlot"
			ItemListFrame3.Parent = ItemListFrame
			local ItemListFrame4 = Instance.new("TextButton")
			ItemListFrame4.Size = UDim2.new(0, 51, 0, 52)
			ItemListFrame4.BackgroundColor3 = (oldhovered == i and Color3.fromRGB(31, 30, 31) or Color3.fromRGB(20, 20, 20))
			ItemListFrame4.BorderSizePixel = 0
			ItemListFrame4.AutoButtonColor = false
			ItemListFrame4.Text = ""
			ItemListFrame4.Name = "ItemListFrame4"
			ItemListFrame4.Position = UDim2.new(0, 2, 0, 2)
			ItemListFrame4.Parent = ItemListFrame3
			local ItemListImage = Instance.new("ImageLabel")
			ItemListImage.Size = UDim2.new(0, 32, 0, 32)
			ItemListImage.BackgroundTransparency = 1
			local img = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or "")
			ItemListImage.Image = img
			ItemListImage.ResampleMode = (img:find("rbxasset://") and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemListImage.Position = UDim2.new(0, 10, 0, 10)
			ItemListImage.Parent = ItemListFrame4
			local ItemListcorner3 = Instance.new("UICorner")
			ItemListcorner3.CornerRadius = UDim.new(0, 5)
			ItemListcorner3.Parent = ItemListFrame3
			local ItemListcorner4 = Instance.new("UICorner")
			ItemListcorner4.CornerRadius = UDim.new(0, 5)
			ItemListcorner4.Parent = ItemListFrame4
			ItemListFrame4.MouseEnter:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
				hoveredslot = i
			end)
			ItemListFrame4.MouseLeave:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				hoveredslot = 0
			end)
			ItemListFrame4.MouseButton1Click:Connect(function()
				selectedslot = i
				refreshslots()
			end)
			ItemListFrame4.MouseButton2Click:Connect(function()
				buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(i)] = nil
				refreshslots()
				refreshList()
			end)
			startnum = startnum + 55
		end
	end

	local function createHotbarButton(num, items)
		num = tonumber(num) or #buttonapi["Hotbars"] + 1
		local hotbarbutton = Instance.new("TextButton")
		hotbarbutton.Size = UDim2.new(1, 0, 0, 30)
		hotbarbutton.BackgroundTransparency = 1
		hotbarbutton.LayoutOrder = num
		hotbarbutton.AutoButtonColor = false
		hotbarbutton.Text = ""
		hotbarbutton.Parent = children3
		buttonapi["Hotbars"][num] = {["Items"] = items or {}, Object = hotbarbutton, ["Number"] = num}
		local hotbarframe = Instance.new("Frame")
		hotbarframe.BackgroundColor3 = (num == buttonapi["CurrentlySelected"] and Color3.fromRGB(54, 53, 54) or Color3.fromRGB(31, 30, 31))
		hotbarframe.Size = UDim2.new(0, 200, 0, 27)
		hotbarframe.Position = UDim2.new(0, 10, 0, 1)
		hotbarframe.Parent = hotbarbutton
		local uicorner3 = Instance.new("UICorner")
		uicorner3.CornerRadius = UDim.new(0, 5)
		uicorner3.Parent = hotbarframe
		local startpos = 11
		for i = 1, 9 do
			local item = buttonapi["Hotbars"][num]["Items"][tostring(i)]
			local hotbarbox = Instance.new("ImageLabel")
			hotbarbox.Name = i
			hotbarbox.Size = UDim2.new(0, 17, 0, 18)
			hotbarbox.Position = UDim2.new(0, startpos, 0, 5)
			hotbarbox.BorderSizePixel = 0
			hotbarbox.Image = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or "")
			hotbarbox.ResampleMode = ((item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or ""):find("rbxasset://") and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			hotbarbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			hotbarbox.Parent = hotbarframe
			startpos = startpos + 18
		end
		hotbarbutton.MouseButton1Click:Connect(function()
			if buttonapi["CurrentlySelected"] == num then
				ItemListBigFrame.Visible = true
				GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = false
				refreshslots()
			end
			buttonapi["CurrentlySelected"] = num
			refreshList()
		end)
		hotbarbutton.MouseButton2Click:Connect(function()
			if buttonapi["CurrentlySelected"] == num then
				buttonapi["CurrentlySelected"] = (num == 2 and 0 or 1)
			end
			table.remove(buttonapi["Hotbars"], num)
			refreshList()
		end)
	end

	refreshList = function()
		local newnum = 0
		local newtab = {}
		for i3,v3 in pairs(buttonapi["Hotbars"]) do
			newnum = newnum + 1
			newtab[newnum] = v3
		end
		buttonapi["Hotbars"] = newtab
		for i,v in pairs(children3:GetChildren()) do
			if v:IsA("TextButton") then
				v:Remove()
			end
		end
		for i2,v2 in pairs(buttonapi["Hotbars"]) do
			createHotbarButton(i2, v2["Items"])
		end
		GuiLibrary["Settings"][children2.Name..argstable["Name"].."ItemList"] = {["Type"] = "ItemList", ["Items"] = buttonapi["Hotbars"], ["CurrentlySelected"] = buttonapi["CurrentlySelected"]}
	end
	buttonapi["RefreshList"] = refreshList

	buttontext.MouseButton1Click:Connect(function()
		createHotbarButton()
	end)

	GuiLibrary["Settings"][children2.Name..argstable["Name"].."ItemList"] = {["Type"] = "ItemList", ["Items"] = buttonapi["Hotbars"], ["CurrentlySelected"] = buttonapi["CurrentlySelected"]}
	GuiLibrary.ObjectsThatCanBeSaved[children2.Name..argstable["Name"].."ItemList"] = {["Type"] = "ItemList", ["Items"] = buttonapi["Hotbars"], ["Api"] = buttonapi, Object = buttontext}

	return buttonapi
end

GuiLibrary.LoadSettingsEvent.Event:Connect(function(res)
	for i,v in pairs(res) do
		local obj = GuiLibrary.ObjectsThatCanBeSaved[i]
		if obj and v.Type == "ItemList" and obj.Api then
			obj.Api.Hotbars = v.Items
			obj.Api.CurrentlySelected = v.CurrentlySelected
			obj.Api.RefreshList()
		end
	end
end)

local function isWhitelistedBed(bed)
	if bed and bed.Name == 'bed' then
		for i, v in pairs(playersService:GetPlayers()) do
			if bed:GetAttribute("Team"..(v:GetAttribute("Team") or 0).."NoBreak") and not ({whitelist:get(v)})[2] then
				return true
			end
		end
	end
	return false
end

local function dumpRemote(tab)
	for i,v in pairs(tab) do
		if v == "Client" then
			return tab[i + 1]
		end
	end
	return ""
end

local KnitGotten, KnitClient
repeat
	KnitGotten, KnitClient = pcall(function()
		return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
	end)
	if KnitGotten then break end
	task.wait()
until KnitGotten
repeat task.wait() until debug.getupvalue(KnitClient.Start, 1)
local Flamework = require(replicatedStorage["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
local Client = require(replicatedStorage.TS.remotes).default.Client
local InventoryUtil = require(replicatedStorage.TS.inventory["inventory-util"]).InventoryUtil
local OldGet = getmetatable(Client).Get
local OldBreak

bedwars = setmetatable({
	AnimationType = require(replicatedStorage.TS.animation["animation-type"]).AnimationType,
	AnimationUtil = require(replicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].util["animation-util"]).AnimationUtil,
	AppController = require(replicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]).AppController,
	AbilityController = Flamework.resolveDependency("@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController"),
	AbilityUIController = Flamework.resolveDependency("@easy-games/game-core:client/controllers/ability/ability-ui-controller@AbilityUIController"),
	AttackRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.SwordController.sendServerRequest)),
	BalanceFile = require(replicatedStorage.TS.balance["balance-file"]).BalanceFile,
	BatteryRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BatteryController.KnitStart, 1), 1))),
	BlockBreaker = KnitClient.Controllers.BlockBreakController.blockBreaker,
	BlockController = require(replicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
	BlockPlacer = require(replicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer,
	BlockEngine = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
	BlockEngineClientEvents = require(replicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client["block-engine-client-events"]).BlockEngineClientEvents,
	BowConstantsTable = debug.getupvalue(KnitClient.Controllers.ProjectileController.enableBeam, 6),
	CannonAimRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.CannonController.startAiming, 5))),
	CannonLaunchRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.CannonHandController.launchSelf)),
	ClickHold = require(replicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.ui.lib.util["click-hold"]).ClickHold,
	Client = Client,
	ClientConstructor = require(replicatedStorage["rbxts_include"]["node_modules"]["@rbxts"].net.out.client),
	ClientDamageBlock = require(replicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.shared.remotes).BlockEngineRemotes.Client,
	ClientStoreHandler = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
	CombatConstant = require(replicatedStorage.TS.combat["combat-constant"]).CombatConstant,
	ConstantManager = require(replicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].constant["constant-manager"]).ConstantManager,
	ConsumeSoulRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GrimReaperController.consumeSoul)),
	CooldownController = Flamework.resolveDependency("@easy-games/game-core:client/controllers/cooldown/cooldown-controller@CooldownController"),
	DamageIndicator = KnitClient.Controllers.DamageIndicatorController.spawnDamageIndicator,
	DefaultKillEffect = require(lplr.PlayerScripts.TS.controllers.game.locker["kill-effect"].effects["default-kill-effect"]),
	DropItem = KnitClient.Controllers.ItemDropController.dropItemInHand,
	DropItemRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.dropItemInHand)),
	DragonRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.DragonSlayerController.KnitStart, 2), 1))),
	EatRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ConsumeController.onEnable, 1))),
	EquipItemRemote = dumpRemote(debug.getconstants(debug.getproto(require(replicatedStorage.TS.entity.entities["inventory-entity"]).InventoryEntity.equipItem, 3))),
	EmoteMeta = require(replicatedStorage.TS.locker.emote["emote-meta"]).EmoteMeta,
	ForgeConstants = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 2),
	ForgeUtil = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 5),
	GameAnimationUtil = require(replicatedStorage.TS.animation["animation-util"]).GameAnimationUtil,
	EntityUtil = require(replicatedStorage.TS.entity["entity-util"]).EntityUtil,
	getIcon = function(item, showinv)
		local itemmeta = bedwars.ItemTable[item.itemType]
		if itemmeta and showinv then
			return itemmeta.image or ""
		end
		return ""
	end,
	getInventory = function(plr)
		local suc, result = pcall(function()
			return InventoryUtil.getInventory(plr)
		end)
		return (suc and result or {
			items = {},
			armor = {},
			hand = nil
		})
	end,
	GuitarHealRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GuitarController.performHeal)),
	ItemTable = debug.getupvalue(require(replicatedStorage.TS.item["item-meta"]).getItemMeta, 1),
	KillEffectMeta = require(replicatedStorage.TS.locker["kill-effect"]["kill-effect-meta"]).KillEffectMeta,
	KnockbackUtil = require(replicatedStorage.TS.damage["knockback-util"]).KnockbackUtil,
	MatchEndScreenController = Flamework.resolveDependency("client/controllers/game/match/match-end-screen-controller@MatchEndScreenController"),
	MinerRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MinerController.onKitEnabled, 1))),
	MageRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MageController.registerTomeInteraction, 1))),
	MageKitUtil = require(replicatedStorage.TS.games.bedwars.kit.kits.mage["mage-kit-util"]).MageKitUtil,
	PickupMetalRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.MetalDetectorController.KnitStart, 1), 2))),
	PickupRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.checkForPickup)),
	PinataRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.PiggyBankController.KnitStart, 2), 5))),
	ProjectileMeta = require(replicatedStorage.TS.projectile["projectile-meta"]).ProjectileMeta,
	ProjectileRemote = dumpRemote(debug.getconstants(debug.getupvalue(KnitClient.Controllers.ProjectileController.launchProjectileWithValues, 2))),
	QueryUtil = require(replicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).GameQueryUtil,
	QueueCard = require(lplr.PlayerScripts.TS.controllers.global.queue.ui["queue-card"]).QueueCard,
	QueueMeta = require(replicatedStorage.TS.game["queue-meta"]).QueueMeta,
	ReportRemote = dumpRemote(debug.getconstants(require(lplr.PlayerScripts.TS.controllers.global.report["report-controller"]).default.reportPlayer)),
	ResetRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ResetController.createBindable, 1))),
	DinoRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.DinoTamerController.KnitStart, 3))),
	Roact = require(replicatedStorage["rbxts_include"]["node_modules"]["@rbxts"]["roact"].src),
	RuntimeLib = require(replicatedStorage["rbxts_include"].RuntimeLib),
	Shop = require(replicatedStorage.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop,
	ShopItems = debug.getupvalue(debug.getupvalue(require(replicatedStorage.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.getShopItem, 1), 3),
	SoundList = require(replicatedStorage.TS.sound["game-sound"]).GameSound,
	SoundManager = require(replicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).SoundManager,
	SpawnRavenRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.RavenController.spawnRaven)),
	TreeRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BigmanController.KnitStart, 1), 2))),
	TrinityRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.AngelController.onKitEnabled, 1))),
	UILayers = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).UILayers,
	WeldTable = require(replicatedStorage.TS.util["weld-util"]).WeldUtil
}, {
	__index = function(self, ind)
		rawset(self, ind, KnitClient.Controllers[ind])
		return rawget(self, ind)
	end
})
OldBreak = bedwars.BlockController.isBlockBreakable

getmetatable(Client).Get = function(self, remoteName)
	if not vapeInjected then return OldGet(self, remoteName) end
	local originalRemote = OldGet(self, remoteName)
	if remoteName == bedwars.AttackRemote then
		return {
			instance = originalRemote.instance,
			SendToServer = function(self, attackTable, ...)
				local suc, plr = pcall(function() return playersService:GetPlayerFromCharacter(attackTable.entityInstance) end)
				if suc and plr then
					if not ({whitelist:get(plr)})[2] then return end
					if Reach.Enabled then
						local attackMagnitude = ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - attackTable.validate.targetPosition.value).magnitude
						if attackMagnitude > 18 then
							return nil
						end
						attackTable.validate.selfPosition = attackValue(attackTable.validate.selfPosition.value + (attackMagnitude > 14.4 and (CFrame.lookAt(attackTable.validate.selfPosition.value, attackTable.validate.targetPosition.value).lookVector * 4) or Vector3.zero))
					end
					store.attackReach = math.floor((attackTable.validate.selfPosition.value - attackTable.validate.targetPosition.value).magnitude * 100) / 100
					store.attackReachUpdate = tick() + 1
				end
				return originalRemote:SendToServer(attackTable, ...)
			end
		}
	end
	return originalRemote
end

bedwars.BlockController.isBlockBreakable = function(self, breakTable, plr)
	local obj = bedwars.BlockController:getStore():getBlockAt(breakTable.blockPosition)
	if isWhitelistedBed(obj) then return false end
	return OldBreak(self, breakTable, plr)
end

store.blockPlacer = bedwars.BlockPlacer.new(bedwars.BlockEngine, "wool_white")
bedwars.placeBlock = function(speedCFrame, customblock)
	if getItem(customblock) then
		store.blockPlacer.blockType = customblock
		return store.blockPlacer:placeBlock(Vector3.new(speedCFrame.X / 3, speedCFrame.Y / 3, speedCFrame.Z / 3))
	end
end

local healthbarblocktable = {
	blockHealth = -1,
	breakingBlockPosition = Vector3.zero
}

local failedBreak = 0
bedwars.breakBlock = function(pos, effects, normal, bypass, anim)
	if GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then
		return
	end
	if lplr:GetAttribute("DenyBlockBreak") then
		return
	end
	local block, blockpos = nil, nil
	if not bypass then block, blockpos = getLastCovered(pos, normal) end
	if not block then block, blockpos = getPlacedBlock(pos) end
	if blockpos and block then
		if bedwars.BlockEngineClientEvents.DamageBlock:fire(block.Name, blockpos, block):isCancelled() then
			return
		end
		local blockhealthbarpos = {blockPosition = Vector3.zero}
		local blockdmg = 0
		if block and block.Parent ~= nil then
			if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - (blockpos * 3)).magnitude > 30 then return end
			store.blockPlace = tick() + 0.1
			switchToAndUseTool(block)
			blockhealthbarpos = {
				blockPosition = blockpos
			}
			task.spawn(function()
				bedwars.ClientDamageBlock:Get("DamageBlock"):CallServerAsync({
					blockRef = blockhealthbarpos,
					hitPosition = blockpos * 3,
					hitNormal = Vector3.FromNormalId(normal)
				}):andThen(function(result)
					if result ~= "failed" then
						failedBreak = 0
						if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
							local blockdata = bedwars.BlockController:getStore():getBlockData(blockhealthbarpos.blockPosition)
							local blockhealth = blockdata and (blockdata:GetAttribute("Health") or blockdata:GetAttribute(lplr.Name .. "_Health")) or block:GetAttribute("Health")
							healthbarblocktable.blockHealth = blockhealth
							healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
						end
						healthbarblocktable.blockHealth = result == "destroyed" and 0 or healthbarblocktable.blockHealth
						blockdmg = bedwars.BlockController:calculateBlockDamage(lplr, blockhealthbarpos)
						healthbarblocktable.blockHealth = math.max(healthbarblocktable.blockHealth - blockdmg, 0)
						if effects then
							bedwars.BlockBreaker:updateHealthbar(blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute("MaxHealth"), blockdmg, block)
							if healthbarblocktable.blockHealth <= 0 then
								bedwars.BlockBreaker.breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, lplr)
								bedwars.BlockBreaker.healthbarMaid:DoCleaning()
								healthbarblocktable.breakingBlockPosition = Vector3.zero
							else
								bedwars.BlockBreaker.breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, lplr)
							end
						end
						local animation
						if anim then
							animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(1))
							bedwars.ViewmodelController:playAnimation(15)
						end
						task.wait(0.3)
						if animation ~= nil then
							animation:Stop()
							animation:Destroy()
						end
					else
						failedBreak = failedBreak + 1
					end
				end)
			end)
			task.wait(physicsUpdate)
		end
	end
end

local function updateStore(newStore, oldStore)
	if newStore.Game ~= oldStore.Game then
		store.matchState = newStore.Game.matchState
		store.queueType = newStore.Game.queueType or "bedwars_test"
		store.forgeMasteryPoints = newStore.Game.forgeMasteryPoints
		store.forgeUpgrades = newStore.Game.forgeUpgrades
	end
	if newStore.Bedwars ~= oldStore.Bedwars then
		store.equippedKit = newStore.Bedwars.kit ~= "none" and newStore.Bedwars.kit or ""
	end
	if newStore.Inventory ~= oldStore.Inventory then
		local newInventory = (newStore.Inventory and newStore.Inventory.observedInventory or {inventory = {}})
		local oldInventory = (oldStore.Inventory and oldStore.Inventory.observedInventory or {inventory = {}})
		store.localInventory = newStore.Inventory.observedInventory
		if newInventory ~= oldInventory then
			vapeEvents.InventoryChanged:Fire()
		end
		if newInventory.inventory.items ~= oldInventory.inventory.items then
			vapeEvents.InventoryAmountChanged:Fire()
		end
		if newInventory.inventory.hand ~= oldInventory.inventory.hand then
			local currentHand = newStore.Inventory.observedInventory.inventory.hand
			local handType = ""
			if currentHand then
				local handData = bedwars.ItemTable[currentHand.itemType]
				handType = handData.sword and "sword" or handData.block and "block" or currentHand.itemType:find("bow") and "bow"
			end
			store.localHand = {tool = currentHand and currentHand.tool, Type = handType, amount = currentHand and currentHand.amount or 0}
		end
	end
end

table.insert(vapeConnections, bedwars.ClientStoreHandler.changed:connect(updateStore))
updateStore(bedwars.ClientStoreHandler:getState(), {})

for i, v in pairs({"MatchEndEvent", "EntityDeathEvent", "EntityDamageEvent", "BedwarsBedBreak", "BalloonPopped", "AngelProgress"}) do
	bedwars.Client:WaitFor(v):andThen(function(connection)
		table.insert(vapeConnections, connection:Connect(function(...)
			vapeEvents[v]:Fire(...)
		end))
	end)
end
for i, v in pairs({"PlaceBlockEvent", "BreakBlockEvent"}) do
	bedwars.ClientDamageBlock:WaitFor(v):andThen(function(connection)
		table.insert(vapeConnections, connection:Connect(function(...)
			vapeEvents[v]:Fire(...)
		end))
	end)
end

store.blocks = collectionService:GetTagged("block")
store.blockRaycast.FilterDescendantsInstances = {store.blocks}
table.insert(vapeConnections, collectionService:GetInstanceAddedSignal("block"):Connect(function(block)
	table.insert(store.blocks, block)
	store.blockRaycast.FilterDescendantsInstances = {store.blocks}
end))
table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(block)
	block = table.find(store.blocks, block)
	if block then
		table.remove(store.blocks, block)
		store.blockRaycast.FilterDescendantsInstances = {store.blocks}
	end
end))
for _, ent in pairs(collectionService:GetTagged("entity")) do
	if ent.Name == "DesertPotEntity" then
		table.insert(store.pots, ent)
	end
end
table.insert(vapeConnections, collectionService:GetInstanceAddedSignal("entity"):Connect(function(ent)
	if ent.Name == "DesertPotEntity" then
		table.insert(store.pots, ent)
	end
end))
table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal("entity"):Connect(function(ent)
	ent = table.find(store.pots, ent)
	if ent then
		table.remove(store.pots, ent)
	end
end))

local oldZephyrUpdate = bedwars.WindWalkerController.updateJump
bedwars.WindWalkerController.updateJump = function(self, orb, ...)
	store.zephyrOrb = lplr.Character and lplr.Character:GetAttribute("Health") > 0 and orb or 0
	return oldZephyrUpdate(self, orb, ...)
end

GuiLibrary.SelfDestructEvent.Event:Connect(function()
	bedwars.WindWalkerController.updateJump = oldZephyrUpdate
	getmetatable(bedwars.Client).Get = OldGet
	bedwars.BlockController.isBlockBreakable = OldBreak
	store.blockPlacer:disable()
end)

local teleportedServers = false
table.insert(vapeConnections, lplr.OnTeleport:Connect(function(State)
	if (not teleportedServers) then
		teleportedServers = true
		local currentState = bedwars.ClientStoreHandler and bedwars.ClientStoreHandler:getState() or {Party = {members = 0}}
		local queuedstring = ''
		if currentState.Party and currentState.Party.members and #currentState.Party.members > 0 then
			queuedstring = queuedstring..'shared.vapeteammembers = '..#currentState.Party.members..'\n'
		end
		if store.TPString then
			queuedstring = queuedstring..'shared.vapeoverlay = "'..store.TPString..'"\n'
		end
		queueonteleport(queuedstring)
	end
end))

do
	entityLibrary.animationCache = {}
	entityLibrary.groundTick = tick()
	entityLibrary.selfDestruct()
	entityLibrary.isPlayerTargetable = function(plr)
		return lplr:GetAttribute("Team") ~= plr:GetAttribute("Team") and not isFriend(plr) and ({whitelist:get(plr)})[2]
	end
	entityLibrary.characterAdded = function(plr, char, localcheck)
		local id = game:GetService("HttpService"):GenerateGUID(true)
		entityLibrary.entityIds[plr.Name] = id
        if char then
            task.spawn(function()
                local humrootpart = char:WaitForChild("HumanoidRootPart", 10)
                local head = char:WaitForChild("Head", 10)
                local hum = char:WaitForChild("Humanoid", 10)
				if entityLibrary.entityIds[plr.Name] ~= id then return end
                if humrootpart and hum and head then
					local childremoved
                    local newent
                    if localcheck then
                        entityLibrary.isAlive = true
                        entityLibrary.character.Head = head
                        entityLibrary.character.Humanoid = hum
                        entityLibrary.character.HumanoidRootPart = humrootpart
						table.insert(entityLibrary.entityConnections, char.AttributeChanged:Connect(function(...)
							vapeEvents.AttributeChanged:Fire(...)
						end))
                    else
						newent = {
                            Player = plr,
                            Character = char,
                            HumanoidRootPart = humrootpart,
                            RootPart = humrootpart,
                            Head = head,
                            Humanoid = hum,
                            Targetable = entityLibrary.isPlayerTargetable(plr),
                            Team = plr.Team,
                            Connections = {},
							Jumping = false,
							Jumps = 0,
							JumpTick = tick()
                        }
						local inv = char:WaitForChild("InventoryFolder", 5)
						if inv then
							local armorobj1 = char:WaitForChild("ArmorInvItem_0", 5)
							local armorobj2 = char:WaitForChild("ArmorInvItem_1", 5)
							local armorobj3 = char:WaitForChild("ArmorInvItem_2", 5)
							local handobj = char:WaitForChild("HandInvItem", 5)
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							if armorobj1 then
								table.insert(newent.Connections, armorobj1.Changed:Connect(function()
									task.delay(0.3, function()
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										store.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj2 then
								table.insert(newent.Connections, armorobj2.Changed:Connect(function()
									task.delay(0.3, function()
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										store.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj3 then
								table.insert(newent.Connections, armorobj3.Changed:Connect(function()
									task.delay(0.3, function()
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										store.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if handobj then
								table.insert(newent.Connections, handobj.Changed:Connect(function()
									task.delay(0.3, function()
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										store.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
						end
						if entityLibrary.entityIds[plr.Name] ~= id then return end
						task.delay(0.3, function()
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							store.inventories[plr] = bedwars.getInventory(plr)
							entityLibrary.entityUpdatedEvent:Fire(newent)
						end)
						table.insert(newent.Connections, hum:GetPropertyChangedSignal("Health"):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum:GetPropertyChangedSignal("MaxHealth"):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum.AnimationPlayed:Connect(function(state)
							local animnum = tonumber(({state.Animation.AnimationId:gsub("%D+", "")})[1])
							if animnum then
								if not entityLibrary.animationCache[state.Animation.AnimationId] then
									entityLibrary.animationCache[state.Animation.AnimationId] = game:GetService("MarketplaceService"):GetProductInfo(animnum)
								end
								if entityLibrary.animationCache[state.Animation.AnimationId].Name:lower():find("jump") then
									newent.Jumps = newent.Jumps + 1
								end
							end
						end))
						table.insert(newent.Connections, char.AttributeChanged:Connect(function(attr) if attr:find("Shield") then entityLibrary.entityUpdatedEvent:Fire(newent) end end))
						table.insert(entityLibrary.entityList, newent)
						entityLibrary.entityAddedEvent:Fire(newent)
                    end
					if entityLibrary.entityIds[plr.Name] ~= id then return end
					childremoved = char.ChildRemoved:Connect(function(part)
						if part.Name == "HumanoidRootPart" or part.Name == "Head" or part.Name == "Humanoid" then
							if localcheck then
								if char == lplr.Character then
									if part.Name == "HumanoidRootPart" then
										entityLibrary.isAlive = false
										local root = char:FindFirstChild("HumanoidRootPart")
										if not root then
											root = char:WaitForChild("HumanoidRootPart", 3)
										end
										if root then
											entityLibrary.character.HumanoidRootPart = root
											entityLibrary.isAlive = true
										end
									else
										entityLibrary.isAlive = false
									end
								end
							else
								childremoved:Disconnect()
								entityLibrary.removeEntity(plr)
							end
						end
					end)
					if newent then
						table.insert(newent.Connections, childremoved)
					end
					table.insert(entityLibrary.entityConnections, childremoved)
                end
            end)
        end
    end
	entityLibrary.entityAdded = function(plr, localcheck, custom)
		table.insert(entityLibrary.entityConnections, plr:GetPropertyChangedSignal("Character"):Connect(function()
            if plr.Character then
                entityLibrary.refreshEntity(plr, localcheck)
            else
                if localcheck then
                    entityLibrary.isAlive = false
                else
                    entityLibrary.removeEntity(plr)
                end
            end
        end))
        table.insert(entityLibrary.entityConnections, plr:GetAttributeChangedSignal("Team"):Connect(function()
			local tab = {}
			for i,v in next, entityLibrary.entityList do
                if v.Targetable ~= entityLibrary.isPlayerTargetable(v.Player) then
                    table.insert(tab, v)
                end
            end
			for i,v in next, tab do
				entityLibrary.refreshEntity(v.Player)
			end
            if localcheck then
                entityLibrary.fullEntityRefresh()
            else
				entityLibrary.refreshEntity(plr, localcheck)
            end
        end))
		if plr.Character then
            task.spawn(entityLibrary.refreshEntity, plr, localcheck)
        end
    end
	entityLibrary.fullEntityRefresh()
	task.spawn(function()
		repeat
			task.wait()
			if entityLibrary.isAlive then
				entityLibrary.groundTick = entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entityLibrary.groundTick
			end
			for i,v in pairs(entityLibrary.entityList) do
				local state = v.Humanoid:GetState()
				v.JumpTick = (state ~= Enum.HumanoidStateType.Running and state ~= Enum.HumanoidStateType.Landed) and tick() or v.JumpTick
				v.Jumping = (tick() - v.JumpTick) < 0.2 and v.Jumps > 1
				if (tick() - v.JumpTick) > 0.2 then
					v.Jumps = 0
				end
			end
		until not vapeInjected
	end)
	local textlabel = Instance.new("TextLabel")
	textlabel.Size = UDim2.new(0.302310646, 0, 0.062656641, 0)
	textlabel.Text = "Thanks for using Voidware :D -erchobg"
	textlabel.BackgroundTransparency = 1
	textlabel.ZIndex = 10
	textlabel.TextStrokeTransparency = 0
	textlabel.TextScaled = true
	textlabel.Font = Enum.Font.SourceSans
	textlabel.TextColor3 = Color3.new(1, 1, 1)
	textlabel.Position = UDim2.new(0.348523736, 0, 0.937343359, 0)
	textlabel.Parent = GuiLibrary.MainGui.ScaledGui.ClickGui
end

run(function()
	local handsquare = Instance.new("ImageLabel")
	handsquare.Size = UDim2.new(0, 26, 0, 27)
	handsquare.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	handsquare.Position = UDim2.new(0, 72, 0, 44)
	handsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local handround = Instance.new("UICorner")
	handround.CornerRadius = UDim.new(0, 4)
	handround.Parent = handsquare
	local helmetsquare = handsquare:Clone()
	helmetsquare.Position = UDim2.new(0, 100, 0, 44)
	helmetsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local chestplatesquare = handsquare:Clone()
	chestplatesquare.Position = UDim2.new(0, 127, 0, 44)
	chestplatesquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local bootssquare = handsquare:Clone()
	bootssquare.Position = UDim2.new(0, 155, 0, 44)
	bootssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local uselesssquare = handsquare:Clone()
	uselesssquare.Position = UDim2.new(0, 182, 0, 44)
	uselesssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local oldupdate = vapeTargetInfo.UpdateInfo
	vapeTargetInfo.UpdateInfo = function(tab, targetsize)
		local bkgcheck = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo.BackgroundTransparency == 1
		handsquare.BackgroundTransparency = bkgcheck and 1 or 0
		helmetsquare.BackgroundTransparency = bkgcheck and 1 or 0
		chestplatesquare.BackgroundTransparency = bkgcheck and 1 or 0
		bootssquare.BackgroundTransparency = bkgcheck and 1 or 0
		uselesssquare.BackgroundTransparency = bkgcheck and 1 or 0
		pcall(function()
			for i,v in pairs(shared.VapeTargetInfo.Targets) do
				local inventory = store.inventories[v.Player] or {}
					if inventory.hand then
						handsquare.Image = bedwars.getIcon(inventory.hand, true)
					else
						handsquare.Image = ""
					end
					if inventory.armor[4] then
						helmetsquare.Image = bedwars.getIcon(inventory.armor[4], true)
					else
						helmetsquare.Image = ""
					end
					if inventory.armor[5] then
						chestplatesquare.Image = bedwars.getIcon(inventory.armor[5], true)
					else
						chestplatesquare.Image = ""
					end
					if inventory.armor[6] then
						bootssquare.Image = bedwars.getIcon(inventory.armor[6], true)
					else
						bootssquare.Image = ""
					end
				break
			end
		end)
		return oldupdate(tab, targetsize)
	end
end)

task.spawn(function()
	for i,v in next, (
		{
			'TargetStrafeOptionsButton', 
			'SongBeatsOptionsButton', 
			'AntiVoidOptionsButton', 
			'FOVChangerOptionsButton', 
			'SafeWalkOptionsButton', 
			'NameTagsOptionsButton', 
			'ClientKickDisablerOptionsButton', 
			'FlyOptionsButton', 
			'SpeedOptionsButton', 
			'AutoLeaveOptionsButton', 
			'TriggerBotOptionsButton', 
			'HitBoxesOptionsButton', 
			'LongJumpOptionsButton', 
			'SpiderOptionsButton',
			'KillauraOptionsButton',
			'AutoClickerOptionsButton',
			'PhaseOptionsButton',
			--'MouseTPOptionsButton',
			'ReachOptionsButton',
			'SilentAimOptionsButton'
		}
	) do 
		pcall(GuiLibrary.RemoveObject, v) 
	end
end)

repeat task.wait() until game:IsLoaded()
--[[if store.matchState == 0 then
	warningNotification("VoidwareAntiCrash", "Waiting for the game to load...", 5)
	repeat task.wait() until store.matchState ~= 0
	warningNotification("VoidwareAntiCrash", "Game Loaded. Loading Voidware now...", 3)
end--]]

run(function()
	local AimAssist = {Enabled = false}
	local AimAssistClickAim = {Enabled = false}
	local AimAssistStrafe = {Enabled = false}
	local AimSpeed = {Value = 1}
	local AimAssistTargetFrame = {Players = {Enabled = false}}
	AimAssist = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "AimAssist",
		Function = function(callback)
			if callback then
				RunLoops:BindToRenderStep("AimAssist", function(dt)
					vapeTargetInfo.Targets.AimAssist = nil
					if ((not AimAssistClickAim.Enabled) or (tick() - bedwars.SwordController.lastSwing) < 0.4) then
						local plr = EntityNearPosition(18)
						if plr then
							vapeTargetInfo.Targets.AimAssist = {
								Humanoid = {
									Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
									MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
								},
								Player = plr.Player
							}
							if store.localHand.Type == "sword" then
								if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
									if store.matchState == 0 then return end
								end
								if AimAssistTargetFrame.Walls.Enabled then
									if not bedwars.SwordController:canSee({instance = plr.Character, player = plr.Player, getInstance = function() return plr.Character end}) then return end
								end
								gameCamera.CFrame = gameCamera.CFrame:lerp(CFrame.new(gameCamera.CFrame.p, plr.Character.HumanoidRootPart.Position), ((1 / AimSpeed.Value) + (AimAssistStrafe.Enabled and (inputService:IsKeyDown(Enum.KeyCode.A) or inputService:IsKeyDown(Enum.KeyCode.D)) and 0.01 or 0)))
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromRenderStep("AimAssist")
				vapeTargetInfo.Targets.AimAssist = nil
			end
		end,
		HoverText = "Smoothly aims to closest valid target with sword"
	})
	AimAssistTargetFrame = AimAssist.CreateTargetWindow({Default3 = true})
	AimAssistClickAim = AimAssist.CreateToggle({
		Name = "Click Aim",
		Function = function() end,
		Default = true,
		HoverText = "Only aim while mouse is down"
	})
	AimAssistStrafe = AimAssist.CreateToggle({
		Name = "Strafe increase",
		Function = function() end,
		HoverText = "Increase speed while strafing away from target"
	})
	AimSpeed = AimAssist.CreateSlider({
		Name = "Smoothness",
		Min = 1,
		Max = 100,
		Function = function(val) end,
		Default = 50
	})
end)

run(function()
	local autoclicker = {Enabled = false}
	local noclickdelay = {Enabled = false}
	local autoclickercps = {GetRandomValue = function() return 1 end}
	local autoclickerblocks = {Enabled = false}
	local AutoClickerThread

	local function isNotHoveringOverGui()
		local mousepos = inputService:GetMouseLocation() - Vector2.new(0, 36)
		for i,v in pairs(lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
			if v.Active then
				return false
			end
		end
		for i,v in pairs(coreGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
			if v.Parent:IsA("ScreenGui") and v.Parent.Enabled then
				if v.Active then
					return false
				end
			end
		end
		return true
	end

	local function AutoClick()
		local firstClick = tick() + 0.1
		AutoClickerThread = task.spawn(function()
			repeat
				task.wait()
				if entityLibrary.isAlive then
					if not autoclicker.Enabled then break end
					if not isNotHoveringOverGui() then continue end
					if bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then continue end
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if store.matchState == 0 then continue end
					end
					if store.localHand.Type == "sword" then
						if bedwars.DaoController.chargingMaid == nil then
							task.spawn(function()
								if firstClick <= tick() then
									bedwars.SwordController:swingSwordAtMouse()
								else
									firstClick = tick()
								end
							end)
							task.wait(math.max((1 / autoclickercps.GetRandomValue()), noclickdelay.Enabled and 0 or 0.142))
						end
					elseif store.localHand.Type == "block" then
						if autoclickerblocks.Enabled and bedwars.BlockPlacementController.blockPlacer and firstClick <= tick() then
							if (workspace:GetServerTimeNow() - bedwars.BlockCpsController.lastPlaceTimestamp) > ((1 / 12) * 0.5) then
								local mouseinfo = bedwars.BlockPlacementController.blockPlacer.clientManager:getBlockSelector():getMouseInfo(0)
								if mouseinfo then
									task.spawn(function()
										if mouseinfo.placementPosition == mouseinfo.placementPosition then
											bedwars.BlockPlacementController.blockPlacer:placeBlock(mouseinfo.placementPosition)
										end
									end)
								end
								task.wait((1 / autoclickercps.GetRandomValue()))
							end
						end
					end
				end
			until not autoclicker.Enabled
		end)
	end

	autoclicker = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "AutoClicker",
		Function = function(callback)
			if callback then
				if inputService.TouchEnabled then
					pcall(function()
						table.insert(autoclicker.Connections, lplr.PlayerGui.MobileUI['2'].MouseButton1Down:Connect(AutoClick))
						table.insert(autoclicker.Connections, lplr.PlayerGui.MobileUI['2'].MouseButton1Up:Connect(function()
							if AutoClickerThread then
								task.cancel(AutoClickerThread)
								AutoClickerThread = nil
							end
						end))
					end)
				end
				table.insert(autoclicker.Connections, inputService.InputBegan:Connect(function(input, gameProcessed)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then AutoClick() end
				end))
				table.insert(autoclicker.Connections, inputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and AutoClickerThread then
						task.cancel(AutoClickerThread)
						AutoClickerThread = nil
					end
				end))
			end
		end,
		HoverText = "Hold attack button to automatically click"
	})
	autoclickercps = autoclicker.CreateTwoSlider({
		Name = "CPS",
		Min = 1,
		Max = 20,
		Function = function(val) end,
		Default = 8,
		Default2 = 12
	})
	autoclickerblocks = autoclicker.CreateToggle({
		Name = "Place Blocks",
		Function = function() end,
		Default = true,
		HoverText = "Automatically places blocks when left click is held."
	})

	local noclickfunc
	noclickdelay = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "NoClickDelay",
		Function = function(callback)
			if callback then
				noclickfunc = bedwars.SwordController.isClickingTooFast
				bedwars.SwordController.isClickingTooFast = function(self)
					self.lastSwing = tick()
					return false
				end
			else
				bedwars.SwordController.isClickingTooFast = noclickfunc
			end
		end,
		HoverText = "Remove the CPS cap"
	})
end)

run(function()
	local ReachValue = {Value = 14}

	Reach = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Reach",
		Function = function(callback)
			bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = callback and ReachValue.Value + 2 or 14.4
		end,
		HoverText = "Extends attack reach"
	})
	ReachValue = Reach.CreateSlider({
		Name = "Reach",
		Min = 0,
		Max = 18,
		Function = function(val)
			if Reach.Enabled then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = val + 2
			end
		end,
		Default = 18
	})
end)

run(function()
	local Sprint = {Enabled = false}
	local oldSprintFunction
	Sprint = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Sprint",
		Function = function(callback)
			if callback then
				if inputService.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI["4"].Visible = false end)
				end
				oldSprintFunction = bedwars.SprintController.stopSprinting
				bedwars.SprintController.stopSprinting = function(...)
					local originalCall = oldSprintFunction(...)
					bedwars.SprintController:startSprinting()
					return originalCall
				end
				table.insert(Sprint.Connections, lplr.CharacterAdded:Connect(function(char)
					char:WaitForChild("Humanoid", 9e9)
					task.wait(0.5)
					bedwars.SprintController:stopSprinting()
				end))
				task.spawn(function()
					bedwars.SprintController:startSprinting()
				end)
			else
				if inputService.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI["4"].Visible = true end)
				end
				bedwars.SprintController.stopSprinting = oldSprintFunction
				bedwars.SprintController:stopSprinting()
			end
		end,
		HoverText = "Sets your sprinting to true."
	})
end)

run(function()
	local Velocity = {Enabled = false}
	local VelocityHorizontal = {Value = 100}
	local VelocityVertical = {Value = 100}
	local applyKnockback
	Velocity = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Velocity",
		Function = function(callback)
			if callback then
				applyKnockback = bedwars.KnockbackUtil.applyKnockback
				bedwars.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
					knockback = knockback or {}
					if VelocityHorizontal.Value == 0 and VelocityVertical.Value == 0 then return end
					knockback.horizontal = (knockback.horizontal or 1) * (VelocityHorizontal.Value / 100)
					knockback.vertical = (knockback.vertical or 1) * (VelocityVertical.Value / 100)
					return applyKnockback(root, mass, dir, knockback, ...)
				end
			else
				bedwars.KnockbackUtil.applyKnockback = applyKnockback
			end
		end,
		HoverText = "Reduces knockback taken"
	})
	VelocityHorizontal = Velocity.CreateSlider({
		Name = "Horizontal",
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
	VelocityVertical = Velocity.CreateSlider({
		Name = "Vertical",
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
end)

run(function()
	local AutoLeaveDelay = {Value = 1}
	local AutoPlayAgain = {Enabled = false}
	local AutoLeaveStaff = {Enabled = true}
	local AutoLeaveStaff2 = {Enabled = true}
	local AutoLeaveRandom = {Enabled = false}
	local leaveAttempted = false

	local function getRole(plr)
		local suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
		if not suc then
			repeat
				suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
				task.wait()
			until suc
		end
		if plr.UserId == 1774814725 then
			return 200
		end
		return res
	end

	local flyAllowedmodules = {"Sprint", "AutoClicker", "AutoReport", "AutoReportV2", "AutoRelic", "AimAssist", "AutoLeave", "Reach"}
	local function autoLeaveAdded(plr)
		task.spawn(function()
			if not shared.VapeFullyLoaded then
				repeat task.wait() until shared.VapeFullyLoaded
			end
			if getRole(plr) >= 100 then
				if AutoLeaveStaff.Enabled then
					if #bedwars.ClientStoreHandler:getState().Party.members > 0 then
						bedwars.QueueController.leaveParty()
					end
					if AutoLeaveStaff2.Enabled then
						warningNotification("Vape", "Staff Detected : "..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name).." : Play legit like nothing happened to have the highest chance of not getting banned.", 60)
						GuiLibrary.SaveSettings = function() end
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do
							if v.Type == "OptionsButton" then
								if table.find(flyAllowedmodules, i:gsub("OptionsButton", "")) == nil and tostring(v.Object.Parent.Parent):find("Render") == nil then
									if v.Api.Enabled then
										v.Api.ToggleButton(false)
									end
									v.Api.SetKeybind("")
									v.Object.TextButton.Visible = false
								end
							end
						end
					else
						GuiLibrary.SelfDestruct()
						game:GetService("StarterGui"):SetCore("SendNotification", {
							Title = "Vape",
							Text = "Staff Detected\n"..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name),
							Duration = 60,
						})
					end
					return
				else
					warningNotification("Vape", "Staff Detected : "..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name), 60)
				end
			end
		end)
	end

	local function isEveryoneDead()
		if #bedwars.ClientStoreHandler:getState().Party.members > 0 then
			for i,v in pairs(bedwars.ClientStoreHandler:getState().Party.members) do
				local plr = playersService:FindFirstChild(v.name)
				if plr and isAlive(plr, true) then
					return false
				end
			end
			return true
		else
			return true
		end
	end

	AutoLeave = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "AutoLeave",
		Function = function(callback)
			if callback then
				table.insert(AutoLeave.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if (not leaveAttempted) and deathTable.finalKill and deathTable.entityInstance == lplr.Character then
						leaveAttempted = true
						if isEveryoneDead() and store.matchState ~= 2 then
							task.wait(1 + (AutoLeaveDelay.Value / 10))
							if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
								if not AutoPlayAgain.Enabled then
									bedwars.Client:Get("TeleportToLobby"):SendToServer()
								else
									if AutoLeaveRandom.Enabled then
										local listofmodes = {}
										for i,v in pairs(bedwars.QueueMeta) do
											if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
										end
										bedwars.QueueController:joinQueue(listofmodes[math.random(1, #listofmodes)])
									else
										bedwars.QueueController:joinQueue(store.queueType)
									end
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(deathTable)
					task.wait(AutoLeaveDelay.Value / 10)
					if not AutoLeave.Enabled then return end
					if leaveAttempted then return end
					leaveAttempted = true
					if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
						if not AutoPlayAgain.Enabled then
							bedwars.Client:Get("TeleportToLobby"):SendToServer()
						else
							if bedwars.ClientStoreHandler:getState().Party.queueState == 0 then
								if AutoLeaveRandom.Enabled then
									local listofmodes = {}
									for i,v in pairs(bedwars.QueueMeta) do
										if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
									end
									bedwars.QueueController:joinQueue(listofmodes[math.random(1, #listofmodes)])
								else
									bedwars.QueueController:joinQueue(store.queueType)
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, playersService.PlayerAdded:Connect(autoLeaveAdded))
				for i, plr in pairs(playersService:GetPlayers()) do
					autoLeaveAdded(plr)
				end
			end
		end,
		HoverText = "Leaves if a staff member joins your game or when the match ends."
	})
	AutoLeaveDelay = AutoLeave.CreateSlider({
		Name = "Delay",
		Min = 0,
		Max = 50,
		Default = 0,
		Function = function() end,
		HoverText = "Delay before going back to the hub."
	})
	AutoPlayAgain = AutoLeave.CreateToggle({
		Name = "Play Again",
		Function = function() end,
		HoverText = "Automatically queues a new game.",
		Default = true
	})
	AutoLeaveStaff = AutoLeave.CreateToggle({
		Name = "Staff",
		Function = function(callback)
			if AutoLeaveStaff2.Object then
				AutoLeaveStaff2.Object.Visible = callback
			end
		end,
		HoverText = "Automatically uninjects when staff joins",
		Default = true
	})
	AutoLeaveStaff2 = AutoLeave.CreateToggle({
		Name = "Staff AutoConfig",
		Function = function() end,
		HoverText = "Instead of uninjecting, It will now reconfig vape temporarily to a more legit config.",
		Default = true
	})
	AutoLeaveRandom = AutoLeave.CreateToggle({
		Name = "Random",
		Function = function(callback) end,
		HoverText = "Chooses a random mode"
	})
	AutoLeaveStaff2.Object.Visible = false
end)

run(function()
	local oldclickhold
	local oldclickhold2
	local roact
	local FastConsume = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "FastConsume",
		Function = function(callback)
			if callback then
				oldclickhold = bedwars.ClickHold.startClick
				oldclickhold2 = bedwars.ClickHold.showProgress
				bedwars.ClickHold.showProgress = function(p5)
					local roact = debug.getupvalue(oldclickhold2, 1)
					local countdown = roact.mount(roact.createElement("ScreenGui", {}, { roact.createElement("Frame", {
						[roact.Ref] = p5.wrapperRef,
						Size = UDim2.new(0, 0, 0, 0),
						Position = UDim2.new(0.5, 0, 0.55, 0),
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = 0.8
					}, { roact.createElement("Frame", {
							[roact.Ref] = p5.progressRef,
							Size = UDim2.new(0, 0, 1, 0),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 0.5
						}) }) }), lplr:FindFirstChild("PlayerGui"))
					p5.handle = countdown
					local sizetween = tweenService:Create(p5.wrapperRef:getValue(), TweenInfo.new(0.1), {
						Size = UDim2.new(0.11, 0, 0.005, 0)
					})
					table.insert(p5.tweens, sizetween)
					sizetween:Play()
					local countdowntween = tweenService:Create(p5.progressRef:getValue(), TweenInfo.new(p5.durationSeconds * (FastConsumeVal.Value / 40), Enum.EasingStyle.Linear), {
						Size = UDim2.new(1, 0, 1, 0)
					})
					table.insert(p5.tweens, countdowntween)
					countdowntween:Play()
					return countdown
				end
				bedwars.ClickHold.startClick = function(p4)
					p4.startedClickTime = tick()
					local u2 = p4:showProgress()
					local clicktime = p4.startedClickTime
					bedwars.RuntimeLib.Promise.defer(function()
						task.wait(p4.durationSeconds * (FastConsumeVal.Value / 40))
						if u2 == p4.handle and clicktime == p4.startedClickTime and p4.closeOnComplete then
							p4:hideProgress()
							if p4.onComplete ~= nil then
								p4.onComplete()
							end
							if p4.onPartialComplete ~= nil then
								p4.onPartialComplete(1)
							end
							p4.startedClickTime = -1
						end
					end)
				end
			else
				bedwars.ClickHold.startClick = oldclickhold
				bedwars.ClickHold.showProgress = oldclickhold2
				oldclickhold = nil
				oldclickhold2 = nil
			end
		end,
		HoverText = "Use/Consume items quicker."
	})
	FastConsumeVal = FastConsume.CreateSlider({
		Name = "Ticks",
		Min = 0,
		Max = 40,
		Default = 0,
		Function = function() end
	})
end)

local autobankballoon = false
run(function()
	local Fly = {Enabled = false}
	local FlyMode = {Value = "CFrame"}
	local FlyVerticalSpeed = {Value = 40}
	local FlyVertical = {Enabled = true}
	local FlyAutoPop = {Enabled = true}
	local FlyAnyway = {Enabled = false}
	local FlyAnywayProgressBar = {Enabled = false}
	local FlyDamageAnimation = {Enabled = false}
	local FlyTP = {Enabled = false}
	local FlyAnywayProgressBarFrame
	local olddeflate
	local FlyUp = false
	local FlyDown = false
	local FlyCoroutine
	local groundtime = tick()
	local onground = false
	local lastonground = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}

	local function inflateBalloon()
		if not Fly.Enabled then return end
		if entityLibrary.isAlive and (lplr.Character:GetAttribute("InflatedBalloons") or 0) < 1 then
			autobankballoon = true
			if getItem("balloon") then
				bedwars.BalloonController:inflateBalloon()
				return true
			end
		end
		return false
	end

	Fly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Fly",
		Function = function(callback)
			if callback then
				olddeflate = bedwars.BalloonController.deflateBalloon
				bedwars.BalloonController.deflateBalloon = function() end

				table.insert(Fly.Connections, inputService.InputBegan:Connect(function(input1)
					if FlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							FlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							FlyDown = true
						end
					end
				end))
				table.insert(Fly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						FlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						FlyDown = false
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(Fly.Connections, jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
							FlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						FlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				table.insert(Fly.Connections, vapeEvents.BalloonPopped.Event:Connect(function(poppedTable)
					if poppedTable.inflatedBalloon and poppedTable.inflatedBalloon:GetAttribute("BalloonOwner") == lplr.UserId then
						lastonground = not onground
						repeat task.wait() until (lplr.Character:GetAttribute("InflatedBalloons") or 0) <= 0 or not Fly.Enabled
						inflateBalloon()
					end
				end))
				table.insert(Fly.Connections, vapeEvents.AutoBankBalloon.Event:Connect(function()
					repeat task.wait() until getItem("balloon")
					inflateBalloon()
				end))

				local balloons
				if entityLibrary.isAlive and (not store.queueType:find("mega")) then
					balloons = inflateBalloon()
				end
				local megacheck = store.queueType:find("mega") or store.queueType == "winter_event"

				task.spawn(function()
					repeat task.wait() until store.queueType ~= "bedwars_test" or (not Fly.Enabled)
					if not Fly.Enabled then return end
					megacheck = store.queueType:find("mega") or store.queueType == "winter_event"
				end)

				local flyAllowed = entityLibrary.isAlive and ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
				if flyAllowed <= 0 and shared.damageanim and (not balloons) then
					shared.damageanim()
					bedwars.SoundManager:playSound(bedwars.SoundList["DAMAGE_"..math.random(1, 3)])
				end

				if FlyAnywayProgressBarFrame and flyAllowed <= 0 and (not balloons) then
					FlyAnywayProgressBarFrame.Visible = true
					FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
				end

				groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
				FlyCoroutine = coroutine.create(function()
					repeat
						repeat task.wait() until (groundtime - tick()) < 0.6 and not onground
						flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
						if (not Fly.Enabled) then break end
						local Flytppos = -99999
						if flyAllowed <= 0 and FlyTP.Enabled and entityLibrary.isAlive then
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), store.blockRaycast)
							if ray then
								Flytppos = entityLibrary.character.HumanoidRootPart.Position.Y
								local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
								args[2] = ray.Position.Y + (entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								task.wait(0.12)
								if (not Fly.Enabled) then break end
								flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
								if flyAllowed <= 0 and Flytppos ~= -99999 and entityLibrary.isAlive then
									local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
									args[2] = Flytppos
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								end
							end
						end
					until (not Fly.Enabled)
				end)
				coroutine.resume(FlyCoroutine)

				RunLoops:BindToHeartbeat("Fly", function(delta)
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
						flyAllowed = ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
						playerMass = playerMass + (flyAllowed > 0 and 4 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)

						if FlyAnywayProgressBarFrame then
							FlyAnywayProgressBarFrame.Visible = flyAllowed <= 0
							FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
							FlyAnywayProgressBarFrame.Frame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
						end

						if flyAllowed <= 0 then
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, (entityLibrary.character.Humanoid.HipHeight * -2) - 1, 0))
							onground = newray and true or false
							if lastonground ~= onground then
								if (not onground) then
									groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
									if FlyAnywayProgressBarFrame then
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, groundtime - tick(), true)
									end
								else
									if FlyAnywayProgressBarFrame then
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
									end
								end
							end
							if FlyAnywayProgressBarFrame then
								FlyAnywayProgressBarFrame.TextLabel.Text = math.max(onground and 2.5 or math.floor((groundtime - tick()) * 10) / 10, 0).."s"
							end
							lastonground = onground
						else
							onground = true
							lastonground = true
						end

						local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (FlyMode.Value == "Normal" and FlySpeed.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (FlyUp and FlyVerticalSpeed.Value or 0) + (FlyDown and -FlyVerticalSpeed.Value or 0), 0))
						if FlyMode.Value ~= "Normal" then
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((FlySpeed.Value + getSpeed()) - 20)) * delta
						end
					end
				end)
			else
				pcall(function() coroutine.close(FlyCoroutine) end)
				autobankballoon = false
				waitingforballoon = false
				lastonground = nil
				FlyUp = false
				FlyDown = false
				RunLoops:UnbindFromHeartbeat("Fly")
				if FlyAnywayProgressBarFrame then
					FlyAnywayProgressBarFrame.Visible = false
				end
				if FlyAutoPop.Enabled then
					if entityLibrary.isAlive and lplr.Character:GetAttribute("InflatedBalloons") then
						for i = 1, lplr.Character:GetAttribute("InflatedBalloons") do
							olddeflate()
						end
					end
				end
				bedwars.BalloonController.deflateBalloon = olddeflate
				olddeflate = nil
			end
		end,
		HoverText = "Makes you go zoom (longer Fly discovered by exelys and Cqded)",
		ExtraText = function()
			return "Heatseeker"
		end
	})
	FlySpeed = Fly.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	FlyVerticalSpeed = Fly.CreateSlider({
		Name = "Vertical Speed",
		Min = 1,
		Max = 100,
		Function = function(val) end,
		Default = 44
	})
	FlyVertical = Fly.CreateToggle({
		Name = "Y Level",
		Function = function() end,
		Default = true
	})
	FlyAutoPop = Fly.CreateToggle({
		Name = "Pop Balloon",
		Function = function() end,
		HoverText = "Pops balloons when Fly is disabled."
	})
	local oldcamupdate
	local camcontrol
	local Flydamagecamera = {Enabled = false}
	FlyDamageAnimation = Fly.CreateToggle({
		Name = "Damage Animation",
		Function = function(callback)
			if Flydamagecamera.Object then
				Flydamagecamera.Object.Visible = callback
			end
			if callback then
				task.spawn(function()
					repeat
						task.wait(0.1)
						for i,v in pairs(getconnections(gameCamera:GetPropertyChangedSignal("CameraType"))) do
							if v.Function then
								camcontrol = debug.getupvalue(v.Function, 1)
							end
						end
					until camcontrol
					local caminput = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput)
					local num = Instance.new("IntValue")
					local numanim
					shared.damageanim = function()
						if numanim then numanim:Cancel() end
						if Flydamagecamera.Enabled then
							num.Value = 1000
							numanim = tweenService:Create(num, TweenInfo.new(0.5), {Value = 0})
							numanim:Play()
						end
					end
					oldcamupdate = camcontrol.Update
					camcontrol.Update = function(self, dt)
						if camcontrol.activeCameraController then
							camcontrol.activeCameraController:UpdateMouseBehavior()
							local newCameraCFrame, newCameraFocus = camcontrol.activeCameraController:Update(dt)
							gameCamera.CFrame = newCameraCFrame * CFrame.Angles(0, 0, math.rad(num.Value / 100))
							gameCamera.Focus = newCameraFocus
							if camcontrol.activeTransparencyController then
								camcontrol.activeTransparencyController:Update(dt)
							end
							if caminput.getInputEnabled() then
								caminput.resetInputForFrameEnd()
							end
						end
					end
				end)
			else
				shared.damageanim = nil
				if camcontrol then
					camcontrol.Update = oldcamupdate
				end
			end
		end
	})
	Flydamagecamera = Fly.CreateToggle({
		Name = "Camera Animation",
		Function = function() end,
		Default = true
	})
	Flydamagecamera.Object.BorderSizePixel = 0
	Flydamagecamera.Object.BackgroundTransparency = 0
	Flydamagecamera.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Flydamagecamera.Object.Visible = false
	FlyAnywayProgressBar = Fly.CreateToggle({
		Name = "Progress Bar",
		Function = function(callback)
			if callback then
				FlyAnywayProgressBarFrame = Instance.new("Frame")
				FlyAnywayProgressBarFrame.AnchorPoint = Vector2.new(0.5, 0)
				FlyAnywayProgressBarFrame.Position = UDim2.new(0.5, 0, 1, -200)
				FlyAnywayProgressBarFrame.Size = UDim2.new(0.2, 0, 0, 20)
				FlyAnywayProgressBarFrame.BackgroundTransparency = 0.5
				FlyAnywayProgressBarFrame.BorderSizePixel = 0
				FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				FlyAnywayProgressBarFrame.Visible = Fly.Enabled
				FlyAnywayProgressBarFrame.Parent = GuiLibrary.MainGui
				local FlyAnywayProgressBarFrame2 = FlyAnywayProgressBarFrame:Clone()
				FlyAnywayProgressBarFrame2.AnchorPoint = Vector2.new(0, 0)
				FlyAnywayProgressBarFrame2.Position = UDim2.new(0, 0, 0, 0)
				FlyAnywayProgressBarFrame2.Size = UDim2.new(1, 0, 0, 20)
				FlyAnywayProgressBarFrame2.BackgroundTransparency = 0
				FlyAnywayProgressBarFrame2.Visible = true
				FlyAnywayProgressBarFrame2.Parent = FlyAnywayProgressBarFrame
				local FlyAnywayProgressBartext = Instance.new("TextLabel")
				FlyAnywayProgressBartext.Text = "2s"
				FlyAnywayProgressBartext.Font = Enum.Font.Gotham
				FlyAnywayProgressBartext.TextStrokeTransparency = 0
				FlyAnywayProgressBartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
				FlyAnywayProgressBartext.TextSize = 20
				FlyAnywayProgressBartext.Size = UDim2.new(1, 0, 1, 0)
				FlyAnywayProgressBartext.BackgroundTransparency = 1
				FlyAnywayProgressBartext.Position = UDim2.new(0, 0, -1, 0)
				FlyAnywayProgressBartext.Parent = FlyAnywayProgressBarFrame
			else
				if FlyAnywayProgressBarFrame then FlyAnywayProgressBarFrame:Destroy() FlyAnywayProgressBarFrame = nil end
			end
		end,
		HoverText = "show amount of Fly time",
		Default = true
	})
	FlyTP = Fly.CreateToggle({
		Name = "TP Down",
		Function = function() end,
		Default = true
	})
end)

run(function()
	local GrappleExploit = {Enabled = false}
	local GrappleExploitMode = {Value = "Normal"}
	local GrappleExploitVerticalSpeed = {Value = 40}
	local GrappleExploitVertical = {Enabled = true}
	local GrappleExploitUp = false
	local GrappleExploitDown = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	local projectileRemote = bedwars.Client:Get(bedwars.ProjectileRemote)

	--me when I have to fix bw code omegalol
	bedwars.Client:Get("GrapplingHookFunctions"):Connect(function(p4)
		if p4.hookFunction == "PLAYER_IN_TRANSIT" then
			bedwars.CooldownController:setOnCooldown("grappling_hook", 3.5)
		end
	end)

	GrappleExploit = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "GrappleExploit",
		Function = function(callback)
			if callback then
				local grappleHooked = false
				table.insert(GrappleExploit.Connections, bedwars.Client:Get("GrapplingHookFunctions"):Connect(function(p4)
					if p4.hookFunction == "PLAYER_IN_TRANSIT" then
						store.grapple = tick() + 1.8
						grappleHooked = true
						GrappleExploit.ToggleButton(false)
					end
				end))

				local fireball = getItem("grappling_hook")
				if fireball then
					task.spawn(function()
						repeat task.wait() until bedwars.CooldownController:getRemainingCooldown("grappling_hook") == 0 or (not GrappleExploit.Enabled)
						if (not GrappleExploit.Enabled) then return end
						switchItem(fireball.tool)
						local pos = entityLibrary.character.HumanoidRootPart.CFrame.p
						local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
						projectileRemote:CallServerAsync(fireball["tool"], nil, "grappling_hook_projectile", offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService("HttpService"):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
					end)
				else
					warningNotification("GrappleExploit", "missing grapple hook", 3)
					GrappleExploit.ToggleButton(false)
					return
				end

				local startCFrame = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.CFrame
				RunLoops:BindToHeartbeat("GrappleExploit", function(delta)
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						entityLibrary.character.HumanoidRootPart.Velocity = Vector3.zero
						entityLibrary.character.HumanoidRootPart.CFrame = startCFrame
					end
				end)
			else
				GrappleExploitUp = false
				GrappleExploitDown = false
				RunLoops:UnbindFromHeartbeat("GrappleExploit")
			end
		end,
		HoverText = "Makes you go zoom (longer GrappleExploit discovered by exelys and Cqded)",
		ExtraText = function()
			if GuiLibrary.ObjectsThatCanBeSaved["Text GUIAlternate TextToggle"]["Api"].Enabled then
				return alternatelist[table.find(GrappleExploitMode["List"], GrappleExploitMode.Value)]
			end
			return GrappleExploitMode.Value
		end
	})
end)

run(function()
	local InfiniteFly = {Enabled = false}
	local InfiniteFlyMode = {Value = "CFrame"}
	local InfiniteFlySpeed = {Value = 23}
	local InfiniteFlyVerticalSpeed = {Value = 40}
	local InfiniteFlyVertical = {Enabled = true}
	local InfiniteFlyUp = false
	local InfiniteFlyDown = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	local clonesuccess = false
	local disabledproper = true
	local oldcloneroot
	local cloned
	local clone
	local bodyvelo
	local FlyOverlap = OverlapParams.new()
	FlyOverlap.MaxParts = 9e9
	FlyOverlap.FilterDescendantsInstances = {}
	FlyOverlap.RespectCanCollide = true

	local function disablefunc()
		if bodyvelo then bodyvelo:Destroy() end
		RunLoops:UnbindFromHeartbeat("InfiniteFlyOff")
		disabledproper = true
		if not oldcloneroot or not oldcloneroot.Parent then return end
		lplr.Character.Parent = game
		oldcloneroot.Parent = lplr.Character
		lplr.Character.PrimaryPart = oldcloneroot
		lplr.Character.Parent = workspace
		oldcloneroot.CanCollide = true
		for i,v in pairs(lplr.Character:GetDescendants()) do
			if v:IsA("Weld") or v:IsA("Motor6D") then
				if v.Part0 == clone then v.Part0 = oldcloneroot end
				if v.Part1 == clone then v.Part1 = oldcloneroot end
			end
			if v:IsA("BodyVelocity") then
				v:Destroy()
			end
		end
		for i,v in pairs(oldcloneroot:GetChildren()) do
			if v:IsA("BodyVelocity") then
				v:Destroy()
			end
		end
		local oldclonepos = clone.Position.Y
		if clone then
			clone:Destroy()
			clone = nil
		end
		lplr.Character.Humanoid.HipHeight = hip or 2
		local origcf = {oldcloneroot.CFrame:GetComponents()}
		origcf[2] = oldclonepos
		oldcloneroot.CFrame = CFrame.new(unpack(origcf))
		oldcloneroot = nil
		warningNotification("InfiniteFly", "Landed!", 3)
	end

	InfiniteFly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "InfiniteFly",
		Function = function(callback)
			if callback then
				if not entityLibrary.isAlive then
					disabledproper = true
				end
				if not disabledproper then
					warningNotification("InfiniteFly", "Wait for the last fly to finish", 3)
					InfiniteFly.ToggleButton(false)
					return
				end
				table.insert(InfiniteFly.Connections, inputService.InputBegan:Connect(function(input1)
					if InfiniteFlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							InfiniteFlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							InfiniteFlyDown = true
						end
					end
				end))
				table.insert(InfiniteFly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						InfiniteFlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						InfiniteFlyDown = false
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(InfiniteFly.Connections, jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
							InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				clonesuccess = false
				if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) then
					cloned = lplr.Character
					oldcloneroot = entityLibrary.character.HumanoidRootPart
					if not lplr.Character.Parent then
						InfiniteFly.ToggleButton(false)
						return
					end
					lplr.Character.Parent = game
					clone = oldcloneroot:Clone()
					clone.Parent = lplr.Character
					oldcloneroot.Parent = gameCamera
					bedwars.QueryUtil:setQueryIgnored(oldcloneroot, true)
					clone.CFrame = oldcloneroot.CFrame
					lplr.Character.PrimaryPart = clone
					lplr.Character.Parent = workspace
					for i,v in pairs(lplr.Character:GetDescendants()) do
						if v:IsA("Weld") or v:IsA("Motor6D") then
							if v.Part0 == oldcloneroot then v.Part0 = clone end
							if v.Part1 == oldcloneroot then v.Part1 = clone end
						end
						if v:IsA("BodyVelocity") then
							v:Destroy()
						end
					end
					for i,v in pairs(oldcloneroot:GetChildren()) do
						if v:IsA("BodyVelocity") then
							v:Destroy()
						end
					end
					if hip then
						lplr.Character.Humanoid.HipHeight = hip
					end
					hip = lplr.Character.Humanoid.HipHeight
					clonesuccess = true
				end
				if not clonesuccess then
					warningNotification("InfiniteFly", "Character missing", 3)
					InfiniteFly.ToggleButton(false)
					return
				end
				local goneup = false
				RunLoops:BindToHeartbeat("InfiniteFly", function(delta)
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if store.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if isnetworkowner(oldcloneroot) then
							local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)

							local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (InfiniteFlyMode.Value == "Normal" and InfiniteFlySpeed.Value or 20)
							entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (InfiniteFlyUp and InfiniteFlyVerticalSpeed.Value or 0) + (InfiniteFlyDown and -InfiniteFlyVerticalSpeed.Value or 0), 0))
							if InfiniteFlyMode.Value ~= "Normal" then
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((InfiniteFlySpeed.Value + getSpeed()) - 20)) * delta
							end

							local speedCFrame = {oldcloneroot.CFrame:GetComponents()}
							speedCFrame[1] = clone.CFrame.X
							if speedCFrame[2] < 1000 or (not goneup) then
								task.spawn(warningNotification, "InfiniteFly", "Teleported Up", 3)
								speedCFrame[2] = 100000
								goneup = true
							end
							speedCFrame[3] = clone.CFrame.Z
							oldcloneroot.CFrame = CFrame.new(unpack(speedCFrame))
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, oldcloneroot.Velocity.Y, clone.Velocity.Z)
						else
							InfiniteFly.ToggleButton(false)
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("InfiniteFly")
				if clonesuccess and oldcloneroot and clone and lplr.Character.Parent == workspace and oldcloneroot.Parent ~= nil and disabledproper and cloned == lplr.Character then
					local rayparams = RaycastParams.new()
					rayparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
					rayparams.RespectCanCollide = true
					local ray = workspace:Raycast(Vector3.new(oldcloneroot.Position.X, clone.CFrame.p.Y, oldcloneroot.Position.Z), Vector3.new(0, -1000, 0), rayparams)
					local origcf = {clone.CFrame:GetComponents()}
					origcf[1] = oldcloneroot.Position.X
					origcf[2] = ray and ray.Position.Y + (entityLibrary.character.Humanoid.HipHeight + (oldcloneroot.Size.Y / 2)) or clone.CFrame.p.Y
					origcf[3] = oldcloneroot.Position.Z
					oldcloneroot.CanCollide = true
					bodyvelo = Instance.new("BodyVelocity")
					bodyvelo.MaxForce = Vector3.new(0, 9e9, 0)
					bodyvelo.Velocity = Vector3.new(0, -1, 0)
					bodyvelo.Parent = oldcloneroot
					oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
					RunLoops:BindToHeartbeat("InfiniteFlyOff", function(dt)
						if oldcloneroot then
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
							local bruh = {clone.CFrame:GetComponents()}
							bruh[2] = oldcloneroot.CFrame.Y
							local newcf = CFrame.new(unpack(bruh))
							FlyOverlap.FilterDescendantsInstances = {lplr.Character, gameCamera}
							local allowed = true
							for i,v in pairs(workspace:GetPartBoundsInRadius(newcf.p, 2, FlyOverlap)) do
								if (v.Position.Y + (v.Size.Y / 2)) > (newcf.p.Y + 0.5) then
									allowed = false
									break
								end
							end
							if allowed then
								oldcloneroot.CFrame = newcf
							end
						end
					end)
					oldcloneroot.CFrame = CFrame.new(unpack(origcf))
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
					disabledproper = false
					if isnetworkowner(oldcloneroot) then
						warningNotification("InfiniteFly", "Waiting 1.1s to not flag", 3)
						task.delay(1.1, disablefunc)
					else
						disablefunc()
					end
				end
				InfiniteFlyUp = false
				InfiniteFlyDown = false
			end
		end,
		HoverText = "Makes you go zoom",
		ExtraText = function()
			return "Heatseeker"
		end
	})
	InfiniteFlySpeed = InfiniteFly.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	InfiniteFlyVerticalSpeed = InfiniteFly.CreateSlider({
		Name = "Vertical Speed",
		Min = 1,
		Max = 100,
		Function = function(val) end,
		Default = 44
	})
	InfiniteFlyVertical = InfiniteFly.CreateToggle({
		Name = "Y Level",
		Function = function() end,
		Default = true
	})
end)

local Killaura = {Enabled = true}
local killauraNearPlayer
run(function()
	local killauraboxes = {}
	local killauratargetframe = {Players = {Enabled = false}}
	local killaurasortmethod = {Value = "Distance"}
	local killaurarealremote = bedwars.Client:Get(bedwars.AttackRemote).instance
	local killauramethod = {Value = "Normal"}
	local killauraothermethod = {Value = "Normal"}
	local killauraanimmethod = {Value = "Normal"}
	local killaurarange = {Value = 14}
	local killauraangle = {Value = 360}
	local killauratargets = {Value = 10}
	local killauraautoblock = {Enabled = false}
	local killauramouse = {Enabled = false}
	local killauracframe = {Enabled = false}
	local killauragui = {Enabled = false}
	local killauratarget = {Enabled = false}
	local killaurasound = {Enabled = false}
	local killauraswing = {Enabled = false}
	local killaurasync = {Enabled = false}
	local killaurahitdelay = {Enabled = false}
	local killaurahandcheck = {Enabled = false}
	local killauraanimation = {Enabled = false}
	local killauraanimationtween = {Enabled = false}
	local killauracolor = {Value = 0.44}
	local killauranovape = {Enabled = false}
	local killauratargethighlight = {Enabled = false}
	local killaurarangecircle = {Enabled = false}
	local killaurarangecirclepart
	local killauraaimcircle = {Enabled = false}
	local killauraaimcirclepart
	local killauraparticle = {Enabled = false}
	local killauraparticlepart
	local Killauranear = false
	local killauraplaying = false
	local oldViewmodelAnimation = function() end
	local oldPlaySound = function() end
	local originalArmC0 = nil
	local killauracurrentanim
	local animationdelay = tick()

	local function getStrength(plr)
		local inv = store.inventories[plr.Player]
		local strength = 0
		local strongestsword = 0
		if inv then
			for i,v in pairs(inv.items) do
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.sword and itemmeta.sword.damage > strongestsword then
					strongestsword = itemmeta.sword.damage / 100
				end
			end
			strength = strength + strongestsword
			for i,v in pairs(inv.armor) do
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.armor then
					strength = strength + (itemmeta.armor.damageReductionMultiplier or 0)
				end
			end
			strength = strength
		end
		return strength
	end

	local kitpriolist = {
		hannah = 5,
		spirit_assassin = 4,
		dasher = 3,
		jade = 2,
		regent = 1
	}

	local killaurasortmethods = {
		Distance = function(a, b)
			return (a.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude < (b.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude
		end,
		Health = function(a, b)
			return a.Humanoid.Health < b.Humanoid.Health
		end,
		Threat = function(a, b)
			return getStrength(a) > getStrength(b)
		end,
		Kit = function(a, b)
			return (kitpriolist[a.Player:GetAttribute("PlayingAsKit")] or 0) > (kitpriolist[b.Player:GetAttribute("PlayingAsKit")] or 0)
		end
	}

	local originalNeckC0
	local originalRootC0
	local anims = {
		Normal = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		Slow = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
		},
		New = {
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.12},
			{CFrame = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), Time = 0.12}
		},
		Latest = {
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
		},
		["Vertical Spin"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
		},
		Exhibition = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		["Exhibition Old"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		},
		Hamsterware = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(40), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-135)), Time = 0.1}
		},
		--[[["Cat V5"] = {
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
		},--]]
		Astral = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
			{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
		},
		Leaked = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(16), math.rad(59), math.rad(-90)), Time = 0.156},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.075}
		},
		Slide2 = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-171), math.rad(47), math.rad(74)), Time = 0.16}
		},
		Femboy = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = 0.08},
			{CFrame = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), Time = 0.08},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0.11}
		},
		Pulse = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.5},
			{CFrame = CFrame.new(0.69, -0.72, 0.6) * CFrame.Angles(math.rad(-20), math.rad(0), math.rad(0)), Time = 1.0},
			{CFrame = CFrame.new(0.69, -0.68, 0.6) * CFrame.Angles(math.rad(20), math.rad(0), math.rad(0)), Time = 1.5},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 2.0}
		},
		["Slowly Smooth"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.25},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.5},
			{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.75},
			{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 1.25},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 1.5},
		},
		["Latest Remake"] = {
			{CFrame = CFrame.new(0.68, -0.72, 0.12) * CFrame.Angles(math.rad(-63), math.rad(57), math.rad(-49)), Time = 0.4},
			{CFrame = CFrame.new(0.17, -1.18, 0.52) * CFrame.Angles(math.rad(-177), math.rad(56), math.rad(31)), Time = 0.4}
		},
		["Exhibition Fast"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-20), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.8, -0.8, 0.5) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.07},
		},
		["Smooth Gaming"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.25},
			{CFrame = CFrame.new(0.68, -0.72, 0.12) * CFrame.Angles(math.rad(-63), math.rad(57), math.rad(-49)), Time = 0.4},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.6},
			{CFrame = CFrame.new(0.17, -1.18, 0.52) * CFrame.Angles(math.rad(-177), math.rad(56), math.rad(31)), Time = 0.6},
			{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.8},
			{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 1.0},
			{CFrame = CFrame.new(0.8, -0.8, 0.5) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 1.2},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 1.4},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 1.6}
		}	
	}

	local function closestpos(block, pos)
		local blockpos = block:GetRenderCFrame()
		local startpos = (blockpos * CFrame.new(-(block.Size / 2))).p
		local endpos = (blockpos * CFrame.new((block.Size / 2))).p
		local speedCFrame = block.Position + (pos - block.Position)
		local x = startpos.X > endpos.X and endpos.X or startpos.X
		local y = startpos.Y > endpos.Y and endpos.Y or startpos.Y
		local z = startpos.Z > endpos.Z and endpos.Z or startpos.Z
		local x2 = startpos.X < endpos.X and endpos.X or startpos.X
		local y2 = startpos.Y < endpos.Y and endpos.Y or startpos.Y
		local z2 = startpos.Z < endpos.Z and endpos.Z or startpos.Z
		return Vector3.new(math.clamp(speedCFrame.X, x, x2), math.clamp(speedCFrame.Y, y, y2), math.clamp(speedCFrame.Z, z, z2))
	end

	local function getAttackData()
		if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
			if store.matchState == 0 then return false end
		end
		if killauramouse.Enabled then
			if not inputService:IsMouseButtonPressed(0) then return false end
		end
		if killauragui.Enabled then
			if bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then return false end
		end
		local sword = killaurahandcheck.Enabled and store.localHand or getSword()
		if not sword or not sword.tool then return false end
		local swordmeta = bedwars.ItemTable[sword.tool.Name]
		if killaurahandcheck.Enabled then
			if store.localHand.Type ~= "sword" or bedwars.DaoController.chargingMaid then return false end
		end
		return sword, swordmeta
	end

	local function autoBlockLoop()
		if not killauraautoblock.Enabled or not Killaura.Enabled then return end
		repeat
			if store.blockPlace < tick() and entityLibrary.isAlive then
				local shield = getItem("infernal_shield")
				if shield then
					switchItem(shield.tool)
					if not lplr.Character:GetAttribute("InfernalShieldRaised") then
						bedwars.InfernalShieldController:raiseShield()
					end
				end
			end
			task.wait()
		until (not Killaura.Enabled) or (not killauraautoblock.Enabled)
	end

	Killaura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Killaura",
		Function = function(callback)
			if callback then
				if killauraaimcirclepart then killauraaimcirclepart.Parent = gameCamera end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = gameCamera end
				if killauraparticlepart then killauraparticlepart.Parent = gameCamera end

				task.spawn(function()
					local oldNearPlayer
					repeat
						task.wait()
						if (killauraanimation.Enabled and not killauraswing.Enabled) then
							if killauraNearPlayer then
								pcall(function()
									if originalArmC0 == nil then
										originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
									end
									if killauraplaying == false then
										killauraplaying = true
										for i,v in pairs(anims[killauraanimmethod.Value]) do
											if (not Killaura.Enabled) or (not killauraNearPlayer) then break end
											if not oldNearPlayer and killauraanimationtween.Enabled then
												gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0 * v.CFrame
												continue
											end
											killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(v.Time), {C0 = originalArmC0 * v.CFrame})
											killauracurrentanim:Play()
											task.wait(v.Time - 0.01)
										end
										killauraplaying = false
									end
								end)
							end
							oldNearPlayer = killauraNearPlayer
						end
					until Killaura.Enabled == false
				end)

				oldViewmodelAnimation = bedwars.ViewmodelController.playAnimation
				oldPlaySound = bedwars.SoundManager.playSound
				bedwars.SoundManager.playSound = function(tab, soundid, ...)
					if (soundid == bedwars.SoundList.SWORD_SWING_1 or soundid == bedwars.SoundList.SWORD_SWING_2) and Killaura.Enabled and killaurasound.Enabled and killauraNearPlayer then
						return nil
					end
					return oldPlaySound(tab, soundid, ...)
				end
				bedwars.ViewmodelController.playAnimation = function(Self, id, ...)
					if id == 15 and killauraNearPlayer and killauraswing.Enabled and entityLibrary.isAlive then
						return nil
					end
					if id == 15 and killauraNearPlayer and killauraanimation.Enabled and entityLibrary.isAlive then
						return nil
					end
					return oldViewmodelAnimation(Self, id, ...)
				end

				local targetedPlayer
				RunLoops:BindToHeartbeat("Killaura", function()
					for i,v in pairs(killauraboxes) do
						if v:IsA("BoxHandleAdornment") and v.Adornee then
							local cf = v.Adornee and v.Adornee.CFrame
							local onex, oney, onez = cf:ToEulerAnglesXYZ()
							v.CFrame = CFrame.new() * CFrame.Angles(-onex, -oney, -onez)
						end
					end
					if entityLibrary.isAlive then
						if killauraaimcirclepart then
							killauraaimcirclepart.Position = targetedPlayer and closestpos(targetedPlayer.RootPart, entityLibrary.character.HumanoidRootPart.Position) or Vector3.new(99999, 99999, 99999)
						end
						if killauraparticlepart then
							killauraparticlepart.Position = targetedPlayer and targetedPlayer.RootPart.Position or Vector3.new(99999, 99999, 99999)
						end
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							if killaurarangecirclepart then
								killaurarangecirclepart.Position = Root.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)
							end
							local Neck = entityLibrary.character.Head:FindFirstChild("Neck")
							local LowerTorso = Root.Parent and Root.Parent:FindFirstChild("LowerTorso")
							local RootC0 = LowerTorso and LowerTorso:FindFirstChild("Root")
							if Neck and RootC0 then
								if originalNeckC0 == nil then
									originalNeckC0 = Neck.C0.p
								end
								if originalRootC0 == nil then
									originalRootC0 = RootC0.C0.p
								end
								if originalRootC0 and killauracframe.Enabled then
									if targetedPlayer ~= nil then
										local targetPos = targetedPlayer.RootPart.Position + Vector3.new(0, 2, 0)
										local direction = (Vector3.new(targetPos.X, targetPos.Y, targetPos.Z) - entityLibrary.character.Head.Position).Unit
										local direction2 = (Vector3.new(targetPos.X, Root.Position.Y, targetPos.Z) - Root.Position).Unit
										local lookCFrame = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction)))
										local lookCFrame2 = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction2)))
										Neck.C0 = CFrame.new(originalNeckC0) * CFrame.Angles(lookCFrame.LookVector.Unit.y, 0, 0)
										RootC0.C0 = lookCFrame2 + originalRootC0
									else
										Neck.C0 = CFrame.new(originalNeckC0)
										RootC0.C0 = CFrame.new(originalRootC0)
									end
								end
							end
						end
					end
				end)
				if killauraautoblock.Enabled then
					task.spawn(autoBlockLoop)
				end
				task.spawn(function()
					repeat
						task.wait()
						if not Killaura.Enabled then break end
						vapeTargetInfo.Targets.Killaura = nil
						local plrs = AllNearPosition(killaurarange.Value, 10, killaurasortmethods[killaurasortmethod.Value], true)
						local firstPlayerNear
						if #plrs > 0 then
							local sword, swordmeta = getAttackData()
							if sword then
								switchItem(sword.tool)
								for i, plr in pairs(plrs) do
									local root = plr.RootPart
									if not root then
										continue
									end
									local localfacing = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
									local vec = (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).unit
									local angle = math.acos(localfacing:Dot(vec))
									if angle >= (math.rad(killauraangle.Value) / 2) then
										continue
									end
									local selfrootpos = entityLibrary.character.HumanoidRootPart.Position
									if killauratargetframe.Walls.Enabled then
										if not bedwars.SwordController:canSee({player = plr.Player, getInstance = function() return plr.Character end}) then continue end
									end
									if killauranovape.Enabled and store.whitelist.clientUsers[plr.Player.Name] then
										continue
									end
									if not firstPlayerNear then
										firstPlayerNear = true
										killauraNearPlayer = true
										targetedPlayer = plr
										vapeTargetInfo.Targets.Killaura = {
											Humanoid = {
												Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
												MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
											},
											Player = plr.Player
										}
										if animationdelay <= tick() then
											animationdelay = tick() + (swordmeta.sword.respectAttackSpeedForEffects and swordmeta.sword.attackSpeed or (killaurasync.Enabled and 0.24 or 0.14))
											if not killauraswing.Enabled then
												bedwars.SwordController:playSwordEffect(swordmeta, false)
											end
											if swordmeta.displayName:find(" Scythe") then
												bedwars.ScytheController:playLocalAnimation()
											end
										end
									end
									local delayval = killaurahitdelay.Value / 100
									if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) < delayval then
										break
									end
									local selfpos = selfrootpos + (killaurarange.Value > 14 and (selfrootpos - root.Position).magnitude > 14.4 and (CFrame.lookAt(selfrootpos, root.Position).lookVector * ((selfrootpos - root.Position).magnitude - 14)) or Vector3.zero)
									bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
									store.attackReach = math.floor((selfrootpos - root.Position).magnitude * 100) / 100
									store.attackReachUpdate = tick() + 1
									killaurarealremote:FireServer({
										weapon = sword.tool,
										chargedAttack = {chargeRatio = swordmeta.sword.chargedAttack and not swordmeta.sword.chargedAttack.disableOnGrounded and 0.999 or 0},
										entityInstance = plr.Character,
										validate = {
											raycast = {
												cameraPosition = attackValue(root.Position),
												cursorDirection = attackValue(CFrame.new(selfpos, root.Position).lookVector)
											},
											targetPosition = attackValue(root.Position),
											selfPosition = attackValue(selfpos)
										}
									})
									break
								end
							end
						end
						if not firstPlayerNear then
							targetedPlayer = nil
							killauraNearPlayer = false
							pcall(function()
								if originalArmC0 == nil then
									originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
								end
								if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
									pcall(function()
										killauracurrentanim:Cancel()
									end)
									if killauraanimationtween.Enabled then
										gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
									else
										killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
										killauracurrentanim:Play()
									end
								end
							end)
						end
						for i,v in pairs(killauraboxes) do
							local attacked = killauratarget.Enabled and plrs[i] or nil
							v.Adornee = attacked and ((not killauratargethighlight.Enabled) and attacked.RootPart or (not GuiLibrary.ObjectsThatCanBeSaved.ChamsOptionsButton.Api.Enabled) and attacked.Character or nil)
						end
					until (not Killaura.Enabled)
				end)
			else
				vapeTargetInfo.Targets.Killaura = nil
				RunLoops:UnbindFromHeartbeat("Killaura")
				killauraNearPlayer = false
				for i,v in pairs(killauraboxes) do v.Adornee = nil end
				if killauraaimcirclepart then killauraaimcirclepart.Parent = nil end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = nil end
				if killauraparticlepart then killauraparticlepart.Parent = nil end
				bedwars.ViewmodelController.playAnimation = oldViewmodelAnimation
				bedwars.SoundManager.playSound = oldPlaySound
				oldViewmodelAnimation = nil
				pcall(function()
					if entityLibrary.isAlive then
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							local Neck = Root.Parent.Head.Neck
							if originalNeckC0 and originalRootC0 then
								Neck.C0 = CFrame.new(originalNeckC0)
								Root.Parent.LowerTorso.Root.C0 = CFrame.new(originalRootC0)
							end
						end
					end
					if originalArmC0 == nil then
						originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
					end
					if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
						pcall(function()
							killauracurrentanim:Cancel()
						end)
						if killauraanimationtween.Enabled then
							gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
						else
							killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
							killauracurrentanim:Play()
						end
					end
				end)
			end
		end,
		HoverText = "Attack players around you\nwithout aiming at them."
	})
	killauratargetframe = Killaura.CreateTargetWindow({})
	local sortmethods = {"Distance"}
	for i,v in pairs(killaurasortmethods) do if i ~= "Distance" then table.insert(sortmethods, i) end end
	killaurasortmethod = Killaura.CreateDropdown({
		Name = "Sort",
		Function = function() end,
		List = sortmethods
	})
	killaurarange = Killaura.CreateSlider({
		Name = "Attack range",
		Min = 1,
		Max = 18,
		Function = function(val)
			if killaurarangecirclepart then
				killaurarangecirclepart.Size = Vector3.new(val * 0.7, 0.01, val * 0.7)
			end
		end,
		Default = 18
	})
	killaurahitdelay = Killaura.CreateSlider({
		Name = "Hit Delay",
		Min = 0,
		Max = 10,
		Function = function(val)

		end,
		Default = 0
	})
	killauraangle = Killaura.CreateSlider({
		Name = "Max angle",
		Min = 1,
		Max = 360,
		Function = function(val) end,
		Default = 360
	})
	local animmethods = {}
	for i,v in pairs(anims) do table.insert(animmethods, i) end
	killauraanimmethod = Killaura.CreateDropdown({
		Name = "Animation",
		List = animmethods,
		Function = function(val) end
	})
	local oldviewmodel
	local oldraise
	local oldeffect
	killauraautoblock = Killaura.CreateToggle({
		Name = "AutoBlock",
		Function = function(callback)
			if callback then
				oldviewmodel = bedwars.ViewmodelController.setHeldItem
				bedwars.ViewmodelController.setHeldItem = function(self, newItem, ...)
					if newItem and newItem.Name == "infernal_shield" then
						return
					end
					return oldviewmodel(self, newItem)
				end
				oldraise = bedwars.InfernalShieldController.raiseShield
				bedwars.InfernalShieldController.raiseShield = function(self)
					if os.clock() - self.lastShieldRaised < 0.4 then
						return
					end
					self.lastShieldRaised = os.clock()
					self.infernalShieldState:SendToServer({raised = true})
					self.raisedMaid:GiveTask(function()
						self.infernalShieldState:SendToServer({raised = false})
					end)
				end
				oldeffect = bedwars.InfernalShieldController.playEffect
				bedwars.InfernalShieldController.playEffect = function()
					return
				end
				if bedwars.ViewmodelController.heldItem and bedwars.ViewmodelController.heldItem.Name == "infernal_shield" then
					local sword, swordmeta = getSword()
					if sword then
						bedwars.ViewmodelController:setHeldItem(sword.tool)
					end
				end
				task.spawn(autoBlockLoop)
			else
				bedwars.ViewmodelController.setHeldItem = oldviewmodel
				bedwars.InfernalShieldController.raiseShield = oldraise
				bedwars.InfernalShieldController.playEffect = oldeffect
			end
		end,
		Default = true
	})
	killauramouse = Killaura.CreateToggle({
		Name = "Require mouse down",
		Function = function() end,
		HoverText = "Only attacks when left click is held.",
		Default = false
	})
	killauragui = Killaura.CreateToggle({
		Name = "GUI Check",
		Function = function() end,
		HoverText = "Attacks when you are not in a GUI."
	})
	killauratarget = Killaura.CreateToggle({
		Name = "Show target",
		Function = function(callback)
			if killauratargethighlight.Object then
				killauratargethighlight.Object.Visible = callback
			end
		end,
		HoverText = "Shows a red box over the opponent."
	})
	killauratargethighlight = Killaura.CreateToggle({
		Name = "Use New Highlight",
		Function = function(callback)
			for i, v in pairs(killauraboxes) do
				v:Remove()
			end
			for i = 1, 10 do
				local killaurabox
				if callback then
					killaurabox = Instance.new("Highlight")
					killaurabox.FillTransparency = 0.39
					killaurabox.FillColor = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					killaurabox.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					killaurabox.OutlineTransparency = 1
					killaurabox.Parent = GuiLibrary.MainGui
				else
					killaurabox = Instance.new("BoxHandleAdornment")
					killaurabox.Transparency = 0.39
					killaurabox.Color3 = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					killaurabox.Adornee = nil
					killaurabox.AlwaysOnTop = true
					killaurabox.Size = Vector3.new(3, 6, 3)
					killaurabox.ZIndex = 11
					killaurabox.Parent = GuiLibrary.MainGui
				end
				killauraboxes[i] = killaurabox
			end
		end
	})
	killauratargethighlight.Object.BorderSizePixel = 0
	killauratargethighlight.Object.BackgroundTransparency = 0
	killauratargethighlight.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	killauratargethighlight.Object.Visible = false
	killauracolor = Killaura.CreateColorSlider({
		Name = "Target Color",
		Function = function(hue, sat, val)
			for i,v in pairs(killauraboxes) do
				v[(killauratargethighlight.Enabled and "FillColor" or "Color3")] = Color3.fromHSV(hue, sat, val)
			end
			if killauraaimcirclepart then
				killauraaimcirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
			if killaurarangecirclepart then
				killaurarangecirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
		end,
		Default = 1
	})
	for i = 1, 10 do
		local killaurabox = Instance.new("BoxHandleAdornment")
		killaurabox.Transparency = 0.5
		killaurabox.Color3 = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
		killaurabox.Adornee = nil
		killaurabox.AlwaysOnTop = true
		killaurabox.Size = Vector3.new(3, 6, 3)
		killaurabox.ZIndex = 11
		killaurabox.Parent = GuiLibrary.MainGui
		killauraboxes[i] = killaurabox
	end
	killauracframe = Killaura.CreateToggle({
		Name = "Face target",
		Function = function() end,
		HoverText = "Makes your character face the opponent."
	})
	killaurarangecircle = Killaura.CreateToggle({
		Name = "Range Visualizer",
		Function = function(callback)
			if callback then
				killaurarangecirclepart = Instance.new("MeshPart")
				killaurarangecirclepart.MeshId = "rbxassetid://3726303797"
				killaurarangecirclepart.Color = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
				killaurarangecirclepart.CanCollide = false
				killaurarangecirclepart.Anchored = true
				killaurarangecirclepart.Material = Enum.Material.Neon
				killaurarangecirclepart.Size = Vector3.new(killaurarange.Value * 0.7, 0.01, killaurarange.Value * 0.7)
				killaurarangecirclepart.Parent = gameCamera
			else
				if killaurarangecirclepart then
					killaurarangecirclepart:Destroy()
					killaurarangecirclepart = nil
				end
			end
		end
	})
	killauraaimcircle = Killaura.CreateToggle({
		Name = "Aim Visualizer",
		Function = function(callback)
			if callback then
				killauraaimcirclepart = Instance.new("Part")
				killauraaimcirclepart.Shape = Enum.PartType.Ball
				killauraaimcirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
				killauraaimcirclepart.CanCollide = false
				killauraaimcirclepart.Anchored = true
				killauraaimcirclepart.Material = Enum.Material.Neon
				killauraaimcirclepart.Size = Vector3.new(0.5, 0.5, 0.5)
				if Killaura.Enabled then
					killauraaimcirclepart.Parent = gameCamera
				end
				bedwars.QueryUtil:setQueryIgnored(killauraaimcirclepart, true)
			else
				if killauraaimcirclepart then
					killauraaimcirclepart:Destroy()
					killauraaimcirclepart = nil
				end
			end
		end
	})
	killauraparticle = Killaura.CreateToggle({
		Name = "Crit Particle",
		Function = function(callback)
			if callback then
				killauraparticlepart = Instance.new("Part")
				killauraparticlepart.Transparency = 1
				killauraparticlepart.CanCollide = false
				killauraparticlepart.Anchored = true
				killauraparticlepart.Size = Vector3.new(3, 6, 3)
				killauraparticlepart.Parent = cam
				bedwars.QueryUtil:setQueryIgnored(killauraparticlepart, true)
				local particle = Instance.new("ParticleEmitter")
				particle.Lifetime = NumberRange.new(0.5)
				particle.Rate = 500
				particle.Speed = NumberRange.new(0)
				particle.RotSpeed = NumberRange.new(180)
				particle.Enabled = true
				particle.Size = NumberSequence.new(0.3)
				particle.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 10, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 98, 255))})
				particle.Parent = killauraparticlepart
			else
				if killauraparticlepart then
					killauraparticlepart:Destroy()
					killauraparticlepart = nil
				end
			end
		end
	})
	killaurasound = Killaura.CreateToggle({
		Name = "No Swing Sound",
		Function = function() end,
		HoverText = "Removes the swinging sound."
	})
	killauraswing = Killaura.CreateToggle({
		Name = "No Swing",
		Function = function() end,
		HoverText = "Removes the swinging animation."
	})
	killaurahandcheck = Killaura.CreateToggle({
		Name = "Limit to items",
		Function = function() end,
		HoverText = "Only attacks when your sword is held."
	})
	killauraanimation = Killaura.CreateToggle({
		Name = "Custom Animation",
		Function = function(callback)
			if killauraanimationtween.Object then killauraanimationtween.Object.Visible = callback end
		end,
		HoverText = "Uses a custom animation for swinging"
	})
	killauraanimationtween = Killaura.CreateToggle({
		Name = "No Tween",
		Function = function() end,
		HoverText = "Disable's the in and out ease"
	})
	killauraanimationtween.Object.Visible = false
	killaurasync = Killaura.CreateToggle({
		Name = "Synced Animation",
		Function = function() end,
		HoverText = "Times animation with hit attempt"
	})
	killauranovape = Killaura.CreateToggle({
		Name = "No Vape",
		Function = function() end,
		HoverText = "no hit vape user"
	})
	killauranovape.Object.Visible = false
end)

task.spawn(function()
	repeat task.wait() until shared.VapeFullyLoaded
	if not Killaura.Enabled then
		Killaura.ToggleButton(false)
	end
end)

local LongJump = {Enabled = false}
run(function()
	local damagetimer = 0
	local damagetimertick = 0
	local directionvec
	local LongJumpSpeed = {Value = 1.5}
	local projectileRemote = bedwars.Client:Get(bedwars.ProjectileRemote)

	local function calculatepos(vec)
		local returned = vec
		if entityLibrary.isAlive then
			local newray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, returned, store.blockRaycast)
			if newray then returned = (newray.Position - entityLibrary.character.HumanoidRootPart.Position) end
		end
		return returned
	end

	local damagemethods = {
		fireball = function(fireball, pos)
			if not LongJump.Enabled then return end
			pos = pos - (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 0.2)
			if not (getPlacedBlock(pos - Vector3.new(0, 3, 0)) or getPlacedBlock(pos - Vector3.new(0, 6, 0))) then
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://4809574295"
				sound.Parent = workspace
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
				sound:Play()
			end
			local origpos = pos
			local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
			local ray = workspace:Raycast(pos, Vector3.new(0, -30, 0), store.blockRaycast)
			if ray then
				pos = ray.Position
				offsetshootpos = pos
			end
			task.spawn(function()
				switchItem(fireball.tool)
				bedwars.ProjectileController:createLocalProjectile(bedwars.ProjectileMeta.fireball, "fireball", "fireball", offsetshootpos, "", Vector3.new(0, -60, 0), {drawDurationSeconds = 1})
				projectileRemote:CallServerAsync(fireball.tool, "fireball", "fireball", offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService("HttpService"):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
			end)
		end,
		tnt = function(tnt, pos2)
			if not LongJump.Enabled then return end
			local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
			local block = bedwars.placeBlock(pos, "tnt")
		end,
		cannon = function(tnt, pos2)
			task.spawn(function()
				local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
				local block = bedwars.placeBlock(pos, "cannon")
				task.delay(0.1, function()
					local block, pos2 = getPlacedBlock(pos)
					if block and block.Name == "cannon" and (entityLibrary.character.HumanoidRootPart.CFrame.p - block.Position).Magnitude < 20 then
						switchToAndUseTool(block)
						local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
						local damage = bedwars.BlockController:calculateBlockDamage(lplr, {
							blockPosition = pos2
						})
						bedwars.Client:Get(bedwars.CannonAimRemote):SendToServer({
							cannonBlockPos = pos2,
							lookVector = vec
						})
						local broken = 0.1
						if damage < block:GetAttribute("Health") then
							task.spawn(function()
								broken = 0.4
								bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
							end)
						end
						task.delay(broken, function()
							for i = 1, 3 do
								local call = bedwars.Client:Get(bedwars.CannonLaunchRemote):CallServer({cannonBlockPos = bedwars.BlockController:getBlockPosition(block.Position)})
								if call then
									bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
									task.delay(0.1, function()
										damagetimer = LongJumpSpeed.Value * 5
										damagetimertick = tick() + 2.5
										directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
									end)
									break
								end
								task.wait(0.1)
							end
						end)
					end
				end)
			end)
		end,
		wood_dao = function(tnt, pos2)
			task.spawn(function()
				switchItem(tnt.tool)
				if not (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < workspace:GetServerTimeNow()) then
					repeat task.wait() until (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < workspace:GetServerTimeNow()) or not LongJump.Enabled
				end
				if LongJump.Enabled then
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					replicatedStorage["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].useAbility:FireServer("dash", {
						direction = vec,
						origin = entityLibrary.character.HumanoidRootPart.CFrame.p,
						weapon = tnt.itemType
					})
					damagetimer = LongJumpSpeed.Value * 3.5
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		jade_hammer = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("jade_hammer_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("jade_hammer_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("jade_hammer_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("jade_hammer_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		void_axe = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("void_axe_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("void_axe_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("void_axe_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("void_axe_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end
	}
	damagemethods.stone_dao = damagemethods.wood_dao
	damagemethods.iron_dao = damagemethods.wood_dao
	damagemethods.diamond_dao = damagemethods.wood_dao
	damagemethods.emerald_dao = damagemethods.wood_dao

	local oldgrav
	local LongJumpacprogressbarframe = Instance.new("Frame")
	LongJumpacprogressbarframe.AnchorPoint = Vector2.new(0.5, 0)
	LongJumpacprogressbarframe.Position = UDim2.new(0.5, 0, 1, -200)
	LongJumpacprogressbarframe.Size = UDim2.new(0.2, 0, 0, 20)
	LongJumpacprogressbarframe.BackgroundTransparency = 0.5
	LongJumpacprogressbarframe.BorderSizePixel = 0
	LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
	LongJumpacprogressbarframe.Visible = LongJump.Enabled
	LongJumpacprogressbarframe.Parent = GuiLibrary.MainGui
	local LongJumpacprogressbarframe2 = LongJumpacprogressbarframe:Clone()
	LongJumpacprogressbarframe2.AnchorPoint = Vector2.new(0, 0)
	LongJumpacprogressbarframe2.Position = UDim2.new(0, 0, 0, 0)
	LongJumpacprogressbarframe2.Size = UDim2.new(1, 0, 0, 20)
	LongJumpacprogressbarframe2.BackgroundTransparency = 0
	LongJumpacprogressbarframe2.Visible = true
	LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
	LongJumpacprogressbarframe2.Parent = LongJumpacprogressbarframe
	local LongJumpacprogressbartext = Instance.new("TextLabel")
	LongJumpacprogressbartext.Text = "2.5s"
	LongJumpacprogressbartext.Font = Enum.Font.Gotham
	LongJumpacprogressbartext.TextStrokeTransparency = 0
	LongJumpacprogressbartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
	LongJumpacprogressbartext.TextSize = 20
	LongJumpacprogressbartext.Size = UDim2.new(1, 0, 1, 0)
	LongJumpacprogressbartext.BackgroundTransparency = 1
	LongJumpacprogressbartext.Position = UDim2.new(0, 0, -1, 0)
	LongJumpacprogressbartext.Parent = LongJumpacprogressbarframe
	LongJump = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "LongJump",
		Function = function(callback)
			if callback then
				table.insert(LongJump.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (not damageTable.knockbackMultiplier or not damageTable.knockbackMultiplier.disabled) then
						local knockbackBoost = damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal and damageTable.knockbackMultiplier.horizontal * LongJumpSpeed.Value or LongJumpSpeed.Value
						if damagetimertick < tick() or knockbackBoost >= damagetimer then
							damagetimer = knockbackBoost
							damagetimertick = tick() + 2.5
							local newDirection = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
							directionvec = Vector3.new(newDirection.X, 0, newDirection.Z).Unit
						end
					end
				end))
				task.spawn(function()
					task.spawn(function()
						repeat
							task.wait()
							if LongJumpacprogressbarframe then
								LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
								LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
							end
						until (not LongJump.Enabled)
					end)
					local LongJumpOrigin = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.Position
					local tntcheck
					for i,v in pairs(damagemethods) do
						local item = getItem(i)
						if item then
							if i == "tnt" then
								local pos = getScaffold(LongJumpOrigin)
								tntcheck = Vector3.new(pos.X, LongJumpOrigin.Y, pos.Z)
								v(item, pos)
							else
								v(item, LongJumpOrigin)
							end
							break
						end
					end
					local changecheck
					LongJumpacprogressbarframe.Visible = true
					RunLoops:BindToHeartbeat("LongJump", function(dt)
						if entityLibrary.isAlive then
							if entityLibrary.character.Humanoid.Health <= 0 then
								LongJump.ToggleButton(false)
								return
							end
							if not LongJumpOrigin then
								LongJumpOrigin = entityLibrary.character.HumanoidRootPart.Position
							end
							local newval = damagetimer ~= 0
							if changecheck ~= newval then
								if newval then
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 2.5, true)
								else
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
								end
								changecheck = newval
							end
							if newval then
								local newnum = math.max(math.floor((damagetimertick - tick()) * 10) / 10, 0)
								if LongJumpacprogressbartext then
									LongJumpacprogressbartext.Text = newnum.."s"
								end
								if directionvec == nil then
									directionvec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
								end
								local longJumpCFrame = Vector3.new(directionvec.X, 0, directionvec.Z)
								local newvelo = longJumpCFrame.Unit == longJumpCFrame.Unit and longJumpCFrame.Unit * (newnum > 1 and damagetimer or 20) or Vector3.zero
								newvelo = Vector3.new(newvelo.X, 0, newvelo.Z)
								longJumpCFrame = longJumpCFrame * (getSpeed() + 3) * dt
								local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, longJumpCFrame, store.blockRaycast)
								if ray then
									longJumpCFrame = Vector3.zero
									newvelo = Vector3.zero
								end

								entityLibrary.character.HumanoidRootPart.Velocity = newvelo
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + longJumpCFrame
							else
								LongJumpacprogressbartext.Text = "2.5s"
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(LongJumpOrigin, LongJumpOrigin + entityLibrary.character.HumanoidRootPart.CFrame.lookVector)
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
								if tntcheck then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(tntcheck + entityLibrary.character.HumanoidRootPart.CFrame.lookVector, tntcheck + (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 2))
								end
							end
						else
							if LongJumpacprogressbartext then
								LongJumpacprogressbartext.Text = "2.5s"
							end
							LongJumpOrigin = nil
							tntcheck = nil
						end
					end)
				end)
			else
				LongJumpacprogressbarframe.Visible = false
				RunLoops:UnbindFromHeartbeat("LongJump")
				directionvec = nil
				tntcheck = nil
				LongJumpOrigin = nil
				damagetimer = 0
				damagetimertick = 0
			end
		end,
		HoverText = "Lets you jump farther (Not landing on same level & Spamming can lead to lagbacks)"
	})
	LongJumpSpeed = LongJump.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 52,
		Function = function() end,
		Default = 52
	})
end)

run(function()
	local NoFall = {Enabled = false}
	local oldfall
	NoFall = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "NoFall",
		Function = function(callback)
			if callback then
				bedwars.Client:Get("GroundHit"):SendToServer()
			end
		end,
		HoverText = "Prevents taking fall damage."
	})
end)

run(function()
	local NoSlowdown = {Enabled = false}
	local OldSetSpeedFunc
	NoSlowdown = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "NoSlowdown",
		Function = function(callback)
			if callback then
				OldSetSpeedFunc = bedwars.SprintController.setSpeed
				bedwars.SprintController.setSpeed = function(tab1, val1)
					local hum = entityLibrary.character.Humanoid
					if hum then
						hum.WalkSpeed = math.max(20 * tab1.moveSpeedMultiplier, 20)
					end
				end
				bedwars.SprintController:setSpeed(20)
			else
				bedwars.SprintController.setSpeed = OldSetSpeedFunc
				bedwars.SprintController:setSpeed(20)
				OldSetSpeedFunc = nil
			end
		end,
		HoverText = "Prevents slowing down when using items."
	})
end)

local spiderActive = false
local holdingshift = false
run(function()
	local activatePhase = false
	local oldActivatePhase = false
	local PhaseDelay = tick()
	local Phase = {Enabled = false}
	local PhaseStudLimit = {Value = 1}
	local PhaseModifiedParts = {}
	local raycastparameters = RaycastParams.new()
	raycastparameters.RespectCanCollide = true
	raycastparameters.FilterType = Enum.RaycastFilterType.Whitelist
	local overlapparams = OverlapParams.new()
	overlapparams.RespectCanCollide = true

	local function isPointInMapOccupied(p)
		overlapparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
		local possible = workspace:GetPartBoundsInBox(CFrame.new(p), Vector3.new(1, 2, 1), overlapparams)
		return (#possible == 0)
	end

	Phase = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Phase",
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat("Phase", function()
					if entityLibrary.isAlive and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero and (not GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton.Api.Enabled or holdingshift) then
						if PhaseDelay <= tick() then
							raycastparameters.FilterDescendantsInstances = {store.blocks, collectionService:GetTagged("spawn-cage")} --workspace.SpectatorPlatform}
							local PhaseRayCheck = workspace:Raycast(entityLibrary.character.Head.CFrame.p, entityLibrary.character.Humanoid.MoveDirection * 1.15, raycastparameters)
							if PhaseRayCheck then
								local PhaseDirection = (PhaseRayCheck.Normal.Z ~= 0 or not PhaseRayCheck.Instance:GetAttribute("GreedyBlock")) and "Z" or "X"
								if PhaseRayCheck.Instance.Size[PhaseDirection] <= PhaseStudLimit.Value * 3 and PhaseRayCheck.Instance.CanCollide and PhaseRayCheck.Normal.Y == 0 then
									local PhaseDestination = entityLibrary.character.HumanoidRootPart.CFrame + (PhaseRayCheck.Normal * (-(PhaseRayCheck.Instance.Size[PhaseDirection]) - (entityLibrary.character.HumanoidRootPart.Size.X / 1.5)))
									if isPointInMapOccupied(PhaseDestination.p) then
										PhaseDelay = tick() + 1
										entityLibrary.character.HumanoidRootPart.CFrame = PhaseDestination
									end
								end
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("Phase")
			end
		end,
		HoverText = "Lets you Phase/Clip through walls. (Hold shift to use Phase over spider)"
	})
	PhaseStudLimit = Phase.CreateSlider({
		Name = "Blocks",
		Min = 1,
		Max = 3,
		Function = function() end
	})
end)

run(function()
	local oldCalculateAim
	local BowAimbotProjectiles = {Enabled = false}
	local BowAimbotPart = {Value = "HumanoidRootPart"}
	local BowAimbotFOV = {Value = 1000}
	local BowAimbot = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "ProjectileAimbot",
		Function = function(callback)
			if callback then
				oldCalculateAim = bedwars.ProjectileController.calculateImportantLaunchValues
				bedwars.ProjectileController.calculateImportantLaunchValues = function(self, projmeta, worldmeta, shootpospart, ...)
					local plr = EntityNearMouse(BowAimbotFOV.Value)
					if plr then
						local startPos = self:getLaunchPosition(shootpospart)
						if not startPos then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						if (not BowAimbotProjectiles.Enabled) and projmeta.projectile:find("arrow") == nil then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						local projmetatab = projmeta:getProjectileMeta()
						local projectilePrediction = (worldmeta and projmetatab.predictionLifetimeSec or projmetatab.lifetimeSec or 3)
						local projectileSpeed = (projmetatab.launchVelocity or 100)
						local gravity = (projmetatab.gravitationalAcceleration or 196.2)
						local projectileGravity = gravity * projmeta.gravityMultiplier
						local offsetStartPos = startPos + projmeta.fromPositionOffset
						local pos = plr.Character[BowAimbotPart.Value].Position
						local playerGravity = workspace.Gravity
						local balloons = plr.Character:GetAttribute("InflatedBalloons")

						if balloons and balloons > 0 then
							playerGravity = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
						end

						if plr.Character.PrimaryPart:FindFirstChild("rbxassetid://8200754399") then
							playerGravity = (workspace.Gravity * 0.3)
						end

						local shootpos, shootvelo = predictGravity(pos, plr.Character.HumanoidRootPart.Velocity, (pos - offsetStartPos).Magnitude / projectileSpeed, plr, playerGravity)
						if projmeta.projectile == "telepearl" then
							shootpos = pos
							shootvelo = Vector3.zero
						end

						local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, 0))
						shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
						local calculated = LaunchDirection(offsetStartPos, shootpos, projectileSpeed, projectileGravity, false)
						oldmove = plr.Character.Humanoid.MoveDirection
						if calculated then
							return {
								initialVelocity = calculated,
								positionFrom = offsetStartPos,
								deltaT = projectilePrediction,
								gravitationalAcceleration = projectileGravity,
								drawDurationSeconds = 5
							}
						end
					end
					return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
				end
			else
				bedwars.ProjectileController.calculateImportantLaunchValues = oldCalculateAim
			end
		end
	})
	BowAimbotPart = BowAimbot.CreateDropdown({
		Name = "Part",
		List = {"HumanoidRootPart", "Head"},
		Function = function() end
	})
	BowAimbotFOV = BowAimbot.CreateSlider({
		Name = "FOV",
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
	BowAimbotProjectiles = BowAimbot.CreateToggle({
		Name = "Other Projectiles",
		Function = function() end,
		Default = true
	})
end)

--until I find a way to make the spam switch item thing not bad I'll just get rid of it, sorry.
local Scaffold = {Enabled = false}
run(function()
	local scaffoldtext = Instance.new("TextLabel")
	scaffoldtext.Font = Enum.Font.SourceSans
	scaffoldtext.TextSize = 20
	scaffoldtext.BackgroundTransparency = 1
	scaffoldtext.TextColor3 = Color3.fromRGB(255, 0, 0)
	scaffoldtext.Size = UDim2.new(0, 0, 0, 0)
	scaffoldtext.Position = UDim2.new(0.5, 0, 0.5, 30)
	scaffoldtext.Text = "0"
	scaffoldtext.Visible = false
	scaffoldtext.Parent = GuiLibrary.MainGui
	local ScaffoldExpand = {Value = 1}
	local ScaffoldDiagonal = {Enabled = false}
	local ScaffoldTower = {Enabled = false}
	local ScaffoldDownwards = {Enabled = false}
	local ScaffoldStopMotion = {Enabled = false}
	local ScaffoldBlockCount = {Enabled = false}
	local ScaffoldHandCheck = {Enabled = false}
	local ScaffoldMouseCheck = {Enabled = false}
	local ScaffoldAnimation = {Enabled = false}
	local scaffoldstopmotionval = false
	local scaffoldposcheck = tick()
	local scaffoldstopmotionpos = Vector3.zero
	local scaffoldposchecklist = {}
	task.spawn(function()
		for x = -3, 3, 3 do
			for y = -3, 3, 3 do
				for z = -3, 3, 3 do
					if Vector3.new(x, y, z) ~= Vector3.new(0, 0, 0) then
						table.insert(scaffoldposchecklist, Vector3.new(x, y, z))
					end
				end
			end
		end
	end)

	local function checkblocks(pos)
		for i,v in pairs(scaffoldposchecklist) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function closestpos(block, pos)
		local startpos = block.Position - (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local speedCFrame = block.Position + (pos - block.Position)
		return Vector3.new(math.clamp(speedCFrame.X, startpos.X, endpos.X), math.clamp(speedCFrame.Y, startpos.Y, endpos.Y), math.clamp(speedCFrame.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag, pos)
		local closest, closestmag = pos, newmag * 3
		if entityLibrary.isAlive then
			for i,v in pairs(store.blocks) do
				local close = closestpos(v, pos)
				local mag = (close - pos).magnitude
				if mag <= closestmag then
					closest = close
					closestmag = mag
				end
			end
		end
		return closest
	end

	local oldspeed
	Scaffold = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Scaffold",
		Function = function(callback)
			if callback then
				scaffoldtext.Visible = ScaffoldBlockCount.Enabled
				if entityLibrary.isAlive then
					scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
				end
				task.spawn(function()
					repeat
						task.wait()
						if ScaffoldHandCheck.Enabled then
							if store.localHand.Type ~= "block" then continue end
						end
						if ScaffoldMouseCheck.Enabled then
							if not inputService:IsMouseButtonPressed(0) then continue end
						end
						if entityLibrary.isAlive then
							local wool, woolamount = getWool()
							if store.localHand.Type == "block" then
								wool = store.localHand.tool.Name
								woolamount = getItem(store.localHand.tool.Name).amount or 0
							elseif (not wool) then
								wool, woolamount = getBlock()
							end

							scaffoldtext.Text = (woolamount and tostring(woolamount) or "0")
							scaffoldtext.TextColor3 = woolamount and (woolamount >= 128 and Color3.fromRGB(9, 255, 198) or woolamount >= 64 and Color3.fromRGB(255, 249, 18)) or Color3.fromRGB(255, 0, 0)
							if not wool then continue end

							local towering = ScaffoldTower.Enabled and inputService:IsKeyDown(Enum.KeyCode.Space) and game:GetService("UserInputService"):GetFocusedTextBox() == nil
							if towering then
								if (not scaffoldstopmotionval) and ScaffoldStopMotion.Enabled then
									scaffoldstopmotionval = true
									scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
								end
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 28, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								if ScaffoldStopMotion.Enabled and scaffoldstopmotionval then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(scaffoldstopmotionpos.X, entityLibrary.character.HumanoidRootPart.CFrame.p.Y, scaffoldstopmotionpos.Z))
								end
							else
								scaffoldstopmotionval = false
							end

							for i = 1, ScaffoldExpand.Value do
								local speedCFrame = getScaffold((entityLibrary.character.HumanoidRootPart.Position + ((scaffoldstopmotionval and Vector3.zero or entityLibrary.character.Humanoid.MoveDirection) * (i * 3.5))) + Vector3.new(0, -((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight + (inputService:IsKeyDown(Enum.KeyCode.LeftShift) and ScaffoldDownwards.Enabled and 4.5 or 1.5))), 0)
								speedCFrame = Vector3.new(speedCFrame.X, speedCFrame.Y - (towering and 4 or 0), speedCFrame.Z)
								if speedCFrame ~= oldpos then
									if not checkblocks(speedCFrame) then
										local oldspeedCFrame = speedCFrame
										speedCFrame = getScaffold(getclosesttop(20, speedCFrame))
										if getPlacedBlock(speedCFrame) then speedCFrame = oldspeedCFrame end
									end
									if ScaffoldAnimation.Enabled then
										if not getPlacedBlock(speedCFrame) then
										bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
										end
									end
									task.spawn(bedwars.placeBlock, speedCFrame, wool, ScaffoldAnimation.Enabled)
									if ScaffoldExpand.Value > 1 then
										task.wait()
									end
									oldpos = speedCFrame
								end
							end
						end
					until (not Scaffold.Enabled)
				end)
			else
				scaffoldtext.Visible = false
				oldpos = Vector3.zero
				oldpos2 = Vector3.zero
			end
		end,
		HoverText = "Helps you make bridges/scaffold walk."
	})
	ScaffoldExpand = Scaffold.CreateSlider({
		Name = "Expand",
		Min = 1,
		Max = 8,
		Function = function(val) end,
		Default = 1,
		HoverText = "Build range"
	})
	ScaffoldDiagonal = Scaffold.CreateToggle({
		Name = "Diagonal",
		Function = function(callback) end,
		Default = true
	})
	ScaffoldTower = Scaffold.CreateToggle({
		Name = "Tower",
		Function = function(callback)
			if ScaffoldStopMotion.Object then
				ScaffoldTower.Object.ToggleArrow.Visible = callback
				ScaffoldStopMotion.Object.Visible = callback
			end
		end
	})
	ScaffoldMouseCheck = Scaffold.CreateToggle({
		Name = "Require mouse down",
		Function = function(callback) end,
		HoverText = "Only places when left click is held.",
	})
	ScaffoldDownwards  = Scaffold.CreateToggle({
		Name = "Downwards",
		Function = function(callback) end,
		HoverText = "Goes down when left shift is held."
	})
	ScaffoldStopMotion = Scaffold.CreateToggle({
		Name = "Stop Motion",
		Function = function() end,
		HoverText = "Stops your movement when going up"
	})
	ScaffoldStopMotion.Object.BackgroundTransparency = 0
	ScaffoldStopMotion.Object.BorderSizePixel = 0
	ScaffoldStopMotion.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ScaffoldStopMotion.Object.Visible = ScaffoldTower.Enabled
	ScaffoldBlockCount = Scaffold.CreateToggle({
		Name = "Block Count",
		Function = function(callback)
			if Scaffold.Enabled then
				scaffoldtext.Visible = callback
			end
		end,
		HoverText = "Shows the amount of blocks in the middle."
	})
	ScaffoldHandCheck = Scaffold.CreateToggle({
		Name = "Whitelist Only",
		Function = function() end,
		HoverText = "Only builds with blocks in your hand."
	})
	ScaffoldAnimation = Scaffold.CreateToggle({
		Name = "Animation",
		Function = function() end
	})
end)

local antivoidvelo
run(function()
	local Speed = {Enabled = false}
	local SpeedMode = {Value = "CFrame"}
	local SpeedValue = {Value = 1}
	local SpeedValueLarge = {Value = 1}
	local SpeedJump = {Enabled = false}
	local SpeedJumpHeight = {Value = 20}
	local SpeedJumpAlways = {Enabled = false}
	local SpeedJumpSound = {Enabled = false}
	local SpeedJumpVanilla = {Enabled = false}
	local SpeedAnimation = {Enabled = false}
	local raycastparameters = RaycastParams.new()

	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	Speed = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Speed",
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat("Speed", function(delta)
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if store.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if not (isnetworkowner(entityLibrary.character.HumanoidRootPart) and entityLibrary.character.Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing and (not spiderActive) and (not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled)) then return end
						if GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton and GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton.Api.Enabled then return end
						if LongJump.Enabled then return end
						if SpeedAnimation.Enabled then
							for i, v in pairs(entityLibrary.character.Humanoid:GetPlayingAnimationTracks()) do
								if v.Name == "WalkAnim" or v.Name == "RunAnim" then
									v:AdjustSpeed(entityLibrary.character.Humanoid.WalkSpeed / 16)
								end
							end
						end

						local speedValue = SpeedValue.Value + getSpeed()
						local speedVelocity = entityLibrary.character.Humanoid.MoveDirection * (SpeedMode.Value == "Normal" and SpeedValue.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = antivoidvelo or Vector3.new(speedVelocity.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, speedVelocity.Z)
						if SpeedMode.Value ~= "Normal" then
							local speedCFrame = entityLibrary.character.Humanoid.MoveDirection * (speedValue - 20) * delta
							raycastparameters.FilterDescendantsInstances = {lplr.Character}
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, speedCFrame, raycastparameters)
							if ray then speedCFrame = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + speedCFrame
						end

						if SpeedJump.Enabled and (not Scaffold.Enabled) and (SpeedJumpAlways.Enabled or killauraNearPlayer) then
							if (entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air) and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero then
								if SpeedJumpSound.Enabled then
									pcall(function() entityLibrary.character.HumanoidRootPart.Jumping:Play() end)
								end
								if SpeedJumpVanilla.Enabled then
									entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								else
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, SpeedJumpHeight.Value, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								end
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("Speed")
			end
		end,
		HoverText = "Increases your movement.",
		ExtraText = function()
			return "Heatseeker"
		end
	})
	SpeedValue = Speed.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedValueLarge = Speed.CreateSlider({
		Name = "Big Mode Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedJump = Speed.CreateToggle({
		Name = "AutoJump",
		Function = function(callback)
			if SpeedJumpHeight.Object then SpeedJumpHeight.Object.Visible = callback end
			if SpeedJumpAlways.Object then
				SpeedJump.Object.ToggleArrow.Visible = callback
				SpeedJumpAlways.Object.Visible = callback
			end
			if SpeedJumpSound.Object then SpeedJumpSound.Object.Visible = callback end
			if SpeedJumpVanilla.Object then SpeedJumpVanilla.Object.Visible = callback end
		end,
		Default = true
	})
	SpeedJumpHeight = Speed.CreateSlider({
		Name = "Jump Height",
		Min = 0,
		Max = 30,
		Default = 25,
		Function = function() end
	})
	SpeedJumpAlways = Speed.CreateToggle({
		Name = "Always Jump",
		Function = function() end
	})
	SpeedJumpSound = Speed.CreateToggle({
		Name = "Jump Sound",
		Function = function() end
	})
	SpeedJumpVanilla = Speed.CreateToggle({
		Name = "Real Jump",
		Function = function() end
	})
	SpeedAnimation = Speed.CreateToggle({
		Name = "Slowdown Anim",
		Function = function() end
	})
end)

run(function()
	local function roundpos(dir, pos, size)
		local suc, res = pcall(function() return Vector3.new(math.clamp(dir.X, pos.X - (size.X / 2), pos.X + (size.X / 2)), math.clamp(dir.Y, pos.Y - (size.Y / 2), pos.Y + (size.Y / 2)), math.clamp(dir.Z, pos.Z - (size.Z / 2), pos.Z + (size.Z / 2))) end)
		return suc and res or Vector3.zero
	end

	local Spider = {Enabled = false}
	local SpiderSpeed = {Value = 0}
	local SpiderMode = {Value = "Normal"}
	local SpiderPart
	Spider = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Spider",
		Function = function(callback)
			if callback then
				table.insert(Spider.Connections, inputService.InputBegan:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then
						holdingshift = true
					end
				end))
				table.insert(Spider.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then
						holdingshift = false
					end
				end))
				RunLoops:BindToHeartbeat("Spider", function()
					if entityLibrary.isAlive and (GuiLibrary.ObjectsThatCanBeSaved.PhaseOptionsButton.Api.Enabled == false or holdingshift == false) then
						if SpiderMode.Value == "Normal" then
							local vec = entityLibrary.character.Humanoid.MoveDirection * 2
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec + Vector3.new(0, 0.1, 0)))
							local newray2 = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray and (not newray.CanCollide) then newray = nil end
							if newray2 and (not newray2.CanCollide) then newray2 = nil end
							if spiderActive and (not newray) and (not newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 0, entityLibrary.character.HumanoidRootPart.Velocity.Z)
							end
							spiderActive = ((newray or newray2) and true or false)
							if (newray or newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.X or 0, SpiderSpeed.Value, newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.Z or 0)
							end
						else
							if not SpiderPart then
								SpiderPart = Instance.new("TrussPart")
								SpiderPart.Size = Vector3.new(2, 2, 2)
								SpiderPart.Transparency = 1
								SpiderPart.Anchored = true
								SpiderPart.Parent = gameCamera
							end
							local newray2, newray2pos = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + ((entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 1.5) - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray2 and (not newray2.CanCollide) then newray2 = nil end
							spiderActive = (newray2 and true or false)
							if newray2 then
								newray2pos = newray2pos * 3
								local newpos = roundpos(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(newray2pos.X, math.min(entityLibrary.character.HumanoidRootPart.Position.Y, newray2pos.Y), newray2pos.Z), Vector3.new(1.1, 1.1, 1.1))
								SpiderPart.Position = newpos
							else
								SpiderPart.Position = Vector3.zero
							end
						end
					end
				end)
			else
				if SpiderPart then SpiderPart:Destroy() end
				RunLoops:UnbindFromHeartbeat("Spider")
				holdingshift = false
			end
		end,
		HoverText = "Lets you climb up walls"
	})
	SpiderMode = Spider.CreateDropdown({
		Name = "Mode",
		List = {"Normal", "Classic"},
		Function = function()
			if SpiderPart then SpiderPart:Destroy() end
		end
	})
	SpiderSpeed = Spider.CreateSlider({
		Name = "Speed",
		Min = 0,
		Max = 40,
		Function = function() end,
		Default = 40
	})
end)

run(function()
	local TargetStrafe = {Enabled = false}
	local TargetStrafeRange = {Value = 18}
	local oldmove
	local controlmodule
	local block
	TargetStrafe = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "TargetStrafe",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if not controlmodule then
						local suc = pcall(function() controlmodule = require(lplr.PlayerScripts.PlayerModule).controls end)
						if not suc then controlmodule = {} end
					end
					oldmove = controlmodule.moveFunction
					local ang = 0
					local oldplr
					block = Instance.new("Part")
					block.Anchored = true
					block.CanCollide = false
					block.Parent = gameCamera
					controlmodule.moveFunction = function(Self, vec, facecam, ...)
						if entityLibrary.isAlive then
							local plr = AllNearPosition(TargetStrafeRange.Value + 5, 10)[1]
							plr = plr and (not workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position), store.blockRaycast)) and workspace:Raycast(plr.RootPart.Position, Vector3.new(0, -70, 0), store.blockRaycast) and plr or nil
							if plr ~= oldplr then
								if plr then
									local x, y, z = CFrame.new(plr.RootPart.Position, entityLibrary.character.HumanoidRootPart.Position):ToEulerAnglesXYZ()
									ang = math.deg(z)
								end
								oldplr = plr
							end
							if plr then
								facecam = false
								local localPos = CFrame.new(plr.RootPart.Position)
								local ray = workspace:Blockcast(localPos, Vector3.new(3, 3, 3), CFrame.Angles(0, math.rad(ang), 0).lookVector * TargetStrafeRange.Value, store.blockRaycast)
								local newPos = localPos + (CFrame.Angles(0, math.rad(ang), 0).lookVector * (ray and ray.Distance - 1 or TargetStrafeRange.Value))
								local factor = getSpeed() > 0 and 6 or 4
								if not workspace:Raycast(newPos.p, Vector3.new(0, -70, 0), store.blockRaycast) then
									newPos = localPos
									factor = 40
								end
								if ((entityLibrary.character.HumanoidRootPart.Position * Vector3.new(1, 0, 1)) - (newPos.p * Vector3.new(1, 0, 1))).Magnitude < 4 or ray then
									ang = ang + factor % 360
								end
								block.Position = newPos.p
								vec = (newPos.p - entityLibrary.character.HumanoidRootPart.Position) * Vector3.new(1, 0, 1)
							end
						end
						return oldmove(Self, vec, facecam, ...)
					end
				end)
			else
				block:Destroy()
				controlmodule.moveFunction = oldmove
			end
		end
	})
	TargetStrafeRange = TargetStrafe.CreateSlider({
		Name = "Range",
		Min = 0,
		Max = 18,
		Function = function() end
	})
end)

run(function()
	local BedESP = {Enabled = false}
	local BedESPFolder = Instance.new("Folder")
	BedESPFolder.Name = "BedESPFolder"
	BedESPFolder.Parent = GuiLibrary.MainGui
	local BedESPTable = {}
	local BedESPColor = {Value = 0.44}
	local BedESPTransparency = {Value = 1}
	local BedESPOnTop = {Enabled = true}
	BedESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "BedESP",
		Function = function(callback)
			if callback then
				table.insert(BedESP.Connections, collectionService:GetInstanceAddedSignal("bed"):Connect(function(bed)
					task.wait(0.2)
					if not BedESP.Enabled then return end
					local BedFolder = Instance.new("Folder")
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in pairs(bed:GetChildren()) do
						if bedesppart.Name ~= 'Bed' then continue end
						local boxhandle = Instance.new("BoxHandleAdornment")
						boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
						boxhandle.AlwaysOnTop = true
						boxhandle.ZIndex = (bedesppart.Name == "Covers" and 10 or 0)
						boxhandle.Visible = true
						boxhandle.Adornee = bedesppart
						boxhandle.Color3 = bedesppart.Color
						boxhandle.Name = bedespnumber
						boxhandle.Parent = BedFolder
					end
				end))
				table.insert(BedESP.Connections, collectionService:GetInstanceRemovedSignal("bed"):Connect(function(bed)
					if BedESPTable[bed] then
						BedESPTable[bed]:Destroy()
						BedESPTable[bed] = nil
					end
				end))
				for i, bed in pairs(collectionService:GetTagged("bed")) do
					local BedFolder = Instance.new("Folder")
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in pairs(bed:GetChildren()) do
						if bedesppart:IsA("BasePart") then
							local boxhandle = Instance.new("BoxHandleAdornment")
							boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
							boxhandle.AlwaysOnTop = true
							boxhandle.ZIndex = (bedesppart.Name == "Covers" and 10 or 0)
							boxhandle.Visible = true
							boxhandle.Adornee = bedesppart
							boxhandle.Color3 = bedesppart.Color
							boxhandle.Parent = BedFolder
						end
					end
				end
			else
				BedESPFolder:ClearAllChildren()
				table.clear(BedESPTable)
			end
		end,
		HoverText = "Render Beds through walls"
	})
end)

run(function()
	local function getallblocks2(pos, normal)
		local blocks = {}
		local lastfound = nil
		for i = 1, 20 do
			local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
			local extrablock = getPlacedBlock(blockpos)
			local covered = true
			if extrablock and extrablock.Parent ~= nil then
				if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) then
					table.insert(blocks, extrablock:GetAttribute("NoBreak") and "unbreakable" or extrablock.Name)
				else
					table.insert(blocks, "unbreakable")
					break
				end
				lastfound = extrablock
				if covered == false then
					break
				end
			else
				break
			end
		end
		return blocks
	end

	local function getallbedblocks(pos)
		local blocks = {}
		for i,v in pairs(cachedNormalSides) do
			for i2,v2 in pairs(getallblocks2(pos, v)) do
				if table.find(blocks, v2) == nil and v2 ~= "bed" then
					table.insert(blocks, v2)
				end
			end
			for i2,v2 in pairs(getallblocks2(pos + Vector3.new(0, 0, 3), v)) do
				if table.find(blocks, v2) == nil and v2 ~= "bed" then
					table.insert(blocks, v2)
				end
			end
		end
		return blocks
	end

	local function refreshAdornee(v)
		local bedblocks = getallbedblocks(v.Adornee.Position)
		for i2,v2 in pairs(v.Frame:GetChildren()) do
			if v2:IsA("ImageLabel") then
				v2:Remove()
			end
		end
		for i3,v3 in pairs(bedblocks) do
			local blockimage = Instance.new("ImageLabel")
			blockimage.Size = UDim2.new(0, 32, 0, 32)
			blockimage.BackgroundTransparency = 1
			blockimage.Image = bedwars.getIcon({itemType = v3}, true)
			blockimage.Parent = v.Frame
		end
	end

	local BedPlatesFolder = Instance.new("Folder")
	BedPlatesFolder.Name = "BedPlatesFolder"
	BedPlatesFolder.Parent = GuiLibrary.MainGui
	local BedPlatesTable = {}
	local BedPlates = {Enabled = false}

	local function addBed(v)
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = BedPlatesFolder
		billboard.Name = "bed"
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 42, 0, 42)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		BedPlatesTable[v] = billboard
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BackgroundTransparency = 0.5
		frame.Parent = billboard
		local uilistlayout = Instance.new("UIListLayout")
		uilistlayout.FillDirection = Enum.FillDirection.Horizontal
		uilistlayout.Padding = UDim.new(0, 4)
		uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
		end)
		uilistlayout.Parent = frame
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = frame
		refreshAdornee(billboard)
	end

	BedPlates = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "BedPlates",
		Function = function(callback)
			if callback then
				table.insert(BedPlates.Connections, vapeEvents.PlaceBlockEvent.Event:Connect(function(p5)
					for i, v in pairs(BedPlatesFolder:GetChildren()) do
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, vapeEvents.BreakBlockEvent.Event:Connect(function(p5)
					for i, v in pairs(BedPlatesFolder:GetChildren()) do
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceAddedSignal("bed"):Connect(function(v)
					addBed(v)
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceRemovedSignal("bed"):Connect(function(v)
					if BedPlatesTable[v] then
						BedPlatesTable[v]:Destroy()
						BedPlatesTable[v] = nil
					end
				end))
				for i, v in pairs(collectionService:GetTagged("bed")) do
					addBed(v)
				end
			else
				BedPlatesFolder:ClearAllChildren()
			end
		end
	})
end)

run(function()
	local ChestESPList = {ObjectList = {}, RefreshList = function() end}
	local function nearchestitem(item)
		for i,v in next, (ChestESPList.ObjectList) do 
			if item:find(v) then return v end
		end
	end
	local function refreshAdornee(v)
		local chest = v.Adornee.ChestFolderValue.Value
		local chestitems = chest and chest:GetChildren() or {}
		for i2,v2 in next, (v.Frame:GetChildren()) do
			if v2:IsA('ImageLabel') then
				v2:Remove()
			end
		end
		v.Enabled = false
		local alreadygot = {}
		for itemNumber, item in next, (chestitems) do
			if alreadygot[item.Name] == nil and (table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name)) then 
				alreadygot[item.Name] = true
				v.Enabled = true
				local blockimage = Instance.new('ImageLabel')
				blockimage.Size = UDim2.new(0, 32, 0, 32)
				blockimage.BackgroundTransparency = 1
				blockimage.Image = bedwars.getIcon({itemType = item.Name}, true)
				blockimage.Parent = v.Frame
			end
		end
	end

	local ChestESPFolder = Instance.new('Folder')
	ChestESPFolder.Name = 'ChestESPFolder'
	ChestESPFolder.Parent = GuiLibrary.MainGui
	local ChestESP = {}
	local ChestESPBackground = {}

	local function chestfunc(v)
		task.spawn(function()
			local billboard = Instance.new('BillboardGui')
			billboard.Parent = ChestESPFolder
			billboard.Name = 'chest'
			billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
			billboard.Size = UDim2.new(0, 42, 0, 42)
			billboard.AlwaysOnTop = true
			billboard.Adornee = v
			local frame = Instance.new('Frame')
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = ChestESPBackground.Enabled and 0.5 or 1
			frame.Parent = billboard
			local uilistlayout = Instance.new('UIListLayout')
			uilistlayout.FillDirection = Enum.FillDirection.Horizontal
			uilistlayout.Padding = UDim.new(0, 4)
			uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uilistlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
				billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
			end)
			uilistlayout.Parent = frame
			local uicorner = Instance.new('UICorner')
			uicorner.CornerRadius = UDim.new(0, 4)
			uicorner.Parent = frame
			local chest = v:WaitForChild('ChestFolderValue').Value
			if chest then 
				table.insert(ChestESP.Connections, chest.ChildAdded:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				table.insert(ChestESP.Connections, chest.ChildRemoved:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				refreshAdornee(billboard)
			end
		end)
	end

	ChestESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'ChestESP',
		Function = function(calling)
			if calling then
				task.spawn(function()
					table.insert(ChestESP.Connections, collectionService:GetInstanceAddedSignal('chest'):Connect(chestfunc))
					for i,v in next, (collectionService:GetTagged('chest')) do chestfunc(v) end
				end)
			else
				ChestESPFolder:ClearAllChildren()
			end
		end
	})
	ChestESPList = ChestESP.CreateTextList({
		Name = 'ItemList',
		TempText = 'item or part of item',
		AddFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		RemoveFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end
	})
	ChestESPBackground = ChestESP.CreateToggle({
		Name = 'Background',
		Function = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		Default = true
	})
end)

run(function()
	local FieldOfViewValue = {Value = 70}
	local oldfov
	local oldfov2
	local FieldOfView = {Enabled = false}
	local FieldOfViewZoom = {Enabled = false}
	FieldOfView = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "FOVChanger",
		Function = function(callback)
			if callback then
				if FieldOfViewZoom.Enabled then
					task.spawn(function()
						repeat
							task.wait()
						until not inputService:IsKeyDown(Enum.KeyCode[FieldOfView.Keybind ~= "" and FieldOfView.Keybind or "C"])
						if FieldOfView.Enabled then
							FieldOfView.ToggleButton(false)
						end
					end)
				end
				oldfov = bedwars.FovController.setFOV
				oldfov2 = bedwars.FovController.getFOV
				bedwars.FovController.setFOV = function(self, fov) return oldfov(self, FieldOfViewValue.Value) end
				bedwars.FovController.getFOV = function(self, fov) return FieldOfViewValue.Value end
			else
				bedwars.FovController.setFOV = oldfov
				bedwars.FovController.getFOV = oldfov2
			end
			bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
		end
	})
	FieldOfViewValue = FieldOfView.CreateSlider({
		Name = "FOV",
		Min = 30,
		Max = 120,
		Function = function(val)
			if FieldOfView.Enabled then
				bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
			end
		end
	})
	FieldOfViewZoom = FieldOfView.CreateToggle({
		Name = "Zoom",
		Function = function() end,
		HoverText = "optifine zoom lol"
	})
end)

run(function()
	local old
	local old2
	local oldhitpart
	local FPSBoost = {Enabled = false}
	local removetextures = {Enabled = false}
	local removetexturessmooth = {Enabled = false}
	local fpsboostdamageindicator = {Enabled = false}
	local fpsboostdamageeffect = {Enabled = false}
	local fpsboostkilleffect = {Enabled = false}
	local originaltextures = {}
	local originaleffects = {}

	local function fpsboosttextures()
		task.spawn(function()
			repeat task.wait() until store.matchState ~= 0
			for i,v in pairs(store.blocks) do
				if v:GetAttribute("PlacedByUserId") == 0 then
					v.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find("glass") and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
					originaltextures[v] = originaltextures[v] or v.MaterialVariant
					v.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and "" or originaltextures[v]
					for i2,v2 in pairs(v:GetChildren()) do
						pcall(function()
							v2.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find("glass") and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
							originaltextures[v2] = originaltextures[v2] or v2.MaterialVariant
							v2.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and "" or originaltextures[v2]
						end)
					end
				end
			end
		end)
	end

	FPSBoost = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "FPSBoost",
		Function = function(callback)
			local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
			if callback then
				wasenabled = true
				fpsboosttextures()
				if fpsboostdamageindicator.Enabled then
					damagetab.strokeThickness = 0
					damagetab.textSize = 0
					damagetab.blowUpDuration = 0
					damagetab.blowUpSize = 0
				end
				if fpsboostkilleffect.Enabled then
					for i,v in pairs(bedwars.KillEffectController.killEffects) do
						originaleffects[i] = v
						bedwars.KillEffectController.killEffects[i] = {new = function(char) return {onKill = function() end, isPlayDefaultKillEffect = function() return char == lplr.Character end} end}
					end
				end
				if fpsboostdamageeffect.Enabled then
					oldhitpart = bedwars.DamageIndicatorController.hitEffectPart
					bedwars.DamageIndicatorController.hitEffectPart = nil
				end
				old = bedwars.EntityHighlightController.highlight
				old2 = getmetatable(bedwars.StopwatchController).tweenOutGhost
				local highlighttable = {}
				getmetatable(bedwars.StopwatchController).tweenOutGhost = function(p17, p18)
					p18:Destroy()
				end
				bedwars.EntityHighlightController.highlight = function() end
			else
				for i,v in pairs(originaleffects) do
					bedwars.KillEffectController.killEffects[i] = v
				end
				fpsboosttextures()
				if oldhitpart then
					bedwars.DamageIndicatorController.hitEffectPart = oldhitpart
				end
				debug.setupvalue(bedwars.KillEffectController.KnitStart, 2, require(lplr.PlayerScripts.TS["client-sync-events"]).ClientSyncEvents)
				damagetab.strokeThickness = 1.5
				damagetab.textSize = 28
				damagetab.blowUpDuration = 0.125
				damagetab.blowUpSize = 76
				debug.setupvalue(bedwars.DamageIndicator, 10, tweenService)
				if bedwars.DamageIndicatorController.hitEffectPart then
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Cubes.Enabled = true
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Shards.Enabled = true
				end
				bedwars.EntityHighlightController.highlight = old
				getmetatable(bedwars.StopwatchController).tweenOutGhost = old2
				old = nil
				old2 = nil
			end
		end
	})
	removetextures = FPSBoost.CreateToggle({
		Name = "Remove Textures",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageindicator = FPSBoost.CreateToggle({
		Name = "Remove Damage Indicator",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageeffect = FPSBoost.CreateToggle({
		Name = "Remove Damage Effect",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostkilleffect = FPSBoost.CreateToggle({
		Name = "Remove Kill Effect",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
end)

run(function()
	local GameFixer = {Enabled = false}
	local GameFixerHit = {Enabled = false}
	GameFixer = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "GameFixer",
		Function = function(callback)
			debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, callback and 'raycast' or 'Raycast')
        	debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, callback and bedwars.QueryUtil or workspace)
		end,
		HoverText = "Fixes game bugs"
	})
end)

run(function()
	local transformed = false
	local GameTheme = {Enabled = false}
	local GameThemeMode = {Value = "GameTheme"}

	local themefunctions = {
		Old = function()
			task.spawn(function()
				local oldbedwarstabofimages = '{"clay_orange":"rbxassetid://7017703219","iron":"rbxassetid://6850537969","glass":"rbxassetid://6909521321","log_spruce":"rbxassetid://6874161124","ice":"rbxassetid://6874651262","marble":"rbxassetid://6594536339","zipline_base":"rbxassetid://7051148904","iron_helmet":"rbxassetid://6874272559","marble_pillar":"rbxassetid://6909323822","clay_dark_green":"rbxassetid://6763635916","wood_plank_birch":"rbxassetid://6768647328","watering_can":"rbxassetid://6915423754","emerald_helmet":"rbxassetid://6931675766","pie":"rbxassetid://6985761399","wood_plank_spruce":"rbxassetid://6768615964","diamond_chestplate":"rbxassetid://6874272898","wool_pink":"rbxassetid://6910479863","wool_blue":"rbxassetid://6910480234","wood_plank_oak":"rbxassetid://6910418127","diamond_boots":"rbxassetid://6874272964","clay_yellow":"rbxassetid://4991097283","tnt":"rbxassetid://6856168996","lasso":"rbxassetid://7192710930","clay_purple":"rbxassetid://6856099740","melon_seeds":"rbxassetid://6956387796","apple":"rbxassetid://6985765179","carrot_seeds":"rbxassetid://6956387835","log_oak":"rbxassetid://6763678414","emerald_chestplate":"rbxassetid://6931675868","wool_yellow":"rbxassetid://6910479606","emerald_boots":"rbxassetid://6931675942","clay_light_brown":"rbxassetid://6874651634","balloon":"rbxassetid://7122143895","cannon":"rbxassetid://7121221753","leather_boots":"rbxassetid://6855466456","melon":"rbxassetid://6915428682","wool_white":"rbxassetid://6910387332","log_birch":"rbxassetid://6763678414","clay_pink":"rbxassetid://6856283410","grass":"rbxassetid://6773447725","obsidian":"rbxassetid://6910443317","shield":"rbxassetid://7051149149","red_sandstone":"rbxassetid://6708703895","diamond_helmet":"rbxassetid://6874272793","wool_orange":"rbxassetid://6910479956","log_hickory":"rbxassetid://7017706899","guitar":"rbxassetid://7085044606","wool_purple":"rbxassetid://6910479777","diamond":"rbxassetid://6850538161","iron_chestplate":"rbxassetid://6874272631","slime_block":"rbxassetid://6869284566","stone_brick":"rbxassetid://6910394475","hammer":"rbxassetid://6955848801","ceramic":"rbxassetid://6910426690","wood_plank_maple":"rbxassetid://6768632085","leather_helmet":"rbxassetid://6855466216","stone":"rbxassetid://6763635916","slate_brick":"rbxassetid://6708836267","sandstone":"rbxassetid://6708657090","snow":"rbxassetid://6874651192","wool_red":"rbxassetid://6910479695","leather_chestplate":"rbxassetid://6876833204","clay_red":"rbxassetid://6856283323","wool_green":"rbxassetid://6910480050","clay_white":"rbxassetid://7017705325","wool_cyan":"rbxassetid://6910480152","clay_black":"rbxassetid://5890435474","sand":"rbxassetid://6187018940","clay_light_green":"rbxassetid://6856099550","clay_dark_brown":"rbxassetid://6874651325","carrot":"rbxassetid://3677675280","clay":"rbxassetid://6856190168","iron_boots":"rbxassetid://6874272718","emerald":"rbxassetid://6850538075","zipline":"rbxassetid://7051148904"}'
				local oldbedwarsicontab = game:GetService("HttpService"):JSONDecode(oldbedwarstabofimages)
				local oldbedwarssoundtable = {
					["QUEUE_JOIN"] = "rbxassetid://6691735519",
					["QUEUE_MATCH_FOUND"] = "rbxassetid://6768247187",
					["UI_CLICK"] = "rbxassetid://6732690176",
					["UI_OPEN"] = "rbxassetid://6732607930",
					["BEDWARS_UPGRADE_SUCCESS"] = "rbxassetid://6760677364",
					["BEDWARS_PURCHASE_ITEM"] = "rbxassetid://6760677364",
					["SWORD_SWING_1"] = "rbxassetid://6760544639",
					["SWORD_SWING_2"] = "rbxassetid://6760544595",
					["DAMAGE_1"] = "rbxassetid://6765457325",
					["DAMAGE_2"] = "rbxassetid://6765470975",
					["DAMAGE_3"] = "rbxassetid://6765470941",
					["CROP_HARVEST"] = "rbxassetid://4864122196",
					["CROP_PLANT_1"] = "rbxassetid://5483943277",
					["CROP_PLANT_2"] = "rbxassetid://5483943479",
					["CROP_PLANT_3"] = "rbxassetid://5483943723",
					["ARMOR_EQUIP"] = "rbxassetid://6760627839",
					["ARMOR_UNEQUIP"] = "rbxassetid://6760625788",
					["PICKUP_ITEM_DROP"] = "rbxassetid://6768578304",
					["PARTY_INCOMING_INVITE"] = "rbxassetid://6732495464",
					["ERROR_NOTIFICATION"] = "rbxassetid://6732495464",
					["INFO_NOTIFICATION"] = "rbxassetid://6732495464",
					["END_GAME"] = "rbxassetid://6246476959",
					["GENERIC_BLOCK_PLACE"] = "rbxassetid://4842910664",
					["GENERIC_BLOCK_BREAK"] = "rbxassetid://4819966893",
					["GRASS_BREAK"] = "rbxassetid://5282847153",
					["WOOD_BREAK"] = "rbxassetid://4819966893",
					["STONE_BREAK"] = "rbxassetid://6328287211",
					["WOOL_BREAK"] = "rbxassetid://4842910664",
					["TNT_EXPLODE_1"] = "rbxassetid://7192313632",
					["TNT_HISS_1"] = "rbxassetid://7192313423",
					["FIREBALL_EXPLODE"] = "rbxassetid://6855723746",
					["SLIME_BLOCK_BOUNCE"] = "rbxassetid://6857999096",
					["SLIME_BLOCK_BREAK"] = "rbxassetid://6857999170",
					["SLIME_BLOCK_HIT"] = "rbxassetid://6857999148",
					["SLIME_BLOCK_PLACE"] = "rbxassetid://6857999119",
					["BOW_DRAW"] = "rbxassetid://6866062236",
					["BOW_FIRE"] = "rbxassetid://6866062104",
					["ARROW_HIT"] = "rbxassetid://6866062188",
					["ARROW_IMPACT"] = "rbxassetid://6866062148",
					["TELEPEARL_THROW"] = "rbxassetid://6866223756",
					["TELEPEARL_LAND"] = "rbxassetid://6866223798",
					["CROSSBOW_RELOAD"] = "rbxassetid://6869254094",
					["VOICE_1"] = "rbxassetid://5283866929",
					["VOICE_2"] = "rbxassetid://5283867710",
					["VOICE_HONK"] = "rbxassetid://5283872555",
					["FORTIFY_BLOCK"] = "rbxassetid://6955762535",
					["EAT_FOOD_1"] = "rbxassetid://4968170636",
					["KILL"] = "rbxassetid://7013482008",
					["ZIPLINE_TRAVEL"] = "rbxassetid://7047882304",
					["ZIPLINE_LATCH"] = "rbxassetid://7047882233",
					["ZIPLINE_UNLATCH"] = "rbxassetid://7047882265",
					["SHIELD_BLOCKED"] = "rbxassetid://6955762535",
					["GUITAR_LOOP"] = "rbxassetid://7084168540",
					["GUITAR_HEAL_1"] = "rbxassetid://7084168458",
					["CANNON_MOVE"] = "rbxassetid://7118668472",
					["CANNON_FIRE"] = "rbxassetid://7121064180",
					["BALLOON_INFLATE"] = "rbxassetid://7118657911",
					["BALLOON_POP"] = "rbxassetid://7118657873",
					["FIREBALL_THROW"] = "rbxassetid://7192289445",
					["LASSO_HIT"] = "rbxassetid://7192289603",
					["LASSO_SWING"] = "rbxassetid://7192289504",
					["LASSO_THROW"] = "rbxassetid://7192289548",
					["GRIM_REAPER_CONSUME"] = "rbxassetid://7225389554",
					["GRIM_REAPER_CHANNEL"] = "rbxassetid://7225389512",
					["TV_STATIC"] = "rbxassetid://7256209920",
					["TURRET_ON"] = "rbxassetid://7290176291",
					["TURRET_OFF"] = "rbxassetid://7290176380",
					["TURRET_ROTATE"] = "rbxassetid://7290176421",
					["TURRET_SHOOT"] = "rbxassetid://7290187805",
					["WIZARD_LIGHTNING_CAST"] = "rbxassetid://7262989886",
					["WIZARD_LIGHTNING_LAND"] = "rbxassetid://7263165647",
					["WIZARD_LIGHTNING_STRIKE"] = "rbxassetid://7263165347",
					["WIZARD_ORB_CAST"] = "rbxassetid://7263165448",
					["WIZARD_ORB_TRAVEL_LOOP"] = "rbxassetid://7263165579",
					["WIZARD_ORB_CONTACT_LOOP"] = "rbxassetid://7263165647",
					["BATTLE_PASS_PROGRESS_LEVEL_UP"] = "rbxassetid://7331597283",
					["BATTLE_PASS_PROGRESS_EXP_GAIN"] = "rbxassetid://7331597220",
					["FLAMETHROWER_UPGRADE"] = "rbxassetid://7310273053",
					["FLAMETHROWER_USE"] = "rbxassetid://7310273125",
					["BRITTLE_HIT"] = "rbxassetid://7310273179",
					["EXTINGUISH"] = "rbxassetid://7310273015",
					["RAVEN_SPACE_AMBIENT"] = "rbxassetid://7341443286",
					["RAVEN_WING_FLAP"] = "rbxassetid://7341443378",
					["RAVEN_CAW"] = "rbxassetid://7341443447",
					["JADE_HAMMER_THUD"] = "rbxassetid://7342299402",
					["STATUE"] = "rbxassetid://7344166851",
					["CONFETTI"] = "rbxassetid://7344278405",
					["HEART"] = "rbxassetid://7345120916",
					["SPRAY"] = "rbxassetid://7361499529",
					["BEEHIVE_PRODUCE"] = "rbxassetid://7378100183",
					["DEPOSIT_BEE"] = "rbxassetid://7378100250",
					["CATCH_BEE"] = "rbxassetid://7378100305",
					["BEE_NET_SWING"] = "rbxassetid://7378100350",
					["ASCEND"] = "rbxassetid://7378387334",
					["BED_ALARM"] = "rbxassetid://7396762708",
					["BOUNTY_CLAIMED"] = "rbxassetid://7396751941",
					["BOUNTY_ASSIGNED"] = "rbxassetid://7396752155",
					["BAGUETTE_HIT"] = "rbxassetid://7396760547",
					["BAGUETTE_SWING"] = "rbxassetid://7396760496",
					["TESLA_ZAP"] = "rbxassetid://7497477336",
					["SPIRIT_TRIGGERED"] = "rbxassetid://7498107251",
					["SPIRIT_EXPLODE"] = "rbxassetid://7498107327",
					["ANGEL_LIGHT_ORB_CREATE"] = "rbxassetid://7552134231",
					["ANGEL_LIGHT_ORB_HEAL"] = "rbxassetid://7552134868",
					["ANGEL_VOID_ORB_CREATE"] = "rbxassetid://7552135942",
					["ANGEL_VOID_ORB_HEAL"] = "rbxassetid://7552136927",
					["DODO_BIRD_JUMP"] = "rbxassetid://7618085391",
					["DODO_BIRD_DOUBLE_JUMP"] = "rbxassetid://7618085771",
					["DODO_BIRD_MOUNT"] = "rbxassetid://7618085486",
					["DODO_BIRD_DISMOUNT"] = "rbxassetid://7618085571",
					["DODO_BIRD_SQUAWK_1"] = "rbxassetid://7618085870",
					["DODO_BIRD_SQUAWK_2"] = "rbxassetid://7618085657",
					["SHIELD_CHARGE_START"] = "rbxassetid://7730842884",
					["SHIELD_CHARGE_LOOP"] = "rbxassetid://7730843006",
					["SHIELD_CHARGE_BASH"] = "rbxassetid://7730843142",
					["ROCKET_LAUNCHER_FIRE"] = "rbxassetid://7681584765",
					["ROCKET_LAUNCHER_FLYING_LOOP"] = "rbxassetid://7681584906",
					["SMOKE_GRENADE_POP"] = "rbxassetid://7681276062",
					["SMOKE_GRENADE_EMIT_LOOP"] = "rbxassetid://7681276135",
					["GOO_SPIT"] = "rbxassetid://7807271610",
					["GOO_SPLAT"] = "rbxassetid://7807272724",
					["GOO_EAT"] = "rbxassetid://7813484049",
					["LUCKY_BLOCK_BREAK"] = "rbxassetid://7682005357",
					["AXOLOTL_SWITCH_TARGETS"] = "rbxassetid://7344278405",
					["HALLOWEEN_MUSIC"] = "rbxassetid://7775602786",
					["SNAP_TRAP_SETUP"] = "rbxassetid://7796078515",
					["SNAP_TRAP_CLOSE"] = "rbxassetid://7796078695",
					["SNAP_TRAP_CONSUME_MARK"] = "rbxassetid://7796078825",
					["GHOST_VACUUM_SUCKING_LOOP"] = "rbxassetid://7814995865",
					["GHOST_VACUUM_SHOOT"] = "rbxassetid://7806060367",
					["GHOST_VACUUM_CATCH"] = "rbxassetid://7815151688",
					["FISHERMAN_GAME_START"] = "rbxassetid://7806060544",
					["FISHERMAN_GAME_PULLING_LOOP"] = "rbxassetid://7806060638",
					["FISHERMAN_GAME_PROGRESS_INCREASE"] = "rbxassetid://7806060745",
					["FISHERMAN_GAME_FISH_MOVE"] = "rbxassetid://7806060863",
					["FISHERMAN_GAME_LOOP"] = "rbxassetid://7806061057",
					["FISHING_ROD_CAST"] = "rbxassetid://7806060976",
					["FISHING_ROD_SPLASH"] = "rbxassetid://7806061193",
					["SPEAR_HIT"] = "rbxassetid://7807270398",
					["SPEAR_THROW"] = "rbxassetid://7813485044",
				}
				for i,v in pairs(bedwars.CombatController.killSounds) do
					bedwars.CombatController.killSounds[i] = oldbedwarssoundtable.KILL
				end
				for i,v in pairs(bedwars.CombatController.multiKillLoops) do
					bedwars.CombatController.multiKillLoops[i] = ""
				end
				for i,v in pairs(bedwars.ItemTable) do
					if oldbedwarsicontab[i] then
						v.image = oldbedwarsicontab[i]
					end
				end
				for i,v in pairs(oldbedwarssoundtable) do
					local item = bedwars.SoundList[i]
					if item then
						bedwars.SoundList[i] = v
					end
				end
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(214, 0, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.ViewmodelController.show, 37, "")
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(1, 1, 1))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				sethiddenproperty(lightingService, "Technology", "ShadowMap")
				lightingService.Ambient = Color3.fromRGB(69, 69, 69)
				lightingService.Brightness = 3
				lightingService.EnvironmentDiffuseScale = 1
				lightingService.EnvironmentSpecularScale = 1
				lightingService.OutdoorAmbient = Color3.fromRGB(69, 69, 69)
				lightingService.Atmosphere.Density = 0.1
				lightingService.Atmosphere.Offset = 0.25
				lightingService.Atmosphere.Color = Color3.fromRGB(198, 198, 198)
				lightingService.Atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				lightingService.Atmosphere.Glare = 0
				lightingService.Atmosphere.Haze = 0
				lightingService.ClockTime = 13
				lightingService.GeographicLatitude = 0
				lightingService.GlobalShadows = false
				lightingService.TimeOfDay = "13:00:00"
				lightingService.Sky.SkyboxBk = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxDn = "rbxassetid://6334928194"
				lightingService.Sky.SkyboxFt = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxLf = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxRt = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxUp = "rbxassetid://7018689553"
			end)
		end,
		Winter = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.StarCount = 5000
				sky.SkyboxUp = "rbxassetid://8139676647"
				sky.SkyboxLf = "rbxassetid://8139676988"
				sky.SkyboxFt = "rbxassetid://8139677111"
				sky.SkyboxBk = "rbxassetid://8139677359"
				sky.SkyboxDn = "rbxassetid://8139677253"
				sky.SkyboxRt = "rbxassetid://8139676842"
				sky.SunTextureId = "rbxassetid://6196665106"
				sky.SunAngularSize = 11
				sky.MoonTextureId = "rbxassetid://8139665943"
				sky.MoonAngularSize = 30
				sky.Parent = lightingService
				local sunray = Instance.new("SunRaysEffect")
				sunray.Intensity = 0.03
				sunray.Parent = lightingService
				local bloom = Instance.new("BloomEffect")
				bloom.Threshold = 2
				bloom.Intensity = 1
				bloom.Size = 2
				bloom.Parent = lightingService
				local atmosphere = Instance.new("Atmosphere")
				atmosphere.Density = 0.3
				atmosphere.Offset = 0.25
				atmosphere.Color = Color3.fromRGB(198, 198, 198)
				atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				atmosphere.Glare = 0
				atmosphere.Haze = 0
				atmosphere.Parent = lightingService
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(70, 255, 255)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(1, 1, 1) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 4653055)
			end)
			task.spawn(function()
				local snowpart = Instance.new("Part")
				snowpart.Size = Vector3.new(240, 0.5, 240)
				snowpart.Name = "SnowParticle"
				snowpart.Transparency = 1
				snowpart.CanCollide = false
				snowpart.Position = Vector3.new(0, 120, 286)
				snowpart.Anchored = true
				snowpart.Parent = workspace
				local snow = Instance.new("ParticleEmitter")
				snow.RotSpeed = NumberRange.new(300)
				snow.VelocitySpread = 35
				snow.Rate = 28
				snow.Texture = "rbxassetid://8158344433"
				snow.Rotation = NumberRange.new(110)
				snow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				snow.Lifetime = NumberRange.new(8,14)
				snow.Speed = NumberRange.new(8,18)
				snow.EmissionDirection = Enum.NormalId.Bottom
				snow.SpreadAngle = Vector2.new(35,35)
				snow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				snow.Parent = snowpart
				local windsnow = Instance.new("ParticleEmitter")
				windsnow.Acceleration = Vector3.new(0,0,1)
				windsnow.RotSpeed = NumberRange.new(100)
				windsnow.VelocitySpread = 35
				windsnow.Rate = 28
				windsnow.Texture = "rbxassetid://8158344433"
				windsnow.EmissionDirection = Enum.NormalId.Bottom
				windsnow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				windsnow.Lifetime = NumberRange.new(8,14)
				windsnow.Speed = NumberRange.new(8,18)
				windsnow.Rotation = NumberRange.new(110)
				windsnow.SpreadAngle = Vector2.new(35,35)
				windsnow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				windsnow.Parent = snowpart
				repeat
					task.wait()
					if entityLibrary.isAlive then
						snowpart.Position = entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, 100, 0)
					end
				until not vapeInjected
			end)
		end,
		Halloween = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				lightingService.TimeOfDay = "00:00:00"
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 100, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 185, 81)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 16737280)
			end)
		end,
		Valentines = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.SkyboxBk = "rbxassetid://1546230803"
				sky.SkyboxDn = "rbxassetid://1546231143"
				sky.SkyboxFt = "rbxassetid://1546230803"
				sky.SkyboxLf = "rbxassetid://1546230803"
				sky.SkyboxRt = "rbxassetid://1546230803"
				sky.SkyboxUp = "rbxassetid://1546230451"
				sky.Parent = lightingService
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 132, 178)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 199, 220)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 16745650)
			end)
		end
	}

	GameTheme = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "GameTheme",
		Function = function(callback)
			if callback then
				if not transformed then
					transformed = true
					themefunctions[GameThemeMode.Value]()
				else
					GameTheme.ToggleButton(false)
				end
			else
				warningNotification("GameTheme", "Disabled Next Game", 10)
			end
		end,
		ExtraText = function()
			return GameThemeMode.Value
		end
	})
	GameThemeMode = GameTheme.CreateDropdown({
		Name = "Theme",
		Function = function() end,
		List = {"Old", "Winter", "Halloween", "Valentines"}
	})
end)

run(function()
	local oldkilleffect
	local KillEffectMode = {Value = "Gravity"}
	local KillEffectList = {Value = "None"}
	local KillEffectName2 = {}
	local killeffects = {
		Gravity = function(p3, p4, p5, p6)
			p5:BreakJoints()
			task.spawn(function()
				local partvelo = {}
				for i,v in pairs(p5:GetDescendants()) do
					if v:IsA("BasePart") then
						partvelo[v.Name] = v.Velocity * 3
					end
				end
				p5.Archivable = true
				local clone = p5:Clone()
				clone.Humanoid.Health = 100
				clone.Parent = workspace
				local nametag = clone:FindFirstChild("Nametag", true)
				if nametag then nametag:Destroy() end
				game:GetService("Debris"):AddItem(clone, 30)
				p5:Destroy()
				task.wait(0.01)
				clone.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				clone:BreakJoints()
				task.wait(0.01)
				for i,v in pairs(clone:GetDescendants()) do
					if v:IsA("BasePart") then
						local bodyforce = Instance.new("BodyForce")
						bodyforce.Force = Vector3.new(0, (workspace.Gravity - 10) * v:GetMass(), 0)
						bodyforce.Parent = v
						v.CanCollide = true
						v.Velocity = partvelo[v.Name] or Vector3.zero
					end
				end
			end)
		end,
		Lightning = function(p3, p4, p5, p6)
			p5:BreakJoints()
			local startpos = 1125
			local startcf = p5.PrimaryPart.CFrame.p - Vector3.new(0, 8, 0)
			local newpos = Vector3.new((math.random(1, 10) - 5) * 2, startpos, (math.random(1, 10) - 5) * 2)
			for i = startpos - 75, 0, -75 do
				local newpos2 = Vector3.new((math.random(1, 10) - 5) * 2, i, (math.random(1, 10) - 5) * 2)
				if i == 0 then
					newpos2 = Vector3.zero
				end
				local part = Instance.new("Part")
				part.Size = Vector3.new(1.5, 1.5, 77)
				part.Material = Enum.Material.SmoothPlastic
				part.Anchored = true
				part.Material = Enum.Material.Neon
				part.CanCollide = false
				part.CFrame = CFrame.new(startcf + newpos + ((newpos2 - newpos) * 0.5), startcf + newpos2)
				part.Parent = workspace
				local part2 = part:Clone()
				part2.Size = Vector3.new(3, 3, 78)
				part2.Color = Color3.new(0.7, 0.7, 0.7)
				part2.Transparency = 0.7
				part2.Material = Enum.Material.SmoothPlastic
				part2.Parent = workspace
				game:GetService("Debris"):AddItem(part, 0.5)
				game:GetService("Debris"):AddItem(part2, 0.5)
				bedwars.QueryUtil:setQueryIgnored(part, true)
				bedwars.QueryUtil:setQueryIgnored(part2, true)
				if i == 0 then
					local soundpart = Instance.new("Part")
					soundpart.Transparency = 1
					soundpart.Anchored = true
					soundpart.Size = Vector3.zero
					soundpart.Position = startcf
					soundpart.Parent = workspace
					bedwars.QueryUtil:setQueryIgnored(soundpart, true)
					local sound = Instance.new("Sound")
					sound.SoundId = "rbxassetid://6993372814"
					sound.Volume = 2
					sound.Pitch = 0.5 + (math.random(1, 3) / 10)
					sound.Parent = soundpart
					sound:Play()
					sound.Ended:Connect(function()
						soundpart:Destroy()
					end)
				end
				newpos = newpos2
			end
		end
	}
	local KillEffectName = {}
	for i,v in pairs(bedwars.KillEffectMeta) do
		table.insert(KillEffectName, v.name)
		KillEffectName[v.name] = i
	end
	table.sort(KillEffectName, function(a, b) return a:lower() < b:lower() end)
	local KillEffect = {Enabled = false}
	KillEffect = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "KillEffect",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0 or not KillEffect.Enabled
					if KillEffect.Enabled then
						lplr:SetAttribute("KillEffectType", "none")
						if KillEffectMode.Value == "Bedwars" then
							lplr:SetAttribute("KillEffectType", KillEffectName[KillEffectList.Value])
						end
					end
				end)
				oldkilleffect = bedwars.DefaultKillEffect.onKill
				bedwars.DefaultKillEffect.onKill = function(p3, p4, p5, p6)
					killeffects[KillEffectMode.Value](p3, p4, p5, p6)
				end
			else
				bedwars.DefaultKillEffect.onKill = oldkilleffect
			end
		end
	})
	local modes = {"Bedwars"}
	for i,v in pairs(killeffects) do
		table.insert(modes, i)
	end
	KillEffectMode = KillEffect.CreateDropdown({
		Name = "Mode",
		Function = function()
			if KillEffect.Enabled then
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = modes
	})
	KillEffectList = KillEffect.CreateDropdown({
		Name = "Bedwars",
		Function = function()
			if KillEffect.Enabled then
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = KillEffectName
	})
end)

run(function()
	local KitESP = {Enabled = false}
	local espobjs = {}
	local espfold = Instance.new("Folder")
	espfold.Parent = GuiLibrary.MainGui

	local function espadd(v, icon)
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = espfold
		billboard.Name = "iron"
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 32, 0, 32)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		local image = Instance.new("ImageLabel")
		image.BackgroundTransparency = 0.5
		image.BorderSizePixel = 0
		image.Image = bedwars.getIcon({itemType = icon}, true)
		image.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		image.Size = UDim2.new(0, 32, 0, 32)
		image.AnchorPoint = Vector2.new(0.5, 0.5)
		image.Parent = billboard
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = image
		espobjs[v] = billboard
	end

	local function addKit(tag, icon)
		table.insert(KitESP.Connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
			espadd(v.PrimaryPart, icon)
		end))
		table.insert(KitESP.Connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
			if espobjs[v.PrimaryPart] then
				espobjs[v.PrimaryPart]:Destroy()
				espobjs[v.PrimaryPart] = nil
			end
		end))
		for i,v in pairs(collectionService:GetTagged(tag)) do
			espadd(v.PrimaryPart, icon)
		end
	end

	KitESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "KitESP", 
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.equippedKit ~= ""
					if KitESP.Enabled then
						if tostring(store.queueType) == "training_room" or store.equippedKit == "metal_detector" then
							addKit("hidden-metal", "iron")
						elseif tostring(store.queueType) == "training_room" or store.equippedKit == "beekeeper" then
							addKit("bee", "bee")
						elseif tostring(store.queueType) == "training_room" or store.equippedKit == "bigman" then
							addKit("treeOrb", "natures_essence_1")
						end
					end
				end)
			else
				espfold:ClearAllChildren()
				table.clear(espobjs)
			end
		end
	})
end)

run(function()
	local function floorNameTagPosition(pos)
		return Vector2.new(math.floor(pos.X), math.floor(pos.Y))
	end

	local function removeTags(str)
        str = str:gsub("<br%s*/>", "\n")
        return (str:gsub("<[^<>]->", ""))
    end

	local NameTagsFolder = Instance.new("Folder")
	NameTagsFolder.Name = "NameTagsFolder"
	NameTagsFolder.Parent = GuiLibrary.MainGui
	local nametagsfolderdrawing = {}
	local NameTagsColor = {Value = 0.44}
	local NameTagsDisplayName = {Enabled = false}
	local NameTagsHealth = {Enabled = false}
	local NameTagsDistance = {Enabled = false}
	local NameTagsBackground = {Enabled = true}
	local NameTagsScale = {Value = 10}
	local NameTagsFont = {Value = "SourceSans"}
	local NameTagsTeammates = {Enabled = true}
	local NameTagsShowInventory = {Enabled = false}
	local NameTagsRangeLimit = {Value = 0}
	local fontitems = {"SourceSans"}
	local nametagstrs = {}
	local nametagsizes = {}
	local kititems = {
		jade = "jade_hammer",
		archer = "tactical_crossbow",
		angel = "",
		cowgirl = "lasso",
		dasher = "wood_dao",
		axolotl = "axolotl",
		yeti = "snowball",
		smoke = "smoke_block",
		trapper = "snap_trap",
		pyro = "flamethrower",
		davey = "cannon",
		regent = "void_axe",
		baker = "apple",
		builder = "builder_hammer",
		farmer_cletus = "carrot_seeds",
		melody = "guitar",
		barbarian = "rageblade",
		gingerbread_man = "gumdrop_bounce_pad",
		spirit_catcher = "spirit",
		fisherman = "fishing_rod",
		oil_man = "oil_consumable",
		santa = "tnt",
		miner = "miner_pickaxe",
		sheep_herder = "crook",
		beast = "speed_potion",
		metal_detector = "metal_detector",
		cyber = "drone",
		vesta = "damage_banner",
		lumen = "light_sword",
		ember = "infernal_saber",
		queen_bee = "bee"
	}

	local nametagfuncs1 = {
		Normal = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = Instance.new("TextLabel")
			thing.BackgroundColor3 = Color3.new()
			thing.BorderSizePixel = 0
			thing.Visible = false
			thing.RichText = true
			thing.AnchorPoint = Vector2.new(0.5, 1)
			thing.Name = plr.Player.Name
			thing.Font = Enum.Font[NameTagsFont.Value]
			thing.TextSize = 14 * (NameTagsScale.Value / 10)
			thing.BackgroundTransparency = NameTagsBackground.Enabled and 0.5 or 1
			nametagstrs[plr.Player] = whitelist:tag(plr.Player, true)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(plr.Humanoid.Health).."</font>"
			end
			if NameTagsDistance.Enabled then
				nametagstrs[plr.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[plr.Player]
			end
			local nametagSize = textService:GetTextSize(removeTags(nametagstrs[plr.Player]), thing.TextSize, thing.Font, Vector2.new(100000, 100000))
			thing.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
			thing.Text = nametagstrs[plr.Player]
			thing.TextColor3 = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			thing.Parent = NameTagsFolder
			local hand = Instance.new("ImageLabel")
			hand.Size = UDim2.new(0, 30, 0, 30)
			hand.Name = "Hand"
			hand.BackgroundTransparency = 1
			hand.Position = UDim2.new(0, -30, 0, -30)
			hand.Image = ""
			hand.Parent = thing
			local helmet = hand:Clone()
			helmet.Name = "Helmet"
			helmet.Position = UDim2.new(0, 5, 0, -30)
			helmet.Parent = thing
			local chest = hand:Clone()
			chest.Name = "Chestplate"
			chest.Position = UDim2.new(0, 35, 0, -30)
			chest.Parent = thing
			local boots = hand:Clone()
			boots.Name = "Boots"
			boots.Position = UDim2.new(0, 65, 0, -30)
			boots.Parent = thing
			local kit = hand:Clone()
			kit.Name = "Kit"
			task.spawn(function()
				repeat task.wait() until plr.Player:GetAttribute("PlayingAsKit") ~= ""
				if kit then
					kit.Image = kititems[plr.Player:GetAttribute("PlayingAsKit")] and bedwars.getIcon({itemType = kititems[plr.Player:GetAttribute("PlayingAsKit")]}, NameTagsShowInventory.Enabled) or ""
				end
			end)
			kit.Position = UDim2.new(0, -30, 0, -65)
			kit.Parent = thing
			nametagsfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end,
		Drawing = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {Main = {}, entity = plr}
			thing.Main.Text = Drawing.new("Text")
			thing.Main.Text.Size = 17 * (NameTagsScale.Value / 10)
			thing.Main.Text.Font = (math.clamp((table.find(fontitems, NameTagsFont.Value) or 1) - 1, 0, 3))
			thing.Main.Text.ZIndex = 2
			thing.Main.BG = Drawing.new("Square")
			thing.Main.BG.Filled = true
			thing.Main.BG.Transparency = 0.5
			thing.Main.BG.Visible = NameTagsBackground.Enabled
			thing.Main.BG.Color = Color3.new()
			thing.Main.BG.ZIndex = 1
			nametagstrs[plr.Player] = whitelist:tag(plr.Player, true)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' '..math.round(plr.Humanoid.Health)
			end
			if NameTagsDistance.Enabled then
				nametagstrs[plr.Player] = '[%s] '..nametagstrs[plr.Player]
			end
			thing.Main.Text.Text = nametagstrs[plr.Player]
			thing.Main.BG.Size = Vector2.new(thing.Main.Text.TextBounds.X + 4, thing.Main.Text.TextBounds.Y)
			thing.Main.Text.Color = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			nametagsfolderdrawing[plr.Player] = thing
		end
	}

	local nametagfuncs2 = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then
				v.Main:Destroy()
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then
				for i2,v2 in pairs(v.Main) do
					pcall(function() v2.Visible = false v2:Remove() end)
				end
			end
		end
	}

	local nametagupdatefuncs = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then
				nametagstrs[ent.Player] = whitelist:tag(ent.Player, true)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					local color = Color3.fromHSV(math.clamp(ent.Humanoid.Health / ent.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(ent.Humanoid.Health).."</font>"
				end
				if NameTagsDistance.Enabled then
					nametagstrs[ent.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[ent.Player]
				end
				if NameTagsShowInventory.Enabled then
					local inventory = store.inventories[ent.Player] or {armor = {}}
					if inventory.hand then
						v.Main.Hand.Image = bedwars.getIcon(inventory.hand, NameTagsShowInventory.Enabled)
						if v.Main.Hand.Image:find("rbxasset://") then
							v.Main.Hand.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Hand.Image = ""
					end
					if inventory.armor[4] then
						v.Main.Helmet.Image = bedwars.getIcon(inventory.armor[4], NameTagsShowInventory.Enabled)
						if v.Main.Helmet.Image:find("rbxasset://") then
							v.Main.Helmet.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Helmet.Image = ""
					end
					if inventory.armor[5] then
						v.Main.Chestplate.Image = bedwars.getIcon(inventory.armor[5], NameTagsShowInventory.Enabled)
						if v.Main.Chestplate.Image:find("rbxasset://") then
							v.Main.Chestplate.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Chestplate.Image = ""
					end
					if inventory.armor[6] then
						v.Main.Boots.Image = bedwars.getIcon(inventory.armor[6], NameTagsShowInventory.Enabled)
						if v.Main.Boots.Image:find("rbxasset://") then
							v.Main.Boots.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Boots.Image = ""
					end
				end
				local nametagSize = textService:GetTextSize(removeTags(nametagstrs[ent.Player]), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
				v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
				v.Main.Text = nametagstrs[ent.Player]
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then
				nametagstrs[ent.Player] = whitelist:tag(ent.Player, true)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' '..math.round(ent.Humanoid.Health)
				end
				if NameTagsDistance.Enabled then
					nametagstrs[ent.Player] = '[%s] '..nametagstrs[ent.Player]
					v.Main.Text.Text = entityLibrary.isAlive and string.format(nametagstrs[ent.Player], math.floor((entityLibrary.character.HumanoidRootPart.Position - ent.RootPart.Position).Magnitude)) or nametagstrs[ent.Player]
				else
					v.Main.Text.Text = nametagstrs[ent.Player]
				end
				v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
				v.Main.Text.Color = getPlayerColor(ent.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			end
		end
	}

	local nametagcolorfuncs = {
		Normal = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in pairs(nametagsfolderdrawing) do
				v.Main.TextColor3 = getPlayerColor(v.entity.Player) or color
			end
		end,
		Drawing = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in pairs(nametagsfolderdrawing) do
				v.Main.Text.Color = getPlayerColor(v.entity.Player) or color
			end
		end
	}

	local nametagloop = {
		Normal = function()
			for i,v in pairs(nametagsfolderdrawing) do
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then
					v.Main.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then
					v.Main.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
					local stringsize = tostring(mag):len()
					if nametagsizes[v.entity.Player] ~= stringsize then
						local nametagSize = textService:GetTextSize(removeTags(string.format(nametagstrs[v.entity.Player], mag)), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
						v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
					v.Main.Text = string.format(nametagstrs[v.entity.Player], mag)
				end
				v.Main.Position = UDim2.new(0, headPos.X, 0, headPos.Y)
				v.Main.Visible = true
			end
		end,
		Drawing = function()
			for i,v in pairs(nametagsfolderdrawing) do
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
					local stringsize = tostring(mag):len()
					v.Main.Text.Text = string.format(nametagstrs[v.entity.Player], mag)
					if nametagsizes[v.entity.Player] ~= stringsize then
						v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
				end
				v.Main.BG.Position = Vector2.new(headPos.X - (v.Main.BG.Size.X / 2), (headPos.Y + v.Main.BG.Size.Y))
				v.Main.Text.Position = v.Main.BG.Position + Vector2.new(2, 0)
				v.Main.Text.Visible = true
				v.Main.BG.Visible = NameTagsBackground.Enabled
			end
		end
	}

	local methodused

	local NameTags = {Enabled = false}
	NameTags = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "NameTags",
		Function = function(callback)
			if callback then
				methodused = NameTagsDrawing.Enabled and "Drawing" or "Normal"
				if nametagfuncs2[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityRemovedEvent:Connect(nametagfuncs2[methodused]))
				end
				if nametagfuncs1[methodused] then
					local addfunc = nametagfuncs1[methodused]
					for i,v in pairs(entityLibrary.entityList) do
						if nametagsfolderdrawing[v.Player] then nametagfuncs2[methodused](v.Player) end
						addfunc(v)
					end
					table.insert(NameTags.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
						if nametagsfolderdrawing[ent.Player] then nametagfuncs2[methodused](ent.Player) end
						addfunc(ent)
					end))
				end
				if nametagupdatefuncs[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityUpdatedEvent:Connect(nametagupdatefuncs[methodused]))
					for i,v in pairs(entityLibrary.entityList) do
						nametagupdatefuncs[methodused](v)
					end
				end
				if nametagcolorfuncs[methodused] then
					table.insert(NameTags.Connections, GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendColorRefresh.Event:Connect(function()
						nametagcolorfuncs[methodused](NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
					end))
				end
				if nametagloop[methodused] then
					RunLoops:BindToRenderStep("NameTags", nametagloop[methodused])
				end
			else
				RunLoops:UnbindFromRenderStep("NameTags")
				if nametagfuncs2[methodused] then
					for i,v in pairs(nametagsfolderdrawing) do
						nametagfuncs2[methodused](i)
					end
				end
			end
		end,
		HoverText = "Renders nametags on entities through walls."
	})
	for i,v in pairs(Enum.Font:GetEnumItems()) do
		if v.Name ~= "SourceSans" then
			table.insert(fontitems, v.Name)
		end
	end
	NameTagsFont = NameTags.CreateDropdown({
		Name = "Font",
		List = fontitems,
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
	NameTagsColor = NameTags.CreateColorSlider({
		Name = "Player Color",
		Function = function(hue, sat, val)
			if NameTags.Enabled and nametagcolorfuncs[methodused] then
				nametagcolorfuncs[methodused](hue, sat, val)
			end
		end
	})
	NameTagsScale = NameTags.CreateSlider({
		Name = "Scale",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = 10,
		Min = 1,
		Max = 50
	})
	NameTagsRangeLimit = NameTags.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 0,
		Max = 1000,
		Default = 0
	})
	NameTagsBackground = NameTags.CreateToggle({
		Name = "Background",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDisplayName = NameTags.CreateToggle({
		Name = "Use Display Name",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsHealth = NameTags.CreateToggle({
		Name = "Health",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsDistance = NameTags.CreateToggle({
		Name = "Distance",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsShowInventory = NameTags.CreateToggle({
		Name = "Equipment",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsTeammates = NameTags.CreateToggle({
		Name = "Teammates",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDrawing = NameTags.CreateToggle({
		Name = "Drawing",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
end)

run(function()
	local nobobdepth = {Value = 8}
	local nobobhorizontal = {Value = 8}
	local nobobvertical = {Value = -2}
	local rotationx = {Value = 0}
	local rotationy = {Value = 0}
	local rotationz = {Value = 0}
	local oldc1
	local oldfunc
	local nobob = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "NoBob",
		Function = function(callback)
			local viewmodel = gameCamera:FindFirstChild("Viewmodel")
			if viewmodel then
				if callback then
					oldfunc = bedwars.ViewmodelController.playAnimation
					bedwars.ViewmodelController.playAnimation = function(self, animid, details)
						if animid == bedwars.AnimationType.FP_WALK then
							return
						end
						return oldfunc(self, animid, details)
					end
					bedwars.ViewmodelController:setHeldItem(lplr.Character and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value and lplr.Character.HandInvItem.Value:Clone())
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(nobobdepth.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (nobobhorizontal.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (nobobvertical.Value / 10))
					oldc1 = viewmodel.RightHand.RightWrist.C1
					viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
				else
					bedwars.ViewmodelController.playAnimation = oldfunc
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", 0)
					viewmodel.RightHand.RightWrist.C1 = oldc1
				end
			end
		end,
		HoverText = "Removes the ugly bobbing when you move and makes sword farther"
	})
	nobobdepth = nobob.CreateSlider({
		Name = "Depth",
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(val / 10))
			end
		end
	})
	nobobhorizontal = nobob.CreateSlider({
		Name = "Horizontal",
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (val / 10))
			end
		end
	})
	nobobvertical= nobob.CreateSlider({
		Name = "Vertical",
		Min = 0,
		Max = 24,
		Default = -2,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (val / 10))
			end
		end
	})
	rotationx = nobob.CreateSlider({
		Name = "RotX",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationy = nobob.CreateSlider({
		Name = "RotY",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationz = nobob.CreateSlider({
		Name = "RotZ",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
end)

run(function()
	local SongBeats = {Enabled = false}
	local SongBeatsList = {ObjectList = {}}
	local SongBeatsIntensity = {Value = 5}
	local SongTween
	local SongAudio

	local function PlaySong(arg)
		local args = arg:split(":")
		local song = isfile(args[1]) and getcustomasset(args[1]) or tonumber(args[1]) and "rbxassetid://"..args[1]
		if not song then
			warningNotification("SongBeats", "missing music file "..args[1], 5)
			SongBeats.ToggleButton(false)
			return
		end
		local bpm = 1 / (args[2] / 60)
		SongAudio = Instance.new("Sound")
		SongAudio.SoundId = song
		SongAudio.Parent = workspace
		SongAudio:Play()
		repeat
			repeat task.wait() until SongAudio.IsLoaded or (not SongBeats.Enabled)
			if (not SongBeats.Enabled) then break end
			local newfov = math.min(bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1), 120)
			gameCamera.FieldOfView = newfov - SongBeatsIntensity.Value
			if SongTween then SongTween:Cancel() end
			SongTween = game:GetService("TweenService"):Create(gameCamera, TweenInfo.new(0.2), {FieldOfView = newfov})
			SongTween:Play()
			task.wait(bpm)
		until (not SongBeats.Enabled) or SongAudio.IsPaused
	end

	SongBeats = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "SongBeats",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if #SongBeatsList.ObjectList <= 0 then
						warningNotification("SongBeats", "no songs", 5)
						SongBeats.ToggleButton(false)
						return
					end
					local lastChosen
					repeat
						local newSong
						repeat newSong = SongBeatsList.ObjectList[Random.new():NextInteger(1, #SongBeatsList.ObjectList)] task.wait() until newSong ~= lastChosen or #SongBeatsList.ObjectList <= 1
						lastChosen = newSong
						PlaySong(newSong)
						if not SongBeats.Enabled then break end
						task.wait(2)
					until (not SongBeats.Enabled)
				end)
			else
				if SongAudio then SongAudio:Destroy() end
				if SongTween then SongTween:Cancel() end
				gameCamera.FieldOfView = bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1)
			end
		end
	})
	SongBeatsList = SongBeats.CreateTextList({
		Name = "SongList",
		TempText = "songpath:bpm"
	})
	SongBeatsIntensity = SongBeats.CreateSlider({
		Name = "Intensity",
		Function = function() end,
		Min = 1,
		Max = 10,
		Default = 5
	})
end)

run(function()
	local performed = false
	GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "UICleanup",
		Function = function(callback)
			if callback and not performed then
				performed = true
				task.spawn(function()
					local hotbar = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui["hotbar-app"]).HotbarApp
					local hotbaropeninv = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui["hotbar-open-inventory"]).HotbarOpenInventory
					local topbarbutton = require(replicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).TopBarButton
					local gametheme = require(replicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.shared.ui["game-theme"]).GameTheme
					bedwars.AppController:closeApp("TopBarApp")
					local oldrender = topbarbutton.render
					topbarbutton.render = function(self)
						local res = oldrender(self)
						if not self.props.Text then
							return bedwars.Roact.createElement("TextButton", {Visible = false}, {})
						end
						return res
					end
					hotbaropeninv.render = function(self)
						return bedwars.Roact.createElement("TextButton", {Visible = false}, {})
					end
					--[[debug.setconstant(hotbar.render, 52, 0.9975)
					debug.setconstant(hotbar.render, 73, 100)
					debug.setconstant(hotbar.render, 89, 1)
					debug.setconstant(hotbar.render, 90, 0.04)
					debug.setconstant(hotbar.render, 91, -0.03)
					debug.setconstant(hotbar.render, 109, 1.35)
					debug.setconstant(hotbar.render, 110, 0)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 30, 1)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 31, 0.175)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 33, -0.101)
					debug.setconstant(debug.getupvalue(hotbar.render, 18).render, 71, 0)
					debug.setconstant(debug.getupvalue(hotbar.render, 18).tweenPosition, 16, 0)]]
					gametheme.topBarBGTransparency = 0.5
					bedwars.TopBarController:mountHud()
					game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
					bedwars.AbilityUIController.abilityButtonsScreenGui.Visible = false
					bedwars.MatchEndScreenController.waitUntilDisplay = function() return false end
					task.spawn(function()
						repeat
							task.wait()
							local gui = lplr.PlayerGui:FindFirstChild("StatusEffectHudScreen")
							if gui then gui.Enabled = false break end
						until false
					end)
					task.spawn(function()
						repeat task.wait() until store.matchState ~= 0
						if bedwars.ClientStoreHandler:getState().Game.customMatch == nil then
							debug.setconstant(bedwars.QueueCard.render, 15, 0.1)
						end
					end)
					local slot = bedwars.ClientStoreHandler:getState().Inventory.observedInventory.hotbarSlot
					bedwars.ClientStoreHandler:dispatch({
						type = "InventorySelectHotbarSlot",
						slot = slot + 1 % 8
					})
					bedwars.ClientStoreHandler:dispatch({
						type = "InventorySelectHotbarSlot",
						slot = slot
					})
				end)
			end
		end
	})
end)

run(function()
	local AntiAFK = {Enabled = false}
	AntiAFK = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AntiAFK",
		Function = function(callback)
			if callback then
				bedwars.Client:Get("AfkInfo"):SendToServer({
					afk = false
				})
			end
		end
	})
end)

run(function()
	local AutoBalloonPart
	local AutoBalloonConnection
	local AutoBalloonDelay = {Value = 10}
	local AutoBalloonLegit = {Enabled = false}
	local AutoBalloonypos = 0
	local balloondebounce = false
	local AutoBalloon = {Enabled = false}
	AutoBalloon = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoBalloon",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0 or  not vapeInjected
					if vapeInjected and AutoBalloonypos == 0 and AutoBalloon.Enabled then
						local lowestypos = 99999
						for i,v in pairs(store.blocks) do
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), store.blockRaycast)
							if i % 200 == 0 then
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						AutoBalloonypos = lowestypos - 8
					end
				end)
				task.spawn(function()
					repeat task.wait() until AutoBalloonypos ~= 0
					if AutoBalloon.Enabled then
						AutoBalloonPart = Instance.new("Part")
						AutoBalloonPart.CanCollide = false
						AutoBalloonPart.Size = Vector3.new(10000, 1, 10000)
						AutoBalloonPart.Anchored = true
						AutoBalloonPart.Transparency = 1
						AutoBalloonPart.Material = Enum.Material.Neon
						AutoBalloonPart.Color = Color3.fromRGB(135, 29, 139)
						AutoBalloonPart.Position = Vector3.new(0, AutoBalloonypos - 50, 0)
						AutoBalloonConnection = AutoBalloonPart.Touched:Connect(function(touchedpart)
							if entityLibrary.isAlive and touchedpart:IsDescendantOf(lplr.Character) and balloondebounce == false then
								autobankballoon = true
								balloondebounce = true
								local oldtool = store.localHand.tool
								for i = 1, 3 do
									if getItem("balloon") and (AutoBalloonLegit.Enabled and getHotbarSlot("balloon") or AutoBalloonLegit.Enabled == false) and (lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") < 3 or lplr.Character:GetAttribute("InflatedBalloons") == nil) then
										if AutoBalloonLegit.Enabled then
											if getHotbarSlot("balloon") then
												bedwars.ClientStoreHandler:dispatch({
													type = "InventorySelectHotbarSlot",
													slot = getHotbarSlot("balloon")
												})
												task.wait(AutoBalloonDelay.Value / 100)
												bedwars.BalloonController:inflateBalloon()
											end
										else
											task.wait(AutoBalloonDelay.Value / 100)
											bedwars.BalloonController:inflateBalloon()
										end
									end
								end
								if AutoBalloonLegit.Enabled and oldtool and getHotbarSlot(oldtool.Name) then
									task.wait(0.2)
									bedwars.ClientStoreHandler:dispatch({
										type = "InventorySelectHotbarSlot",
										slot = (getHotbarSlot(oldtool.Name) or 0)
									})
								end
								balloondebounce = false
								autobankballoon = false
							end
						end)
						AutoBalloonPart.Parent = workspace
					end
				end)
			else
				if AutoBalloonConnection then AutoBalloonConnection:Disconnect() end
				if AutoBalloonPart then
					AutoBalloonPart:Remove()
				end
			end
		end,
		HoverText = "Automatically Inflates Balloons"
	})
	AutoBalloonDelay = AutoBalloon.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Default = 20,
		Function = function() end,
		HoverText = "Delay to inflate balloons."
	})
	AutoBalloonLegit = AutoBalloon.CreateToggle({
		Name = "Legit Mode",
		Function = function() end,
		HoverText = "Switches to balloons in hotbar and inflates them."
	})
end)

local autobankapple = false
run(function()
	local AutoBuy = {Enabled = false}
	local AutoBuyArmor = {Enabled = false}
	local AutoBuySword = {Enabled = false}
	local AutoBuyGen = {Enabled = false}
	local AutoBuyProt = {Enabled = false}
	local AutoBuySharp = {Enabled = false}
	local AutoBuyDestruction = {Enabled = false}
	local AutoBuyDiamond = {Enabled = false}
	local AutoBuyAlarm = {Enabled = false}
	local AutoBuyGui = {Enabled = false}
	local AutoBuyTierSkip = {Enabled = true}
	local AutoBuyRange = {Value = 20}
	local AutoBuyCustom = {ObjectList = {}, RefreshList = function() end}
	local AutoBankUIToggle = {Enabled = false}
	local AutoBankDeath = {Enabled = false}
	local AutoBankStay = {Enabled = false}
	local buyingthing = false
	local shoothook
	local bedwarsshopnpcs = {}
	local id
	local armors = {
		[1] = "leather_chestplate",
		[2] = "iron_chestplate",
		[3] = "diamond_chestplate",
		[4] = "emerald_chestplate"
	}

	local swords = {
		[1] = "wood_sword",
		[2] = "stone_sword",
		[3] = "iron_sword",
		[4] = "diamond_sword",
		[5] = "emerald_sword"
	}

	local axes = {
		[1] = "wood_axe",
		[2] = "stone_axe",
		[3] = "iron_axe",
		[4] = "diamond_axe"
	}

	local pickaxes = {
		[1] = "wood_pickaxe",
		[2] = "stone_pickaxe",
		[3] = "iron_pickaxe",
		[4] = "diamond_pickaxe"
	}

	task.spawn(function()
		repeat task.wait() until store.matchState ~= 0 or not vapeInjected
		for i,v in pairs(collectionService:GetTagged("BedwarsItemShop")) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = true, Id = v.Name})
		end
		for i,v in pairs(collectionService:GetTagged("TeamUpgradeShopkeeper")) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = false, Id = v.Name})
		end
	end)

	local function nearNPC(range)
		local npc, npccheck, enchant, newid = nil, false, false, nil
		if entityLibrary.isAlive then
			local enchanttab = {}
			for i,v in pairs(collectionService:GetTagged("broken-enchant-table")) do
				table.insert(enchanttab, v)
			end
			for i,v in pairs(collectionService:GetTagged("enchant-table")) do
				table.insert(enchanttab, v)
			end
			for i,v in pairs(enchanttab) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= 6 then
					if ((not v:GetAttribute("Team")) or v:GetAttribute("Team") == lplr:GetAttribute("Team")) then
						npc, npccheck, enchant = true, true, true
					end
				end
			end
			for i, v in pairs(bedwarsshopnpcs) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= (range or 20) then
					npc, npccheck, enchant = true, (v.TeamUpgradeNPC or npccheck), false
					newid = v.TeamUpgradeNPC and v.Id or newid
				end
			end
			local suc, res = pcall(function() return lplr.leaderstats.Bed.Value == "✅"  end)
			if AutoBankDeath.Enabled and (workspace:GetServerTimeNow() - lplr.Character:GetAttribute("LastDamageTakenTime")) < 2 and suc and res then
				return nil, false, false
			end
			if AutoBankStay.Enabled then
				return nil, false, false
			end
		end
		return npc, not npccheck, enchant, newid
	end

	local function buyItem(itemtab, waitdelay)
		if not id then return end
		local res
		bedwars.Client:Get("BedwarsPurchaseItem"):CallServerAsync({
			shopItem = itemtab,
			shopId = id
		}):andThen(function(p11)
			if p11 then
				bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
				bedwars.ClientStoreHandler:dispatch({
					type = "BedwarsAddItemPurchased",
					itemType = itemtab.itemType
				})
			end
			res = p11
		end)
		if waitdelay then
			repeat task.wait() until res ~= nil
		end
	end

	local function getAxeNear(inv)
		for i5, v5 in pairs(inv or store.localInventory.inventory.items) do
			if v5.itemType:find("axe") and v5.itemType:find("pickaxe") == nil then
				return v5.itemType
			end
		end
		return nil
	end

	local function getPickaxeNear(inv)
		for i5, v5 in pairs(inv or store.localInventory.inventory.items) do
			if v5.itemType:find("pickaxe") then
				return v5.itemType
			end
		end
		return nil
	end

	local function getShopItem(itemType)
		if itemType == "axe" then
			itemType = getAxeNear() or "wood_axe"
			itemType = axes[table.find(axes, itemType) + 1] or itemType
		end
		if itemType == "pickaxe" then
			itemType = getPickaxeNear() or "wood_pickaxe"
			itemType = pickaxes[table.find(pickaxes, itemType) + 1] or itemType
		end
		for i,v in pairs(bedwars.ShopItems) do
			if v.itemType == itemType then return v end
		end
		return nil
	end

	local buyfunctions = {
		Armor = function(inv, upgrades, shoptype)
			if AutoBuyArmor.Enabled == false or shoptype ~= "item" then return end
			local currentarmor = (inv.armor[2] ~= "empty" and inv.armor[2].itemType:find("chestplate") ~= nil) and inv.armor[2] or nil
			local armorindex = (currentarmor and table.find(armors, currentarmor.itemType) or 0) + 1
			if armors[armorindex] == nil then return end
			local highestbuyable = nil
			for i = armorindex, #armors, 1 do
				local shopitem = getShopItem(armors[i])
				if shopitem and i == armorindex then
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price then
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = "BedwarsAddItemPurchased",
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, store.equippedKit) == nil) then
				buyItem(highestbuyable)
			end
		end,
		Sword = function(inv, upgrades, shoptype)
			if AutoBuySword.Enabled == false or shoptype ~= "item" then return end
			local currentsword = getItemNear("sword", inv.items)
			local swordindex = (currentsword and table.find(swords, currentsword.itemType) or 0) + 1
			if currentsword ~= nil and table.find(swords, currentsword.itemType) == nil then return end
			local highestbuyable = nil
			for i = swordindex, #swords, 1 do
				local shopitem = getShopItem(swords[i])
				if shopitem and i == swordindex then
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price and (shopitem.category ~= "Armory" or upgrades.armory) then
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = "BedwarsAddItemPurchased",
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, store.equippedKit) == nil) then
				buyItem(highestbuyable)
			end
		end
	}

	AutoBuy = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoBuy",
		Function = function(callback)
			if callback then
				buyingthing = false
				task.spawn(function()
					repeat
						task.wait()
						local found, npctype, enchant, newid = nearNPC(AutoBuyRange.Value)
						id = newid
						if found then
							local inv = store.localInventory.inventory
							local currentupgrades = bedwars.ClientStoreHandler:getState().Bedwars.teamUpgrades
							if tostring(store.queueType) == "training_room" or store.equippedKit == "dasher" then
								swords = {
									[1] = "wood_dao",
									[2] = "stone_dao",
									[3] = "iron_dao",
									[4] = "diamond_dao",
									[5] = "emerald_dao"
								}
							elseif tostring(store.queueType) == "training_room" or store.equippedKit == "ice_queen" then
								swords[5] = "ice_sword"
							elseif tostring(store.queueType) == "training_room" or store.equippedKit == "ember" then
								swords[5] = "infernal_saber"
							elseif tostring(store.queueType) == "training_room" or store.equippedKit == "lumen" then
								swords[5] = "light_sword"
							end
							if (AutoBuyGui.Enabled == false or (bedwars.AppController:isAppOpen("BedwarsItemShopApp") or bedwars.AppController:isAppOpen("BedwarsTeamUpgradeApp"))) and (not enchant) then
								for i,v in pairs(AutoBuyCustom.ObjectList) do
									local autobuyitem = v:split("/")
									if #autobuyitem >= 3 and autobuyitem[4] ~= "true" then
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == "wool_white" and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
								for i,v in pairs(buyfunctions) do v(inv, currentupgrades, npctype and "upgrade" or "item") end
								for i,v in pairs(AutoBuyCustom.ObjectList) do
									local autobuyitem = v:split("/")
									if #autobuyitem >= 3 and autobuyitem[4] == "true" then
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == "wool_white" and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
							end
						end
					until (not AutoBuy.Enabled)
				end)
			end
		end,
		HoverText = "Automatically Buys Swords, Armor, and Team Upgrades\nwhen you walk near the NPC"
	})
	AutoBuyRange = AutoBuy.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 1,
		Max = 20,
		Default = 20
	})
	AutoBuyArmor = AutoBuy.CreateToggle({
		Name = "Buy Armor",
		Function = function() end,
		Default = true
	})
	AutoBuySword = AutoBuy.CreateToggle({
		Name = "Buy Sword",
		Function = function() end,
		Default = true
	})
	AutoBuyGui = AutoBuy.CreateToggle({
		Name = "Shop GUI Check",
		Function = function() end,
	})
	AutoBuyTierSkip = AutoBuy.CreateToggle({
		Name = "Tier Skip",
		Function = function() end,
		Default = true
	})
	AutoBuyCustom = AutoBuy.CreateTextList({
		Name = "BuyList",
		TempText = "item/amount/priority/after",
		SortFunction = function(a, b)
			local amount1 = a:split("/")
			local amount2 = b:split("/")
			amount1 = #amount1 and tonumber(amount1[3]) or 1
			amount2 = #amount2 and tonumber(amount2[3]) or 1
			return amount1 < amount2
		end
	})
	AutoBuyCustom.Object.AddBoxBKG.AddBox.TextSize = 14
end)

run(function()
	local AutoConsume = {Enabled = false}
	local AutoConsumeHealth = {Value = 100}
	local AutoConsumeSpeed = {Enabled = true}
	local AutoConsumeDelay = tick()

	local function AutoConsumeFunc()
		if entityLibrary.isAlive then
			local speedpotion = getItem("speed_potion")
            local treasure_chest = getItem("treasure_chest")
			if lplr.Character:GetAttribute("Health") <= (lplr.Character:GetAttribute("MaxHealth") - (100 - AutoConsumeHealth.Value)) then
				autobankapple = true
				local item = getItem("apple")
				local pot = getItem("heal_splash_potion")
				if (item or pot) and AutoConsumeDelay <= tick() then
					if item then
						bedwars.Client:Get(bedwars.EatRemote):CallServerAsync({
							item = item.tool
						})
						AutoConsumeDelay = tick() + 0.6
					else
						local newray = workspace:Raycast((oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -76, 0), store.blockRaycast)
						if newray ~= nil then
							bedwars.Client:Get(bedwars.ProjectileRemote):CallServerAsync(pot.tool, "heal_splash_potion", "heal_splash_potion", (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -70, 0), game:GetService("HttpService"):GenerateGUID(), {drawDurationSeconds = 1})
						end
					end
				end
			else
				autobankapple = false
			end
			if speedpotion and (not lplr.Character:GetAttribute("StatusEffect_speed")) and AutoConsumeSpeed.Enabled then
				bedwars.Client:Get(bedwars.EatRemote):CallServerAsync({
					item = speedpotion.tool
				})
			end
			if lplr.Character:GetAttribute("Shield_POTION") and ((not lplr.Character:GetAttribute("Shield_POTION")) or lplr.Character:GetAttribute("Shield_POTION") == 0) then
				local shield = getItem("big_shield") or getItem("mini_shield")
				if shield then
					bedwars.Client:Get(bedwars.EatRemote):CallServerAsync({
						item = shield.tool
					})
				end
			end
            if treasure_chest then
				local secret = pcall(function() workspace:FindFirstChild("PirateTreasure"):GetAttribute("Secret") end)
				if secret then
                	local args = {[1] = {["secret"] = secret}}
                	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("OpenTreasureChest"):InvokeServer(unpack(args))
				end
            end
		end
	end

	AutoConsume = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoConsume",
		Function = function(callback)
			if callback then
				table.insert(AutoConsume.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(AutoConsumeFunc))
				table.insert(AutoConsume.Connections, vapeEvents.AttributeChanged.Event:Connect(function(changed)
					if changed:find("Shield") or changed:find("Health") or changed:find("speed") then
						AutoConsumeFunc()
					end
				end))
				table.insert(AutoConsume.Connections, workspace.ChildAdded:Connect(function(child)
					if child.Name == "PirateTreasure" then
						local args = {[1] = {["secret"] = child:GetAttribute("Secret")}}
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("OpenTreasureChest"):InvokeServer(unpack(args))
					end
				end))
				table.insert(AutoConsume.Connections, game:GetService("ReplicatedStorage"):WaitForChild("Inventories"):WaitForChild(lplr.Name).ChildAdded:Connect(function(child)
					if child.Name == "treasure_chest" then
						local args = {
							[1] = {
								["item"] = game:GetService("ReplicatedStorage"):WaitForChild("Inventories"):WaitForChild(lplr.Name):WaitForChild("treasure_chest")
							}
						}
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("ConsumeItem"):InvokeServer(unpack(args))
						
					end
				end))
				AutoConsumeFunc()
			end
		end,
		HoverText = "Automatically heals for you when health or shield is under threshold."
	})
	AutoConsumeHealth = AutoConsume.CreateSlider({
		Name = "Health",
		Min = 1,
		Max = 99,
		Default = 70,
		Function = function() end
	})
	AutoConsumeSpeed = AutoConsume.CreateToggle({
		Name = "Speed Potions",
		Function = function() end,
		Default = true
	})
end)
run(function()
	local AutoHotbarList = {Hotbars = {}, CurrentlySelected = 1}
	local AutoHotbarMode = {Value = "Toggle"}
	local AutoHotbarClear = {Enabled = false}
	local AutoHotbar = {Enabled = false}
	local AutoHotbarActive = false

	local function getCustomItem(v2)
		local realitem = v2.itemType
		if realitem == "swords" then
			local sword = getSword()
			realitem = sword and sword.itemType or "wood_sword"
		elseif realitem == "pickaxes" then
			local pickaxe = getPickaxe()
			realitem = pickaxe and pickaxe.itemType or "wood_pickaxe"
		elseif realitem == "axes" then
			local axe = getAxe()
			realitem = axe and axe.itemType or "wood_axe"
		elseif realitem == "bows" then
			local bow = getBow()
			realitem = bow and bow.itemType or "wood_bow"
		elseif realitem == "wool" then
			realitem = getWool() or "wool_white"
		end
		return realitem
	end

	local function findItemInTable(tab, item)
		for i, v in pairs(tab) do
			if v and v.itemType then
				if item.itemType == getCustomItem(v) then
					return i
				end
			end
		end
		return nil
	end

	local function findinhotbar(item)
		for i,v in pairs(store.localInventory.hotbar) do
			if v.item and v.item.itemType == item.itemType then
				return i, v.item
			end
		end
	end

	local function findininventory(item)
		for i,v in pairs(store.localInventory.inventory.items) do
			if v.itemType == item.itemType then
				return v
			end
		end
	end

	local function AutoHotbarSort()
		task.spawn(function()
			if AutoHotbarActive then return end
			AutoHotbarActive = true
			local items = (AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected] and AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected].Items or {})
			for i, v in pairs(store.localInventory.inventory.items) do
				local customItem
				local hotbarslot = findItemInTable(items, v)
				if hotbarslot then
					local oldhotbaritem = store.localInventory.hotbar[tonumber(hotbarslot)]
					if oldhotbaritem.item and oldhotbaritem.item.itemType == v.itemType then continue end
					if oldhotbaritem.item then
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryRemoveFromHotbar",
							slot = tonumber(hotbarslot) - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local newhotbaritemslot, newhotbaritem = findinhotbar(v)
					if newhotbaritemslot then
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryRemoveFromHotbar",
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					if oldhotbaritem.item and newhotbaritemslot then
						local nextitem1, nextitem1num = findininventory(oldhotbaritem.item)
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryAddToHotbar",
							item = nextitem1,
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local nextitem2, nextitem2num = findininventory(v)
					bedwars.ClientStoreHandler:dispatch({
						type = "InventoryAddToHotbar",
						item = nextitem2,
						slot = tonumber(hotbarslot) - 1
					})
					vapeEvents.InventoryChanged.Event:Wait()
				else
					if AutoHotbarClear.Enabled then
						local newhotbaritemslot, newhotbaritem = findinhotbar(v)
						if newhotbaritemslot then
							bedwars.ClientStoreHandler:dispatch({
								type = "InventoryRemoveFromHotbar",
								slot = newhotbaritemslot - 1
							})
							vapeEvents.InventoryChanged.Event:Wait()
						end
					end
				end
			end
			AutoHotbarActive = false
		end)
	end

	AutoHotbar = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoHotbar",
		Function = function(callback)
			if callback then
				AutoHotbarSort()
				if AutoHotbarMode.Value == "On Key" then
					if AutoHotbar.Enabled then
						AutoHotbar.ToggleButton(false)
					end
				else
					table.insert(AutoHotbar.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(function()
						if not AutoHotbar.Enabled then return end
						AutoHotbarSort()
					end))
				end
			end
		end,
		HoverText = "Automatically arranges hotbar to your liking."
	})
	AutoHotbarMode = AutoHotbar.CreateDropdown({
		Name = "Activation",
		List = {"On Key", "Toggle"},
		Function = function(val)
			if AutoHotbar.Enabled then
				AutoHotbar.ToggleButton(false)
				AutoHotbar.ToggleButton(false)
			end
		end
	})
	AutoHotbarList = CreateAutoHotbarGUI(AutoHotbar.Children, {
		Name = "lol"
	})
	AutoHotbarClear = AutoHotbar.CreateToggle({
		Name = "Clear Hotbar",
		Function = function() end
	})
end)

run(function()
	local AutoKit = {Enabled = false}
	local AutoKitTrinity = {Value = "Void"}
	local oldfish
	local function GetTeammateThatNeedsMost()
		local plrs = GetAllNearestHumanoidToPosition(true, 30, 1000, true)
		local lowest, lowestplayer = 10000, nil
		for i,v in pairs(plrs) do
			if not v.Targetable then
				if v.Character:GetAttribute("Health") <= lowest and v.Character:GetAttribute("Health") < v.Character:GetAttribute("MaxHealth") then
					lowest = v.Character:GetAttribute("Health")
					lowestplayer = v
				end
			end
		end
		return lowestplayer
	end

	AutoKit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoKit",
		Function = function(callback)
			if callback then
				oldfish = bedwars.FishermanController.startMinigame
				bedwars.FishermanController.startMinigame = function(Self, dropdata, func) func({win = true}) end
				task.spawn(function()
					repeat task.wait() until store.equippedKit ~= ""
					if AutoKit.Enabled then
						if tostring(store.queueType) == "training_room" or store.equippedKit == "melody" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if getItem("guitar") then
										local plr = GetTeammateThatNeedsMost()
										if plr and healtick <= tick() then
											bedwars.Client:Get(bedwars.GuitarHealRemote):SendToServer({
												healTarget = plr.Character
											})
											healtick = tick() + 2
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif tostring(store.queueType) == "training_room" or store.equippedKit == "bigman" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged("treeOrb")
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and v:FindFirstChild("Spirit") and (entityLibrary.character.HumanoidRootPart.Position - v.Spirit.Position).magnitude <= 20 then
											if bedwars.Client:Get(bedwars.TreeRemote):CallServer({
												treeOrbSecret = v:GetAttribute("TreeOrbSecret")
											}) then
												v:Destroy()
												collectionService:RemoveTag(v, "treeOrb")
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif tostring(store.queueType) == "training_room" or store.equippedKit == "metal_detector" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged("hidden-metal")
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 20 then
											bedwars.Client:Get(bedwars.PickupMetalRemote):SendToServer({
												id = v:GetAttribute("Id")
											})
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif tostring(store.queueType) == "training_room" or store.equippedKit == "battery" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = bedwars.BatteryEffectsController.liveBatteries
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.position).magnitude <= 10 then
											bedwars.Client:Get(bedwars.BatteryRemote):SendToServer({
												batteryId = i
											})
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif tostring(store.queueType) == "training_room" or store.equippedKit == "grim_reaper" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = bedwars.GrimReaperController.soulsByPosition
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and lplr.Character:GetAttribute("Health") <= (lplr.Character:GetAttribute("MaxHealth") / 4) and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 120 and (not lplr.Character:GetAttribute("GrimReaperChannel")) then
											bedwars.Client:Get(bedwars.ConsumeSoulRemote):CallServer({
												secret = v:GetAttribute("GrimReaperSoulSecret")
											})
											v:Destroy()
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif tostring(store.queueType) == "training_room" or store.equippedKit == "farmer_cletus" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged("HarvestableCrop")
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.Position).magnitude <= 10 then
											bedwars.Client:Get("CropHarvest"):CallServerAsync({
												position = bedwars.BlockController:getBlockPosition(v.Position)
											}):andThen(function(suc)
												if suc then
													bedwars.GameAnimationUtil.playAnimation(lplr.Character, 1)
													bedwars.SoundManager:playSound(bedwars.SoundList.CROP_HARVEST)
												end
											end)
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif tostring(store.queueType) == "training_room" or store.equippedKit == "pinata" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged(lplr.Name..':pinata')
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and getItem('candy') then
											bedwars.Client:Get(bedwars.PinataRemote):CallServer(v)
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif tostring(store.queueType) == "training_room" or store.equippedKit == "dragon_slayer" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i,v in pairs(bedwars.DragonSlayerController.dragonEmblems) do
											if v.stackCount >= 3 then
												bedwars.DragonSlayerController:deleteEmblem(i)
												local localPos = lplr.Character:GetPrimaryPartCFrame().Position
												local punchCFrame = CFrame.new(localPos, (i:GetPrimaryPartCFrame().Position * Vector3.new(1, 0, 1)) + Vector3.new(0, localPos.Y, 0))
												lplr.Character:SetPrimaryPartCFrame(punchCFrame)
												bedwars.DragonSlayerController:playPunchAnimation(punchCFrame - punchCFrame.Position)
												bedwars.Client:Get(bedwars.DragonRemote):SendToServer({
													target = i
												})
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif tostring(store.queueType) == "training_room" or store.equippedKit == "mage" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i, v in pairs(collectionService:GetTagged("TomeGuidingBeam")) do
											local obj = v.Parent and v.Parent.Parent and v.Parent.Parent.Parent
											if obj and (entityLibrary.character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude < 5 and obj:GetAttribute("TomeSecret") then
												local res = bedwars.Client:Get(bedwars.MageRemote):CallServer({
													secret = obj:GetAttribute("TomeSecret")
												})
												if res.success and res.element then
													bedwars.GameAnimationUtil.playAnimation(lplr, bedwars.AnimationType.PUNCH)
													bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
													bedwars.MageController:destroyTomeGuidingBeam()
													bedwars.MageController:playLearnLightBeamEffect(lplr, obj)
													local sound = bedwars.MageKitUtil.MageElementVisualizations[res.element].learnSound
													if sound and sound ~= "" then
														bedwars.SoundManager:playSound(sound)
													end
													task.delay(bedwars.BalanceFile.LEARN_TOME_DURATION, function()
														bedwars.MageController:fadeOutTome(obj)
														if lplr.Character and res.element then
															bedwars.MageKitUtil.changeMageKitAppearance(lplr, lplr.Character, res.element)
														end
													end)
												end
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif tostring(store.queueType) == "training_room" or store.equippedKit == "angel" then
							table.insert(AutoKit.Connections, vapeEvents.AngelProgress.Event:Connect(function(angelTable)
								task.wait(0.5)
								if not AutoKit.Enabled then return end
								if bedwars.ClientStoreHandler:getState().Kit.angelProgress >= 1 and lplr.Character:GetAttribute("AngelType") == nil then
									bedwars.Client:Get(bedwars.TrinityRemote):SendToServer({
										angel = AutoKitTrinity.Value
									})
								end
							end))
						elseif tostring(store.queueType) == "training_room" or store.equippedKit == "miner" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i,v in pairs(collectionService:GetTagged("petrified-player")) do
											bedwars.Client:Get(bedwars.MinerRemote):SendToServer({
												petrifyId = v:GetAttribute("PetrifyId")
											})
										end
									end
								until (not AutoKit.Enabled)
							end)
						end
					end
				end)
			else
				bedwars.FishermanController.startMinigame = oldfish
				oldfish = nil
			end
		end,
		HoverText = "Automatically uses a kits ability"
	})
	AutoKitTrinity = AutoKit.CreateDropdown({
		Name = "Angel",
		List = {"Void", "Light"},
		Function = function() end
	})
end)

run(function()
	local AutoForge = {Enabled = false}
	local AutoForgeWeapon = {Value = "Sword"}
	local AutoForgeBow = {Enabled = false}
	local AutoForgeArmor = {Enabled = false}
	local AutoForgeSword = {Enabled = false}
	local AutoForgeBuyAfter = {Enabled = false}
	local AutoForgeNotification = {Enabled = true}

	local function buyForge(i)
		if not store.forgeUpgrades[i] or store.forgeUpgrades[i] < 6 then
			local cost = bedwars.ForgeUtil:getUpgradeCost(1, store.forgeUpgrades[i] or 0)
			if store.forgeMasteryPoints >= cost then
				if AutoForgeNotification.Enabled then
					local forgeType = "none"
					for name,v in pairs(bedwars.ForgeConstants) do
						if v == i then forgeType = name:lower() end
					end
					warningNotification("AutoForge", "Purchasing "..forgeType..".", bedwars.ForgeUtil.FORGE_DURATION_SEC)
				end
				bedwars.Client:Get("ForgePurchaseUpgrade"):SendToServer(i)
				task.wait(bedwars.ForgeUtil.FORGE_DURATION_SEC + 0.2)
			end
		end
	end

	AutoForge = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoForge",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if store.matchState == 1 and entityLibrary.isAlive then
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeArmor.Enabled then buyForge(bedwars.ForgeConstants.ARMOR) end
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeBow.Enabled then buyForge(bedwars.ForgeConstants.RANGED) end
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeSword.Enabled then
								if AutoForgeBuyAfter.Enabled then
									if not store.forgeUpgrades[bedwars.ForgeConstants.ARMOR] or store.forgeUpgrades[bedwars.ForgeConstants.ARMOR] < 6 then continue end
								end
								local weapon = bedwars.ForgeConstants[AutoForgeWeapon.Value:upper()]
								if weapon then buyForge(weapon) end
							end
						end
					until (not AutoForge.Enabled)
				end)
			end
		end
	})
	AutoForgeWeapon = AutoForge.CreateDropdown({
		Name = "Weapon",
		Function = function() end,
		List = {"Sword", "Dagger", "Scythe", "Great_Hammer", "Gauntlets"}
	})
	AutoForgeArmor = AutoForge.CreateToggle({
		Name = "Armor",
		Function = function() end,
		Default = true
	})
	AutoForgeSword = AutoForge.CreateToggle({
		Name = "Weapon",
		Function = function() end
	})
	AutoForgeBow = AutoForge.CreateToggle({
		Name = "Bow",
		Function = function() end
	})
	AutoForgeBuyAfter = AutoForge.CreateToggle({
		Name = "Buy After",
		Function = function() end,
		HoverText = "buy a weapon after armor is maxed"
	})
	AutoForgeNotification = AutoForge.CreateToggle({
		Name = "Notification",
		Function = function() end,
		Default = true
	})
end)

run(function()
	local alreadyreportedlist = {}
	local AutoReportV2 = {Enabled = false}
	local AutoReportV2Notify = {Enabled = false}
	AutoReportV2 = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoReportV2",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						for i,v in pairs(playersService:GetPlayers()) do
							if v ~= lplr and alreadyreportedlist[v] == nil and v:GetAttribute("PlayerConnected") and whitelist:get(v) == 0 then
								task.wait(1)
								alreadyreportedlist[v] = true
								bedwars.Client:Get(bedwars.ReportRemote):SendToServer(v.UserId)
								store.statistics.reported = store.statistics.reported + 1
								if AutoReportV2Notify.Enabled then
									warningNotification("AutoReportV2", "Reported "..v.Name, 15)
								end
							end
						end
					until (not AutoReportV2.Enabled)
				end)
			end
		end,
		HoverText = "dv mald"
	})
	AutoReportV2Notify = AutoReportV2.CreateToggle({
		Name = "Notify",
		Function = function() end
	})
end)

run(function()
	local justsaid = ''
	local leavesaid = false
	local alreadyreported = {}

	local function removerepeat(str)
		local newstr = ''
		local lastlet = ''
		for i,v in next, (str:split('')) do 
			if v ~= lastlet then
				newstr = newstr..v 
				lastlet = v
			end
		end
		return newstr
	end

	local reporttable = {
		gay = 'Bullying',
		gae = 'Bullying',
		gey = 'Bullying',
		hack = 'Scamming',
		exploit = 'Scamming',
		cheat = 'Scamming',
		hecker = 'Scamming',
		haxker = 'Scamming',
		hacer = 'Scamming',
		fat = 'Bullying',
		black = 'Bullying',
		getalife = 'Bullying',
		report = 'Bullying',
		fatherless = 'Bullying',
		disco = 'Offsite Links',
		yt = 'Offsite Links',
		dizcourde = 'Offsite Links',
		retard = 'Swearing',
		bad = 'Bullying',
		trash = 'Bullying',
		nolife = 'Bullying',
		killyour = 'Bullying',
		kys = 'Bullying',
		hacktowin = 'Bullying',
		bozo = 'Bullying',
		kid = 'Bullying',
		adopted = 'Bullying',
		linlife = 'Bullying',
		commitnotalive = 'Bullying',
		vape = 'Offsite Links',
		futureclient = 'Offsite Links',
		download = 'Offsite Links',
		youtube = 'Offsite Links',
		die = 'Bullying',
		lobby = 'Bullying',
		ban = 'Bullying',
		wizard = 'Bullying',
		wisard = 'Bullying',
		witch = 'Bullying',
		magic = 'Bullying',
	}
	local reporttableexact = {
		L = 'Bullying',
	}

	local rendermessages = {
		[1] = {'cry me a river <name>', 'boo hooo <name>', 'womp womp <name>', 'I could care less <name>.'}
	}

	local function findreport(msg)
		local checkstr = removerepeat(msg:gsub('%W+', ''):lower())
		for i,v in next, (reporttable) do 
			if checkstr:find(i) then 
				return v, i
			end
		end
		for i,v in next, (reporttableexact) do 
			if checkstr == i then 
				return v, i
			end
		end
		for i,v in next, (AutoToxicPhrases5.ObjectList) do 
			if checkstr:find(v) then 
				return 'Bullying', v
			end
		end
		return nil
	end

	AutoToxic = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoToxic',
		Function = function(calling)
			if calling then 
				table.insert(AutoToxic.Connections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if AutoToxicBedDestroyed.Enabled and bedTable.brokenBedTeam.id == lplr:GetAttribute('Team') then
						local custommsg = #AutoToxicPhrases6.ObjectList > 0 and AutoToxicPhrases6.ObjectList[math.random(1, #AutoToxicPhrases6.ObjectList)] or 'Who needs a bed when you got Voidware <name>? | .gg/voidware'
						if custommsg then
							custommsg = custommsg:gsub('<name>', (bedTable.player.DisplayName or bedTable.player.Name))
						end
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
					elseif AutoToxicBedBreak.Enabled and bedTable.player.UserId == lplr.UserId then
						local custommsg = #AutoToxicPhrases7.ObjectList > 0 and AutoToxicPhrases7.ObjectList[math.random(1, #AutoToxicPhrases7.ObjectList)] or 'Your bed has been sent to the abyss <teamname>! | .gg/voidware'
						if custommsg then
							local team = bedwars.QueueMeta[store.queueType].teams[tonumber(bedTable.brokenBedTeam.id)]
							local teamname = team and team.displayName:lower() or 'white'
							custommsg = custommsg:gsub('<teamname>', teamname)
						end
						sendmessage(custommsg)
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed == lplr then 
							if (not leavesaid) and killer ~= lplr and AutoToxicDeath.Enabled then
								leavesaid = true
								local custommsg = #AutoToxicPhrases3.ObjectList > 0 and AutoToxicPhrases3.ObjectList[math.random(1, #AutoToxicPhrases3.ObjectList)] or 'I was too laggy <name>. That\'s why you won. | .gg/voidware'
								if custommsg then
									custommsg = custommsg:gsub('<name>', (killer.DisplayName or killer.Name))
								end
								sendmessage(custommsg)
							end
						else
							if killer == lplr and AutoToxicFinalKill.Enabled then 
								local custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or '<name> things could have ended for you so differently, if you\'ve used Voidware. | .gg/voidware'
								if custommsg == lastsaid then
									custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or '<name> things could have ended for you so differently, if you\'ve used Voidware. | .gg/voidware'
								else
									lastsaid = custommsg
								end
								if custommsg then
									custommsg = custommsg:gsub('<name>', (killed.DisplayName or killed.Name))
								end
								sendmessage(custommsg)
							end
						end
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						if AutoToxicGG.Enabled then
							sendmessage('gg')
						end
						if AutoToxicWin.Enabled then
							sendmessage(#AutoToxicPhrases.ObjectList > 0 and AutoToxicPhrases.ObjectList[math.random(1, #AutoToxicPhrases.ObjectList)] or 'Voidware is simply better everyone. | .gg/voidware')
						end
					end
				end))
				table.insert(AutoToxic.Connections, RenderStore.MessageReceived.Event:Connect(function(plr, text)
					if AutoToxicRespond.Enabled then
						local args = text:split(' ')
						if plr and plr ~= lplr and not alreadyreported[plr] then
							local reportreason, reportedmatch = findreport(text)
							if reportreason then 
								alreadyreported[plr] = true
								local custommsg = #AutoToxicPhrases4.ObjectList > 0 and AutoToxicPhrases4.ObjectList[math.random(1, #AutoToxicPhrases4.ObjectList)]
								if custommsg then
									custommsg = custommsg:gsub('<name>', (plr.DisplayName or plr.Name))
								end
								local msg = (custommsg or getrandomvalue(rendermessages[1]):gsub('<name>', plr.DisplayName)..' | .gg/voidware')
								sendmessage(msg)
							end
						end
					end
				end))
			end
		end
	})
	AutoToxicGG = AutoToxic.CreateToggle({
		Name = 'AutoGG',
		Function = function() end, 
		Default = true
	})
	AutoToxicWin = AutoToxic.CreateToggle({
		Name = 'Win',
		Function = function() end, 
		Default = true
	})
	AutoToxicDeath = AutoToxic.CreateToggle({
		Name = 'Death',
		Function = function() end, 
		Default = true
	})
	AutoToxicBedBreak = AutoToxic.CreateToggle({
		Name = 'Bed Break',
		Function = function() end, 
		Default = true
	})
	AutoToxicBedDestroyed = AutoToxic.CreateToggle({
		Name = 'Bed Destroyed',
		Function = function() end, 
		Default = true
	})
	AutoToxicRespond = AutoToxic.CreateToggle({
		Name = 'Respond',
		Function = function() end, 
		Default = true
	})
	AutoToxicFinalKill = AutoToxic.CreateToggle({
		Name = 'Final Kill',
		Function = function() end, 
		Default = true
	})
	AutoToxicTeam = AutoToxic.CreateToggle({
		Name = 'Teammates',
		Function = function() end, 
	})
	AutoToxicPhrases = AutoToxic.CreateTextList({
		Name = 'ToxicList',
		TempText = 'phrase (win)',
	})
	AutoToxicPhrases2 = AutoToxic.CreateTextList({
		Name = 'ToxicList2',
		TempText = 'phrase (kill) <name>',
	})
	AutoToxicPhrases3 = AutoToxic.CreateTextList({
		Name = 'ToxicList3',
		TempText = 'phrase (death) <name>',
	})
	AutoToxicPhrases7 = AutoToxic.CreateTextList({
		Name = 'ToxicList7',
		TempText = 'phrase (bed break) <teamname>',
	})
	AutoToxicPhrases7.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases6 = AutoToxic.CreateTextList({
		Name = 'ToxicList6',
		TempText = 'phrase (bed destroyed) <name>',
	})
	AutoToxicPhrases6.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases4 = AutoToxic.CreateTextList({
		Name = 'ToxicList4',
		TempText = 'phrase (text to respond with) <name>',
	})
	AutoToxicPhrases4.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases5 = AutoToxic.CreateTextList({
		Name = 'ToxicList5',
		TempText = 'phrase (text to respond to)',
	})
	AutoToxicPhrases5.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases8 = AutoToxic.CreateTextList({
		Name = 'ToxicList8',
		TempText = 'phrase (lagback) <name>',
	})
	AutoToxicPhrases8.Object.AddBoxBKG.AddBox.TextSize = 12
end)

run(function()
	local ChestStealer = {Enabled = false}
	local ChestStealerDistance = {Value = 1}
	local ChestStealerDelay = {Value = 1}
	local ChestStealerOpen = {Enabled = false}
	local ChestStealerSkywars = {Enabled = true}
	local cheststealerdelays = {}
	local cheststealerfuncs = {
		Open = function()
			if bedwars.AppController:isAppOpen("ChestApp") then
				local chest = lplr.Character:FindFirstChild("ObservedChestFolder")
				local chestitems = chest and chest.Value and chest.Value:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in pairs(chestitems) do
						if v3:IsA("Accessory") and (cheststealerdelays[v3] == nil or cheststealerdelays[v3] < tick()) then
							task.spawn(function()
								pcall(function()
									cheststealerdelays[v3] = tick() + 0.2
									bedwars.Client:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(chest.Value, v3)
								end)
							end)
							task.wait(ChestStealerDelay.Value / 100)
						end
					end
				end
			end
		end,
		Closed = function()
			for i, v in pairs(collectionService:GetTagged("chest")) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= ChestStealerDistance.Value then
					local chest = v:FindFirstChild("ChestFolderValue")
					chest = chest and chest.Value or nil
					local chestitems = chest and chest:GetChildren() or {}
					if #chestitems > 0 then
						bedwars.Client:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(chest)
						for i3,v3 in pairs(chestitems) do
							if v3:IsA("Accessory") then
								task.spawn(function()
									pcall(function()
										bedwars.Client:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(v.ChestFolderValue.Value, v3)
									end)
								end)
								task.wait(ChestStealerDelay.Value / 100)
							end
						end
						bedwars.Client:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(nil)
					end
				end
			end
		end
	}

	ChestStealer = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ChestStealer",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.queueType ~= "bedwars_test"
					if (not ChestStealerSkywars.Enabled) or store.queueType:find("skywars") then
						repeat
							task.wait(0.1)
							if entityLibrary.isAlive then
								cheststealerfuncs[ChestStealerOpen.Enabled and "Open" or "Closed"]()
							end
						until (not ChestStealer.Enabled)
					end
				end)
			end
		end,
		HoverText = "Grabs items from near chests."
	})
	ChestStealerDistance = ChestStealer.CreateSlider({
		Name = "Range",
		Min = 0,
		Max = 18,
		Function = function() end,
		Default = 18
	})
	ChestStealerDelay = ChestStealer.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Function = function() end,
		Default = 1,
		Double = 100
	})
	ChestStealerOpen = ChestStealer.CreateToggle({
		Name = "GUI Check",
		Function = function() end
	})
	ChestStealerSkywars = ChestStealer.CreateToggle({
		Name = "Only Skywars",
		Function = function() end,
		Default = true
	})
end)

run(function()
	local FastDrop = {Enabled = false}
	FastDrop = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "FastDrop",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if entityLibrary.isAlive and (not store.localInventory.opened) and (inputService:IsKeyDown(Enum.KeyCode.Q) or inputService:IsKeyDown(Enum.KeyCode.Backspace)) and inputService:GetFocusedTextBox() == nil then
							task.spawn(bedwars.DropItem)
						end
					until (not FastDrop.Enabled)
				end)
			end
		end,
		HoverText = "Drops items fast when you hold Q"
	})
end)

run(function()
	local MissileTP = {Enabled = false}
	local MissileTeleportDelaySlider = {Value = 30}
	MissileTP = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "MissileTP",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if getItem("guided_missile") then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.RuntimeLib.await(bedwars.GuidedProjectileController.fireGuidedProjectile:CallServerAsync("guided_missile"))
							if projectile then
								local projectilemodel = projectile.model
								if not projectilemodel.PrimaryPart then
									projectilemodel:GetPropertyChangedSignal("PrimaryPart"):Wait()
								end;
								local bodyforce = Instance.new("BodyForce")
								bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
								bodyforce.Name = "AntiGravity"
								bodyforce.Parent = projectilemodel.PrimaryPart

								repeat
									task.wait()
									if projectile.model then
										if plr then
											projectile.model:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
										else
											warningNotification("MissileTP", "Player died before it could TP.", 3)
											break
										end
									end
								until projectile.model.Parent == nil
							else
								warningNotification("MissileTP", "Missile on cooldown.", 3)
							end
						else
							warningNotification("MissileTP", "Player not found.", 3)
						end
					else
						warningNotification("MissileTP", "Missile not found.", 3)
					end
				end)
				MissileTP.ToggleButton(true)
			end
		end,
		HoverText = "Spawns and teleports a missile to a player\nnear your mouse."
	})
end)

run(function()
	local PickupRangeRange = {Value = 1}
	local PickupRange = {Enabled = false}
	PickupRange = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "PickupRange",
		Function = function(callback)
			if callback then
				local pickedup = {}
				task.spawn(function()
					repeat
						local itemdrops = collectionService:GetTagged("ItemDrop")
						for i,v in pairs(itemdrops) do
							if entityLibrary.isAlive and (v:GetAttribute("ClientDropTime") and tick() - v:GetAttribute("ClientDropTime") > 2 or v:GetAttribute("ClientDropTime") == nil) then
								if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= PickupRangeRange.Value and (pickedup[v] == nil or pickedup[v] <= tick()) then
									task.spawn(function()
										pickedup[v] = tick() + 0.2
										bedwars.Client:Get(bedwars.PickupRemote):CallServerAsync({
											itemDrop = v
										}):andThen(function(suc)
											if suc then
												bedwars.SoundManager:playSound(bedwars.SoundList.PICKUP_ITEM_DROP)
											end
										end)
									end)
								end
							end
						end
						task.wait()
					until (not PickupRange.Enabled)
				end)
			end
		end
	})
	PickupRangeRange = PickupRange.CreateSlider({
		Name = "Range",
		Min = 1,
		Max = 10,
		Function = function() end,
		Default = 10
	})
end)

run(function()
	local BowExploit = {Enabled = false}
	local BowExploitTarget = {Value = "Mouse"}
	local BowExploitAutoShootFOV = {Value = 1000}
	local oldrealremote
	local noveloproj = {
		"fireball",
		"telepearl"
	}

	BowExploit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ProjectileExploit",
		Function = function(callback)
			if callback then
				oldrealremote = bedwars.ClientConstructor.Function.new
				bedwars.ClientConstructor.Function.new = function(self, ind, ...)
					local res = oldrealremote(self, ind, ...)
					local oldRemote = res.instance
					if oldRemote and oldRemote.Name == bedwars.ProjectileRemote then
						res.instance = {InvokeServer = function(self, shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
							local plr
							if BowExploitTarget.Value == "Mouse" then
								plr = EntityNearMouse(10000)
							else
								plr = EntityNearPosition(BowExploitAutoShootFOV.Value, true)
							end
							if plr then
								tab1.drawDurationSeconds = 1
								repeat
									task.wait(0.03)
									local offsetStartPos = plr.RootPart.CFrame.p - plr.RootPart.CFrame.lookVector
									local pos = plr.RootPart.Position
									local playergrav = workspace.Gravity
									local balloons = plr.Character:GetAttribute("InflatedBalloons")
									if balloons and balloons > 0 then
										playergrav = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
									end
									if plr.Character.PrimaryPart:FindFirstChild("rbxassetid://8200754399") then
										playergrav = (workspace.Gravity * 0.3)
									end
									local newLaunchVelo = bedwars.ProjectileMeta[proj2].launchVelocity
									local shootpos, shootvelo = predictGravity(pos, plr.RootPart.Velocity, (pos - offsetStartPos).Magnitude / newLaunchVelo, plr, playergrav)
									if proj2 == "telepearl" then
										shootpos = pos
										shootvelo = Vector3.zero
									end
									local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))
									shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
									local calculated = LaunchDirection(offsetStartPos, shootpos, newLaunchVelo, workspace.Gravity, false)
									if calculated then
										launchvelo = calculated
										launchpos1 = offsetStartPos
										launchpos2 = offsetStartPos
										tab1.drawDurationSeconds = 1
									else
										break
									end
									if oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, workspace:GetServerTimeNow() - 0.045) then break end
								until false
							else
								return oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
							end
						end}
					end
					return res
				end
			else
				bedwars.ClientConstructor.Function.new = oldrealremote
				oldrealremote = nil
			end
		end
	})
	BowExploitTarget = BowExploit.CreateDropdown({
		Name = "Mode",
		List = {"Mouse", "Range"},
		Function = function() end
	})
	BowExploitAutoShootFOV = BowExploit.CreateSlider({
		Name = "FOV",
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
end)

run(function()
	local RavenTP = {Enabled = false}
	RavenTP = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "RavenTP",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if getItem("raven") then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.Client:Get(bedwars.SpawnRavenRemote):CallServerAsync():andThen(function(projectile)
								if projectile then
									local projectilemodel = projectile
									if not projectilemodel then
										projectilemodel:GetPropertyChangedSignal("PrimaryPart"):Wait()
									end
									local bodyforce = Instance.new("BodyForce")
									bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
									bodyforce.Name = "AntiGravity"
									bodyforce.Parent = projectilemodel.PrimaryPart

									if plr then
										projectilemodel:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
										task.wait(0.3)
										bedwars.RavenController:detonateRaven()
									else
										warningNotification("RavenTP", "Player died before it could TP.", 3)
									end
								else
									warningNotification("RavenTP", "Raven on cooldown.", 3)
								end
							end)
						else
							warningNotification("RavenTP", "Player not found.", 3)
						end
					else
						warningNotification("RavenTP", "Raven not found.", 3)
					end
				end)
				RavenTP.ToggleButton(true)
			end
		end,
		HoverText = "Spawns and teleports a raven to a player\nnear your mouse."
	})
end)

run(function()
	local tiered = {}
	local nexttier = {}

	for i,v in pairs(bedwars.ShopItems) do
		if type(v) == "table" then
			if v.tiered then
				tiered[v.itemType] = v.tiered
			end
			if v.nextTier then
				nexttier[v.itemType] = v.nextTier
			end
		end
	end

	GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ShopTierBypass",
		Function = function(callback)
			if callback then
				for i,v in pairs(bedwars.ShopItems) do
					if type(v) == "table" then
						v.tiered = nil
						v.nextTier = nil
					end
				end
			else
				for i,v in pairs(bedwars.ShopItems) do
					if type(v) == "table" then
						if tiered[v.itemType] then
							v.tiered = tiered[v.itemType]
						end
						if nexttier[v.itemType] then
							v.nextTier = nexttier[v.itemType]
						end
					end
				end
			end
		end,
		HoverText = "Allows you to access tiered items early."
	})
end)

local lagbackedaftertouch = false
run(function()
	local AntiVoidPart
	local AntiVoidConnection
	local AntiVoidMode = {Value = "Normal"}
	local AntiVoidMoveMode = {Value = "Normal"}
	local AntiVoid = {Enabled = false}
	local AntiVoidTransparent = {Value = 50}
	local AntiVoidColor = {Hue = 1, Sat = 1, Value = 0.55}
	local lastvalidpos

	local function closestpos(block)
		local startpos = block.Position - (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local newpos = block.Position + (entityLibrary.character.HumanoidRootPart.Position - block.Position)
		return Vector3.new(math.clamp(newpos.X, startpos.X, endpos.X), endpos.Y + 3, math.clamp(newpos.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag)
		local closest, closestmag = nil, newmag * 3
		if entityLibrary.isAlive then
			local tops = {}
			for i,v in pairs(store.blocks) do
				local close = getScaffold(closestpos(v), false)
				if getPlacedBlock(close) then continue end
				if close.Y < entityLibrary.character.HumanoidRootPart.Position.Y then continue end
				if (close - entityLibrary.character.HumanoidRootPart.Position).magnitude <= newmag * 3 then
					table.insert(tops, close)
				end
			end
			for i,v in pairs(tops) do
				local mag = (v - entityLibrary.character.HumanoidRootPart.Position).magnitude
				if mag <= closestmag then
					closest = v
					closestmag = mag
				end
			end
		end
		return closest
	end

	local antivoidypos = 0
	local antivoiding = false
	AntiVoid = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "AntiVoid",
		Function = function(callback)
			if callback then
				task.spawn(function()
					AntiVoidPart = Instance.new("Part")
					AntiVoidPart.CanCollide = AntiVoidMode.Value == "Collide"
					AntiVoidPart.Size = Vector3.new(10000, 1, 10000)
					AntiVoidPart.Anchored = true
					AntiVoidPart.Material = Enum.Material.Neon
					AntiVoidPart.Color = Color3.fromHSV(AntiVoidColor.Hue, AntiVoidColor.Sat, AntiVoidColor.Value)
					AntiVoidPart.Transparency = 1 - (AntiVoidTransparent.Value / 100)
					AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
					AntiVoidPart.Parent = workspace
					if AntiVoidMoveMode.Value == "Classic" and antivoidypos == 0 then
						AntiVoidPart.Parent = nil
					end
					AntiVoidConnection = AntiVoidPart.Touched:Connect(function(touchedpart)
						if touchedpart.Parent == lplr.Character and entityLibrary.isAlive then
							if (not antivoiding) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) and entityLibrary.character.Humanoid.Health > 0 and AntiVoidMode.Value ~= "Collide" then
								if AntiVoidMode.Value == "Velocity" then
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 100, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								else
									antivoiding = true
									local pos = getclosesttop(1000)
									if pos then
										local lastTeleport = lplr:GetAttribute("LastTeleported")
										RunLoops:BindToHeartbeat("AntiVoid", function(dt)
											if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) and (entityLibrary.character.HumanoidRootPart.Position - pos).Magnitude > 1 and AntiVoid.Enabled and lplr:GetAttribute("LastTeleported") == lastTeleport then
												local hori1 = Vector3.new(entityLibrary.character.HumanoidRootPart.Position.X, 0, entityLibrary.character.HumanoidRootPart.Position.Z)
												local hori2 = Vector3.new(pos.X, 0, pos.Z)
												local newpos = (hori2 - hori1).Unit
												local realnewpos = CFrame.new(newpos == newpos and entityLibrary.character.HumanoidRootPart.CFrame.p + (newpos * ((3 + getSpeed()) * dt)) or Vector3.zero)
												entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(realnewpos.p.X, pos.Y, realnewpos.p.Z)
												antivoidvelo = newpos == newpos and newpos * 20 or Vector3.zero
												entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(antivoidvelo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, antivoidvelo.Z)
												if getPlacedBlock((entityLibrary.character.HumanoidRootPart.CFrame.p - Vector3.new(0, 1, 0)) + entityLibrary.character.HumanoidRootPart.Velocity.Unit) or getPlacedBlock(entityLibrary.character.HumanoidRootPart.CFrame.p + Vector3.new(0, 3)) then
													pos = pos + Vector3.new(0, 1, 0)
												end
											else
												RunLoops:UnbindFromHeartbeat("AntiVoid")
												antivoidvelo = nil
												antivoiding = false
											end
										end)
									else
										entityLibrary.character.HumanoidRootPart.CFrame += Vector3.new(0, 100000, 0)
										antivoiding = false
									end
								end
							end
						end
					end)
					repeat
						if entityLibrary.isAlive and AntiVoidMoveMode.Value == "Normal" then
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), store.blockRaycast)
							if ray or GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled or GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then
								AntiVoidPart.Position = entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, 21, 0)
							end
						end
						task.wait()
					until (not AntiVoid.Enabled)
				end)
			else
				if AntiVoidConnection then AntiVoidConnection:Disconnect() end
				if AntiVoidPart then
					AntiVoidPart:Destroy()
				end
			end
		end,
		HoverText = "Gives you a chance to get on land (Bouncing Twice, abusing, or bad luck will lead to lagbacks)"
	})
	AntiVoidMoveMode = AntiVoid.CreateDropdown({
		Name = "Position Mode",
		Function = function(val)
			if val == "Classic" then
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0 or not vapeInjected
					if vapeInjected and AntiVoidMoveMode.Value == "Classic" and antivoidypos == 0 and AntiVoid.Enabled then
						local lowestypos = 99999
						for i,v in pairs(store.blocks) do
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), store.blockRaycast)
							if i % 200 == 0 then
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						antivoidypos = lowestypos - 8
					end
					if AntiVoidPart then
						AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
						AntiVoidPart.Parent = workspace
					end
				end)
			end
		end,
		List = {"Normal", "Classic"}
	})
	AntiVoidMode = AntiVoid.CreateDropdown({
		Name = "Move Mode",
		Function = function(val)
			if AntiVoidPart then
				AntiVoidPart.CanCollide = val == "Collide"
			end
		end,
		List = {"Normal", "Collide", "Velocity"}
	})
	AntiVoidTransparent = AntiVoid.CreateSlider({
		Name = "Invisible",
		Min = 1,
		Max = 100,
		Default = 50,
		Function = function(val)
			if AntiVoidPart then
				AntiVoidPart.Transparency = 1 - (val / 100)
			end
		end,
	})
	AntiVoidColor = AntiVoid.CreateColorSlider({
		Name = "Color",
		Function = function(h, s, v)
			if AntiVoidPart then
				AntiVoidPart.Color = Color3.fromHSV(h, s, v)
			end
		end
	})
end)

run(function()
	local oldhitblock

	local AutoTool = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "AutoTool",
		Function = function(callback)
			if callback then
				oldhitblock = bedwars.BlockBreaker.hitBlock
				bedwars.BlockBreaker.hitBlock = function(self, maid, raycastparams, ...)
					if (GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled == false or store.matchState ~= 0) then
						local block = self.clientManager:getBlockSelector():getMouseInfo(1, {ray = raycastparams})
						if block and block.target and not block.target.blockInstance:GetAttribute("NoBreak") and not block.target.blockInstance:GetAttribute("Team"..(lplr:GetAttribute("Team") or 0).."NoBreak") then
							if switchToAndUseTool(block.target.blockInstance, true) then return end
						end
					end
					return oldhitblock(self, maid, raycastparams, ...)
				end
			else
				bedwars.BlockBreaker.hitBlock = oldhitblock
				oldhitblock = nil
			end
		end,
		HoverText = "Automatically swaps your hand to the appropriate tool."
	})
end)

run(function()
	local BedProtector = {Enabled = false}
	local bedprotector1stlayer = {
		Vector3.new(0, 3, 0),
		Vector3.new(0, 3, 3),
		Vector3.new(3, 0, 0),
		Vector3.new(3, 0, 3),
		Vector3.new(-3, 0, 0),
		Vector3.new(-3, 0, 3),
		Vector3.new(0, 0, 6),
		Vector3.new(0, 0, -3)
	}
	local bedprotector2ndlayer = {
		Vector3.new(0, 6, 0),
		Vector3.new(0, 6, 3),
		Vector3.new(0, 3, 6),
		Vector3.new(0, 3, -3),
		Vector3.new(0, 0, -6),
		Vector3.new(0, 0, 9),
		Vector3.new(3, 3, 0),
		Vector3.new(3, 3, 3),
		Vector3.new(3, 0, 6),
		Vector3.new(3, 0, -3),
		Vector3.new(6, 0, 3),
		Vector3.new(6, 0, 0),
		Vector3.new(-3, 3, 3),
		Vector3.new(-3, 3, 0),
		Vector3.new(-6, 0, 3),
		Vector3.new(-6, 0, 0),
		Vector3.new(-3, 0, 6),
		Vector3.new(-3, 0, -3),
	}

	local function getItemFromList(list)
		local selecteditem
		for i3,v3 in pairs(list) do
			local item = getItem(v3)
			if item then
				selecteditem = item
				break
			end
		end
		return selecteditem
	end

	local function placelayer(layertab, obj, selecteditems)
		for i2,v2 in pairs(layertab) do
			local selecteditem = getItemFromList(selecteditems)
			if selecteditem then
				bedwars.placeBlock(obj.Position + v2, selecteditem.itemType)
			else
				return false
			end
		end
		return true
	end

	local bedprotectorrange = {Value = 1}
	BedProtector = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "BedProtector",
		Function = function(callback)
            if callback then
                task.spawn(function()
                    for i, obj in pairs(collectionService:GetTagged("bed")) do
                        if entityLibrary.isAlive and obj:GetAttribute("Team"..(lplr:GetAttribute("Team") or 0).."NoBreak") and obj.Parent ~= nil then
                            if (entityLibrary.character.HumanoidRootPart.Position - obj.Position).magnitude <= bedprotectorrange.Value then
                                local firstlayerplaced = placelayer(bedprotector1stlayer, obj, {"obsidian", "stone_brick", "plank_oak", getWool()})
							    if firstlayerplaced then
									placelayer(bedprotector2ndlayer, obj, {getWool()})
							    end
                            end
                            break
                        end
                    end
                    BedProtector.ToggleButton(false)
                end)
            end
		end,
		HoverText = "Automatically places a bed defense (Toggle)"
	})
	bedprotectorrange = BedProtector.CreateSlider({
		Name = "Place range",
		Min = 1,
		Max = 100,
		Function = function(val) end,
		Default = 20
	})
end)

run(function()
	local Nuker = {Enabled = false}
	local nukerrange = {Value = 1}
	local nukereffects = {Enabled = false}
	local nukeranimation = {Enabled = false}
	local nukernofly = {Enabled = false}
	local nukerlegit = {Enabled = false}
	local nukerown = {Enabled = false}
    local nukerluckyblock = {Enabled = false}
	local nukerironore = {Enabled = false}
    local nukerbeds = {Enabled = false}
	local nukercustom = {RefreshValues = function() end, ObjectList = {}}
    local luckyblocktable = {}

	Nuker = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "Nuker",
		Function = function(callback)
            if callback then
				for i,v in pairs(store.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
				table.insert(Nuker.Connections, collectionService:GetInstanceAddedSignal("block"):Connect(function(v)
                    if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
                        table.insert(luckyblocktable, v)
                    end
                end))
                table.insert(Nuker.Connections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(v)
                    if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
                        table.remove(luckyblocktable, table.find(luckyblocktable, v))
                    end
                end))
                task.spawn(function()
                    repeat
						if (not nukernofly.Enabled or not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
							local broke = not entityLibrary.isAlive
							local tool = (not nukerlegit.Enabled) and {Name = "wood_axe"} or store.localHand.tool
							if nukerbeds.Enabled then
								for i, obj in pairs(collectionService:GetTagged("bed")) do
									if broke then break end
									if obj.Parent ~= nil then
										if obj:GetAttribute("BedShieldEndTime") then
											if obj:GetAttribute("BedShieldEndTime") > workspace:GetServerTimeNow() then continue end
										end
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												local res, amount = getBestBreakSide(obj.Position)
												local res2, amount2 = getBestBreakSide(obj.Position + Vector3.new(0, 0, 3))
												broke = true
												bedwars.breakBlock((amount < amount2 and obj.Position or obj.Position + Vector3.new(0, 0, 3)), nukereffects.Enabled, (amount < amount2 and res or res2), false, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
							broke = broke and not entityLibrary.isAlive
							for i, obj in pairs(luckyblocktable) do
								if broke then break end
								if entityLibrary.isAlive then
									if obj and obj.Parent ~= nil then
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value and (nukerown.Enabled or obj:GetAttribute("PlacedByUserId") ~= lplr.UserId) then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												bedwars.breakBlock(obj.Position, nukereffects.Enabled, getBestBreakSide(obj.Position), true, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
						end
						task.wait()
                    until (not Nuker.Enabled)
                end)
            else
                luckyblocktable = {}
            end
		end,
		HoverText = "Automatically destroys beds & luckyblocks around you."
	})
	nukerrange = Nuker.CreateSlider({
		Name = "Break range",
		Min = 1,
		Max = 30,
		Function = function(val) end,
		Default = 30
	})
	nukerlegit = Nuker.CreateToggle({
		Name = "Hand Check",
		Function = function() end
	})
	nukereffects = Nuker.CreateToggle({
		Name = "Show HealthBar & Effects",
		Function = function(callback)
			if not callback then
				bedwars.BlockBreaker.healthbarMaid:DoCleaning()
			end
		 end,
		Default = true
	})
	nukeranimation = Nuker.CreateToggle({
		Name = "Break Animation",
		Function = function() end
	})
	nukerown = Nuker.CreateToggle({
		Name = "Self Break",
		Function = function() end,
	})
    nukerbeds = Nuker.CreateToggle({
		Name = "Break Beds",
		Function = function(callback) end,
		Default = true
	})
	nukernofly = Nuker.CreateToggle({
		Name = "Fly Disable",
		Function = function() end
	})
    nukerluckyblock = Nuker.CreateToggle({
		Name = "Break LuckyBlocks",
		Function = function(callback)
			if callback then
				luckyblocktable = {}
				for i,v in pairs(store.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		 end,
		Default = true
	})
	nukerironore = Nuker.CreateToggle({
		Name = "Break IronOre",
		Function = function(callback)
			if callback then
				luckyblocktable = {}
				for i,v in pairs(store.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		end
	})
	nukercustom = Nuker.CreateTextList({
		Name = "NukerList",
		TempText = "block (tesla_trap)",
		AddFunction = function()
			luckyblocktable = {}
			for i,v in pairs(store.blocks) do
				if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) then
					table.insert(luckyblocktable, v)
				end
			end
		end
	})
end)

run(function()
	local controlmodule = require(lplr.PlayerScripts.PlayerModule).controls
	local oldmove
	local SafeWalk = {Enabled = false}
	local SafeWalkMode = {Value = "Optimized"}
	SafeWalk = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "SafeWalk",
		Function = function(callback)
			if callback then
				oldmove = controlmodule.moveFunction
				controlmodule.moveFunction = function(Self, vec, facecam)
					if entityLibrary.isAlive and (not Scaffold.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
						if SafeWalkMode.Value == "Optimized" then
							local newpos = (entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight * 2, 0))
							local ray = getPlacedBlock(newpos + Vector3.new(0, -6, 0) + vec)
							for i = 1, 50 do
								if ray then break end
								ray = getPlacedBlock(newpos + Vector3.new(0, -i * 6, 0) + vec)
							end
							local ray2 = getPlacedBlock(newpos)
							if ray == nil and ray2 then
								local ray3 = getPlacedBlock(newpos + vec) or getPlacedBlock(newpos + (vec * 1.5))
								if ray3 == nil then
									vec = Vector3.zero
								end
							end
						else
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + vec, Vector3.new(0, -1000, 0), store.blockRaycast)
							local ray2 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -entityLibrary.character.Humanoid.HipHeight * 2, 0), store.blockRaycast)
							if ray == nil and ray2 then
								local ray3 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + (vec * 1.8), Vector3.new(0, -1000, 0), store.blockRaycast)
								if ray3 == nil then
									vec = Vector3.zero
								end
							end
						end
					end
					return oldmove(Self, vec, facecam)
				end
			else
				controlmodule.moveFunction = oldmove
			end
		end,
		HoverText = "lets you not walk off because you are bad"
	})
	SafeWalkMode = SafeWalk.CreateDropdown({
		Name = "Mode",
		List = {"Optimized", "Accurate"},
		Function = function() end
	})
end)

run(function()
	local Schematica = {Enabled = false}
	local SchematicaBox = {Value = ""}
	local SchematicaTransparency = {Value = 30}
	local positions = {}
	local tempfolder
	local tempgui
	local aroundpos = {
		[1] = Vector3.new(0, 3, 0),
		[2] = Vector3.new(-3, 3, 0),
		[3] = Vector3.new(-3, -0, 0),
		[4] = Vector3.new(-3, -3, 0),
		[5] = Vector3.new(0, -3, 0),
		[6] = Vector3.new(3, -3, 0),
		[7] = Vector3.new(3, -0, 0),
		[8] = Vector3.new(3, 3, 0),
		[9] = Vector3.new(0, 3, -3),
		[10] = Vector3.new(-3, 3, -3),
		[11] = Vector3.new(-3, -0, -3),
		[12] = Vector3.new(-3, -3, -3),
		[13] = Vector3.new(0, -3, -3),
		[14] = Vector3.new(3, -3, -3),
		[15] = Vector3.new(3, -0, -3),
		[16] = Vector3.new(3, 3, -3),
		[17] = Vector3.new(0, 3, 3),
		[18] = Vector3.new(-3, 3, 3),
		[19] = Vector3.new(-3, -0, 3),
		[20] = Vector3.new(-3, -3, 3),
		[21] = Vector3.new(0, -3, 3),
		[22] = Vector3.new(3, -3, 3),
		[23] = Vector3.new(3, -0, 3),
		[24] = Vector3.new(3, 3, 3),
		[25] = Vector3.new(0, -0, 3),
		[26] = Vector3.new(0, -0, -3)
	}

	local function isNearBlock(pos)
		for i,v in pairs(aroundpos) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function gethighlightboxatpos(pos)
		if tempfolder then
			for i,v in pairs(tempfolder:GetChildren()) do
				if v.Position == pos then
					return v
				end
			end
		end
		return nil
	end

	local function removeduplicates(tab)
		local actualpositions = {}
		for i,v in pairs(tab) do
			if table.find(actualpositions, Vector3.new(v.X, v.Y, v.Z)) == nil then
				table.insert(actualpositions, Vector3.new(v.X, v.Y, v.Z))
			else
				table.remove(tab, i)
			end
			if v.blockType == "start_block" then
				table.remove(tab, i)
			end
		end
	end

	local function rotate(tab)
		for i,v in pairs(tab) do
			local radvec, radius = entityLibrary.character.HumanoidRootPart.CFrame:ToAxisAngle()
			radius = (radius * 57.2957795)
			radius = math.round(radius / 90) * 90
			if radvec == Vector3.new(0, -1, 0) and radius == 90 then
				radius = 270
			end
			local rot = CFrame.new() * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.rad(radius))
			local newpos = CFrame.new(0, 0, 0) * rot * CFrame.new(Vector3.new(v.X, v.Y, v.Z))
			v.X = math.round(newpos.p.X)
			v.Y = math.round(newpos.p.Y)
			v.Z = math.round(newpos.p.Z)
		end
	end

	local function getmaterials(tab)
		local materials = {}
		for i,v in pairs(tab) do
			materials[v.blockType] = (materials[v.blockType] and materials[v.blockType] + 1 or 1)
		end
		return materials
	end

	local function schemplaceblock(pos, blocktype, removefunc)
		local fail = false
		local ok = bedwars.RuntimeLib.try(function()
			bedwars.ClientDamageBlock:Get("PlaceBlock"):CallServer({
				blockType = blocktype or getWool(),
				position = bedwars.BlockController:getBlockPosition(pos)
			})
		end, function(thing)
			fail = true
		end)
		if (not fail) and bedwars.BlockController:getStore():getBlockAt(bedwars.BlockController:getBlockPosition(pos)) then
			removefunc()
		end
	end

	Schematica = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "Schematica",
		Function = function(callback)
			if callback then
				local mouseinfo = bedwars.BlockEngine:getBlockSelector():getMouseInfo(0)
				if mouseinfo and isfile(SchematicaBox.Value) then
					tempfolder = Instance.new("Folder")
					tempfolder.Parent = workspace
					local newpos = mouseinfo.placementPosition * 3
					positions = game:GetService("HttpService"):JSONDecode(readfile(SchematicaBox.Value))
					if positions.blocks == nil then
						positions = {blocks = positions}
					end
					rotate(positions.blocks)
					removeduplicates(positions.blocks)
					if positions["start_block"] == nil then
						bedwars.placeBlock(newpos)
					end
					for i2,v2 in pairs(positions.blocks) do
						local texturetxt = bedwars.ItemTable[(v2.blockType == "wool_white" and getWool() or v2.blockType)].block.greedyMesh.textures[1]
						local newerpos = (newpos + Vector3.new(v2.X, v2.Y, v2.Z))
						local block = Instance.new("Part")
						block.Position = newerpos
						block.Size = Vector3.new(3, 3, 3)
						block.CanCollide = false
						block.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
						block.Anchored = true
						block.Parent = tempfolder
						for i3,v3 in pairs(Enum.NormalId:GetEnumItems()) do
							local texture = Instance.new("Texture")
							texture.Face = v3
							texture.Texture = texturetxt
							texture.Name = tostring(v3)
							texture.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
							texture.Parent = block
						end
					end
					task.spawn(function()
						repeat
							task.wait(.1)
							if not Schematica.Enabled then break end
							for i,v in pairs(positions.blocks) do
								local newerpos = (newpos + Vector3.new(v.X, v.Y, v.Z))
								if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - newerpos).magnitude <= 30 and isNearBlock(newerpos) and bedwars.BlockController:isAllowedPlacement(lplr, getWool(), newerpos / 3, 0) then
									schemplaceblock(newerpos, (v.blockType == "wool_white" and getWool() or v.blockType), function()
										table.remove(positions.blocks, i)
										if gethighlightboxatpos(newerpos) then
											gethighlightboxatpos(newerpos):Remove()
										end
									end)
								end
							end
						until #positions.blocks == 0 or (not Schematica.Enabled)
						if Schematica.Enabled then
							Schematica.ToggleButton(false)
							warningNotification("Schematica", "Finished Placing Blocks", 4)
						end
					end)
				end
			else
				positions = {}
				if tempfolder then
					tempfolder:Remove()
				end
			end
		end,
		HoverText = "Automatically places structure at mouse position."
	})
	SchematicaBox = Schematica.CreateTextBox({
		Name = "File",
		TempText = "File (location in workspace)",
		FocusLost = function(enter)
			local suc, res = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(SchematicaBox.Value)) end)
			if tempgui then
				tempgui:Remove()
			end
			if suc then
				if res.blocks == nil then
					res = {blocks = res}
				end
				removeduplicates(res.blocks)
				tempgui = Instance.new("Frame")
				tempgui.Name = "SchematicListOfBlocks"
				tempgui.BackgroundTransparency = 1
				tempgui.LayoutOrder = 9999
				tempgui.Parent = SchematicaBox.Object.Parent
				local uilistlayoutschmatica = Instance.new("UIListLayout")
				uilistlayoutschmatica.Parent = tempgui
				uilistlayoutschmatica:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					tempgui.Size = UDim2.new(0, 220, 0, uilistlayoutschmatica.AbsoluteContentSize.Y)
				end)
				for i4,v4 in pairs(getmaterials(res.blocks)) do
					local testframe = Instance.new("Frame")
					testframe.Size = UDim2.new(0, 220, 0, 40)
					testframe.BackgroundTransparency = 1
					testframe.Parent = tempgui
					local testimage = Instance.new("ImageLabel")
					testimage.Size = UDim2.new(0, 40, 0, 40)
					testimage.Position = UDim2.new(0, 3, 0, 0)
					testimage.BackgroundTransparency = 1
					testimage.Image = bedwars.getIcon({itemType = i4}, true)
					testimage.Parent = testframe
					local testtext = Instance.new("TextLabel")
					testtext.Size = UDim2.new(1, -50, 0, 40)
					testtext.Position = UDim2.new(0, 50, 0, 0)
					testtext.TextSize = 20
					testtext.Text = v4
					testtext.Font = Enum.Font.SourceSans
					testtext.TextXAlignment = Enum.TextXAlignment.Left
					testtext.TextColor3 = Color3.new(1, 1, 1)
					testtext.BackgroundTransparency = 1
					testtext.Parent = testframe
				end
			end
		end
	})
	SchematicaTransparency = Schematica.CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 10,
		Default = 7,
		Function = function()
			if tempfolder then
				for i2,v2 in pairs(tempfolder:GetChildren()) do
					v2.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
					for i3,v3 in pairs(v2:GetChildren()) do
						v3.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
					end
				end
			end
		end
	})
end)

run(function()
	store.TPString = shared.vapeoverlay or nil
	local origtpstring = store.TPString
	local Overlay = GuiLibrary.CreateCustomWindow({
		Name = "Overlay",
		Icon = "vape/assets/TargetIcon1.png",
		IconSize = 16
	})
	local overlayframe = Instance.new("Frame")
	overlayframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe.Size = UDim2.new(0, 200, 0, 120)
	overlayframe.Position = UDim2.new(0, 0, 0, 5)
	overlayframe.Parent = Overlay.GetCustomChildren()
	local overlayframe2 = Instance.new("Frame")
	overlayframe2.Size = UDim2.new(1, 0, 0, 10)
	overlayframe2.Position = UDim2.new(0, 0, 0, -5)
	overlayframe2.Parent = overlayframe
	local overlayframe3 = Instance.new("Frame")
	overlayframe3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe3.Size = UDim2.new(1, 0, 0, 6)
	overlayframe3.Position = UDim2.new(0, 0, 0, 6)
	overlayframe3.BorderSizePixel = 0
	overlayframe3.Parent = overlayframe2
	local oldguiupdate = GuiLibrary.UpdateUI
	GuiLibrary.UpdateUI = function(h, s, v, ...)
		overlayframe2.BackgroundColor3 = Color3.fromHSV(h, s, v)
		return oldguiupdate(h, s, v, ...)
	end
	local framecorner1 = Instance.new("UICorner")
	framecorner1.CornerRadius = UDim.new(0, 5)
	framecorner1.Parent = overlayframe
	local framecorner2 = Instance.new("UICorner")
	framecorner2.CornerRadius = UDim.new(0, 5)
	framecorner2.Parent = overlayframe2
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -7, 1, -5)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Font = Enum.Font.Arial
	label.LineHeight = 1.2
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	label.TextSize = 16
	label.Text = ""
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Position = UDim2.new(0, 7, 0, 5)
	label.Parent = overlayframe
	local OverlayFonts = {"Arial"}
	for i,v in pairs(Enum.Font:GetEnumItems()) do
		if v.Name ~= "Arial" then
			table.insert(OverlayFonts, v.Name)
		end
	end
	local OverlayFont = Overlay.CreateDropdown({
		Name = "Font",
		List = OverlayFonts,
		Function = function(val)
			label.Font = Enum.Font[val]
		end
	})
	OverlayFont.Bypass = true
	Overlay.Bypass = true
	local overlayconnections = {}
	local oldnetworkowner
	local teleported = {}
	local teleported2 = {}
	local teleportedability = {}
	local teleportconnections = {}
	local pinglist = {}
	local fpslist = {}
	local matchstatechanged = 0
	local mapname = "Unknown"
	local overlayenabled = false

	task.spawn(function()
		pcall(function()
			mapname = workspace:WaitForChild("Map"):WaitForChild("Worlds"):GetChildren()[1].Name
			mapname = string.gsub(string.split(mapname, "_")[2] or mapname, "-", "") or "Blank"
		end)
	end)

	local function didpingspike()
		local currentpingcheck = pinglist[1] or math.floor(tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue()))
		for i,v in pairs(pinglist) do
			if v ~= currentpingcheck and math.abs(v - currentpingcheck) >= 100 then
				return currentpingcheck.." => "..v.." ping"
			else
				currentpingcheck = v
			end
		end
		return nil
	end

	local function notlasso()
		for i,v in pairs(collectionService:GetTagged("LassoHooked")) do
			if v == lplr.Character then
				return false
			end
		end
		return true
	end
	local matchstatetick = tick()

	GuiLibrary.ObjectsThatCanBeSaved.GUIWindow.Api.CreateCustomToggle({
		Name = "Overlay",
		Icon = "vape/assets/TargetIcon1.png",
		Function = function(callback)
			overlayenabled = callback
			Overlay.SetVisible(callback)
			if callback then
				table.insert(overlayconnections, bedwars.Client:OnEvent("ProjectileImpact", function(p3)
					if not vapeInjected then return end
					if p3.projectile == "telepearl" then
						teleported[p3.shooterPlayer] = true
					elseif p3.projectile == "swap_ball" then
						if p3.hitEntity then
							teleported[p3.shooterPlayer] = true
							local plr = playersService:GetPlayerFromCharacter(p3.hitEntity)
							if plr then teleported[plr] = true end
						end
					end
				end))

				table.insert(overlayconnections, replicatedStorage["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].abilityUsed.OnClientEvent:Connect(function(char, ability)
					if ability == "recall" or ability == "hatter_teleport" or ability == "spirit_assassin_teleport" or ability == "hannah_execute" then
						local plr = playersService:GetPlayerFromCharacter(char)
						if plr then
							teleportedability[plr] = tick() + (ability == "recall" and 12 or 1)
						end
					end
				end))

				table.insert(overlayconnections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if bedTable.player.UserId == lplr.UserId then
						store.statistics.beds = store.statistics.beds + 1
					end
				end))

				local victorysaid = false
				table.insert(overlayconnections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						victorysaid = true
					end
				end))

				table.insert(overlayconnections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed ~= lplr and killer == lplr then
							store.statistics.kills = store.statistics.kills + 1
						end
					end
				end))

				task.spawn(function()
					repeat
						local ping = math.floor(tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue()))
						if #pinglist >= 10 then
							table.remove(pinglist, 1)
						end
						table.insert(pinglist, ping)
						task.wait(1)
						if store.matchState ~= matchstatechanged then
							if store.matchState == 1 then
								matchstatetick = tick() + 3
							end
							matchstatechanged = store.matchState
						end
						if not store.TPString then
							store.TPString = tick().."/"..store.statistics.kills.."/"..store.statistics.beds.."/"..(victorysaid and 1 or 0).."/"..(1).."/"..(0).."/"..(0).."/"..(0)
							origtpstring = store.TPString
						end
						if entityLibrary.isAlive and (not oldcloneroot) then
							local newnetworkowner = isnetworkowner(entityLibrary.character.HumanoidRootPart)
							if oldnetworkowner ~= nil and oldnetworkowner ~= newnetworkowner and newnetworkowner == false and notlasso() then
								local respawnflag = math.abs(lplr:GetAttribute("SpawnTime") - lplr:GetAttribute("LastTeleported")) > 3
								if (not teleported[lplr]) and respawnflag then
									task.delay(1, function()
										local falseflag = didpingspike()
										if not falseflag then
											store.statistics.lagbacks = store.statistics.lagbacks + 1
										end
									end)
								end
							end
							oldnetworkowner = newnetworkowner
						else
							oldnetworkowner = nil
						end
						teleported[lplr] = nil
						for i, v in pairs(entityLibrary.entityList) do
							if teleportconnections[v.Player.Name.."1"] then continue end
							teleportconnections[v.Player.Name.."1"] = v.Player:GetAttributeChangedSignal("LastTeleported"):Connect(function()
								if not vapeInjected then return end
								for i = 1, 15 do
									task.wait(0.1)
									if teleported[v.Player] or teleported2[v.Player] or matchstatetick > tick() or math.abs(v.Player:GetAttribute("SpawnTime") - v.Player:GetAttribute("LastTeleported")) < 3 or (teleportedability[v.Player] or tick() - 1) > tick() then break end
								end
								if v.Player ~= nil and (not v.Player.Neutral) and teleported[v.Player] == nil and teleported2[v.Player] == nil and (teleportedability[v.Player] or tick() - 1) < tick() and math.abs(v.Player:GetAttribute("SpawnTime") - v.Player:GetAttribute("LastTeleported")) > 3 and matchstatetick <= tick() then
									store.statistics.universalLagbacks = store.statistics.universalLagbacks + 1
									vapeEvents.LagbackEvent:Fire(v.Player)
								end
								teleported[v.Player] = nil
							end)
							teleportconnections[v.Player.Name.."2"] = v.Player:GetAttributeChangedSignal("PlayerConnected"):Connect(function()
								teleported2[v.Player] = true
								task.delay(5, function()
									teleported2[v.Player] = nil
								end)
							end)
						end
						local splitted = origtpstring:split("/")
						label.Text = "Session Info\nTime Played : "..os.date("!%X",math.floor(tick() - splitted[1])).."\nKills : "..(splitted[2] + store.statistics.kills).."\nBeds : "..(splitted[3] + store.statistics.beds).."\nWins : "..(splitted[4] + (victorysaid and 1 or 0)).."\nGames : "..splitted[5].."\nLagbacks : "..(splitted[6] + store.statistics.lagbacks).."\nUniversal Lagbacks : "..(splitted[7] + store.statistics.universalLagbacks).."\nReported : "..(splitted[8] + store.statistics.reported).."\nMap : "..mapname
						local textsize = textService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(9e9, 9e9))
						overlayframe.Size = UDim2.new(0, math.max(textsize.X + 19, 200), 0, (textsize.Y * 1.2) + 6)
						store.TPString = splitted[1].."/"..(splitted[2] + store.statistics.kills).."/"..(splitted[3] + store.statistics.beds).."/"..(splitted[4] + (victorysaid and 1 or 0)).."/"..(splitted[5] + 1).."/"..(splitted[6] + store.statistics.lagbacks).."/"..(splitted[7] + store.statistics.universalLagbacks).."/"..(splitted[8] + store.statistics.reported)
					until not overlayenabled
				end)
			else
				for i, v in pairs(overlayconnections) do
					if v.Disconnect then pcall(function() v:Disconnect() end) continue end
					if v.disconnect then pcall(function() v:disconnect() end) continue end
				end
				table.clear(overlayconnections)
			end
		end,
		Priority = 2
	})
end)

run(function()
	local ReachDisplay = {}
	local ReachLabel
	ReachDisplay = GuiLibrary.CreateLegitModule({
		Name = "Reach Display",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait(0.4)
						ReachLabel.Text = store.attackReachUpdate > tick() and store.attackReach.." studs" or "0.00 studs"
					until (not ReachDisplay.Enabled)
				end)
			end
		end
	})
	ReachLabel = Instance.new("TextLabel")
	ReachLabel.Size = UDim2.new(0, 100, 0, 41)
	ReachLabel.BackgroundTransparency = 0.5
	ReachLabel.TextSize = 15
	ReachLabel.Font = Enum.Font.Gotham
	ReachLabel.Text = "0.00 studs"
	ReachLabel.TextColor3 = Color3.new(1, 1, 1)
	ReachLabel.BackgroundColor3 = Color3.new()
	ReachLabel.Parent = ReachDisplay.GetCustomChildren()
	local ReachCorner = Instance.new("UICorner")
	ReachCorner.CornerRadius = UDim.new(0, 4)
	ReachCorner.Parent = ReachLabel
end)
task.spawn(function()
	local function createannouncement(announcetab)
		local vapenotifframe = Instance.new("TextButton")
		vapenotifframe.AnchorPoint = Vector2.new(0.5, 0)
		vapenotifframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
		vapenotifframe.Size = UDim2.new(1, -10, 0, 50)
		vapenotifframe.Position = UDim2.new(0.5, 0, 0, -100)
		vapenotifframe.AutoButtonColor = false
		vapenotifframe.Text = ""
		vapenotifframe.Parent = shared.GuiLibrary.MainGui
		local vapenotifframecorner = Instance.new("UICorner")
		vapenotifframecorner.CornerRadius = UDim.new(0, 256)
		vapenotifframecorner.Parent = vapenotifframe
		local vapeicon = Instance.new("Frame")
		vapeicon.Size = UDim2.new(0, 40, 0, 40)
		vapeicon.Position = UDim2.new(0, 5, 0, 5)
		vapeicon.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		vapeicon.Parent = vapenotifframe
		local vapeiconicon = Instance.new("ImageLabel")
		vapeiconicon.BackgroundTransparency = 1
		vapeiconicon.Size = UDim2.new(1, -10, 1, -10)
		vapeiconicon.AnchorPoint = Vector2.new(0.5, 0.5)
		vapeiconicon.Position = UDim2.new(0.5, 0, 0.5, 0)
		vapeiconicon.Image = getcustomasset("vape/assets/VapeIcon.png")
		vapeiconicon.Parent = vapeicon
		local vapeiconcorner = Instance.new("UICorner")
		vapeiconcorner.CornerRadius = UDim.new(0, 256)
		vapeiconcorner.Parent = vapeicon
		local vapetext = Instance.new("TextLabel")
		vapetext.Size = UDim2.new(1, -55, 1, -10)
		vapetext.Position = UDim2.new(0, 50, 0, 5)
		vapetext.BackgroundTransparency = 1
		vapetext.TextScaled = true
		vapetext.RichText = true
		vapetext.Font = Enum.Font.Ubuntu
		vapetext.Text = announcetab.Text
		vapetext.TextColor3 = Color3.new(1, 1, 1)
		vapetext.TextXAlignment = Enum.TextXAlignment.Left
		vapetext.Parent = vapenotifframe
		tweenService:Create(vapenotifframe, TweenInfo.new(0.3), {Position = UDim2.new(0.5, 0, 0, 5)}):Play()
		local sound = Instance.new("Sound")
		sound.PlayOnRemove = true
		sound.SoundId = "rbxassetid://6732495464"
		sound.Parent = workspace
		sound:Destroy()
		vapenotifframe.MouseButton1Click:Connect(function()
			local sound = Instance.new("Sound")
			sound.PlayOnRemove = true
			sound.SoundId = "rbxassetid://6732690176"
			sound.Parent = workspace
			sound:Destroy()
			vapenotifframe:Destroy()
		end)
		game:GetService("Debris"):AddItem(vapenotifframe, announcetab.Time or 20)
	end

	local function rundata(datatab, olddatatab)
		if not olddatatab then
			if datatab.Disabled then 
				coroutine.resume(coroutine.create(function()
					repeat task.wait() until shared.VapeFullyLoaded
					task.wait(1)
					GuiLibrary.SelfDestruct()
				end))
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Vape",
					Text = "Vape is currently disabled, please use vape later.",
					Duration = 30,
				})
			end
			if datatab.KickUsers and datatab.KickUsers[tostring(lplr.UserId)] then
				lplr:Kick(datatab.KickUsers[tostring(lplr.UserId)])
			end
		else
			if datatab.Disabled then 
				coroutine.resume(coroutine.create(function()
					repeat task.wait() until shared.VapeFullyLoaded
					task.wait(1)
					GuiLibrary.SelfDestruct()
				end))
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Vape",
					Text = "Vape is currently disabled, please use vape later.",
					Duration = 30,
				})
			end
			if datatab.KickUsers and datatab.KickUsers[tostring(lplr.UserId)] then
				lplr:Kick(datatab.KickUsers[tostring(lplr.UserId)])
			end
			if datatab.Announcement and datatab.Announcement.ExpireTime >= os.time() and (datatab.Announcement.ExpireTime ~= olddatatab.Announcement.ExpireTime or datatab.Announcement.Text ~= olddatatab.Announcement.Text) then 
				task.spawn(function()
					createannouncement(datatab.Announcement)
				end)
			end	
		end
	end
	task.spawn(function()
		pcall(function()
			if not isfile("vape/Profiles/bedwarsdata.txt") then 
				local commit = "main"
				for i,v in pairs(game:HttpGet("https://github.com/VapeVoidware/vapevoidware"):split("\n")) do 
					if v:find("commit") and v:find("fragment") then 
						local str = v:split("/")[5]
						commit = str:sub(0, str:find('"') - 1)
						break
					end
				end
				writefile("vape/Profiles/bedwarsdata.txt", game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/vapevoidware/"..commit.."/CustomModules/bedwarsdata", true))
			end
			local olddata = readfile("vape/Profiles/bedwarsdata.txt")

			repeat
				local commit = "main"
				for i,v in pairs(game:HttpGet("https://github.com/VapeVoidware/vapevoidware"):split("\n")) do 
					if v:find("commit") and v:find("fragment") then 
						local str = v:split("/")[5]
						commit = str:sub(0, str:find('"') - 1)
						break
					end
				end
				
				local newdata = game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/vapevoidware/"..commit.."/CustomModules/bedwarsdata", true)
				if newdata ~= olddata then 
					rundata(game:GetService("HttpService"):JSONDecode(newdata), game:GetService("HttpService"):JSONDecode(olddata))
					olddata = newdata
					writefile("vape/Profiles/bedwarsdata.txt", newdata)
				end

				task.wait(10)
			until not vapeInjected
		end)
	end)
end)

task.spawn(function()
	repeat task.wait() until shared.VapeFullyLoaded
	if not AutoLeave.Enabled then
		AutoLeave.ToggleButton(false)
	end
end)
function VoidwareFunctions:GetPlayerType(plr)
	if not VoidwareFunctions.WhitelistLoaded then return "DEFAULT", true, 0, "SPECIAL USER", "FFFFFF", true, 0, false, "ABCDEFGH" end
	plr = plr or lplr
	local tab = VoidwareWhitelistStore.Players[plr.UserId]
	if tab == nil then
		return "DEFAULT", true, 0, "SPECIAL USER", "FFFFFF", true, 0, false, "ABCDEFGH"
	else
		tab.Priority = VoidwarePriority[tab.Rank:upper()]
		return tab.Rank, tab.Attackable, tab.Priority, tab.TagText, tab.TagColor, tab.TagHidden, tab.UID, tab.HWID
	end
end
local playerRaycasted = function() return true end
local GetTarget = function() return {} end
GetTarget = function(distance, healthmethod, raycast, npc, team)
	local magnitude, target = (distance or healthmethod and 0 or math.huge), {}
	--[[local function isAlive(plr, healthblacklist)
		plr = plr or lplr
		local alive = false 
		if plr.Character and plr.Character.PrimaryPart and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then 
			alive = true
		end
		if not healthblacklist and alive and plr.Character.Humanoid.Health and plr.Character.Humanoid.Health <= 0 then 
			alive = false
		end
		return alive
	end--]]
	for i,v in playersService:GetPlayers() do 
		if v ~= lplr and isAlive(v) and isAlive(lplr, true) then 
			--[[if not RenderFunctions:GetPlayerType(2) then 
				continue
			end--]]
			if not ({shared.vapewhitelist:get(v)})[2] then
				continue
			end
			if not shared.vapeentity.isPlayerTargetable(v) then 
				continue
			end
			if not playerRaycasted(v) and raycast then 
				continue
			end
			if healthmethod and v.Character.Humanoid.Health < magnitude then 
				magnitude = v.Character.Humanoid.Health
				target.Human = true
				target.RootPart = v.Character.HumanoidRootPart
				target.Humanoid = v.Character.Humanoid
				target.Player = v
				continue
			end 
			local playerdistance = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
			if playerdistance < magnitude then 
				magnitude = playerdistance
				target.Human = true
				target.RootPart = v.Character.HumanoidRootPart
				target.Humanoid = v.Character.Humanoid
				target.Player = v
			end
		end
	end
	return target
end

run(function()
	local DoubleHighJump = {Enabled = false}
	local DoubleHighJumpHeight = {Value = 500}
	local DoubleHighJumpHeight2 = {Value = 500}
	local jumps = 0
	DoubleHighJump = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "DoubleHighJump",
		NoSave = true,
		HoverText = "A very interesting high jump.",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					if entityLibrary.isAlive and lplr.Character.Humanoid.FloorMaterial == Enum.Material.Air or jumps > 0 then 
						DoubleHighJump.ToggleButton(false) 
						return
					end
					for i = 1, 2 do 
						if not entityLibrary.isAlive then
							DoubleHighJump.ToggleButton(false) 
							return  
						end
						if i == 2 and lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then 
							continue
						end
						lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, i == 1 and DoubleHighJumpHeight.Value or DoubleHighJumpHeight2.Value, 0)
						jumps = i
						task.wait(i == 1 and 1 or 0.30)
					end
					task.spawn(function()
						for i = 1, 20 do 
							if entityLibrary.isAlive then 
								lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
							end
						end
					end)
					task.delay(1.6, function() jumps = 0 end)
					if DoubleHighJump.Enabled then
					   DoubleHighJump.ToggleButton(false)
					end
				end)
			else
				VoidwareStore.jumpTick = tick() + 5
			end
		end
	})
	DoubleHighJumpHeight = DoubleHighJump.CreateSlider({
		Name = "First Jump",
		Min = 50,
		Max = 500,
		Default = 500,
		Function = function() end
	})
	DoubleHighJumpHeight2 = DoubleHighJump.CreateSlider({
		Name = "Second Jump",
		Min = 50,
		Max = 450,
		Default = 450,
		Function = function() end
	})
end)
local isEnabled = function() return false end
local function isEnabled(module)
	return GuiLibrary.ObjectsThatCanBeSaved[module] and GuiLibrary.ObjectsThatCanBeSaved[module].Api.Enabled and true or false
end
local isAlive = function() return false end
isAlive = function(plr, nohealth) 
	plr = plr or lplr
	local alive = false
	if plr.Character and plr.Character:FindFirstChildWhichIsA('Humanoid') and plr.Character.PrimaryPart and plr.Character:FindFirstChild('Head') then 
		alive = true
	end
	local success, health = pcall(function() return plr.Character:FindFirstChildWhichIsA('Humanoid').Health end)
	if success and health <= 0 and not nohealth then
		alive = false
	end
	return alive
end
run(function() 
	local Invisibility = {}
	local collideparts = {}
	local invisvisual = {}
	local visualrootcolor = {Hue = 0, Sat = 0, Sat = 0}
	local oldcamoffset = Vector3.zero
	local oldcolor
	Invisibility = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Invisibility',
		HoverText = 'Makes your invisible.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
				repeat task.wait() until ((isAlive(lplr, true) or not Invisibility.Enabled) and (isEnabled('Lobby Check', 'Toggle') == false or store.matchState ~= 0))
				if not Invisibility.Enabled then 
					return 
				end
				task.wait(0.5)
				local anim = Instance.new('Animation')
				anim.AnimationId = 'rbxassetid://11360825341'
				local anim2 = lplr.Character.Humanoid.Animator:LoadAnimation(anim) 
				for i,v in next, lplr.Character:GetDescendants() do 
					if v:IsA('BasePart') and v.CanCollide and v ~= lplr.Character.HumanoidRootPart then 
						v.CanCollide = false 
						table.insert(collideparts, v) 
					end 
				end
				table.insert(Invisibility.Connections, runService.Stepped:Connect(function()
					for i,v in next, collideparts do 
						pcall(function() v.CanCollide = false end)
					end
				end))
				repeat 
					if isEnabled('AnimationPlayer') then 
						GuiLibrary.ObjectsThatCanBeSaved.AnimationPlayerOptionsButton.Api.ToggleButton()
					end
					if isAlive(lplr, true) and isnetworkowner(lplr.Character.HumanoidRootPart) then 
						lplr.Character.HumanoidRootPart.Transparency = (invisvisual.Enabled and 0.6 or 1)
						oldcolor = lplr.Character.HumanoidRootPart.Color
						lplr.Character.HumanoidRootPart.Color = Color3.fromHSV(visualrootcolor.Hue, visualrootcolor.Sat, visualrootcolor.Value)
						anim2:Play(0.1, 9e9, 0.1) 
					elseif Invisibility.Enabled then 
						Invisibility.ToggleButton() 
						break 
					end	
					task.wait()
				until not Invisibility.Enabled
			end)
			else
				for i,v in next, collideparts do 
					pcall(function() v.CanCollide = true end) 
				end
				table.clear(collideparts)
				if isAlive(lplr, true) then 
					lplr.Character.HumanoidRootPart.Transparency = 1 
					lplr.Character.HumanoidRootPart.Color = oldcolor
					task.wait()
				    bedwars.SwordController:swingSwordAtMouse() 
				end
			end
		end
	})
	invisvisual = Invisibility.CreateToggle({
		Name = 'Show Root',
		Function = function(calling)
			pcall(function() visualrootcolor.Object.Visible = calling end) 
		end
	})
	visualrootcolor = Invisibility.CreateColorSlider({
		Name = 'Root Color',
		Function = function() end
	})
	visualrootcolor.Object.Visible = false
end)

task.spawn(function()
    local tweenmodules = {"BedTP", "EmeraldTP", "DiamondTP", "MiddleTP", "Autowin", "PlayerTP"}
    local tweening = false
    repeat
    for i,v in pairs(tweenmodules) do
        pcall(function()
        if GuiLibrary.ObjectsThatCanBeSaved[v.."OptionsButton"].Api.Enabled then
            tweening = true
        end
        end)
    end
    VoidwareStore.Tweening = tweening
    tweening = false
    task.wait()
  until not vapeInjected
end)
local vapeAssert = function(argument, title, text, duration, hault, moduledisable, module) 
	if not argument then
    local suc, res = pcall(function()
    local notification = GuiLibrary.CreateNotification(title or "Voidware", text or "Failed to call function.", duration or 20, "assets/WarningNotification.png")
    notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
    notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
    if moduledisable and (module and GuiLibrary.ObjectsThatCanBeSaved[module.."OptionsButton"].Api.Enabled) then GuiLibrary.ObjectsThatCanBeSaved[module.."OptionsButton"].Api.ToggleButton(false) end
    end)
    if hault then while true do task.wait() end end
end
end
local function GetMagnitudeOf2Objects(part, part2, bypass)
	local magnitude, partcount = 0, 0
	if not bypass then 
		local suc, res = pcall(function() return part.Position end)
		partcount = suc and partcount + 1 or partcount
		suc, res = pcall(function() return part2.Position end)
		partcount = suc and partcount + 1 or partcount
	end
	if partcount > 1 or bypass then 
		magnitude = bypass and (part - part2).magnitude or (part.Position - part2.Position).magnitude
	end
	return magnitude
end
local function GetTopBlock(position, smart, raycast, customvector)
	position = position or isAlive(lplr, true) and lplr.Character.HumanoidRootPart.Position
	if not position then 
		return nil 
	end
	if raycast and not workspace:Raycast(position, Vector3.new(0, -2000, 0), store.blockRaycast) then
	    return nil
    end
	local lastblock = nil
	for i = 1, 500 do 
		local newray = workspace:Raycast(lastblock and lastblock.Position or position, customvector or Vector3.new(0.55, 999999, 0.55), store.blockRaycast)
		local smartest = newray and smart and workspace:Raycast(lastblock and lastblock.Position or position, Vector3.new(0, 5.5, 0), store.blockRaycast) or not smart
		if newray and smartest then
			lastblock = newray
		else
			break
		end
	end
	return lastblock
end
local function FindEnemyBed(maxdistance, highest)
	local target = nil
	local distance = maxdistance or math.huge
	local whitelistuserteams = {}
	local badbeds = {}
	if not lplr:GetAttribute("Team") then return nil end
	for i,v in pairs(playersService:GetPlayers()) do
		if v ~= lplr then
			local type, attackable = shared.vapewhitelist:get(v)
			if not attackable then
				whitelistuserteams[v:GetAttribute("Team")] = true
			end
		end
	end
	for i,v in pairs(collectionService:GetTagged("bed")) do
			local bedteamstring = string.split(v:GetAttribute("id"), "_")[1]
			if whitelistuserteams[bedteamstring] ~= nil then
			   badbeds[v] = true
		    end
	    end
	for i,v in pairs(collectionService:GetTagged("bed")) do
		if v:GetAttribute("id") and v:GetAttribute("id") ~= lplr:GetAttribute("Team").."_bed" and badbeds[v] == nil and lplr.Character and lplr.Character.PrimaryPart then
			if v:GetAttribute("NoBreak") or v:GetAttribute("PlacedByUserId") and v:GetAttribute("PlacedByUserId") ~= 0 then continue end
			local magdist = GetMagnitudeOf2Objects(lplr.Character.PrimaryPart, v)
			if magdist < distance then
				target = v
				distance = magdist
			end
		end
	end
	local coveredblock = highest and target and GetTopBlock(target.Position, true)
	if coveredblock then
		target = coveredblock.Instance
	end
	return target
end
local function FindTeamBed()
	local bedstate, res = pcall(function()
		return lplr.leaderstats.Bed.Value
	end)
	return bedstate and res and res ~= nil and res == "✅"
end
local function FindItemDrop(item)
	local itemdist = nil
	local dist = math.huge
	local function abletocalculate() return lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") end
    for i,v in pairs(collectionService:GetTagged("ItemDrop")) do
		if v and v.Name == item and abletocalculate() then
			local itemdistance = GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v)
			if itemdistance < dist then
			itemdist = v
			dist = itemdistance
		end
		end
	end
	return itemdist
end
local function FindTarget(dist, blockRaycast, includemobs, healthmethod)
	local sort, entity = healthmethod and math.huge or dist or math.huge, {}
	local function abletocalculate() return lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") end
	local sortmethods = {Normal = function(entityroot, entityhealth) return abletocalculate() and GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, entityroot) < sort end, Health = function(entityroot, entityhealth) return abletocalculate() and entityhealth < sort end}
	local sortmethod = healthmethod and "Health" or "Normal"
	local function raycasted(entityroot) return abletocalculate() and blockRaycast and workspace:Raycast(entityroot.Position, Vector3.new(0, -2000, 0), store.blockRaycast) or not blockRaycast and true or false end
	for i,v in pairs(playersService:GetPlayers()) do
		if v ~= lplr and abletocalculate() and isAlive(v) and ({VoidwareFunctions:GetPlayerType(v)})[2] and v.Team ~= lplr.Team then
			if not ({whitelist:get(v)})[2] then 
				continue
			end
			if sortmethods[sortmethod](v.Character.HumanoidRootPart, v.Character:GetAttribute("Health") or v.Character.Humanoid.Health) and raycasted(v.Character.HumanoidRootPart) then
				sort = healthmethod and v.Character.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v.Character.HumanoidRootPart)
				entity.Player = v
				entity.Human = true 
				entity.RootPart = v.Character.HumanoidRootPart
				entity.Humanoid = v.Character.Humanoid
			end
		end
	end
	if includemobs then
		local maxdistance = dist or math.huge
		for i,v in pairs(store.pots) do
			if abletocalculate() and v.PrimaryPart and GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v.PrimaryPart) < maxdistance then
			entity.Player = {Character = v, Name = "PotEntity", DisplayName = "PotEntity", UserId = 1}
			entity.Human = false
			entity.RootPart = v.PrimaryPart
			entity.Humanoid = {Health = 1, MaxHealth = 1}
			end
		end
		for i,v in pairs(collectionService:GetTagged("DiamondGuardian")) do 
			if v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health and abletocalculate() then
				if sortmethods[sortmethod](v.PrimaryPart, v.Humanoid.Health) and raycasted(v.PrimaryPart) then
				sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v.PrimaryPart)
				entity.Player = {Character = v, Name = "DiamondGuardian", DisplayName = "DiamondGuardian", UserId = 1}
				entity.Human = false
				entity.RootPart = v.PrimaryPart
				entity.Humanoid = v.Humanoid
				end
			end
		end
		for i,v in pairs(collectionService:GetTagged("GolemBoss")) do
			if v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health and abletocalculate() then
				if sortmethods[sortmethod](v.PrimaryPart, v.Humanoid.Health) and raycasted(v.PrimaryPart) then
				sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v.PrimaryPart)
				entity.Player = {Character = v, Name = "Titan", DisplayName = "Titan", UserId = 1}
				entity.Human = false
				entity.RootPart = v.PrimaryPart
				entity.Humanoid = v.Humanoid
				end
			end
		end
		for i,v in pairs(collectionService:GetTagged("Drone")) do
			local plr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
			if plr and plr ~= lplr and plr.Team and lplr.Team and plr.Team ~= lplr.Team and ({VoidwareFunctions:GetPlayerType(plr)})[2] and abletocalculate() and v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health then
				if sortmethods[sortmethod](v.PrimaryPart, v.Humanoid.Health) and raycasted(v.PrimaryPart) then
					sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v.PrimaryPart)
					entity.Player = {Character = v, Name = "Drone", DisplayName = "Drone", UserId = 1}
					entity.Human = false
					entity.RootPart = v.PrimaryPart
					entity.Humanoid = v.Humanoid
				end
			end
		end
		for i,v in pairs(collectionService:GetTagged("Monster")) do
			if v:GetAttribute("Team") ~= lplr:GetAttribute("Team") and abletocalculate() and v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health then
				if sortmethods[sortmethod](v.PrimaryPart, v.Humanoid.Health) and raycasted(v.PrimaryPart) then
				sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v.PrimaryPart)
				entity.Player = {Character = v, Name = "Monster", DisplayName = "Monster", UserId = 1}
				entity.Human = false
				entity.RootPart = v.PrimaryPart
				entity.Humanoid = v.Humanoid
			end
		end
	end
    end
    return entity
end
run(function()
	local Autowin = {Enabled = false}
	local AutowinNotification = {Enabled = true}
	local bedtween
	local playertween
	Autowin = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Autowin",
		ExtraText = function() return store.queueType :find("5v5") and "BedShield" or "Normal" end,
		Function = function(callback)
			if callback then
				task.spawn(function()
					if store.matchState == 0 then repeat task.wait() until store.matchState ~= 0 or not Autowin.Enabled end
					if not shared.VapeFullyLoaded then repeat task.wait() until shared.VapeFullyLoaded or not Autowin.Enabled end
					if not Autowin.Enabled then return end
					vapeAssert(not store.queueType:find("skywars"), "Autowin", "Skywars not supported.", 7, true, true, "Autowin")
					if isAlive(lplr, true) then
						lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
						lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
					end
					table.insert(Autowin.Connections, runService.Heartbeat:Connect(function()
						pcall(function()
						if not isnetworkowner(lplr.Character.HumanoidRootPart) and (FindEnemyBed() and GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, FindEnemyBed()) > 75 or not FindEnemyBed()) then
							if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled and not VoidwareStore.GameFinished then
								lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
								lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
							end
						end
					end)
					end))
					table.insert(Autowin.Connections, lplr.CharacterAdded:Connect(function()
						if not isAlive(lplr, true) then repeat task.wait() until isAlive(lplr, true) end
						local bed = FindEnemyBed()
						if bed and (bed:GetAttribute("BedShieldEndTime") and bed:GetAttribute("BedShieldEndTime") < workspace:GetServerTimeNow() or not bed:GetAttribute("BedShieldEndTime")) then
						bedtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {CFrame = CFrame.new(bed.Position) + Vector3.new(0, 10, 0)})
						task.wait(0.1)
						bedtween:Play()
						bedtween.Completed:Wait()
						task.spawn(function()
						task.wait(1.5)
						local magnitude = GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, bed)
						if magnitude >= 50 and FindTeamBed() and Autowin.Enabled then
							lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
							lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
						end
						end)
						if AutowinNotification.Enabled then
							local bedname = VoidwareStore.bedtable[bed] or "unknown"
							task.spawn(InfoNotification, "Autowin", "Destroying "..bedname:lower().." team's bed", 5)
						end
						if not isEnabled("Nuker") then
							--GuiLibrary.ObjectsThatCanBeSaved.NukerOptionsButton.Api.ToggleButton(false)
						end
						repeat task.wait() until FindEnemyBed() ~= bed or not isAlive()
						if FindTarget(45, store.blockRaycast).RootPart and isAlive() then
							if AutowinNotification.Enabled then
								local team = VoidwareStore.bedtable[bed] or "unknown"
								task.spawn(InfoNotification, "Autowin", "Killing "..team:lower().." team's teamates", 5)
							end
							repeat
							local target = FindTarget(45, store.blockRaycast)
							if not target.RootPart then break end
							playertween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.75), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
							playertween:Play()
							task.wait()
							until not FindTarget(45, store.blockRaycast).RootPart or not Autowin.Enabled or not isAlive()
						end
						if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled then
							lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
							lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
						end
						elseif FindTarget(nil, store.blockRaycast).RootPart then
							task.wait()
							local target = FindTarget(nil, store.blockRaycast)
							playertween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
							playertween:Play()
							if AutowinNotification.Enabled then
								task.spawn(InfoNotification, "Autowin", "Killing "..target.Player.DisplayName.." ("..(target.Player.Team and target.Player.Team.Name or "neutral").." Team)", 5)
							end
							playertween.Completed:Wait()
							if not Autowin.Enabled then return end
								if FindTarget(50, store.blockRaycast).RootPart and isAlive() then
									repeat
									target = FindTarget(50, store.blockRaycast)
									if not target.RootPart or not isAlive() then break end
									playertween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.75), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
									playertween:Play()
									task.wait()
									until not FindTarget(50, store.blockRaycast).RootPart or not Autowin.Enabled or not isAlive()
								end
							if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled then
								lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
								lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
							end
						else
						if VoidwareStore.GameFinished then return end
						lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
						lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
						end
					end))
					table.insert(Autowin.Connections, lplr.CharacterAdded:Connect(function()
						if not isAlive(lplr, true) then repeat task.wait() until isAlive(lplr, true) end
						if not VoidwareStore.GameFinished then return end
						local oldpos = lplr.Character.HumanoidRootPart.CFrame
						repeat 
						lplr.Character.HumanoidRootPart.CFrame = oldpos
						task.wait()
						until not isAlive(lplr, true) or not Autowin.Enabled
					end))
				end)
			else
				pcall(function() playertween:Cancel() end)
				pcall(function() bedtween:Cancel() end)
			end
		end,
		HoverText = "best paid autowin 2023!1!!! rel11!11!1"
	})
end)

run(function()
	local PlayerLevelSet = {}
	local PlayerLevel = {Value = 100}
	PlayerLevelSet = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'SetPlayerLevel',
		HoverText = 'Sets your player level to 100 (client sided)',
		Function = function(calling)
			if calling then 
				warningNotification("SetPlayerLevel", "This is client sided (only u will see the new level)", 3)
				game.Players.LocalPlayer:SetAttribute("PlayerLevel", PlayerLevel.Value)
			end
		end
	})
	PlayerLevel = PlayerLevelSet.CreateSlider({
		Name = 'Sets your desired player level',
		Function = function() game.Players.LocalPlayer:SetAttribute("PlayerLevel", PlayerLevel.Value) end,
		Min = 1,
		Max = 100,
		Default = 100
	})
end)

local GetAllTargets = function() return {} end
GetAllTargets = function(distance, sort)
	local targets = {}
	for i,v in playersService:GetPlayers() do 
		if v ~= lplr and isAlive(v) and isAlive(lplr, true) then 
			--if not RenderFunctions:GetPlayerType(2) then 
				--continue
			--end--]]
			if not ({whitelist:get(v)})[2] then 
				continue
			end
			if not entityLibrary.isPlayerTargetable(v) then 
				continue
			end
			local playerdistance = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
			if playerdistance <= (distance or math.huge) then 
				table.insert(targets, {Human = true, RootPart = v.Character.PrimaryPart, Humanoid = v.Character.Humanoid, Player = v})
			end
		end
	end
	if sort then 
		table.sort(targets, sort)
	end
	return targets
end

local dumptable = function() return {} end
dumptable = function(tab, tabtype, sortfunction)
	local data = {}
	for i,v in next, tab do
		local tabtype = tabtype and tabtype == 1 and i or v
		table.insert(data, tabtype)
	end
	if sortfunction then
		table.sort(data, sortfunction)
	end
	return data
end

local tweenInProgress = function() end
tweenInProgress = function()
	if store.autowinning then 
		return true 
	end
	for i,v in next, ({'BedTP', 'PlayerTP', 'EmeraldTP', 'DiamondTP'}) do 
		if isEnabled(v) then 
			return true
		end
	end
	return false
end

function VoidwareFunctions:LoadTime()
	if shared.VapeFullyLoaded then
		return (tick() - VoidwareStore.TimeLoaded)
	else
		return 0
	end
end
run(function()
	local middletween
	local MiddleTP = {Enabled = false}
	MiddleTP = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "MiddleTP",
		NoSave = true,
		HoverText = "Tween/Teleport to the middle position.",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if VoidwareFunctions:LoadTime() <= 0.1 or isEnabled("InfiniteFly") then
						MiddleTP.ToggleButton(false)
						return
					end
					pcall(function()
						middletween = workspace:FindFirstChild("RespawnView")
						vapeAssert(middletween, "MiddleTP", "Middle not Found.", 7, true, true, "MiddleTP")
						if store.queueType:find("skywars") and getItem("telepearl") and isAlive() then
							local pearl = getItem("telepearl")
							local projectileexploit = false
							if isEnabled("ProjectileExploit") then GuiLibrary.ObjectsThatCanBeSaved.ProjectileExploitOptionsButton.Api.ToggleButton(false) projectileexploit = true end
							local raycast = workspace:Raycast(middletween.Position, Vector3.new(0, -2000, 0), store.blockRaycast)
							raycast = raycast and raycast.Position or middletween.Position
							switchItem(pearl.tool)
							local fired = bedwars.Client:Get(bedwars.ProjectileRemote):CallServerAsync(pearl.tool, "telepearl", "telepearl", raycast + Vector3.new(0, 3, 0), raycast + Vector3.new(0, 3, 0), Vector3.new(0, -1, 0), httpService:GenerateGUID(), {drawDurationSeconds = 3}, workspace:GetServerTimeNow() - 0.045)
							if MiddleTP.Enabled then
								MiddleTP.ToggleButton(false)
							end
							if not isEnabled("ProjectileExploit") and projectileexploit then GuiLibrary.ObjectsThatCanBeSaved.ProjectileExploitOptionsButton.Api.ToggleButton(false) end
							if fired then InfoNotification("MiddleTP", "Teleported!") end
						else
							vapeAssert(FindTeamBed(), "MiddleTP", store.queueType:find("skywars") and "Telepearl not Found." or "Team Bed not Found.", 7, true, true, "MiddleTP")
							if isAlive(lplr, true) then
								lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
								lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
							end
							table.insert(MiddleTP.Connections, lplr.CharacterAdded:Connect(function()
								if not isAlive() then repeat task.wait() until isAlive() end
								if not MiddleTP.Enabled then return end
								task.wait(0.2)
								local raycast = workspace:Raycast(middletween.Position, Vector3.new(0, -2000, 0), store.blockRaycast)
								raycast = raycast and raycast.Position or middletween.Position
								middletween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.65, Enum.EasingStyle.Linear), {CFrame = CFrame.new(raycast) + Vector3.new(0, 5, 0)})
								middletween:Play()
								middletween.Completed:Wait()
								if MiddleTP.Enabled then
									MiddleTP.ToggleButton(false)
								end
								InfoNotification("MiddleTP", "Teleported!")
							end))
						end
					end)
				end)
			end
		end,
		HoverText = "Teleport to the middle."
	})
end)

run(function()
	local GetEnumItems = function() return {} end
	GetEnumItems = function(enum)
		local fonts = {}
		for i,v in next, Enum[enum]:GetEnumItems() do 
			table.insert(fonts, v.Name) 
		end
		return fonts
	end
	local canRespawn = function() end
	canRespawn = function()
		local success, response = pcall(function() 
			return lplr.leaderstats.Bed.Value == '✅' 
		end)
		return success and response 
	end
	local PlayerTP = {}
	local PlayerTPTeleport = {Value = 'Respawn'}
	local PlayerTPSort = {Value = 'Distance'}
	local PlayerTPMethod = {Value = 'Linear'}
	local PlayerTPAutoSpeed = {}
	local PlayerTPSpeed = {Value = 200}
	local PlayerTPTarget = {Value = ''}
	local playertween
	local oldmovefunc
	local bypassmethods = {
		Respawn = function() 
			if isEnabled('InfiniteFly') then 
				return 
			end
			if not canRespawn() then 
				return 
			end
			for i = 1, 30 do 
				if isAlive(lplr, true) and lplr.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
					lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(0.1)
			local target = GetTarget(nil, PlayerTPSort.Value == 'Health', true)
			if target.RootPart == nil or not PlayerTP.Enabled then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (PlayerTPAutoSpeed.Enabled and ((target.RootPart.Position - localposition).Magnitude / 470) + 0.001 * 2 or (PlayerTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (PlayerTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[PlayerTPMethod.Value])
			playertween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = target.RootPart.CFrame}) 
			playertween:Play() 
			playertween.Completed:Wait()
		end,
		Instant = function() 
			local target = GetTarget(nil, PlayerTPSort.Value == 'Health', true)
			if target.RootPart == nil then 
				return PlayerTP.ToggleButton()
			end
			lplr.Character.HumanoidRootPart.CFrame = (target.RootPart.CFrame + Vector3.new(0, 5, 0)) 
			PlayerTP.ToggleButton()
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character.Humanoid.FloorMaterial == Enum.Material.Air then 
				errorNotification('PlayerTP', 'Recall ability not available.', 7)
				return 
			end
			if not bedwars.AbilityController:canUseAbility('recall') then 
				errorNotification('PlayerTP', 'Recall ability not available.', 7)
				return
			end
			pcall(function()
				oldmovefunc = require(lplr.PlayerScripts.PlayerModule).controls.moveFunction 
				require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = function() end
			end)
			bedwars.AbilityController:useAbility('recall')
			local teleported
			table.insert(PlayerTP.Connections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function() teleported = true end))
			repeat task.wait() until teleported or not PlayerTP.Enabled or not isAlive(lplr, true) 
			task.wait()
			local target = GetTarget(nil, PlayerTPSort.Value == 'Health', true)
			if target.RootPart == nil or not isAlive(lplr, true) or not PlayerTP.Enabled then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (PlayerTPAutoSpeed.Enabled and ((target.RootPart.Position - localposition).Magnitude / 1000) + 0.001 or (PlayerTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (PlayerTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[PlayerTPMethod.Value])
			playertween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = target.RootPart.CFrame}) 
			playertween:Play() 
			playertween.Completed:Wait()
		end
	}
	PlayerTP = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'PlayerTP',
		HoverText = 'Tweens you to a nearby target.',
		Function = function(calling)
			if calling then 
				if isEnabled('FullDisabler') and isAlive(lplr, true) then 
					return bypassmethods.Instant()
				end
				if isEnabled('FullDisabler') then 
					return PlayerTP.ToggleButton()
				end
				if GetTarget(nil, PlayerTPSort.Value == 'Health', true).RootPart and shared.VapeFullyLoaded then 
					bypassmethods[isAlive() and PlayerTPTeleport.Value or 'Respawn']() 
				end
				if PlayerTP.Enabled then 
					PlayerTP.ToggleButton()
				end
			else
				pcall(function() playertween:Disconnect() end)
				if oldmovefunc then 
					pcall(function() require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = oldmovefunc end)
				end
				oldmovefunc = nil
			end
		end
	})
	PlayerTPTeleport = PlayerTP.CreateDropdown({
		Name = 'Teleport Method',
		List = {'Respawn', 'Recall'},
		Function = function() end
	})
	PlayerTPAutoSpeed = PlayerTP.CreateToggle({
		Name = 'Auto Speed',
		HoverText = 'Automatically uses a "good" tween speed.',
		Default = true,
		Function = function(calling) 
			if calling then 
				pcall(function() PlayerTPSpeed.Object.Visible = false end) 
			else 
				pcall(function() PlayerTPSpeed.Object.Visible = true end) 
			end
		end
	})
	PlayerTPSpeed = PlayerTP.CreateSlider({
		Name = 'Tween Speed',
		Min = 20, 
		Max = 350,
		Default = 200,
		Function = function() end
	})
	PlayerTPMethod = PlayerTP.CreateDropdown({
		Name = 'Teleport Method',
		List = GetEnumItems('EasingStyle'),
		Function = function() end
	})
	PlayerTPSpeed.Object.Visible = false
	local Credits
	Credits = PlayerTP.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Render'
    })
end)

local function GetClanTag(plr)
	local atr, res = pcall(function()
		return plr:GetAttribute("ClanTag")
	end)
	return atr and res ~= nil and res
end

run(function()
	local ClanDetector = {Enabled = false}
	local alreadyclanchecked = {}
	local blacklistedclans = {}
	local function detectblacklistedclan(plr)
		if not plr:GetAttribute("LobbyConnected") then repeat task.wait() until plr:GetAttribute("LobbyConnected") end
		for i2, v2 in pairs(blacklistedclans.ObjectList) do
			if GetClanTag(plr) == v2 and alreadyclanchecked[plr] == nil then
				warningNotification("ClanDetector", plr.DisplayName.. " is in the "..v2.." clan!", 15)
				alreadyclanchecked[plr] = true
			end
		end
	end
	ClanDetector = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ClanDetector",
		Approved = true,
		Function = function(callback)
			if callback then
				task.spawn(function()
				for i,v in pairs(playersService:GetPlayers()) do
					task.spawn(function()
					 if v ~= lplr then
						 task.spawn(detectblacklistedclan, v)
					 end
					end)
				end
				table.insert(ClanDetector.Connections, playersService.PlayerAdded:Connect(function(v)
					task.spawn(detectblacklistedclan, v)
				end))
			end)
			end
		end,
		HoverText = "detect players in certain clans (customizable)"
	})
	blacklistedclans = ClanDetector.CreateTextList({
		Name = "Clans",
		TempText = "clans to detect",
		AddFunction = function() 
		if ClanDetector.Enabled then
			ClanDetector.ToggleButton(false)
			ClanDetector.ToggleButton(false)
		end
		end
	})
end)

run(function() -- credits to _dremi on discord for finding the method (godpaster and the other skid skidded it from him)
	local SetEmote = {}
	local SetEmoteList = {Value = ''}
	local oldemote
	local emo2 = {}
	local credits
	SetEmote = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'SetEmote',
		HoverText = "Sets your emote",
		Function = function(calling)
			if calling then
				oldemote = lplr:GetAttribute('EmoteTypeSlot1')
				lplr:SetAttribute('EmoteTypeSlot1', emo2[SetEmoteList.Value])
			else
				if oldemote then 
					lplr:GetAttribute('EmoteTypeSlot1', oldemote)
					oldemote = nil 
				end
			end
		end
	})
	local emo = {}
	for i,v in pairs(bedwars.EmoteMeta) do 
		table.insert(emo, v.name)
		emo2[v.name] = i
	end
	table.sort(emo, function(a, b) return a:lower() < b:lower() end)
	credits = SetEmote.CreateCredits({
        Name = 'CreditsButtonInstance',
        ButtonText = 'Show Credits',
        Credits = 'Render'
    })
	SetEmoteList = SetEmote.CreateDropdown({
		Name = 'Emote',
		List = emo,
		Function = function(emote)
			if SetEmote.Enabled then 
				lplr:SetAttribute('EmoteTypeSlot1', emo2[emote])
			end
		end
	})
end)

run(function()
	local NoEmoteWheel = {}
	local emoting
	local credits
	NoEmoteWheel = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'NoEmoteWheel',
		HoverText = 'Removes the old emote wheel and uses the first\nemote in your emote slot.',
		Function = function(calling)
			if calling then 
				table.insert(NoEmoteWheel.Connections, lplr.PlayerGui.ChildAdded:Connect(function(v)
					local anim
					if tostring(v) == 'RoactTree' and isAlive(lplr, true) and not emoting then 
						v:WaitForChild('1'):WaitForChild('1')
						if not v['1']:IsA('ImageButton') then 
							return 
						end
						v['1'].Visible = false
						emoting = true
						bedwars.Client:Get('Emote'):CallServer({emoteType = lplr:GetAttribute('EmoteTypeSlot1')})
						local oldpos = lplr.Character.HumanoidRootPart.Position 
						if tostring(lplr:GetAttribute('EmoteTypeSlot1')):lower():find('nightmare') then 
							anim = Instance.new('Animation')
							anim.AnimationId = 'rbxassetid://9191822700'
							anim = lplr.Character.Humanoid.Animator:LoadAnimation(anim)
							task.spawn(function()
								repeat 
									anim:Play()
									anim.Completed:Wait()
								until not anim
							end)
						end
						repeat task.wait() until ((lplr.Character.HumanoidRootPart.Position - oldpos).Magnitude >= 0.3 or not isAlive(lplr, true))
						pcall(function() anim:Stop() end)
						anim = nil
						emoting = false
						bedwars.Client:Get('EmoteCancelled'):CallServer({emoteType = lplr:GetAttribute('EmoteTypeSlot1')})
					end
				end))
			end
		end
	})
	credits = NoEmoteWheel.CreateCredits({
        Name = 'CreditsButtonInstance',
        ButtonText = 'Show Credits',
        Credits = 'Vape+ Booster'
    })
end)

run(function()
	local GetHost = {Enabled = false}
	GetHost = GuiLibrary.ObjectsThatCanBeSaved.VoidwareDevWindow.Api.CreateOptionsButton({
		Name = "GetHost",
		HoverText = ":troll:",
		Function = function(callback) 
			if callback then
				task.spawn(function()
					warningNotification("GetHost", "This module is only for show. None of the settings will work.", 5)
					game.Players.LocalPlayer:SetAttribute("CustomMatchRole", "host")
				end)
			end
		end
	})
end)

local function warningNotification(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/InfoNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(255, 0, 255)
		return frame
	end)
	return (suc and res)
end


local function warnAction(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/WarningNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(255, 0, 0)
		return frame
	end)
	return (suc and res)
end

local function Action(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/InfoNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(0, 255, 255)
		return frame
	end)
	return (suc and res)
end

local function WinW(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/InfoNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(50, 205, 50)
		return frame
	end)
	return (suc and res)
end

--[[run(function()
	local deb
	local con
	local client = require(game:GetService("ReplicatedStorage"):WaitForChild("TS"):WaitForChild("remotes")).default.Client
	local lplr = game:GetService("Players").LocalPlayer
	function fetchBed()
		local selectedBed
		for _, bed in next, workspace:GetChildren() do
			if bed.Name == "bed" and not selectedBed then
				local Blanket = bed:WaitForChild("Blanket")
				
				if lplr.TeamColor ~= Blanket.BrickColor then
					selectedBed = bed
				end
			end
		end
		return (selectedBed)
	end
	deb = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "AutoWin v2 [Duels recommended]",
		HoverText = "Duels AutoWin",
		Function = function(callback)
			if callback then
				lplr = game:GetService("Players").LocalPlayer
				chr = lplr.Character
				if lplr and chr then
					local bed = fetchBed()
					local tppos2 = bed.Position + Vector3.new(0, 10, 0)
					local hum = chr:FindFirstChildWhichIsA("Humanoid")
					con = lplr.CharacterAdded:Connect(function(chr)
						con:Disconnect()
						task.wait(.5)
						local root = chr:WaitForChild("HumanoidRootPart")
						local check = (lplr:GetAttribute("LastTeleported") - lplr:GetAttribute("SpawnTime")) < 1
						con = game:GetService("RunService").Heartbeat:Connect(function(dt)
							local dist = ((check and 700 or 1200) * dt)
							if (tppos2 - root.CFrame.p).Magnitude > dist then
								root.CFrame = root.CFrame + (tppos2 - root.CFrame.p).Unit * dist
								local yes = (tppos2 - root.CFrame.p).Unit * 20
								root.Velocity = Vector3.new(yes.X, root.Velocity.Y, yes.Z)
								task.wait(3)
								for i, v in pairs(game:GetService("Players"):GetChildren()) do
									if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Team ~= game.Players.LocalPlayer.Team then
										print(v.Name)
										repeat wait(0.2)
										game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
										until v.Character.Humanoid.Health == 0 or not v.Character:FindFirstChild("Humanoid")
									end
								end
							else
								root.CFrame = root.CFrame + (tppos2 - root.CFrame.p)
							end
						end)
						repeat
							task.wait()
						until (tppos2 - root.CFrame.p).Magnitude < 10
						con:Disconnect()
					end)
					for _ = 1, 10, 1 do
						hum:ChangeState(Enum.HumanoidStateType.Dead)
						hum.Health = 0
					end
				end
				deb.ToggleButton(false)
			end
		end
	})
end)--]]

--[[run(function() 
	local TeleportBed
	local bedConnection
	local client = require(game:GetService("ReplicatedStorage"):WaitForChild("TS"):WaitForChild("remotes")).default.Client
	local lplr = game:GetService("Players").LocalPlayer
	local teleportMethod = "DEFAULT"
	pcall(function()
		local initialPosition = lplr.Character and lplr.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0)
	end)

	local teleportSpeed = 100 

	function fetchBed()
		local selectedBed
		for _, bed in next, workspace:GetChildren() do
			if bed.Name == "bed" and not selectedBed then
				local Blanket = bed:WaitForChild("Blanket")
				if lplr.TeamColor ~= Blanket.BrickColor then
					selectedBed = bed
				end
			end
		end
		return selectedBed
	end

	function teleportToBed()
		local bed = fetchBed()
		if not bed then return end 
		local teleportPosition = bed.Position + Vector3.new(0, 10, 0)
		local character = lplr.Character
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
		
		if not humanoid then return end 
		
		if teleportMethod == "DEFAULT" then
			for _ = 1, 10 do
				humanoid.Health = 0
				humanoid:ChangeState(Enum.HumanoidStateType.Dead)
			end
	
			local characterAddedConnection
			characterAddedConnection = lplr.CharacterAdded:Connect(function(newCharacter)
				humanoid = newCharacter:WaitForChild("Humanoid")
				local root = newCharacter:WaitForChild("HumanoidRootPart")
				local check = (lplr:GetAttribute("LastTeleported") - lplr:GetAttribute("SpawnTime")) < 1
	
				task.wait(0.35)
	
				bedConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
					local dist = (teleportSpeed * dt)
					if (teleportPosition - root.Position).Magnitude > dist then
						root.CFrame = root.CFrame + (teleportPosition - root.Position).Unit * dist
						root.Velocity = (teleportPosition - root.Position).Unit * 20
					else
						root.CFrame = CFrame.new(teleportPosition)
					end
				end)
	
				repeat
					task.wait()
				until (teleportPosition - root.Position).Magnitude < 10
	
				bedConnection:Disconnect()
				characterAddedConnection:Disconnect()
			end)		
		end
	end
	
	TeleportBed = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "BedTeleport v2",
		HoverText = "Randomly teleports you to a bed",
		Function = function(callback)
			if callback then
				lplr = game:GetService("Players").LocalPlayer
				chr = lplr.Character
				if lplr and chr then
					teleportToBed()
				end
				TeleportBed.ToggleButton(false)
			end
		end
	})

	BedTeleportSlider = TeleportBed.CreateSlider({
		Name = "Bed Teleport Speed",
		Min = 1,
		Max = 1500,
		Default = 1200,
		Function = function(val) 
			teleportSpeed = val
		end
	})
	
	TeleportMethodDropdown = TeleportBed.CreateDropdown({
		Name = "Teleport Method",
		Function = function(value)
			teleportMethod = value
		end,
		List = {"DEFAULT"}
	})
end)--]]	

--[[local WaterMark = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
	Name = "WaterMark",
	Function = function(callback)
		if callback then 
			local plrgui = game.Players.LocalPlayer.PlayerGui
			local Converted = {
				["_ScreenGui"] = Instance.new("ScreenGui");
				["_Frame"] = Instance.new("Frame");
				["_Frame1"] = Instance.new("Frame");
				["_UIGradient"] = Instance.new("UIGradient");
				["_LocalScript"] = Instance.new("LocalScript");
				["_UIStroke"] = Instance.new("UIStroke");
				["_TextLabel"] = Instance.new("TextLabel");
				["_LocalScript1"] = Instance.new("LocalScript");
			}
			
			Converted["_ScreenGui"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			Converted["_ScreenGui"].Parent = plrgui
			Converted["_ScreenGui"].Name = "WatermarkVoidWareLol"
			
			Converted["_Frame"].BackgroundColor3 = Color3.fromRGB(17.00000088661909, 17.00000088661909, 17.00000088661909)
			Converted["_Frame"].BorderColor3 = Color3.fromRGB(0, 0, 0)
			Converted["_Frame"].BorderSizePixel = 0
			Converted["_Frame"].Position = UDim2.new(0.0150891636, 0, 0.0564516112, 0)
			Converted["_Frame"].Size = UDim2.new(0.156378597, 0, 0.0483870953, 0)
			Converted["_Frame"].Parent = Converted["_ScreenGui"]
			
			Converted["_Frame1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Converted["_Frame1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
			Converted["_Frame1"].BorderSizePixel = 0
			Converted["_Frame1"].Size = UDim2.new(1, 0, 0.200000003, 0)
			Converted["_Frame1"].Parent = Converted["_Frame"]
			
			Converted["_UIGradient"].Parent = Converted["_Frame1"]
			
			Converted["_UIStroke"].Color = Color3.fromRGB(15.00000100582838, 15.00000100582838, 15.00000100582838)
			Converted["_UIStroke"].LineJoinMode = Enum.LineJoinMode.Miter
			Converted["_UIStroke"].Thickness = 2
			Converted["_UIStroke"].Parent = Converted["_Frame"]
			
			Converted["_TextLabel"].Font = Enum.Font.Sarpanch
			Converted["_TextLabel"].Text = "VoidWare | FPS | .gg/e2HUEAmsuA"
			Converted["_TextLabel"].TextColor3 = Color3.fromRGB(255, 255, 255)
			Converted["_TextLabel"].TextScaled = true
			Converted["_TextLabel"].TextSize = 14
			Converted["_TextLabel"].TextWrapped = true
			Converted["_TextLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Converted["_TextLabel"].BackgroundTransparency = 1
			Converted["_TextLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
			Converted["_TextLabel"].BorderSizePixel = 0
			Converted["_TextLabel"].Position = UDim2.new(-3.3462257e-08, 0, 0.200000003, 0)
			Converted["_TextLabel"].Size = UDim2.new(0.973684192, 0, 0.800000012, 0)
			Converted["_TextLabel"].Parent = Converted["_Frame"]
			
			local fake_module_scripts = {}
			
			local function GarbageGradientAnim() 
				local script = Instance.new("LocalScript")
				script.Name = "LocalScript"
				script.Parent = Converted["_Frame1"]
				local req = require
				local require = function(obj)
					local fake = fake_module_scripts[obj]
					if fake then
						return fake()
					end
					return req(obj)
				end
			
				local retardedstorage = {
					panel = script.Parent,
					gradient = script.Parent.UIGradient,
					Tsrvc = game:GetService("TweenService"),
					Tinfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					offset = {Offset = Vector2.new(1, 0)},
					create = nil,
					startingPos = Vector2.new(-1, 0),
					list = {},
					s = ColorSequence.new, 
					kpt = ColorSequenceKeypoint.new,
					counter = 0,
					status = "down"
				}
				
				retardedstorage.create = retardedstorage.Tsrvc:Create(retardedstorage.gradient, retardedstorage.Tinfo, retardedstorage.offset)
				
				local function GenerateMoreGarbageLul()
					local sat, val = 255, 255
					for i = 1, 15 do
						local hue = i * 17
						table.insert(retardedstorage.list, Color3.fromHSV(hue / 255, sat / 255, val / 255))
					end
				end
				
				GenerateMoreGarbageLul()
				
				local function IHateLerpingColors(color1, color2, t)
					return Color3.new(
						color1.R + (color2.R - color1.R) * t,
						color1.G + (color2.G - color1.G) * t,
						color1.B + (color2.B - color1.B) * t
					)
				end
				
				local function SeTheFuckingColorForZaGradient(startIndex, middleIndex, endIndex)
					local start = retardedstorage.list[startIndex]
					local endc = retardedstorage.list[endIndex]
					local steps = middleIndex - startIndex
					local stepsize = 1 / steps
					local sequence = {}
				
					if steps > 1 then
						for i = 0, 1, stepsize do
							local IHATEINTERPOLATEDCOLORSFR = IHateLerpingColors(start, endc, i)
							table.insert(sequence, retardedstorage.kpt(i, IHATEINTERPOLATEDCOLORSFR))
						end
					else
						table.insert(sequence, retardedstorage.kpt(0, start))
						table.insert(sequence, retardedstorage.kpt(1, endc))
					end
				
					retardedstorage.gradient.Color = retardedstorage.s(sequence)
				end
				
				local function DaFuckingAnimPlayer()
					retardedstorage.create:Play()
					retardedstorage.create.Completed:Wait()
					retardedstorage.gradient.Offset = retardedstorage.startingPos
					retardedstorage.gradient.Rotation = (retardedstorage.status == "down") and 180 or 0
				end
				
				local function ShittyUpdaterForStatusAndCounter(news, newc)
					retardedstorage.status = news
					retardedstorage.counter = newc
				end
				
				local function DownGarbage()
					if retardedstorage.counter == #retardedstorage.list - 1 and retardedstorage.status == "down" then
						SeTheFuckingColorForZaGradient(1, #retardedstorage.list, 1)
						ShittyUpdaterForStatusAndCounter("up", 1)
					elseif retardedstorage.counter == #retardedstorage.list and retardedstorage.status == "down" then
						SeTheFuckingColorForZaGradient(1, 1, 2)
						ShittyUpdaterForStatusAndCounter("up", 1)
					elseif retardedstorage.counter <= #retardedstorage.list - 2 and retardedstorage.status == "down" then
						local startKey = retardedstorage.counter + 1
						SeTheFuckingColorForZaGradient(startKey, startKey, startKey + 1)
						ShittyUpdaterForStatusAndCounter("up", startKey)
					end
				end
				
				local function UpGarbage()
					if retardedstorage.counter == #retardedstorage.list - 1 and retardedstorage.status == "up" then
						SeTheFuckingColorForZaGradient(1, 1, #retardedstorage.list)
						ShittyUpdaterForStatusAndCounter("down", 1)
					elseif retardedstorage.counter == #retardedstorage.list and retardedstorage.status == "up" then
						SeTheFuckingColorForZaGradient(1, 2, 1)
						ShittyUpdaterForStatusAndCounter("down", 1)
					elseif retardedstorage.counter <= #retardedstorage.list - 2 and retardedstorage.status == "up" then
						local startKey = retardedstorage.counter + 2
						SeTheFuckingColorForZaGradient(startKey, startKey, startKey - 1)
						ShittyUpdaterForStatusAndCounter("down", startKey)
					end
				end
				
				local function GradientStupidAnimation()
					DaFuckingAnimPlayer()
					if retardedstorage.status == "down" then
						DownGarbage()
					elseif retardedstorage.status == "up" then
						UpGarbage()
					end
					GradientStupidAnimation()
				end
				
				GradientStupidAnimation()
				
			end
			local function TextUpdateOmegaLul() 
				local script = Instance.new("LocalScript")
				script.Name = "LocalScript"
				script.Parent = Converted["_TextLabel"]
				local req = require
				local require = function(obj)
					local fake = fake_module_scripts[obj]
					if fake then
						return fake()
					end
					return req(obj)
				end
			
				local RS = game:GetService("RunService")
				local parent = script.Parent
				local lastupdate = tick()
				local framecounter = 0
				
				RS.Stepped:Connect(function()
					framecounter = framecounter + 1
					local current = tick()
					if current - lastupdate >= 1 then
						local fps = math.floor(framecounter / (current - lastupdate))
						parent.Text = "VoidWare | " .. fps .. " FPS | .gg/e2HUEAmsuA"
						lastupdate = current
						framecounter = 0
					end
				end)
				
			end
			
			coroutine.wrap(GarbageGradientAnim)()
			coroutine.wrap(TextUpdateOmegaLul)()
		else 
			local plrgui = game.Players.LocalPlayer.PlayerGui
			if plrgui:FindFirstChild("WatermarkVoidWareLol") then 
				local watermark = plrgui:FindFirstChild("WatermarkVoidWareLol") 
				watermark:Destroy()
			else
				warningNotification("WaterMark Error", "Couldn't find the watermark in playergui, please dm salad about this", 60)
			end
		end
	end
})--]]


	local KeyStrokes = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "KeyStrokes",
		Function = function(callback)
			if callback then 
				local Converted = {
					["_KeyStrokes"] = Instance.new("ScreenGui");
					["_KeysContainer"] = Instance.new("Folder");
					["_AKey"] = Instance.new("Frame");
					["_ALabel"] = Instance.new("TextLabel");
					["_DKey"] = Instance.new("Frame");
					["_DLabel"] = Instance.new("TextLabel");
					["_SKey"] = Instance.new("Frame");
					["_SLabel"] = Instance.new("TextLabel");
					["_SpaceBarKey"] = Instance.new("Frame");
					["_SpaceBarInside"] = Instance.new("Frame");
					["_WKey"] = Instance.new("Frame");
					["_WLabel"] = Instance.new("TextLabel");
					["_LocalScript"] = Instance.new("LocalScript");
				}
				
				
				Converted["_KeyStrokes"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				Converted["_KeyStrokes"].Name = "KeyStrokes"
				Converted["_KeyStrokes"].Parent = game.Players.LocalPlayer.PlayerGui
				
				Converted["_KeysContainer"].Name = "KeysContainer"
				Converted["_KeysContainer"].Parent = Converted["_KeyStrokes"]
				
				Converted["_AKey"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_AKey"].BackgroundTransparency = 0.6000000238418579
				Converted["_AKey"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_AKey"].BorderSizePixel = 0
				Converted["_AKey"].Position = UDim2.new(0.00960219465, 0, 0.820967734, 0)
				Converted["_AKey"].Size = UDim2.new(0.0432098769, 0, 0.101612903, 0)
				Converted["_AKey"].Name = "AKey"
				Converted["_AKey"].Parent = Converted["_KeysContainer"]
				
				Converted["_ALabel"].Font = Enum.Font.Sarpanch
				Converted["_ALabel"].Text = "A"
				Converted["_ALabel"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_ALabel"].TextScaled = true
				Converted["_ALabel"].TextSize = 14
				Converted["_ALabel"].TextWrapped = true
				Converted["_ALabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_ALabel"].BackgroundTransparency = 1
				Converted["_ALabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_ALabel"].BorderSizePixel = 0
				Converted["_ALabel"].Size = UDim2.new(1, 0, 1, 0)
				Converted["_ALabel"].Name = "ALabel"
				Converted["_ALabel"].Parent = Converted["_AKey"]
				
				Converted["_DKey"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_DKey"].BackgroundTransparency = 0.6000000238418579
				Converted["_DKey"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_DKey"].BorderSizePixel = 0
				Converted["_DKey"].Position = UDim2.new(0.106995888, 0, 0.820967734, 0)
				Converted["_DKey"].Size = UDim2.new(0.0432098769, 0, 0.101612903, 0)
				Converted["_DKey"].Name = "DKey"
				Converted["_DKey"].Parent = Converted["_KeysContainer"]
				
				Converted["_DLabel"].Font = Enum.Font.Sarpanch
				Converted["_DLabel"].Text = "D"
				Converted["_DLabel"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_DLabel"].TextScaled = true
				Converted["_DLabel"].TextSize = 14
				Converted["_DLabel"].TextWrapped = true
				Converted["_DLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_DLabel"].BackgroundTransparency = 1
				Converted["_DLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_DLabel"].BorderSizePixel = 0
				Converted["_DLabel"].Size = UDim2.new(1, 0, 1, 0)
				Converted["_DLabel"].Name = "DLabel"
				Converted["_DLabel"].Parent = Converted["_DKey"]
				
				Converted["_SKey"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_SKey"].BackgroundTransparency = 0.6000000238418579
				Converted["_SKey"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_SKey"].BorderSizePixel = 0
				Converted["_SKey"].Position = UDim2.new(0.0582990386, 0, 0.820967734, 0)
				Converted["_SKey"].Size = UDim2.new(0.0432098769, 0, 0.101612903, 0)
				Converted["_SKey"].Name = "SKey"
				Converted["_SKey"].Parent = Converted["_KeysContainer"]
				
				Converted["_SLabel"].Font = Enum.Font.Sarpanch
				Converted["_SLabel"].Text = "S"
				Converted["_SLabel"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_SLabel"].TextScaled = true
				Converted["_SLabel"].TextSize = 14
				Converted["_SLabel"].TextWrapped = true
				Converted["_SLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_SLabel"].BackgroundTransparency = 1
				Converted["_SLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_SLabel"].BorderSizePixel = 0
				Converted["_SLabel"].Size = UDim2.new(1, 0, 1, 0)
				Converted["_SLabel"].Name = "SLabel"
				Converted["_SLabel"].Parent = Converted["_SKey"]
				
				Converted["_SpaceBarKey"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_SpaceBarKey"].BackgroundTransparency = 0.6000000238418579
				Converted["_SpaceBarKey"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_SpaceBarKey"].BorderSizePixel = 0
				Converted["_SpaceBarKey"].Position = UDim2.new(0.00960219465, 0, 0.935483873, 0)
				Converted["_SpaceBarKey"].Size = UDim2.new(0.140603572, 0, 0.0483870953, 0)
				Converted["_SpaceBarKey"].Name = "SpaceBarKey"
				Converted["_SpaceBarKey"].Parent = Converted["_KeysContainer"]
				
				Converted["_SpaceBarInside"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_SpaceBarInside"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_SpaceBarInside"].BorderSizePixel = 0
				Converted["_SpaceBarInside"].Position = UDim2.new(0.0439024381, 0, 0.333333343, 0)
				Converted["_SpaceBarInside"].Size = UDim2.new(0.907317102, 0, 0.300000012, 0)
				Converted["_SpaceBarInside"].Name = "SpaceBarInside"
				Converted["_SpaceBarInside"].Parent = Converted["_SpaceBarKey"]
				
				Converted["_WKey"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_WKey"].BackgroundTransparency = 0.6000000238418579
				Converted["_WKey"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_WKey"].BorderSizePixel = 0
				Converted["_WKey"].Position = UDim2.new(0.0582990386, 0, 0.709677398, 0)
				Converted["_WKey"].Size = UDim2.new(0.0432098769, 0, 0.101612903, 0)
				Converted["_WKey"].Name = "WKey"
				Converted["_WKey"].Parent = Converted["_KeysContainer"]
				
				Converted["_WLabel"].Font = Enum.Font.Sarpanch
				Converted["_WLabel"].Text = "W"
				Converted["_WLabel"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_WLabel"].TextScaled = true
				Converted["_WLabel"].TextSize = 14
				Converted["_WLabel"].TextWrapped = true
				Converted["_WLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_WLabel"].BackgroundTransparency = 1
				Converted["_WLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_WLabel"].BorderSizePixel = 0
				Converted["_WLabel"].Size = UDim2.new(1, 0, 1, 0)
				Converted["_WLabel"].Name = "WLabel"
				Converted["_WLabel"].Parent = Converted["_WKey"]
				
				local StupidTable = {
					parent = Converted["_KeyStrokes"],
					dafuckingkeys = {
						[Enum.KeyCode.A] = "AKey",
						[Enum.KeyCode.D] = "DKey",
						[Enum.KeyCode.S] = "SKey",
						[Enum.KeyCode.W] = "WKey",
						[Enum.KeyCode.Space] = "SpaceBarKey"
					}
				}
				
				StupidTable.folder = StupidTable.parent:WaitForChild("KeysContainer")
				
				for key, value in pairs(StupidTable.dafuckingkeys) do
					StupidTable[value] = StupidTable.folder:WaitForChild(value, 2)
				end
				
				local UIS = game:GetService("UserInputService")
				
				local function colorupdateshit(input, color)
					local stupidkey = StupidTable.dafuckingkeys[input.KeyCode]
					if stupidkey then
						local key = StupidTable[stupidkey]
						if key then
							key.BackgroundColor3 = color
							--print(stupidkey .. " color updated to " .. tostring(color))
						else
							--warn("Key not found: " .. stupidkey)
						end
					else
						--warn("KeyCode not found: " .. tostring(input.KeyCode))
					end
				end
				
				UIS.InputBegan:Connect(function(input, chatting)
					if not chatting then
						colorupdateshit(input, Color3.fromRGB(34, 0, 86))
						--print("Input Began: " .. tostring(input.KeyCode))
					end
				end)
				
				UIS.InputEnded:Connect(function(input)
					colorupdateshit(input, Color3.fromRGB(0, 0, 0))
					--print("Input Ended: " .. tostring(input.KeyCode))
				end)			
			else
				local plrgui = game.Players.LocalPlayer.PlayerGui 
				if plrgui:FindFirstChild("KeyStrokes") then 
					KeyStrokes = plrgui:FindFirstChild("KeyStrokes")
					KeyStrokes:Destroy()	
				else
					warningNotification("KeyStrokes Error", "Couldn't find KeyStrokes in playergui, please dm Salad about this\nOr if you know what you're doing, you can enable the debugs in the code and try fix them.", 60)
				end
			end
		end
	})
	

local function getNotificationMessage(messagesList, defaultMessage, replaceTag, replaceValue)
    local message = #messagesList > 0 and messagesList[math.random(1, #messagesList)] or defaultMessage
    return message:gsub(replaceTag, replaceValue)
end

local function handleBedBreakEvent(bedTable, lplr, BedBreakMessage)
    if bedTable.brokenBedTeam.id == lplr:GetAttribute("Team") then
        warnAction("Bed", "Your bed has been destroyed by " .. (bedTable.player.DisplayName or bedTable.player.Name) .. "! Be careful.", 7)
    elseif bedTable.player.UserId == lplr.UserId then
        local team = bedwars.QueueMeta[store.queueType].teams[tonumber(bedTable.brokenBedTeam.id)]
        local teamname = team and team.displayName:lower() or "unknown"
        local message = getNotificationMessage({}, "You have destroyed <bed>'s bed", "<bed>", teamname)
        Action("EventNotifier", message, 3)
    end
end

local function handleEntityDeathEvent(deathTable, lplr, DeathMessage, FinalKillMessage)
    local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
    local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
    
    if not killed or not killer then return end
    
    if deathTable.finalKill then
        if killed == lplr and killer ~= lplr then
            local message = getNotificationMessage({}, "You have lost to <name>. Good game.", "<name>", killer.DisplayName)
            warnAction("EventNotifier", message, 3)
        elseif killer == lplr then
            local message = getNotificationMessage({}, "You've defeated <name>!", "<name>", killed.DisplayName)
            Action("EventNotifier", message, 3)
        end
    else
        if deathTable.fromEntity == lplr.Character and deathTable.entityInstance ~= lplr.Character then
            local message = getNotificationMessage({}, "You have killed <name>.", "<name>", killed.DisplayName)
            Action("EventNotifier", message, 3)
        end
    end
end

local function handleMatchEndEvent(winstuff, lplr)
    local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
    if myTeam and myTeam.id == winstuff.winningTeamId then
        WinW("EventNotifier", "You've won the game! gg", 60)
    end
end

local function handleBedShieldEndEvent()
    warnAction("EventNotifier", "Bed shields are down.", 7)
end

local function initializeNotifications(notifications, lplr)
    notifications = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = "EventNotifier",
        Function = function(notified)
            if notified then
                task.spawn(function()
                    table.insert(notifications.Connections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
                        handleBedBreakEvent(bedTable, lplr)
                    end))

                    table.insert(notifications.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
                        handleEntityDeathEvent(deathTable, lplr)
                    end))
                    
                    table.insert(notifications.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
                        handleMatchEndEvent(winstuff, lplr)
                    end))

                    table.insert(notifications.Connections, vapeEvents.BedShieldsEnd.Event:Connect(handleBedShieldEndEvent))
                end)
            end
        end,
        HoverText = "This module will notify you on specific events",
		ExtraText = function() return "UselessModule" end
    })

    local toggles = {
        {"Final Kill Notifier", "Notifies you when you final kill someone (he wont be able to respawn)"},
        {"No Bed Notifier", "Notifies you when your bed gets destroyed by someone"},
        {"Player Death Notifier", "Notifies you when you pass away (with cheats lmao)"},
        {"Bed Destroyer Notifier", "Notifies when you destroy a team's bed."},
        {"Kills Notifier", "Notifies when you kill someone."},
        {"Game Won Notifier", "Notifies you when you win the game."},
        {"End Of Bed Protection", "Notifies you when bed shields end."}
    }

    for _, toggle in ipairs(toggles) do
        notifications.CreateToggle({
            Name = toggle[1],
            Function = function() end,
            Default = true,
            HoverText = toggle[2]
        })
    end
end

run(function()
    local lplr = game.Players.LocalPlayer 
    local notifications = {Connections = {}}
    initializeNotifications(notifications, lplr)
end)


run(function()
	local TweenService = game:GetService("TweenService")
	local function TweenObject(target, properties, time, easingStyle, direction, callback)
		local info = TweenInfo.new(time, easingStyle, direction)
		local tween = TweenService:Create(target, info, properties)
		tween:Play()
		
		if callback then
			tween.Completed:Connect(callback)
		end
	end
	local previousTargetHP = 0  
	local CustomTargetHud = {Enabled = false}
	CustomTargetHud = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
	Name = "CustomTargetHud",
	Function = function(callback)
		if callback then 
			CustomTargetHud.Enabled = false 
		        wait() --prevents breaking/not loading lol (yup, laziest way ever to do this.)
			CustomTargetHud.Enabled = true 
			local Table = {
				["_MainGui"] = Instance.new("ScreenGui");
				["_MainFrame"] = Instance.new("Frame");
				["_UIStroke"] = Instance.new("UIStroke");
				["_UIGradient"] = Instance.new("UIGradient");
				["_LocalScript"] = Instance.new("LocalScript");
				["_UICorner"] = Instance.new("UICorner");
				["_DropShadowHolder"] = Instance.new("Frame");
				["_DropShadow"] = Instance.new("ImageLabel");
				["_ImageLabel"] = Instance.new("ImageLabel");
				["_Corner"] = Instance.new("UICorner");
				["_Stroke"] = Instance.new("UIStroke");
				["_HealthFrame"] = Instance.new("Frame");
				["_UICorner1"] = Instance.new("UICorner");
				["_HP"] = Instance.new("TextLabel");
				["_User"] = Instance.new("TextLabel");
				["_Win/Lose"] = Instance.new("TextLabel");
				}
				
				Table["_MainGui"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				Table["_MainGui"].Name = "MainGui"
				Table["_MainGui"].Parent = coreGui
				
				Table["_MainFrame"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Table["_MainFrame"].BackgroundTransparency = 0.20000000298023224
				Table["_MainFrame"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Table["_MainFrame"].BorderSizePixel = 0
				Table["_MainFrame"].Position = UDim2.new(0.476450503, 0, 0.631067932, 0)
				Table["_MainFrame"].Size = UDim2.new(0, 304, 0, 100)
				Table["_MainFrame"].Name = "MainFrame"
				Table["_MainFrame"].Parent = Table["_MainGui"]
				
				Table["_UIStroke"].Color = Color3.fromRGB(255, 255, 255)
				Table["_UIStroke"].Thickness = 2
				Table["_UIStroke"].Parent = Table["_MainFrame"]
				
				Table["_UIGradient"].Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 251.00000023841858)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 238.00000101327896))
				}
				Table["_UIGradient"].Parent = Table["_UIStroke"]
				
				Table["_UICorner"].Parent = Table["_MainFrame"]
				
				Table["_DropShadowHolder"].BackgroundTransparency = 1
				Table["_DropShadowHolder"].BorderSizePixel = 0
				Table["_DropShadowHolder"].Size = UDim2.new(1, 0, 1, 0)
				Table["_DropShadowHolder"].ZIndex = 0
				Table["_DropShadowHolder"].Name = "DropShadowHolder"
				Table["_DropShadowHolder"].Parent = Table["_MainFrame"]
				
				Table["_DropShadow"].Image = "rbxassetid://6014261993"
				Table["_DropShadow"].ImageColor3 = Color3.fromRGB(0, 0, 0)
				Table["_DropShadow"].ImageTransparency = 0.5
				Table["_DropShadow"].ScaleType = Enum.ScaleType.Slice
				Table["_DropShadow"].SliceCenter = Rect.new(49, 49, 450, 450)
				Table["_DropShadow"].AnchorPoint = Vector2.new(0.5, 0.5)
				Table["_DropShadow"].BackgroundTransparency = 1
				Table["_DropShadow"].BorderSizePixel = 0
				Table["_DropShadow"].Position = UDim2.new(0.5, 0, 0.5, 0)
				Table["_DropShadow"].Size = UDim2.new(1, 47, 1, 47)
				Table["_DropShadow"].ZIndex = 0
				Table["_DropShadow"].Name = "DropShadow"
				Table["_DropShadow"].Parent = Table["_DropShadowHolder"]
				
				Table["_ImageLabel"].Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
				Table["_ImageLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Table["_ImageLabel"].BackgroundTransparency = 1
				Table["_ImageLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Table["_ImageLabel"].BorderSizePixel = 0
				Table["_ImageLabel"].Position = UDim2.new(0.0361842103, 0, 0.119999997, 0)
				Table["_ImageLabel"].Size = UDim2.new(0, 80, 0, 75)
				Table["_ImageLabel"].Parent = Table["_MainFrame"]
				
				Table["_Corner"].Name = "Corner"
				Table["_Corner"].Parent = Table["_ImageLabel"]
				
				Table["_Stroke"].Color = Color3.fromRGB(255, 255, 255)
				Table["_Stroke"].Thickness = 2
				Table["_Stroke"].Name = "Stroke"
				Table["_Stroke"].Parent = Table["_ImageLabel"]
				
				Table["_HealthFrame"].BackgroundColor3 = Color3.fromRGB(0, 157.0000058412552, 58.00000414252281)
				Table["_HealthFrame"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Table["_HealthFrame"].BorderSizePixel = 0
				Table["_HealthFrame"].Position = UDim2.new(0.335526317, 0, 0.699999988, 0)
				Table["_HealthFrame"].Size = UDim2.new(0, 187, 0, 17)
				Table["_HealthFrame"].Name = "HealthFrame"
				Table["_HealthFrame"].Parent = Table["_MainFrame"]
				
				Table["_UICorner1"].CornerRadius = UDim.new(0, 4)
				Table["_UICorner1"].Parent = Table["_HealthFrame"]
				
				Table["_HP"].Font = Enum.Font.SourceSans
				Table["_HP"].Text = "100 HP"
				Table["_HP"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Table["_HP"].TextScaled = true
				Table["_HP"].TextSize = 14
				Table["_HP"].TextWrapped = true
				Table["_HP"].TextXAlignment = Enum.TextXAlignment.Left
				Table["_HP"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Table["_HP"].BackgroundTransparency = 1
				Table["_HP"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Table["_HP"].BorderSizePixel = 0
				Table["_HP"].Position = UDim2.new(0.335526317, 0, 0.379999995, 0)
				Table["_HP"].Size = UDim2.new(0, 84, 0, 24)
				Table["_HP"].Name = "HP"
				Table["_HP"].Parent = Table["_MainFrame"]
				
				Table["_User"].Font = Enum.Font.SourceSans
				Table["_User"].Text = "UserName"
				Table["_User"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Table["_User"].TextScaled = true
				Table["_User"].TextSize = 14
				Table["_User"].TextWrapped = true
				Table["_User"].TextXAlignment = Enum.TextXAlignment.Left
				Table["_User"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Table["_User"].BackgroundTransparency = 1
				Table["_User"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Table["_User"].BorderSizePixel = 0
				Table["_User"].Position = UDim2.new(0.335526317, 0, 0.119999997, 0)
				Table["_User"].Size = UDim2.new(0, 195, 0, 24)
				Table["_User"].Name = "User"
				Table["_User"].Parent = Table["_MainFrame"]
				
				Table["_Win/Lose"].Font = Enum.Font.SourceSans
				Table["_Win/Lose"].Text = "Winning"
				Table["_Win/Lose"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Table["_Win/Lose"].TextScaled = true
				Table["_Win/Lose"].TextSize = 14
				Table["_Win/Lose"].TextWrapped = true
				Table["_Win/Lose"].TextXAlignment = Enum.TextXAlignment.Left
				Table["_Win/Lose"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Table["_Win/Lose"].BackgroundTransparency = 1
				Table["_Win/Lose"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Table["_Win/Lose"].BorderSizePixel = 0
				Table["_Win/Lose"].Position = UDim2.new(0.611842096, 0, 0.360000014, 0)
				Table["_Win/Lose"].Size = UDim2.new(0, 103, 0, 26)
				Table["_Win/Lose"].Name = "Win/Lose"
				Table["_Win/Lose"].Parent = Table["_MainFrame"]
				
				local fake_module_scripts = {}
				
				local function MYASSISA_fake_script() 
				local script = Instance.new("LocalScript")
				script.Name = "LocalScript"
				script.Parent = Table["_UIStroke"]
				local req = require
				local require = function(obj)
					local fake = fake_module_scripts[obj]
					if fake then
						return fake()
					end
					return req(obj)
				end
				
				local r = game:GetService("RunService")
				local g = script.Parent.UIGradient
				
				r.RenderStepped:Connect(function()
					g.Rotation += 2
				end)
				end
				
				coroutine.wrap(MYASSISA_fake_script)()
				local lplr = game.Players.LocalPlayer
				local character = lplr.Character or lplr.CharacterAdded:Wait()
				local rootPart = character:WaitForChild("HumanoidRootPart")
				local target = nil
				
				
				local function updateGUI(target)
				if not target or not target.Character or not target.Character:FindFirstChild("Humanoid") or not character or not character:FindFirstChild("Humanoid") then
					return
				end
				
				Table["_User"].Text = target.Name
				local userId = target.UserId
				Table["_ImageLabel"].Image = "rbxthumb://type=AvatarHeadShot&w=420&h=420&id=" .. userId
				
				local lplrHP = character.Humanoid.Health
				local targetHP = target.Character.Humanoid.Health
				local targetMaxHP = target.Character.Humanoid.MaxHealth
				local targetHPPercentage = targetHP / targetMaxHP
				Table["_HP"].Text = tostring(math.floor(targetHP)) .. " HP"
				
				local targetHPPercentageChange = targetHPPercentage - (previousTargetHP / targetMaxHP)
				local tweenTime = math.abs(targetHPPercentageChange) * 1.5
				tweenTime = math.max(tweenTime, 0.2)  
				
				TweenObject(Table["_HealthFrame"], {Size = UDim2.new(0, 187 * targetHPPercentage, 0, 17)}, tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				
				
				if targetHP < 20 then
					Table["_HealthFrame"].BackgroundColor3 = Color3.fromRGB(255, 0, 0) 
				elseif targetHP < 50 then
					Table["_HealthFrame"].BackgroundColor3 = Color3.fromRGB(255, 165, 0)
				else
					Table["_HealthFrame"].BackgroundColor3 = Color3.fromRGB(0, 157, 58) 
				end
				
				if lplrHP > targetHP then
					Table["_Win/Lose"].Text = "Winning"
					Table["_Win/Lose"].TextColor3 = Color3.fromRGB(0, 255, 0)
				elseif lplrHP == targetHP then
					Table["_Win/Lose"].Text = "Same HPS"
					Table["_Win/Lose"].TextColor3 = Color3.fromRGB(255, 255, 0)
				else
					Table["_Win/Lose"].Text = "Losing"
					Table["_Win/Lose"].TextColor3 = Color3.fromRGB(255, 0, 0)
				end
				
				previousTargetHP = targetHP
				end
				
				
				
				local function updateCharacterReferences()
				character = lplr.Character or lplr.CharacterAdded:Wait()
				rootPart = character:WaitForChild("HumanoidRootPart")
				Table["_MainGui"].Enabled = false  
				end
				
				local debounce = false
				local function checkPlayersWithinReach()
				if debounce then return end
				debounce = true
				
				local nearestPlayer = nil
				local shortestDistance = 18 
				
				for _, player in pairs(game.Players:GetPlayers()) do
					if player ~= lplr and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local distance = (rootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
						if distance < shortestDistance then
							shortestDistance = distance
							nearestPlayer = player
						end
					end
				end
				
				if nearestPlayer then
					target = nearestPlayer
					updateGUI(nearestPlayer) 
					Table["_MainGui"].Enabled = true  
				else 
					target = nil
					Table["_MainGui"].Enabled = false  
				end
				
				debounce = false
				end
				
				local heartbeatConnection
				
				local function startCheckingPlayers()
				if heartbeatConnection then
					heartbeatConnection:Disconnect()
				end
				heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(checkPlayersWithinReach)
				end
				
				local function stopCheckingPlayers()
				if heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end
				end
				
				game.Players.PlayerRemoving:Connect(function(removedPlayer)
				if removedPlayer == target then
					target = nil
					Table["_MainGui"].Enabled = false 
				end
				end)
				
				lplr.CharacterAdded:Connect(function()
				stopCheckingPlayers()
				character = lplr.Character
				rootPart = character:WaitForChild("HumanoidRootPart")
				startCheckingPlayers()
				end)
				
				startCheckingPlayers()
				
				
				else
				local MainGui = coreGui:FindFirstChild("MainGui")
				if MainGui then 
					MainGui:Destroy()
				end	
			end
		end
	})
end)

run(function()
	local HackerDetector = {}
	local HackerDetectorInfFly = {}
	local HackerDetectorTeleport = {}
	local HackerDetectorNuker = {}
	local HackerDetectorFunny = {}
	local HackerDetectorInvis = {}
	local HackerDetectorName = {}
	local HackerDetectorSpeed = {}
	local HackerDetectorFileCache = {}
	local pastesploit
	local detectedusers = {
		InfiniteFly = {},
		Teleport = {},
		Nuker = {},
		AnticheatBypass = {},
		Invisibility = {},
		Speed = {},
		Name = {},
		Cache = {}
	}
	local distances = { -- more stuff will be added in future idk
		windwalker = 80
	}
	local function cachedetection(player, detection)
		if not HackerDetectorFileCache.Enabled then 
			return 
		end
		if type(response) ~= 'table' then 
			response = {}
		end
		if response[player.Name] then 
			if table.find(response[player.Name], detection) == nil then 
				table.insert(response[player.Name].Detections, detection) 
			end
		else
			response[player.Name] = {DisplayName = player.DisplayName, UserId = tostring(player.DisplayName), Detections = {detection}}
		end
	end
	local detectionmethods = {
		Teleport = function(plr)
			if table.find(detectedusers.Teleport, plr) then 
				return 
			end
			if store.queueType:find('bedwars') == nil or plr:GetAttribute('Spectator') then 
				return 
			end
			local lastbwteleport = plr:GetAttribute('LastTeleported')
			table.insert(HackerDetector.Connections, plr:GetAttributeChangedSignal('LastTeleported'):Connect(function() lastbwteleport = plr:GetAttribute('LastTeleported') end))
			table.insert(HackerDetector.Connections, plr.CharacterAdded:Connect(function()
				oldpos = Vector3.zero
				if table.find(detectedusers.Teleport, plr) then 
					return 
				end
				 repeat task.wait() until isAlive(plr, true)
				 local oldpos2 = plr.Character.HumanoidRootPart.Position 
				 task.delay(2, function()
					if isAlive(plr, true) then 
						local newdistance = (plr.Character.HumanoidRootPart.Position - oldpos2).Magnitude 
						if newdistance >= 400 and (plr:GetAttribute('LastTeleported') - lastbwteleport) == 0 then 
							InfoNotification('HackerDetector', plr.DisplayName..' is using Teleport Exploit!', 100) 
							table.insert(detectedusers.Teleport, plr)
							cachedetection(plr, 'Teleport')
							whitelist.customtags[plr.Name] = {{text = 'VAPE USER', color = Color3.new(1, 1, 0)}}
							if RenderFunctions.playerTags[plr] == nil then 
								RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
							end
						end 
					end
				 end)
			end))
		end,
		Speed = function(plr) 
			repeat task.wait() until (store.matchState ~= 0 or not HackerDetector.Enabled or not HackerDetectorSpeed.Enabled)
			if table.find(detectedusers.Speed, plr) then 
				return 
			end
			local lastbwteleport = plr:GetAttribute('LastTeleported')
			local oldpos = Vector3.zero 
			table.insert(HackerDetector.Connections, plr:GetAttributeChangedSignal('LastTeleported'):Connect(function() lastbwteleport = plr:GetAttribute('LastTeleported') end)) 
			table.insert(HackerDetector.Connections, plr.CharacterAdded:Connect(function() oldpos = Vector3.zero end))
			repeat 
				if isAlive(plr, true) then 
					local magnitude = (plr.Character.HumanoidRootPart.Position - oldpos).Magnitude
					if (plr:GetAttribute('LastTeleported') - lastbwteleport) ~= 0 and magnitude >= ((distances[plr:GetAttribute('PlayingAsKit') or ''] or 25) + (playerRaycasted(plr, Vector3.new(0, -15, 0)) and 0 or 40)) then 
						InfoNotification('HackerDetector', plr.DisplayName..' is using speed!', 60)
						whitelist.customtags[plr.Name] = {{text = 'VAPE USER', color = Color3.new(1, 1, 0)}}
						if RenderFunctions.playerTags[plr] == nil then 
							RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
						end
					end
					oldpos = plr.Character.HumanoidRootPart.Position
					task.wait(2.5)
					lastbwteleport = plr:GetAttribute('LastTeleported')
				end
			until not task.wait() or table.find(detectedusers.Speed, plr) or (not HackerDetector.Enabled or not HackerDetectorSpeed.Enabled)
		end,
		InfiniteFly = function(plr) 
			repeat 
				if isAlive(plr, true) then 
					local magnitude = (RenderStore.LocalPosition - plr.Character.HumanoidRootPart.Position).Magnitude
					if magnitude >= 10000 and playerRaycast(plr) == nil and playerRaycast({Character = {PrimaryPart = {Position = RenderStore.LocalPosition}}}) then 
						InfoNotification('HackerDetector', plr.DisplayName..' is using InfiniteFly!', 60) 
						cachedetection(plr, 'InfiniteFly')
						table.insert(detectedusers.InfiniteFly, plr)
						whitelist.customtags[plr.Name] = {{text = 'VAPE USER', color = Color3.new(1, 1, 0)}}
						if RenderFunctions.playerTags[plr] == nil then 
							RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
						end
					end
					task.wait(2.5)
				end
			until not task.wait() or table.find(detectedusers.InfiniteFly, plr) or (not HackerDetector.Enabled or not HackerDetectorInfFly.Enabled)
		end,
		Invisibility = function(plr) 
			if table.find(detectedusers.Invisibility, plr) then 
				return 
			end
			repeat 
				for i,v in next, (isAlive(plr, true) and plr.Character.Humanoid:GetPlayingAnimationTracks() or {}) do 
					if v.Animation.AnimationId == 'http://www.roblox.com/asset/?id=11335949902' or v.Animation.AnimationId == 'rbxassetid://11335949902' then 
						InfoNotification('HackerDetector', plr.DisplayName..' is using Invisibility!', 60) 
						table.insert(detectedusers.Invisibility, plr)
						cachedetection(plr, 'Invisibility')
						whitelist.customtags[plr.Name] = {{text = 'VAPE USER', color = Color3.new(1, 1, 0)}}
						if RenderFunctions.playerTags[plr] == nil then 
							RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
						end
					end
				end
				task.wait(0.5)
			until table.find(detectedusers.Invisibility, plr) or (not HackerDetector.Enabled or not HackerDetectorInvis.Enabled)
		end,
		Name = function(plr) 
			repeat task.wait() until pastesploit 
			local lines = pastesploit:split('\n') 
			for i,v in next, lines do 
				if v:find('local Owner = ') then 
					local name = lines[i]:gsub('local Owner =', ''):gsub('"', ''):gsub("'", '') 
					if plr.Name == name then 
						InfoNotification('HackerDetector', plr.DisplayName..' is the owner of Godsploit! They\'re is most likely cheating.', 60) 
						cachedetection(plr, 'Name')
						whitelist.customtags[plr.Name] = {{text = 'VAPE USER', color = Color3.new(1, 1, 0)}}
						if RenderFunctions.playerTags[plr] == nil then 
							RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
						end 
					end
				end
			end
			for i,v in next, ({'godsploit', 'alsploit', 'renderintents'}) do 
				local user = plr.Name:lower():find(v) 
				local display = plr.DisplayName:lower():find(v)
				if user or display then 
					InfoNotification('HackerDetector', plr.DisplayName..' has "'..v..'" in their '..(user and 'username' or 'display name')..'! They might be cheating.', 20)
					cachedetection(plr, 'Name') 
					return 
				end
			end
		end, 
		Cache = function(plr)
			local success, response = pcall(function()
				return httpService:JSONDecode(readfile('vape/Libraries/exploiters.json')) 
			end) 
			if type(response) == 'table' and response[plr.Name] then 
				InfoNotification('HackerDetector', plr.DisplayName..' is cached on the exploiter database!', 30)
				table.insert(detectedusers.Cached, plr)
				whitelist.customtags[plr.Name] = {{text = 'VAPE USER', color = Color3.new(1, 1, 0)}}
				if RenderFunctions.playerTags[plr] == nil then 
					RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
				end
			end
		end
	}
	local function bootdetections(player)
		local detectiontoggles = {InfiniteFly = HackerDetectorInfFly, Teleport = HackerDetectorTeleport, Nuker = HackerDetectorNuker, Invisibility = HackerDetectorInvis, Speed = HackerDetectorSpeed, Name = HackerDetectorName, Cache = HackerDetectorFileCache}
		for i, detection in next, detectionmethods do 
			if detectiontoggles[i].Enabled then
			   task.spawn(detection, player)
			end
		end
	end
	HackerDetector = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'HackerDetector',
		HoverText = 'Notify when someone is\nsuspected of using exploits.',
		ExtraText = function() return 'Vanilla' end,
		Function = function(calling) 
			if calling then 
				for i,v in next, playersService:GetPlayers() do 
					if v ~= lplr then 
						bootdetections(v) 
					end 
				end
				table.insert(HackerDetector.Connections, playersService.PlayerAdded:Connect(bootdetections))
			end
		end
	})
	HackerDetectorTeleport = HackerDetector.CreateToggle({
		Name = 'Teleport',
		Default = true,
		Function = function() end
	})
	HackerDetectorInfFly = HackerDetector.CreateToggle({
		Name = 'InfiniteFly',
		Default = true,
		Function = function() end
	})
	HackerDetectorInvis = HackerDetector.CreateToggle({
		Name = 'Invisibility',
		Default = true,
		Function = function() end
	})
	HackerDetectorNuker = HackerDetector.CreateToggle({
		Name = 'Nuker',
		Default = true,
		Function = function() end
	})
	HackerDetectorSpeed = HackerDetector.CreateToggle({
		Name = 'Speed',
		Default = true,
		Function = function() end
	})
	HackerDetectorName = HackerDetector.CreateToggle({
		Name = 'Name',
		Default = true,
		Function = function() end
	})
	HackerDetectorFileCache = HackerDetector.CreateToggle({
		Name = 'Cached detections',
		HoverText = 'Writes (vape/Libraries/exploiters.json)\neverytime someone is detected.',
		Default = true,
		Function = function() end
	})
end)

--[[for i,v in pairs(store.blocks) do
    local highlight = Instance.new("Highlight", store.blocks[i])
end--]]

--[[run(function()
	local LuckyBlocksESP = {Enabled = false}
	local EspTransparency = {Value = 0.5}
	local espParts = {}
	local partEspTrigger = nil
	LuckyBlocksESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "ESP Lucky Blocks",
		HoverText = "Shows where lucky blocks are",
		Function = function(callback) 
			if callback then
				function sethighlight(entity)
					local highlight = Instance.new("Highlight")
					highlight.Parent = entity
					highlight.FillTransparency = EspTransparency.Value
				end
				for i, V in ipairs(game.workspace:GetDescendants()) do 
					if V.Name:lower() == "lucky_block" then
						sethighlight(V)
					end
				end
			end
		end
	})
end)--]]

local teleportService = game:GetService("TeleportService")
--[[run(function()
	local StaffDetector = {}
	local StaffDetectorMode = {Value = 'Lobby'}
	local legitgamers = {}
	local staffconfig = {legitmessages = {}, staffaccounts = {}, legitmodules = {}}
	local cachedfriends = {}
	local cachedroles = {}
	local knownstaff = {}
	local staffactions = {
		Uninject = GuiLibrary.SelfDestruct,
		Lobby = function()
			teleportService:Teleport(6872265039)
		end,
		LegitLobby = function()
			GuiLibrary.SelfDestruct()
			local messages = getrandomvalue(staffconfig.legitmessages)
			if messages ~= '' then 
				for i,v in next, messages do 
					sendchatmessage(v)
					if i < #messages then 
						task.wait(math.random(0.5, 1.2)) 
					end
				end
			end
			teleportService:Teleport(6872265039)
		end,
		Config = function()
			for i,v in next, GuiLibrary.ObjectsThatCanBeSaved do 
				if v.Type == 'OptionsButton' and table.find(staffconfig.legitmodules, i:gsub('OptionsButton', '')) == nil then 
					GuiLibrary.SaveSettings = function() end
					if v.Api.Enabled then
						v.Api.ToggleButton()
					end
					pcall(GuiLibrary.RemoveObject, i)
				end
			end
		end
	}
	local function savestaffConfig(plr, detection)
		local success, json = pcall(function() 
			return httpService:JSONDecode(readfile('vape/Libraries/staffdata.json'))
		end)
		if not success then 
			json = {}
		end
		table.insert(json, {Username = plr.Name, DisplayName = plr.DisplayName, Detection = detection, Tick = tick()})
		if isfolder('vape/Libraries') then 
			writefile('vape/Libraries/staffdata.json', httpService:JSONEncode(json))
		end
	end
	local function GetRobloxFriends(plr)
		local friends = {}
		local success, page = pcall(function() return playersService:GetFriendsAsync(plr.UserId) end)
		if success then
		   repeat
			   for i,v in next, page:GetCurrentPage() do
				   table.insert(friends, v.UserId)
			   end
			   if not page.IsFinished then 
				   page:AdvanceToNextPageAsync()
			   end
		   until page.IsFinished
		end
		return friends
	end
	local function friendActive(friendtab)
		for i,v in next, friendtab do 
			local friend = playersService:GetPlayerByUserId(v)
			if friend then 
				return friend 
			end
		end
	end
	local function staffDetectorFunction(player)
		repeat 
			local friends = (cachedfriends[player] or GetRobloxFriends(player))
			cachedfriends[player] = friends
			if player:GetAttribute('Spectator') and table.find(legitgamers, player) == nil and friendActive(friends) == nil and bedwars.ClientStoreHandler:getState().Game.customMatch == nil then 
				savestaffConfig(player, 'illegal_join')
				bedwars.LobbyEvents.leaveParty:FireServer()
				errorNotification('StaffDetector', player.DisplayName..' is overwatching you.', 60)
				return staffactions[StaffDetectorMode.Value]()
			end
			if table.find(legitgamers, player) == nil and tostring(player.Team) ~= 'Neutral' and not player:GetAttribute('Spectator') then 
				table.insert(legitgamers, player)
			end
			if table.find(staffconfig.staffaccounts, player.UserId) or table.find(knownstaff, player.UserId) then 
				savestaffConfig(player, 'blacklisted_users')
				bedwars.LobbyEvents.leaveParty:FireServer()
				errorNotification('StaffDetector', player.DisplayName..' is cached on staff json.', 60)
				return staffactions[StaffDetectorMode.Value]()
			end
			local success, response = true, cachedroles[player]
			if response == nil then 
				success, response = pcall(player.GetRoleInGroup, lplr, 5774246)
			end
			cachedroles[player] = response 
			if tonumber(response) and tonumber(response) >= 100 then 
				savestaffConfig(player, 'group_rank')
				bedwars.LobbyEvents.leaveParty:FireServer()
				errorNotification('StaffDetector', player.DisplayName..' has a high role in the Easy.gg group (GetRoleInGroup() >= 100).', 60)
				return staffactions[StaffDetectorMode.Value]()
			end
			task.wait()
		until (not StaffDetector.Enabled)
	end
	StaffDetector = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'AStaffDetector',
		HoverText = 'Detects when bedwars staff are in the server (75% accuracy).',
		Function = function(calling)
			if calling then 
				pcall(function() staffconfig = httpService:JSONDecode(RenderFunctions:GetFile('Libraries/staffconfig.json')) end)
				pcall(function() knownstaff = httpService:JSONDecode(RenderFunctions:GetFile('Libraries/knownstaff.json')) end)
				pcall(function() 
					for i,v in next, httpService:JSONDecode(readfile('vape/Libraries/staffdata.json')) do 
						if table.find(knownstaff, v) == nil then 
							table.insert(knownstaff, v)
						end
					end
				end)
				repeat task.wait() until (shared.VapeFullyLoaded or not StaffDetector.Enabled)
				if not StaffDetector.Enabled then 
					return 
				end
				for i,v in next, playersService:GetPlayers() do 
					if v ~= lplr then
						task.spawn(staffDetectorFunction, v)
					end
				end
				table.insert(vapeConnections, playersService.PlayerAdded:Connect(staffDetectorFunction))
			end
		end
	})
	StaffDetectorMode = StaffDetector.CreateDropdown({
		Name = 'Action',
		List = dumptable(staffactions, 1),
		Function = function() end
	})
end)--]]

run(function() 
	local JoinQueue = {}
	local queuetojoin = {Value = ''}
	local function dumpmeta()
		local queuemeta = {}
		for i,v in next, bedwars.QueueMeta do 
			if v.title ~= 'Sandbox' and not v.disabled then 
				table.insert(queuemeta, v.title) 
			end 
		end 
		return queuemeta
	end
	JoinQueue = GuiLibrary.ObjectsThatCanBeSaved.VoidwareWindow.Api.CreateOptionsButton({
		Name = 'JoinQueue',
		NoSave = true,
		HoverText = 'Starts a match for the provided gamemode.',
		Function = function(calling)
			if calling then 
				for i,v in next, bedwars.QueueMeta do 
					if v.title == queuetojoin.Value then 
						game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("leaveQueue"):FireServer()
						task.wait(0.1)
						local args = {
							[1] = {
								["queueType"] = i
							}
						}
						game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("joinQueue"):FireServer(unpack(args))
						local listofmodes = {}
						for i,v in pairs(bedwars.QueueMeta) do
						if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
						end
						break
					end
				end
				JoinQueue.ToggleButton()
			end
		end
	})
	queuetojoin = JoinQueue.CreateDropdown({
		Name = 'QueueType',
		List = dumpmeta(),
		Function = function() end
	})
	task.spawn(function()
		repeat task.wait() until shared.VapeFullyLoaded 
		for i,v in next, bedwars.QueueMeta do 
			if i == store.queueType then 
				queuetojoin.SetValue(v.title) 
			end
		end
	end)
end)

run(function() 
	local AutoBedDefense = {}
	AutoBedDefense = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoBedDefense',
		HoverText = 'Auto puts bed defense the moment u get blocks (useful when someone spams fireballs at ur bed)',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					while wait(1) and AutoBedDefense.Enabled do
						--GuiLibrary.ObjectsThatCanBeSaved.VoidwareWindow.Api.OptionsButtons.BedProtector.ToggleButton(true)
						GuiLibrary.ObjectsThatCanBeSaved.BedProtectorOptionsButton.Api.ToggleButton()
					end
				end)
			end
		end
	})
end)

local playerRaycasted = function() return true end

playerRaycasted = function(plr, customvector)
	plr = plr or lplr
	return workspace:Raycast(plr.Character.PrimaryPart.Position, customvector or Vector3.new(0, -2000, 0), store.blockRaycast)
end

local GetTarget = function() return {} end

GetTarget = function(distance, healthmethod, raycast, npc, mouse, bypass)
	local magnitude, target = distance or math.huge, {}
	if healthmethod or mouse then 
		magnitude = math.huge 
	end
	local mousepos = inputService:GetMouseLocation()
	local entcalculate = function(v, name)
		if v.PrimaryPart and v:FindFirstChildWhichIsA('Humanoid') then 
			local localpos = (isAlive(lplr, true) and lplr.Character.HumanoidRootPart.Position or RenderStore.LocalPosition or Vector3.zero)
			local vec, screen = worldtoscreenpoint(v.PrimaryPart.Position)
			local distance = (healthmethod and v.Humanoid.Health or mouse and (mousepos - Vector2.new(vec.X, vec.Y)).Magnitude or (localpos - v.PrimaryPart.Position).Magnitude)
			local raycast = (playerRaycasted({Character = v}) or not raycast)
			if mouse and not screen and not bypass then 
				return 
			end
			if distance < magnitude and raycast then 
				magnitude = distance
				target.Human = false
				target.Player = {Name = name, DisplayName = name, UserId = 1, Character = v}
				target.RootPart = v.PrimaryPart
				target.Humanoid = v.Humanoid
				target.Player = v
			end
		end
	end
	if not isAlive(lplr, true) and not RenderStore.LocalPosition then 
		return target 
	end
	for i,v in next, playersService:GetPlayers() do 
		local localpos = (isAlive(lplr, true) and lplr.Character.HumanoidRootPart.Position or RenderStore.LocalPosition or Vector3.zero)
		if v ~= lplr and isAlive(v) and isAlive(lplr, true) then 
			if not RenderFunctions:GetPlayerType(2, v) then 
				continue
			end
			--[[if not ({whitelist:get(v)})[2] then
				continue
			end--]]
			if not entityLibrary.isPlayerTargetable(v) then 
				continue
			end
			if not playerRaycasted(v) and raycast then 
				continue
			end
			if healthmethod and v.Character:GetAttribute('Health') < magnitude then 
				magnitude = v.Character:GetAttribute('Health')
				target.Human = true
				target.RootPart = v.Character.HumanoidRootPart
				target.Humanoid = v.Character.Humanoid
				target.Player = v
				continue
			end 
			if mouse then 
				local vec, screen = worldtoscreenpoint(v.Character.HumanoidRootPart.Position)
				local mousedistance = (mousepos - Vector2.new(vec.X, vec.Y)).Magnitude
				if mousedistance < magnitude and (screen or bypass) then 
					magnitude = mousedistance
					target.Human = true
					target.RootPart = v.Character.HumanoidRootPart
					target.Humanoid = v.Character.Humanoid
					target.Player = v
				end
				continue
			end
			local playerdistance = (localpos - v.Character.HumanoidRootPart.Position).Magnitude
			if playerdistance < magnitude then 
				magnitude = playerdistance
				target.Human = true
				target.RootPart = v.Character.HumanoidRootPart
				target.Humanoid = v.Character.Humanoid
				target.Player = v
			end
		end
	end
	if npc and isAlive(lplr, true) then 
		local entities = {
			Monster = collectionService:GetTagged('Monster'),
			DiamondGuardian = collectionService:GetTagged('DiamondGuardian'),
			Titan = collectionService:GetTagged('GolemBoss'),
			Drone = collectionService:GetTagged('Drone'),
			Monarch = collectionService:GetTagged('GooseBoss'),
			Dummy = collectionService:GetTagged('trainingRoomDummy')
		}
		for i,v in entities do 
			for i2, ent in next, v do 
				entcalculate(ent, i)
			end
		end
	end
	return target
end

local GetAllTargets = function() return {} end

GetAllTargets = function(distance, mobs, raycast, sort)
	local targets = {}
	local entities = {
		Monster = collectionService:GetTagged('Monster'),
		DiamondGuardian = collectionService:GetTagged('DiamondGuardian'),
		Titan = collectionService:GetTagged('GolemBoss'),
		Drone = collectionService:GetTagged('Drone'),
		Monarch = collectionService:GetTagged('GooseBoss'),
		Dummy = collectionService:GetTagged('trainingRoomDummy')
	}
	for i,v in next, playersService:GetPlayers() do 
		if v ~= lplr and isAlive(v) and isAlive(lplr, true) then 
			if not VoidwareFunctions:GetPlayerType(2, v) then 
				continue
			end
			if not entityLibrary.isPlayerTargetable(v) then 
				continue
			end
			local playerdistance = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
			if playerdistance <= (distance or math.huge) then 
				table.insert(targets, {Human = true, RootPart = v.Character.PrimaryPart, Humanoid = v.Character.Humanoid, Player = v, JumpTick = tick()})
			end
		end
	end
	if mobs then 
		for i, entdata in next, entities do 
			for i2, v in next, entdata do 
				if isAlive(lplr, true) then 
					if type(v) == 'userdata' and v:IsA('Model') and v.PrimaryPart then 
						local entdistance = (lplr.Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude
						if entdistance <= (distance or math.huge) then 
							table.insert(targets, {Human = false, RootPart = v.PrimaryPart, Humanoid = v:FindFirstChildWhichIsA('Humanoid'), Player = {Character = v, Name = i, DisplayName = i, UserId = 1, JumpTick = tick()}})
						end
					end
				end
			end
		end
	end
	if sort then 
		table.sort(targets, sort)
	end
	return targets
end

run(function()
	local BowExploit = {}
	local BowExploitMobs = {}
	local BowExploitTarget = {Value = 'Mouse'}
	local BowExploitAutoShootFOV = {Value = 1000}
	local oldrealremote
	local noveloproj = {
		'fireball',
		'telepearl'
	}

	BowExploit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'ProjectileExploit',
		Function = function(calling)
			if calling then 
				oldrealremote = bedwars.ClientConstructor.Function.new
				bedwars.ClientConstructor.Function.new = function(self, ind, ...)
					local res = oldrealremote(self, ind, ...)
					local oldRemote = res.instance
					if oldRemote and oldRemote.Name == bedwars.ProjectileRemote then 
						res.instance = {InvokeServer = function(self, shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...) 
							local extra = ({...})
							local plr
							if BowExploitTarget.Value == 'Mouse' then 
								plr = GetTarget(nil, nil, nil, BowExploitMobs.Enabled, true)
							else
								plr = GetTarget(nil, nil, nil, BowExploitMobs.Enabled)
							end
							if extra[2] == 'fireball' then 
								plr = {}
							end
							if type(extra[2]) == 'table' then 
								plr = extra[2] 
							end
							if plr.RootPart then
								store.switchdelay = tick() + 1.2
								task.wait()
								for i = 1, 5 do 
									switchItem(shooting) 
								end
								tab1.drawDurationSeconds = 1
								repeat
									task.wait(0.03)
									local offsetStartPos = plr.RootPart.CFrame.p - plr.RootPart.CFrame.lookVector
									local pos = plr.RootPart.Position
									local playergrav = workspace.Gravity
									local balloons = (plr.Human and plr.Player.Character:GetAttribute('InflatedBalloons'))
									if plr.Human and balloons and balloons > 0 then 
										playergrav = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
									end
									if plr.Human and plr.Player.Character.PrimaryPart:FindFirstChild('rbxassetid://8200754399') then 
										playergrav = (workspace.Gravity * 0.3)
									end
									plr.JumpTick = tick()
									local newLaunchVelo = bedwars.ProjectileMeta[proj2].launchVelocity
									local shootpos, shootvelo = predictGravity(pos, plr.RootPart.Velocity, (pos - offsetStartPos).Magnitude / newLaunchVelo, plr, playergrav)
									if proj2 == 'telepearl' then
										shootpos = pos
										shootvelo = Vector3.zero
									end
									local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))
									shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
									local calculated = LaunchDirection(offsetStartPos, shootpos, newLaunchVelo, workspace.Gravity, false)
									if calculated then 
										launchvelo = calculated
										launchpos1 = offsetStartPos
										launchpos2 = offsetStartPos
										tab1.drawDurationSeconds = 1
									else
										break
									end
									if oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, workspace:GetServerTimeNow() - 0.045) then break end
								until false
							else
								return oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
							end
						end}
					end
					return res
				end
			else
				bedwars.ClientConstructor.Function.new = oldrealremote
				oldrealremote = nil
			end
		end
	})
	BowExploitTarget = BowExploit.CreateDropdown({
		Name = 'Mode',
		List = {'Mouse', 'Range'},
		Function = function() end
	})
	BowExploitAutoShootFOV = BowExploit.CreateSlider({
		Name = 'FOV',
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
	BowExploitMobs = BowExploit.CreateToggle({
		Name = 'NPC',
		HoverText = 'Targets NPCs too.',
		Function = function() end
	})
end)

local httpService = game:GetService("HttpService")

run(function()
	local ProjectileAura = {}
	local ProjectileAuraSort = {Value = 'Distance'}
	local ProjectileAuraMobs = {}
	local ProjectileAuraRangeSlider = {Value = 50}
	local ProjectileAuraRange = {}
	local ProjectileAuraBlacklist = {ObjectList = {}}
	local ProjectileMobIgnore = {'spear'}
	local ProjectileAuraDelay = {Value = 0}
	local ProjectileAuraSwitchDelay = {Value = 0}
	local crackerdelay = tick()
	local specialprojectiles = {
		rainbow_bow = 'rainbow_arrow',
		orions_belt_bow = 'star',
		fireball = 'fireball',
		frosted_snowball = 'frosted_snowball',
		snowball = 'snowball',
		spear = 'spear',
		carrot_cannon = 'carrot_rocket',
		light_sword = 'sword_wave1',
		firecrackers = 'firecrackers'
	}
	local biggestTargets = {
		spirit_assassin = 1,
		hannah = 2,
		melody = 3,
		kaliyah = 4
	}
	local sortfunctions = {
		Distance = function()
			return GetTarget(ProjectileAuraRange.Enabled and ProjectileAuraRangeSlider.Value, nil, true, ProjectileAuraMobs.Enabled)
		end,
		Health = function()
			return GetTarget(nil, true, true, ProjectileAuraMobs.Enabled)
		end,
		Mouse = function()
			return GetTarget(nil, nil, true, ProjectileAuraMobs.Enabled, true, true)
		end, 
		Kit = function() 
			local target, prio = {}, -1
			for i,v in next, GetAllTargets() do
				local kit = (v.Player:GetAttribute('PlayingAsKit') or 'none')
				local kitprio = (biggestTargets[kit] or 0)
				if kitprio > prio then 
					target = v
				end
			end
			if prio < 1 then 
				return GetTarget(nil, nil, true)
			end
			return target
		end
	}
	local function betterswitch(item)
		if tostring(item) == 'firecrackers' then 
			if crackerdelay > tick() then 
				return 
			else 
				crackerdelay = tick() + 3.5 
			end 
		end
		if tick() > store.switchdelay then 
			switchItem(item) 
		end
		local oldval = ProjectileAuraSwitchDelay.Value
		local valdelay = (tick() + ProjectileAuraSwitchDelay.Value)
		repeat task.wait() until (tick() > valdelay or ProjectileAuraSwitchDelay.Value ~= oldval)
	end
	local function getarrow()
		for i,v in next, store.localInventory.inventory.items do  
			if v.itemType:find('arrow') then 
				return v 
			end
		end
	end
	local function getammo(item)
		if (item.itemType:find('bow') or item.itemType:find('headhunter')) and specialprojectiles[item.itemType] == nil then 
			return getarrow() or {} 
		end
		if item.itemType:find('ninja_chakram') then 
			return getItem(item.itemType) 
		end
		if item.itemType == 'light_sword' then 
			return {tool = 'sword_wave1'} 
		end
		local special = specialprojectiles[item.itemType]
		for i,v in next, ProjectileAuraBlacklist.ObjectList do 
			if item.itemType:find(v:lower()) then 
				return {} 
			end 
		end 
		if special then 
			return getItem(special) or {} 
		end
		return {}
	end
	ProjectileAura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'ProjectileAura',
		HoverText = 'Automatically shoots hostile projectiles\nwithout aiming.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat 
						local range = (ProjectileAuraRange.Enabled and ProjectileAuraRangeSlider.Value or 9e9)
						local target = sortfunctions[ProjectileAuraSort.Value]()
						if target.RootPart and target.RootPart.Parent:FindFirstChildWhichIsA('ForceField') == nil then 
							for i,v in next, store.localInventory.inventory.items do 
								local ammo = getammo(v)
								if target.Human == nil and table.find(ProjectileMobIgnore, v.itemType) or tweenInProgress() then 
									continue 
								end 
								if store.matchState ~= 0 and store.equippedKit == 'dragon_sword' then 
									bedwars.Client:Get('DragonSwordFire'):SendToServer({target = target.RootPart.Parent}) 
								end
								if ammo.tool then 
									betterswitch(v.tool)
									bedwars.Client:Get(bedwars.ProjectileRemote):CallServerAsync(v.tool, tostring(ammo.tool), tostring(ammo.tool) == 'star' and 'star_projectile' or tostring(ammo.tool) == 'mage_spell_base' and target.RootPart.Position + Vector3.new(0, 3, 0) or tostring(ammo.tool), target.RootPart.Position + Vector3.new(0, 3, 0), target.RootPart.Position + Vector3.new(0, 3, 0), Vector3.new(0, -1, 0), httpService:GenerateGUID(), {drawDurationSeconds = 1}, workspace:GetServerTimeNow(), target)
								end
							end
						end
						store.switchdelay += (ProjectileAuraDelay.Value * 0.2)
						if RenderStore.ping > 1000 then 
							store.switchdelay += (store.switchdelay + 8)
						end
						task.wait(getItem('star') and 0 or killauraNearPlayer and 0.25 or ProjectileAuraDelay.Value + 0.15)
					until not ProjectileAura.Enabled
				end)
			end
		end
	})
	ProjectileAuraBlacklist = ProjectileAura.CreateTextList({
		Name = 'Blacklisted Projectiles',
		TempText = 'blacklisted items',
		AddFunction = function() end
	})
	ProjectileAuraSort = ProjectileAura.CreateDropdown({
		Name = 'Sort',
		List = dumptable(sortfunctions, 1),
		Function = function(method)
			pcall(function() ProjectileAuraRange.Object.Visible = (method == 'Distance') end) 
			pcall(function() ProjectileAuraRangeSlider.Object.Visible = (method == 'Distance' and ProjectileAuraRange.Enabled) end) 
			pcall(function() ProjectileAuraMobs.Object.Visible = (method ~= 'Kit') end)
		end
	})
	ProjectileAuraDelay = ProjectileAura.CreateSlider({
		Name = 'Target Delay',
		Min = 0,
		Max = 60,
		Function = function() 
			store.switchdelay = tick() 
		end
	})
	ProjectileAuraSwitchDelay = ProjectileAura.CreateSlider({
		Name = 'Switch Delay',
		Min = 0,
		Max = 60,
		Function = function() 
			store.switchdelay = tick() 
		end
	})
	ProjectileAuraRange = ProjectileAura.CreateToggle({
		Name = 'Range Check',
		Function = function(calling) 
			pcall(function() ProjectileAuraRangeSlider.Object.Visible = calling end)
		end 
	}) 
	ProjectileAuraRangeSlider = ProjectileAura.CreateSlider({
		Name = 'Range',
		Min = 5,
		Max = 80,
		Default = 75,
		Function = function() end
	})
	ProjectileAuraMobs = ProjectileAura.CreateToggle({
		Name = 'NPC',
		HoverText = 'Targets NPCs too.',
		Function = function() end 
	})
	ProjectileAuraRange.Object.Visible = false
	ProjectileAuraRangeSlider.Object.Visible = false
	ProjectileAuraMobs.Object.Visible = false
end)
																																																	
run(function()
	local lplr = game.Players.LocalPlayer
	local plrgui = lplr.PlayerGui
	local deathscounter = 0
	local regiondisplay = plrgui:WaitForChild("ServerRegionDisplay").ServerRegionText.Text
	local playerded = false 
	local debouncegaming = false
	local SessionInfo = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "SessionInfo Custom",
		HoverText = "Customizable session info.",
		Function = function(callback)
			if callback then 
				local function extractnumber(text)
					local number = text:match("<b>(%d+)</b>")
					return tonumber(number)
				end
				local function extracttimer(text)
					local minutes, seconds = text:match("<b>(%d+:%d+)</b>")
					return minutes
				end
				local function extractregion(text)
					local region = text:match("REGION:%s*([^<]+)")
					return region
				end
				
				local Converted = {
					["_SessionInfo"] = Instance.new("ScreenGui");
					["_Background"] = Instance.new("Frame");
					["_UICorner"] = Instance.new("UICorner");
					["_SessionInfoLabel"] = Instance.new("TextLabel");
					["_TimePlayed"] = Instance.new("TextLabel");
					["_Kills"] = Instance.new("TextLabel");
					["_Deaths"] = Instance.new("TextLabel");
					["_Region"] = Instance.new("TextLabel");
					["_DropShadowHolder"] = Instance.new("Frame");
					["_DropShadow"] = Instance.new("ImageLabel");
				}
				
				Converted["_SessionInfo"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				Converted["_SessionInfo"].Name = "SessionInfo"
				Converted["_SessionInfo"].Parent = plrgui
				Converted["_SessionInfo"].ResetOnSpawn = false
				
				Converted["_Background"].BackgroundColor3 = Color3.fromHSV(0, 0, 0)
				Converted["_Background"].BackgroundTransparency = 0.800000011920929
				Converted["_Background"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_Background"].BorderSizePixel = 0
				Converted["_Background"].Position = UDim2.new(0.0116598075, 0, 0.375, 0)
				Converted["_Background"].Size = UDim2.new(0.128257886, 0, 0.16310975, 0)
				Converted["_Background"].Name = "Background"
				Converted["_Background"].Parent = Converted["_SessionInfo"]
				
				Converted["_UICorner"].Parent = Converted["_Background"]
				
				Converted["_SessionInfoLabel"].Font = Enum.Font.SourceSansBold
				Converted["_SessionInfoLabel"].Text = "Session Info"
				Converted["_SessionInfoLabel"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_SessionInfoLabel"].TextScaled = true
				Converted["_SessionInfoLabel"].TextSize = 14
				Converted["_SessionInfoLabel"].TextWrapped = true
				Converted["_SessionInfoLabel"].TextXAlignment = Enum.TextXAlignment.Left
				Converted["_SessionInfoLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_SessionInfoLabel"].BackgroundTransparency = 1
				Converted["_SessionInfoLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_SessionInfoLabel"].BorderSizePixel = 0
				Converted["_SessionInfoLabel"].Position = UDim2.new(0.0374331549, 0, 0, 0)
				Converted["_SessionInfoLabel"].Size = UDim2.new(1, 0, 0.242990658, 0)
				Converted["_SessionInfoLabel"].Name = "SessionInfoLabel"
				Converted["_SessionInfoLabel"].Parent = Converted["_Background"]
				
				Converted["_TimePlayed"].Font = Enum.Font.SourceSans
				Converted["_TimePlayed"].Text = "Time Played: 00:00" 
				Converted["_TimePlayed"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_TimePlayed"].TextScaled = true
				Converted["_TimePlayed"].TextSize = 14
				Converted["_TimePlayed"].TextWrapped = true
				Converted["_TimePlayed"].TextXAlignment = Enum.TextXAlignment.Left
				Converted["_TimePlayed"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_TimePlayed"].BackgroundTransparency = 1
				Converted["_TimePlayed"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_TimePlayed"].BorderSizePixel = 0
				Converted["_TimePlayed"].Position = UDim2.new(0.0374331549, 0, 0.275288522, 0)
				Converted["_TimePlayed"].Size = UDim2.new(1, 0, 0.168224305, 0)
				Converted["_TimePlayed"].Name = "TimePlayed"
				Converted["_TimePlayed"].Parent = Converted["_Background"]
				
				Converted["_Kills"].Font = Enum.Font.SourceSans
				Converted["_Kills"].Text = "Kills: 0" 
				Converted["_Kills"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_Kills"].TextScaled = true
				Converted["_Kills"].TextSize = 14
				Converted["_Kills"].TextWrapped = true
				Converted["_Kills"].TextXAlignment = Enum.TextXAlignment.Left
				Converted["_Kills"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_Kills"].BackgroundTransparency = 1
				Converted["_Kills"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_Kills"].BorderSizePixel = 0
				Converted["_Kills"].Position = UDim2.new(0.0374331549, 0, 0.445024729, 0)
				Converted["_Kills"].Size = UDim2.new(1, 0, 0.168224305, 0)
				Converted["_Kills"].Name = "Kills"
				Converted["_Kills"].Parent = Converted["_Background"]
				
				Converted["_Deaths"].Font = Enum.Font.SourceSans
				Converted["_Deaths"].Text = "Deaths: 0"
				Converted["_Deaths"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_Deaths"].TextScaled = true
				Converted["_Deaths"].TextSize = 14
				Converted["_Deaths"].TextWrapped = true
				Converted["_Deaths"].TextXAlignment = Enum.TextXAlignment.Left
				Converted["_Deaths"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_Deaths"].BackgroundTransparency = 1
				Converted["_Deaths"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_Deaths"].BorderSizePixel = 0
				Converted["_Deaths"].Position = UDim2.new(0.0374331549, 0, 0.614760935, 0)
				Converted["_Deaths"].Size = UDim2.new(1, 0, 0.168224305, 0)
				Converted["_Deaths"].Name = "Deaths"
				Converted["_Deaths"].Parent = Converted["_Background"]
				
				Converted["_Region"].Font = Enum.Font.SourceSans
				Converted["_Region"].Text = "Region: "..extractregion(regiondisplay)
				Converted["_Region"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_Region"].TextScaled = true
				Converted["_Region"].TextSize = 14
				Converted["_Region"].TextWrapped = true
				Converted["_Region"].TextXAlignment = Enum.TextXAlignment.Left
				Converted["_Region"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_Region"].BackgroundTransparency = 1
				Converted["_Region"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_Region"].BorderSizePixel = 0
				Converted["_Region"].Position = UDim2.new(0.0374331549, 0, 0.78298521, 0)
				Converted["_Region"].Size = UDim2.new(1, 0, 0.168224305, 0)
				Converted["_Region"].Name = "Region"
				Converted["_Region"].Parent = Converted["_Background"]
				
				Converted["_DropShadowHolder"].BackgroundTransparency = 1
				Converted["_DropShadowHolder"].BorderSizePixel = 0
				Converted["_DropShadowHolder"].Size = UDim2.new(1, 0, 1, 0)
				Converted["_DropShadowHolder"].ZIndex = 0
				Converted["_DropShadowHolder"].Name = "DropShadowHolder"
				Converted["_DropShadowHolder"].Parent = Converted["_Background"]
				
				Converted["_DropShadow"].Image = "rbxassetid://6014261993"
				Converted["_DropShadow"].ImageColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_DropShadow"].ImageTransparency = 0.5
				Converted["_DropShadow"].ScaleType = Enum.ScaleType.Slice
				Converted["_DropShadow"].SliceCenter = Rect.new(49, 49, 450, 450)
				Converted["_DropShadow"].AnchorPoint = Vector2.new(0.5, 0.5)
				Converted["_DropShadow"].BackgroundTransparency = 1
				Converted["_DropShadow"].BorderSizePixel = 0
				Converted["_DropShadow"].Position = UDim2.new(0.5, 0, 0.5, 0)
				Converted["_DropShadow"].Size = UDim2.new(1, 47, 1, 47)
				Converted["_DropShadow"].ZIndex = 0
				Converted["_DropShadow"].Name = "DropShadow"
				Converted["_DropShadow"].Parent = Converted["_DropShadowHolder"]
				
				local function timerupdate()
					while true do
						wait()
						local timercounter = plrgui.TopBarAppGui.TopBarApp["2"]["5"].Text
						local timergaming = extracttimer(timercounter)
						Converted["_TimePlayed"].Text = "Time Played: " .. timergaming
					end
				end
				
				local function killsupdate()
					while true do
						wait()
						local killscounter = plrgui.TopBarAppGui.TopBarApp["3"]["5"].Text
						local kills = extractnumber(killscounter)
						Converted["_Kills"].Text = "Kills: " .. kills
					end
				end
				
				local function deathcounterfunc()
					local humanoid = lplr.Character:WaitForChild("Humanoid")
					humanoid.HealthChanged:Connect(function(health)
						if not debouncegaming then
							debouncegaming = true
							if health <= 0 and not playerded then
								deathscounter = deathscounter + 1
								Converted["_Deaths"].Text = "Deaths: " .. deathscounter
								playerded = true
								debouncegaming = false
								wait(1) 
							elseif health > 0 and playerded then
								playerded = false
							end
						end
					end)
				end
				
				task.spawn(timerupdate)
				task.spawn(killsupdate)
				task.spawn(deathcounterfunc)	
			else 
				local plrgui = game.Players.LocalPlayer.PlayerGui
				if plrgui:FindFirstChild("SessionInfo") then 
					local sessioninfo = plrgui.SessionInfo
					sessioninfo:Destroy()
				else 
					ErrorWarning("SessionInfo", "Session Info not found, please dm salad about this.", 30)
				end
			end
		end
	})
	SessioninfoBgColor = SessionInfo.CreateColorSlider({
		Name = "Background Color",
		Function = function(h, s, v) 
			if game.Players.LocalPlayer.PlayerGui:FindFirstChild("SessionInfo") then 
				game.Players.LocalPlayer.PlayerGui.SessionInfo.Background.BackgroundColor3 = Color3.fromHSV(h, s, v)
			else
				print("no session info found lol")
			end
		end
	})
end)

local function instawin()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    for _, part in pairs(game.Workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            for _, child in pairs(part:GetChildren()) do
                if child:IsA("TouchTransmitter") then
                    firetouchinterest(humanoidRootPart, part, 0)
                    firetouchinterest(humanoidRootPart, part, 1)
                end
            end
        end
    end
end

run(function()
    local isEnabled = false
    local credits
    local instaWinExploit = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = "BridgeduelsInstawin",
        Function = function(callback)
            isEnabled = callback
            if callback then
                task.spawn(function()
                    while isEnabled do
                        instawin()
                        wait(0.1)
                    end
                end)
            end
        end,
        HoverText = "Instantly wins every game for you"
    })
	credits = instaWinExploit.CreateCredits({
        Name = 'CreditsButtonInstance',
        ButtonText = 'Show Credits',
        Credits = 'Vape+ Booster'
    })
end)

--[[run(function()
	local ShellExploit = {}
	local shells = {}
	local function remove_esp(part)
		if part.Token:FindFirstChild("Highlight_ESP") then
			part.Token:FindFirstChild("Highlight_ESP"):Destroy()
		else warn("No highlight found!") end
	end
	local function add_esp(part)
		local create = function(part)
			local highlight = Instance.new("Highlight")
			highlight.FillColor = Color3.new(236, 237, 41)
			highlight.Name = "Highlight_ESP"
			highlight.Parent = part.Token
		end
		if part.Token:FindFirstChild("Highlight_ESP") then remove_esp(part) create(part) else
			create(part)
		end
	end
	ShellExploit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'ShellExploit',
		HoverText = 'Makes esp for u to see the shells',
		Function = function(calling)
			if calling then 
				local neeeded_item_name = "Summer2024KillToken"
				local workspace = game:GetService("Workspace")
				local workspace_children = workspace:GetChildren()
				for i,v in pairs(workspace_children) do
					if workspace_children[i].Name == neeeded_item_name then
						add_esp(workspace_children[i])
						table.insert(shells, workspace_children[i])
					end
				end
				workspace.ChildRemoved:Connect(function(child)
					if child.Name == neeeded_item_name then
						remove_esp(child)
						for i,v in pairs(shells) do if shells[i] == child then table.remove(shells, tonumber(i)) end end
					end
				end)
				workspace.ChildAdded:Connect(function(child)
					if child.Name == neeeded_item_name then
						add_esp(child)
						table.insert(shells, child)
					end
				end)
				local needed_parent = {}
				for i,v in pairs(shells) do
					shells[i].Parent = game.Attributes
				end
			else
				for i,v in pairs(shells) do
					remove_esp(shells[i])
				end
			end
		end
	})
end)--]]

run(function()
	local SpawnParts = {}
	local SpawnPartColor
	local realspawnpart
	local SpawnESP = {Enabled = false}
	SpawnESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "SpawnESP",
		Function = function(callback)
			if callback then 
				task.spawn(function()
				for i,v2 in pairs(workspace.MapCFrames:GetChildren()) do 
					if v2.Name:find("spawn") and v2.Name ~= "spawn" and v2.Name:find("respawn") == nil then
						realspawnpart = Instance.new("Part")
						realspawnpart.Size = Vector3.new(1, 1000, 1)
						realspawnpart.Position = v2.Value.p
						realspawnpart.Anchored = true
						realspawnpart.Parent = workspace
						realspawnpart.CanCollide = false
						realspawnpart.Transparency = 0.5
						realspawnpart.Material = Enum.Material.Neon
						realspawnpart.Color = Color3.fromHSV(SpawnPartColor.Hue, SpawnPartColor.Sat, SpawnPartColor.Value)
						bedwars.QueryUtil:setQueryIgnored(realspawnpart, true)
						table.insert(SpawnParts, realspawnpart)
					end
				end
			end)
			else
				for i,v in pairs(SpawnParts) do pcall(function() v:Destroy() end) end
				table.clear(SpawnParts)
			end
		end
	})
	SpawnPartColor = SpawnESP.CreateColorSlider({
		Name = "Color",
		Function = function(h, s, v) if SpawnESP.Enabled then for i,v in pairs(SpawnParts) do pcall(function() v.Color = Color3.fromHSV(SpawnPartColor.Hue, SpawnPartColor.Sat, SpawnPartColor.Value) end) end end end
	})
end)

run(function()
	local StaffDetector = {}
	local StaffDetectorMode = {Value = 'Lobby'}
	local StaffDetectorFamous = {}
	local StaffDetectorManual = {ObjectList = {}}
	local credits 
	local legitgamers = {}
	local staffconfig = {legitmessages = {}, staffaccounts = {}, legitmodules = {}}
	local cachedfriends = {}
	local cachedroles = {}
	local knownstaff = {}
	local actionperformed
	local olderror = errorNotification
	local errorNotification = function(title: string, text: string, duration: number)
		if StaffDetectorMode.Value == 'Uninject' then 
			return game.GetService(game, 'StarterGui'):SetCore('SendNotification', ({
				Title = title, 
				Text = text, 
				Duration = duration
			})) 
		end
		return olderror(title, text, duration)
	end
	local staffactions = {
		Uninject = GuiLibrary.SelfDestruct,
		Lobby = function()
			teleportService:Teleport(6872265039)
		end,
		Config = function()
			for i,v in next, GuiLibrary.ObjectsThatCanBeSaved do 
				if v.Type == 'OptionsButton' and table.find(staffconfig.legitmodules, i:gsub('OptionsButton', '')) == nil then 
					GuiLibrary.SaveSettings = function() end
					if v.Api.Enabled then
						v.Api.ToggleButton()
					end
					pcall(GuiLibrary.RemoveObject, i)
				end
			end
		end
	}
	for i,v in next, staffactions do 
		local oldfunc = staffactions[i]
		staffactions[i] = function()
			actionperformed = true 
			return oldfunc()
		end
	end
	local function savestaffConfig(plr, detection)
		local success, json = pcall(function() 
			return httpService:JSONDecode(readfile('vape/Libraries/staffdata.json'))
		end)
		if not success then 
			json = {}
		end
		table.insert(json, {Username = plr.Name, DisplayName = plr.DisplayName, Detection = detection, Tick = tick()})
		if isfolder('vape/Libraries') then 
			writefile('vape/Libraries/staffdata.json', httpService:JSONEncode(json))
		end
	end
	local function GetRobloxFriends(plr)
		local friends = {}
		local success, page = pcall(playersService.GetFriendsAsync, playersService, plr.UserId)
		if success then
			repeat
				for i,v in next, page:GetCurrentPage() do
					table.insert(friends, v.UserId)
				end
				if not page.IsFinished then 
					page:AdvanceToNextPageAsync()
				end
			until page.IsFinished
		end
		return friends
	end
	local function friendActive(friendtab)
		for i,v in next, friendtab do 
			local friend = playersService:GetPlayerByUserId(v)
			if friend then 
				return friend 
			end
		end
	end
	local function matchtag(tag: Instance)
		if tag.Value:lower():find('mod') or tag.Value:lower():find('dev') or tag.Value:lower():find('owner') then 
			return 'has a moderation rank in bedwars.'
		end
		if StaffDetectorFamous.Enabled and tag.Value:lower():find('famous') then 
			return 'is a famous creator in bedwars.'
		end
	end
	local function staffDetectorFunction(player)
		task.spawn(function()
			local tags = player:WaitForChild('Tags', 9e9)
			local addconnection
			for i,v in next, tags:GetChildren() do 
				if v:IsA('StringValue') then 
					local report = matchtag(v)
					if report then 
						savestaffConfig(player, 'illegal_tag')
						bedwars.LobbyEvents.leaveParty:FireServer()
						errorNotification('StaffDetector', player.DisplayName..' '..report, 60)
						return actionperformed or staffactions[StaffDetectorMode.Value]()
					end
				end
			end
			addconnection = tags.ChildAdded:Connect(function(v)
				local report = matchtag(v)
				if report then 
					addconnection:Disconnect()
					savestaffConfig(player, 'illegal_tag')
					bedwars.LobbyEvents.leaveParty:FireServer()
					errorNotification('StaffDetector', player.DisplayName..' '..report, 60)
					return actionperformed or staffactions[StaffDetectorMode.Value]()
				end
			end)
			table.insert(StaffDetector.Connections, addconnection)
		end)
		repeat 
			for i,v in next, StaffDetectorManual.ObjectList do 
				if player.Name:lower() == v:lower() or tonumber(v) == tonumber(player.UserId) then 
					savestaffConfig(player, 'manual_user')
					bedwars.LobbyEvents.leaveParty:FireServer()
					errorNotification('StaffDetector', player.DisplayName..' is currently in your blacklisted user list.', 60)
					return actionperformed or staffactions[StaffDetectorMode.Value]()
				end
			end
			local friends = (cachedfriends[player] or GetRobloxFriends(player))
			cachedfriends[player] = friends
			if player:GetAttribute('Spectator') and table.find(legitgamers, player) == nil and friendActive(friends) == nil and bedwars.ClientStoreHandler:getState().Game.customMatch == nil then 
				savestaffConfig(player, 'illegal_join')
				bedwars.LobbyEvents.leaveParty:FireServer()
				errorNotification('StaffDetector', player.DisplayName..' is overwatching you.', 60)
				return actionperformed or staffactions[StaffDetectorMode.Value]()
			end
			if table.find(legitgamers, player) == nil and tostring(player.Team) ~= 'Neutral' and not player:GetAttribute('Spectator') then 
				table.insert(legitgamers, player)
			end
			if table.find(staffconfig.staffaccounts, player.UserId) or table.find(knownstaff, player.UserId) then 
				savestaffConfig(player, 'blacklisted_users')
				bedwars.LobbyEvents.leaveParty:FireServer()
				errorNotification('StaffDetector', player.DisplayName..' is cached on staff json.', 60)
				return actionperformed or staffactions[StaffDetectorMode.Value]()
			end
			local success, response = true, cachedroles[player]
			if response == nil then 
				success, response = pcall(player.GetRoleInGroup, lplr, 5774246)
			end
			cachedroles[player] = response 
			if tonumber(response) and tonumber(response) >= 121 then 
				savestaffConfig(player, 'group_rank')
				bedwars.LobbyEvents.leaveParty:FireServer()
				errorNotification('StaffDetector', player.DisplayName..' has a high role in the Easy.gg group (GetRoleInGroup() >= 121).', 60)
				return actionperformed or staffactions[StaffDetectorMode.Value]()
			end
			task.wait()
		until (not StaffDetector.Enabled)
	end
	StaffDetector = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'StaffDetector',
		HoverText = 'Detects when bedwars staff are in the server (75% accuracy).',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					if store.matchState ~= 0 then 
						return 
					end
					pcall(function() staffconfig = httpService:JSONDecode(RenderFunctions:GetFile('Libraries/staffconfig.json')) end)
					pcall(function() knownstaff = httpService:JSONDecode(RenderFunctions:GetFile('Libraries/knownstaff.json')) end)
					pcall(function() 
						for i,v in next, httpService:JSONDecode(readfile('vape/Libraries/staffdata.json')) do 
							if table.find(knownstaff, v) == nil then 
								table.insert(knownstaff, v)
							end
						end
					end)
					repeat task.wait() until (shared.VapeFullyLoaded or not StaffDetector.Enabled)
					if not StaffDetector.Enabled then 
						return 
					end
					for i,v in next, playersService:GetPlayers() do 
						if v ~= lplr then
							task.spawn(staffDetectorFunction, v)
						end
					end
					table.insert(vapeConnections, playersService.PlayerAdded:Connect(staffDetectorFunction))
				end)
			end
		end
	})
	StaffDetectorMode = StaffDetector.CreateDropdown({
		Name = 'Action',
		List = dumptable(staffactions, 1),
		Function = function() end
	})
	StaffDetectorManual = StaffDetector.CreateTextList({
		Name = 'Accounts',
		TempText = 'accounts (user/id)',
		AddFunction = function() end,
	})
	StaffDetectorFamous = StaffDetector.CreateToggle({
		Name = 'Famous',
		HoverText = 'Detects famous bedwars creators',
		Function = function() end
	})
	Credits = StaffDetector.CreateCredits({
		Name = 'CreditsButtonInstance',
        Credits = 'Render'
	})
end)

run(function()
    local btext = function(text: string): string
        return text .. ' '
    end
    local antiDeath = {}
    local antiDeathConfig = {
        Mode = {},
        BoostMode = {},
        SongId = {},
        Health = {},
        Velocity = {},
        CFrame = {},
        TweenPower = {},
        TweenDuration = {},
        SkyPosition = {},
        AutoDisable = {},
        Sound = {},
        Notify = {}
    }
    local antiDeathState = {}
    local handlers = {}

    local playSound = function(soundID, loop)
        soundID = (soundID or ''):gsub('rbxassetid://', '')
        local sound = Instance.new('Sound')
        sound.Looped = loop and true or false
        sound.Parent = workspace
        sound.SoundId = 'rbxassetid://' .. soundID
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
        return sound
    end

    local function getHealth(player)
        player = player or lplr
        return player.Character.Humanoid.Health
    end

    function handlers.new()
        local self = {
            boost = false,
            inf = false,
            notify = false,
            id = false,
            hrp = entityLibrary.character.HumanoidRootPart,
            hasNotified = false
        }
        setmetatable(self, { __index = handlers })
        return self
    end

    function handlers:enable()
        RunLoops:BindToHeartbeat('antiDeath', function()
            if not isAlive(lplr, true) then
                self:disable()
                return
            end

            if getHealth() <= antiDeathConfig.Health.Value and getHealth() > 0 then
                if not self.boost then
                    self:activateMode()
                    if not self.hasNotified and antiDeathConfig.Notify.Enabled then
                        self:sendNotification()
                    end
                    self:playNotificationSound()
                    self.boost = true
                end
            else
                self:resetMode()
                self.hrp.Anchored = false
                self.boost = false

                -- Reset the notification state when health is above the threshold
                if self.hasNotified then
                    self.hasNotified = false
                end
            end
        end)
    end

    function handlers:disable()
        RunLoops:UnbindFromHeartbeat('antiDeath')
    end

    function handlers:activateMode()
        local modeActions = {
            Infinite = function() self:enableInfiniteMode() end,
            Boost = function() self:applyBoost() end,
            Sky = function() self:moveToSky() end
        }
        modeActions[antiDeathConfig.Mode.Value]()
    end

    function handlers:enableInfiniteMode()
        if not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then
            GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.ToggleButton(true)
            self.inf = true
        end
    end

    function handlers:applyBoost()
        local boostActions = {
            Velocity = function() self.hrp.Velocity += vec3(0, antiDeathConfig.Velocity.Value, 0) end,
            CFrame = function() self.hrp.CFrame += vec3(0, antiDeathConfig.CFrame.Value, 0) end,
            Tween = function()
                tweenService:Create(self.hrp, twinfo(antiDeathConfig.TweenDuration.Value / 10), {
                    CFrame = self.hrp.CFrame + vec3(0, antiDeathConfig.TweenPower.Value, 0)
                }):Play()
            end
        }
        boostActions[antiDeathConfig.BoostMode.Value]()
    end

    function handlers:moveToSky()
        self.hrp.CFrame += vec3(0, antiDeathConfig.SkyPosition.Value, 0)
        self.hrp.Anchored = true
    end

    function handlers:sendNotification()
        InfoNotification('AntiDeath', 'Prevented death. Health is lower than ' .. antiDeathConfig.Health.Value ..
            '. (Current health: ' .. math.floor(getHealth() + 0.5) .. ')', 5)
        self.hasNotified = true
    end

    function handlers:playNotificationSound()
        if antiDeathConfig.Sound.Enabled then
            local soundId = antiDeathConfig.SongId.Value ~= '' and antiDeathConfig.SongId.Value or '7396762708'
            playSound(soundId, false)
        end
    end

    function handlers:resetMode()
        if self.inf then
            if antiDeathConfig.AutoDisable.Enabled then
                if GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then
                    GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.ToggleButton(false)
                end
            end
            self.inf = false

            -- Reset the notification state when Infinite Fly is disabled
            self.hasNotified = false
        end
    end

    local antiDeathStatus = handlers.new()

    antiDeath = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = 'AntiDeath',
        Function = function(callback)
            if callback then
                coroutine.wrap(function()
                    antiDeathStatus:enable()
                end)()
            else
                pcall(function()
                    antiDeathStatus:disable()
                end)
            end
        end,
        Default = false,
        HoverText = btext('Prevents you from dying.\nMade by Specter Solutions.'),
        ExtraText = function()
            return antiDeathConfig.Mode.Value
        end
    })

    antiDeathConfig.Mode = antiDeath.CreateDropdown({
        Name = 'Mode',
        List = { 'Infinite', 'Boost', 'Sky' },
        Default = 'Infinite',
        HoverText = btext('Mode to prevent death.'),
        Function = function(val)
            antiDeathConfig.BoostMode.Object.Visible = val == 'Boost'
            antiDeathConfig.SkyPosition.Object.Visible = val == 'Sky'
            antiDeathConfig.AutoDisable.Object.Visible = val == 'Infinite'
            antiDeathConfig.Velocity.Object.Visible = false
            antiDeathConfig.CFrame.Object.Visible = false
            antiDeathConfig.TweenPower.Object.Visible = false
            antiDeathConfig.TweenDuration.Object.Visible = false
        end
    })

    antiDeathConfig.BoostMode = antiDeath.CreateDropdown({
        Name = 'Boost',
        List = { 'Velocity', 'CFrame', 'Tween' },
        Default = 'Velocity',
        HoverText = btext('Mode to boost your character.'),
        Function = function(val)
            antiDeathConfig.Velocity.Object.Visible = val == 'Velocity'
            antiDeathConfig.CFrame.Object.Visible = val == 'CFrame'
            antiDeathConfig.TweenPower.Object.Visible = val == 'Tween'
            antiDeathConfig.TweenDuration.Object.Visible = val == 'Tween'
        end
    })
    antiDeathConfig.BoostMode.Object.Visible = false

    antiDeathConfig.SongId = antiDeath.CreateTextBox({
        Name = 'SongID',
        TempText = 'Song ID',
        HoverText = 'ID to play the song.',
        FocusLost = function()
            if antiDeath.Enabled then
                antiDeath.ToggleButton()
                antiDeath.ToggleButton()
            end
        end
    })
    antiDeathConfig.SongId.Object.Visible = false

    antiDeathConfig.Health = antiDeath.CreateSlider({
        Name = 'Health Trigger',
        Min = 10,
        Max = 90,
        HoverText = btext('Health at which AntiDeath will perform its actions.'),
        Default = 50,
        Function = function(val) end
    })

    antiDeathConfig.Velocity = antiDeath.CreateSlider({
        Name = 'Velocity Boost',
        Min = 100,
        Max = 600,
        HoverText = btext('Power to get boosted in the air.'),
        Default = 600,
        Function = function(val) end
    })
    antiDeathConfig.Velocity.Object.Visible = false

    antiDeathConfig.CFrame = antiDeath.CreateSlider({
        Name = 'CFrame Boost',
        Min = 100,
        Max = 1000,
        HoverText = btext('Power to get boosted in the air.'),
        Default = 1000,
        Function = function(val) end
    })
    antiDeathConfig.CFrame.Object.Visible = false

    antiDeathConfig.TweenPower = antiDeath.CreateSlider({
        Name = 'Tween Boost',
        Min = 100,
        Max = 1300,
        HoverText = btext('Power to get boosted in the air.'),
        Default = 1000,
        Function = function(val) end
    })
    antiDeathConfig.TweenPower.Object.Visible = false

    antiDeathConfig.TweenDuration = antiDeath.CreateSlider({
        Name = 'Tween Duration',
        Min = 1,
        Max = 10,
        HoverText = btext('Duration of the tweening process.'),
        Default = 4,
        Function = function(val) end
    })
    antiDeathConfig.TweenDuration.Object.Visible = false

    antiDeathConfig.SkyPosition = antiDeath.CreateSlider({
        Name = 'Sky Position',
        Min = 100,
        Max = 1000,
        HoverText = btext('Position to TP in the sky.'),
        Default = 1000,
        Function = function(val) end
    })
    antiDeathConfig.SkyPosition.Object.Visible = false

    antiDeathConfig.AutoDisable = antiDeath.CreateToggle({
        Name = 'Auto Disable',
        HoverText = btext('Automatically disables InfiniteFly after healing.'),
        Function = function(val) end,
        Default = true
    })
    antiDeathConfig.AutoDisable.Object.Visible = false

    antiDeathConfig.Sound = antiDeath.CreateToggle({
        Name = 'Sound',
        HoverText = btext('Plays a sound after preventing death.'),
        Function = function(callback)
            antiDeathConfig.SongId.Object.Visible = callback
        end,
        Default = true
    })

    antiDeathConfig.Notify = antiDeath.CreateToggle({
        Name = 'Notification',
        HoverText = btext('Notifies you when AntiDeath actioned.'),
        Default = true,
        Function = function(callback) end
    })
end)
			
run(function()
	local QueueCardMods = {}
	local QueueCardGradientToggle = {}
	local QueueCardGradient = {Hue = 0, Sat = 0, Value = 0}
	local QueueCardGradient2 = {Hue = 0, Sat = 0, Value = 0}
	local queuemodsgradients = {}
	local function patchQueueCard()
		if lplr.PlayerGui:FindFirstChild('QueueApp') then 
			if lplr.PlayerGui.QueueApp:WaitForChild('1'):IsA('Frame') then 
				lplr.PlayerGui.QueueApp['1'].BackgroundColor3 = Color3.fromHSV(QueueCardGradient.Hue, QueueCardGradient.Sat, QueueCardGradient.Value)
			end
			if QueueCardGradientToggle.Enabled then 
				lplr.PlayerGui.QueueApp['1'].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				local gradient = (lplr.PlayerGui.QueueApp['1']:FindFirstChildWhichIsA('UIGradient') or Instance.new('UIGradient', lplr.PlayerGui.QueueApp['1']))
				gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(QueueCardGradient.Hue, QueueCardGradient.Sat, QueueCardGradient.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(QueueCardGradient2.Hue, QueueCardGradient2.Sat, QueueCardGradient2.Value))})
				table.insert(queuemodsgradients, gradient)
			end
		end
	end
	QueueCardMods = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'QueueCardMods',
		HoverText = 'Mods the QueueApp at the end of the game.',
		Function = function(calling) 
			if calling then 
				patchQueueCard()
				table.insert(QueueCardMods.Connections, lplr.PlayerGui.ChildAdded:Connect(patchQueueCard))
			end
		end
	})
	QueueCardGradientToggle = QueueCardMods.CreateToggle({
		Name = 'Gradient',
		Function = function(calling)
			pcall(function() QueueCardGradient2.Object.Visible = calling end) 
		end
	})
	QueueCardGradient = QueueCardMods.CreateColorSlider({
		Name = 'Color',
		Function = function()
			pcall(patchQueueCard)
		end
	})
	QueueCardGradient2 = QueueCardMods.CreateColorSlider({
		Name = 'Color 2',
		Function = function()
			pcall(patchQueueCard)
		end
	})
	Credits = QueueCardMods.CreateCredits({
		Name = 'CreditsButtonInstance',
        Credits = 'Render'
	})
end)

run(function()
    local tppos2 = nil
    local TweenSpeed = 0.7
    local HeightOffset = 5
    local BedTP = {}

    local function teleportWithTween(char, destination)
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            destination = destination + Vector3.new(0, HeightOffset, 0)
            local currentPosition = root.Position
            if (destination - currentPosition).Magnitude > 0.5 then
                local tweenInfo = TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local goal = {CFrame = CFrame.new(destination)}
                local tween = TweenService:Create(root, tweenInfo, goal)
                tween:Play()
                tween.Completed:Wait()
				BedTP.ToggleButton(false)
            end
        end
    end

    local function killPlayer(player)
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end

    local function getEnemyBed(range)
        range = range or math.huge
        local bed = nil
        local player = lplr

        if not isAlive(player, true) then 
            return nil 
        end

        local localPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.zero
        local playerTeam = player:GetAttribute('Team')
        local beds = collectionService:GetTagged('bed')

        for _, v in ipairs(beds) do 
            if v:GetAttribute('PlacedByUserId') == 0 then
                local bedTeam = v:GetAttribute('id'):sub(1, 1)
                if bedTeam ~= playerTeam then 
                    local bedPosition = v.Position
                    local bedDistance = (localPos - bedPosition).Magnitude
                    if bedDistance < range then 
                        bed = v
                        range = bedDistance
                    end
                end
            end
        end

        if not bed then 
            warningNotification("BedTP", 'No enemy beds found. Total beds: '..#beds, 5)
        else
            --warningNotification("BedTP", 'Teleporting to bed at position: '..tostring(bed.Position), 3)
			warningNotification("BedTP", 'Teleporting to bed at position: '..tostring(bed.Position), 3)
        end

        return bed
    end

    BedTP = GuiLibrary["ObjectsThatCanBeSaved"]["WorldWindow"]["Api"].CreateOptionsButton({
        ["Name"] = "BedTP",
        ["Function"] = function(callback)
            if callback then
				table.insert(BedTP.Connections, lplr.CharacterAdded:Connect(function(char)
					if tppos2 then 
						task.spawn(function()
							local root = char:WaitForChild("HumanoidRootPart", 9e9)
							if root and tppos2 then 
								teleportWithTween(char, tppos2)
								tppos2 = nil
							end
						end)
					end
				end))
                local bed = getEnemyBed()
                if bed then 
                    tppos2 = bed.Position
                    killPlayer(lplr)
                else
                    BedTP.ToggleButton(false)
                end
            end
        end
    })
end)

--[[local GuiLibrary = shared.GuiLibrary
run(function()
	local ScytheDisabler = {}
	ScytheDisabler = GuiLibrary.ObjectsThatCanBeSaved.VoidwareDevWindow.Api.CreateOptionsButton({
		Name = 'ScytheDisabler',
		HoverText = "Works on everymatch (you need forge mechanic).",
		Function = function(calling)
			if calling then 
				repeat
					task.wait()
					if killauraNearPlayer then 
						continue
					end
					local scythe = getItemNear('_scythe')
					if isAlive(lplr, true) and not scythe then 
						bedwars.Client:Get('ForgePurchaseUpgrade'):SendToServer(bedwars.ForgeConstants.SCYTHE)
						continue
					end
					if isAlive(lplr, true) then 
						local move = lplr.Character.Humanoid.MoveDirection
						switchItem(scythe.tool)
						bedwars.Client:Get('ScytheDash'):SendToServer({direction = move == Vector3.zero and Vector3.new(9e9, 9e9, 9e9) or move * 9e9})
						if lplr:GetAttribute('ScytheSpinning') then 
							store.scythe = (tick() + 1) 
						end
					end
				until (not ScytheDisabler.Enabled)
			end
		end
	})
end)]]

--[[run(function()
	local Disabler = {Enabled = false}
	local ZephyrSpeed = {Value = 1}
	local DisablerMode = {Value = "Scythe"}
	local mode = "Scythe"
	local sd = false
	local csd = false
	local zd = false
	local fd = false
	local function DeleteClientSidedAnticheat()
		if lplr.PlayerScripts.Modules:FindFirstChild("anticheat") then
			lplr.PlayerScripts.Modules.anticheat:Destroy()
		end
		if lplr.PlayerScripts:FindFirstChild("GameAnalyticsClient") then
			lplr.PlayerScripts.GameAnalyticsClient:Destroy()
		end
		if game:GetService("ReplicatedStorage").Modules:FindFirstChild("anticheat") then
			game:GetService("ReplicatedStorage").Modules:FindFirstChild("anticheat"):Destroy()
		end
	end
	Disabler = GuiLibrary.ObjectsThatCanBeSaved.VoidwareDevWindow.Api.CreateOptionsButton({
		Name = "Disabler",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if zd then
							disablerZephyr = true
						else
							disablerZephyr = false
						end
						if fd then
							game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("TridentUnanchor"):InvokeServer()
							game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("TridentAnchor"):InvokeServer()
						end
						if sd then
							local item = getItemNear("scythe")
							if item and lplr.Character.HandInvItem.Value == item.tool and bedwars.CombatController then 
								bedwars.Client:Get("ScytheDash"):SendToServer({direction = lplr.Character.HumanoidRootPart.CFrame.LookVector*9e9})
								if entityLibrary.isAlive and entityLibrary.character.Head.Transparency ~= 0 then
									store.scythe = tick() + 1
								end
							end
						end
					until (not Disabler.Enabled)
				end)
				if csd then
					local catver = "4.0"
					DeleteClientSidedAnticheat()
					--warningNotification("Disabler", "Disabled Client", 3)
				end
			else
				disablerZephyr = false
			end
		end,
		HoverText = "Attempts to help bypass the AntiCheat",
		ExtraText = function()
			return "Heatseeker"
		end
	})
	ClientS = Disabler.CreateToggle({
		Name = "Client Sided",
		Default = true,
		Function = function(callback)
			csd = callback
			Disabler.ToggleButton(false)
			Disabler.ToggleButton(false)
		end
	})
	Scythe = Disabler.CreateToggle({
		Name = "Scythe",
		Default = true,
		Function = function(callback)
			sd = callback
			Disabler.ToggleButton(false)
			Disabler.ToggleButton(false)
		end
	})
	Zephyr = Disabler.CreateToggle({
		Name = "Zephyr",
		Default = true,
		Function = function(callback)
			zd = callback
			Disabler.ToggleButton(false)
			Disabler.ToggleButton(false)
		end
	})
	--[[Float = Disabler.CreateToggle({
		Name = "Float (EXPERIMENTAL)",
		Default = true,
		Function = function(callback)
			fd = callback
			Disabler.ToggleButton(false)
			Disabler.ToggleButton(false)
		end
	})
	ZephyrSpeed = Disabler.CreateSlider({
		Name = "Speed Multiplier",
		Min = 0,
		Max = 30,
		Function = function(callback)
			disablerBoost = callback
			Disabler.ToggleButton(false)
			Disabler.ToggleButton(false)
		end,
		Default = 20
	})
	local Credits
	Credits = Disabler.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Cat V5 (qwertyui)'
    })
end)--]]

--[[run(function()
    local enchantexploit = {};
	local enchantnum = 0
	local et = 0
    local effects = {
        'fire_3', 'forest_3', 'void_3', 'static_3', 'updraft_2', 
        'shield_gen_3', 'anti_knockback_2', 'rapid_regen_3', 'execute_3', 
        'wind_3', 'plunder_2', 'critical_strike_3', 'volley_3', 
        'grounded_3', 'clingy_3', 'life_steal_3', 'fortune_1'
    };
	local function addEnchants()
		for i,v in effects do 
			bedwars.Client:Get('RequestFortuneDoubleDown').instance:FireServer({statusEffectType = v});
			et = 0
		end
	end
    enchantexploit = GuiLibrary.ObjectsThatCanBeSaved.VoidwareWindow.Api.CreateOptionsButton({
        Name = 'EnchantExploit',
        HoverText = 'Gives you most enchants.',
        Function = function(calling)
            if calling then 
				et = 0
				RunLoops:BindToStepped("enchant",function()
					et = et + 1
					if et == 45 then
						task.delay(1,addEnchants)
						et = 0
					end
				end)
			else
				RunLoops:UnbindFromStepped("enchant")
            end
        end
    })
	local Credits
	Credits = enchantexploit.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Cat V5 (qwertyui)'
    })
end)--]]

--[[run(function()
	local MelodyExploit = {Enabled = false}

	MelodyExploit = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({ -- how does this work? idk honestly
		Name = "MelodyExploit",
		Function = function(callback)
			if callback then
				warningNotification("MelodyExploit", "Requires a guitar! Recommended lucky blocks or melody kit", 3)
				RunLoops:BindToHeartbeat("melody",function()			
					if getItem("guitar") then
						if lplr.Character.Humanoid.Health < lplr.Character.Humanoid.MaxHealth then
							bedwars.Client:Get(bedwars.GuitarHealRemote):SendToServer({healTarget = lplr})
							game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("StopPlayingGuitar"):FireServer()
						else
							game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("StopPlayingGuitar"):FireServer()
						end
					else
						local args = {
							[1] = {
								["shopItem"] = {
									["lockAfterPurchase"] = true,
									["currency"] = "iron",
									["itemType"] = "guitar",
									["amount"] = 1,
									["price"] = 16,
									["category"] = "Combat",
									["spawnWithItems"] = {
										[1] = "guitar"
									},
									["requiresKit"] = {
										[1] = "melody"
									}
								},
								["shopId"] = "2_item_shop_1"
							}
						}
						
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("BedwarsPurchaseItem"):InvokeServer(unpack(args))
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("melody")
			end
		end
	})

	local Credits
	Credits = MelodyExploit.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Cat V5 (qwertyui)'
    })
end)--]]
--[[run(function()
	local InstantEmeraldArmour = {}
	InstantEmeraldArmour = GuiLibrary.ObjectsThatCanBeSaved.VoidwareWindow.Api.CreateOptionsButton({
		Name = 'InstantEmeraldArmour',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat 
						local args = {
							[1] = {
								["statusEffectType"] = "fortune_1",
								["fortuneStacks"] = 9e+9
							}
						}
						
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("RequestFortuneCashOut"):FireServer(unpack(args))
						task.wait(0.1)
					until (not InstantEmeraldArmour)
				end)
				--InstantEmeraldArmour["ToggleButton"](false) 
			end
		end
	})
	local Credits
	Credits = InstantEmeraldArmour.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'floppa'
    })
end)--]]

local function getItemDrop(drop)
	if not isAlive(lplr, true) and not RenderStore.LocalPosition then 
		return nil
	end
	local itemdrop, magnitude = nil, math.huge
	for i,v in next, collectionService:GetTagged('ItemDrop') do 
		if v.Name == drop then 
			local localpos = (isAlive(lplr, true) and lplr.Character.HumanoidRootPart.Position or RenderStore.LocalPosition)
			local newdistance = (localpos - v.Position).Magnitude 
			if newdistance < magnitude then 
				magnitude = newdistance 
				itemdrop = v 
			end
		end
	end
	return itemdrop
end

run(function()
	local canRespawn = function() end
	canRespawn = function()
		local success, response = pcall(function() 
			return lplr.leaderstats.Bed.Value == '✅' 
		end)
		return success and response 
	end
	local GetEnumItems = function() return {} end
	GetEnumItems = function(enum)
		local fonts = {}
		for i,v in next, Enum[enum]:GetEnumItems() do 
			table.insert(fonts, v.Name) 
		end
		return fonts
	end
	local function getItemDrop(drop)
		if not isAlive(lplr, true) and not RenderStore.LocalPosition then 
			return nil
		end
		local itemdrop, magnitude = nil, math.huge
		for i,v in next, collectionService:GetTagged('ItemDrop') do 
			if v.Name == drop then 
				local localpos = (isAlive(lplr, true) and lplr.Character.HumanoidRootPart.Position or RenderStore.LocalPosition)
				local newdistance = (localpos - v.Position).Magnitude 
				if newdistance < magnitude then 
					magnitude = newdistance 
					itemdrop = v 
				end
			end
		end
		return itemdrop
	end

	local DiamondTP = {}
	local DiamondTPAutoSpeed = {}
	local DiamondTPSpeed = {Value = 200}
	local DiamondTPTeleport = {Value = 'Respawn'}
	local DiamondTPMethod = {Value = 'Linear'}
	local diamondtween 
	local oldmovefunc 
	local bypassmethods = {
		Respawn = function() 
			if isEnabled('InfiniteFly') then 
				return 
			end
			if not canRespawn() then 
				return 
			end
			for i = 1, 30 do 
				if isAlive(lplr, true) and lplr.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
					lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(0.1)
			local item = getItemDrop('diamond')
			if item == nil or not DiamondTP.Enabled then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (DiamondTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (DiamondTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (DiamondTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[DiamondTPTeleport.Value])
			diamondtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			diamondtween:Play() 
			diamondtween.Completed:Wait()
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character.Humanoid.FloorMaterial == Enum.Material.Air then 
				errorNotification('DiamondTP', 'Recall ability not available.', 7)
				return 
			end
			if not bedwars.AbilityController:canUseAbility('recall') then 
				errorNotification('DiamondTP', 'Recall ability not available.', 7)
				return
			end
			pcall(function()
				oldmovefunc = require(lplr.PlayerScripts.PlayerModule).controls.moveFunction 
				require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = function() end
			end)
			bedwars.AbilityController:useAbility('recall')
			local teleported
			table.insert(DiamondTP.Connections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function() teleported = true end))
			repeat task.wait() until teleported or not DiamondTP.Enabled or not isAlive(lplr, true) 
			task.wait()
			local item = getItemDrop('diamond')
			if item == nil or not isAlive(lplr, true) then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (DiamondTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (DiamondTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (DiamondTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[DiamondTPTeleport.Value])
			diamondtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			diamondtween:Play() 
			diamondtween.Completed:Wait()
		end
	}
	DiamondTP = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'DiamondTP',
		HoverText = 'Tweens you to a nearby diamond drop.',
		Function = function(calling)
			if calling then 
				if getItemDrop('diamond') then 
					bypassmethods[isAlive() and DiamondTPTeleport.Value or 'Respawn']() 
				end
				if DiamondTP.Enabled then 
					DiamondTP.ToggleButton()
				end 
			else
				pcall(function() diamondtween:Cancel() end) 
				if oldmovefunc then 
					pcall(function() require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = oldmovefunc end)
				end
				oldmovefunc = nil
			end
		end
	})
	DiamondTPTeleport = DiamondTP.CreateDropdown({
		Name = 'Teleport Method',
		List = {'Respawn', 'Recall'},
		Function = function() end
	})
	DiamondTPAutoSpeed = DiamondTP.CreateToggle({
		Name = 'Auto Speed',
		HoverText = 'Automatically uses a "good" tween speed.',
		Default = true,
		Function = function(calling) 
			if calling then 
				pcall(function() DiamondTPSpeed.Object.Visible = false end) 
			else 
				pcall(function() DiamondTPSpeed.Object.Visible = true end) 
			end
		end
	})
	DiamondTPSpeed = DiamondTP.CreateSlider({
		Name = 'Tween Speed',
		Min = 20, 
		Max = 350,
		Default = 200,
		Function = function() end
	})
	DiamondTPMethod = DiamondTP.CreateDropdown({
		Name = 'Teleport Method',
		List = GetEnumItems('EasingStyle'),
		Function = function() end
	})
	DiamondTPSpeed.Object.Visible = false
	local Credits
	Credits = DiamondTP.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Render'
    })

	local EmeraldTP = {}
	local EmeraldTPAutoSpeed = {}
	local EmeraldTPSpeed = {Value = 200}
	local EmeraldTPTeleport = {Value = 'Respawn'}
	local EmeraldTPMethod = {Value = 'Linear'}
	local emeraldtween 
	local bypassmethods = {
		Respawn = function() 
			if isEnabled('InfiniteFly') then 
				return 
			end
			if not canRespawn() then 
				return 
			end
			for i = 1, 30 do 
				if isAlive(lplr, true) and lplr.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
					lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(0.1)
			local item = getItemDrop('emerald')
			if item == nil or not EmeraldTP.Enabled then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (EmeraldTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (EmeraldTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (EmeraldTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[EmeraldTPTeleport.Value])
			emeraldtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			emeraldtween:Play() 
			emeraldtween.Completed:Wait()
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character.Humanoid.FloorMaterial == Enum.Material.Air then 
				errorNotification('EmeraldTP', 'Recall ability not available.', 7)
				return 
			end
			if not bedwars.AbilityController:canUseAbility('recall') then 
				errorNotification('EmeraldTP', 'Recall ability not available.', 7)
				return
			end
			pcall(function()
				oldmovefunc = require(lplr.PlayerScripts.PlayerModule).controls.moveFunction 
				require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = function() end
			end)
			bedwars.AbilityController:useAbility('recall')
			local teleported
			table.insert(EmeraldTP.Connections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function() teleported = true end))
			repeat task.wait() until teleported or not EmeraldTP.Enabled or not isAlive(lplr, true) 
			task.wait()
			local item = getItemDrop('emerald')
			if item == nil or not isAlive(lplr, true) then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (EmeraldTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (EmeraldTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (EmeraldTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[EmeraldTPTeleport.Value])
			emeraldtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			emeraldtween:Play() 
			emeraldtween.Completed:Wait()
		end
	}
	EmeraldTP = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'EmeraldTP',
		HoverText = 'Tweens you to a nearby diamond drop.',
		Function = function(calling)
			if calling then 
				if getItemDrop('emerald') then 
					bypassmethods[isAlive() and EmeraldTPTeleport.Value or 'Respawn']() 
				end
				if EmeraldTP.Enabled then 
					EmeraldTP.ToggleButton()
				end 
			else
				pcall(function() emeraldtween:Cancel() end) 
				if oldmovefunc then 
					pcall(function() require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = oldmovefunc end)
				end
				oldmovefunc = nil
			end
		end
	})
	EmeraldTPTeleport = EmeraldTP.CreateDropdown({
		Name = 'Teleport Method',
		List = {'Respawn', 'Recall'},
		Function = function() end
	})
	EmeraldTPAutoSpeed = EmeraldTP.CreateToggle({
		Name = 'Auto Speed',
		HoverText = 'Automatically uses a "good" tween speed.',
		Default = true,
		Function = function(calling) 
			if calling then 
				pcall(function() EmeraldTPSpeed.Object.Visible = false end) 
			else 
				pcall(function() EmeraldTPSpeed.Object.Visible = true end) 
			end
		end
	})
	EmeraldTPSpeed = EmeraldTP.CreateSlider({
		Name = 'Tween Speed',
		Min = 20, 
		Max = 350,
		Default = 200,
		Function = function() end
	})
	EmeraldTPMethod = EmeraldTP.CreateDropdown({
		Name = 'Teleport Method',
		List = GetEnumItems('EasingStyle'),
		Function = function() end
	})
	EmeraldTPSpeed.Object.Visible = false
	local Credits
	Credits = EmeraldTP.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Render'
    })
end)


local GetEnumItems = function() return {} end
GetEnumItems = function(enum)
	local fonts = {}
	for i,v in next, Enum[enum]:GetEnumItems() do 
		table.insert(fonts, v.Name) 
	end
	return fonts
end

run(function()
	local ArmorMods = {}
	local armorobjects = {}
	local oldtextures = {}
	local armorhighlights = {}
	local ArmorModsMaterial = {Value = 'SmoothPlastic'}
	local ArmorModsRender = {Value = 'Highlight'}
	local ArmorHighlightTrans = {Value = 0}
	local ArmorModsColor = newcolor()
	local armorFunction = function()
		for i,v in next, armorobjects do 
			pcall(function()
				oldtextures[v] = v.Handle.TextureID
				v.Handle.TextureID = ''
				if ArmorModsRender.Value == 'Highlight' then 
					local highlight = (armorhighlights[v.Handle] or Instance.new('Highlight', game))
					highlight.Adornee = v.Handle
					highlight.FillColor = Color3.fromHSV(ArmorModsColor.Hue, ArmorModsColor.Sat, ArmorModsColor.Value)
					highlight.FillTransparency = (0.7 / (ArmorHighlightTrans.Value + 0.1))
					highlight.OutlineTransparency = 1
					armorhighlights[v.Handle] = highlight
				else
					v.Handle.Color = Color3.fromHSV(ArmorModsColor.Hue, ArmorModsColor.Sat, ArmorModsColor.Value)
				end
				v.Handle.Material = ArmorModsMaterial.Value
			end)
		end
	end
	ArmorMods = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'ArmorMods',
		HoverText = 'Make your armor look better!',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat task.wait() until (isAlive(lplr, true) or not ArmorMods.Enabled)
					if not ArmorMods.Enabled then 
						return 
					end
					for i,v in next, lplr.Character:GetChildren() do 
						if v:GetAttribute('ArmorSlot') then 
							armorFunction()
							table.insert(armorobjects, v)
						end
					end
					table.insert(ArmorMods.Connections, lplr.Character.ChildAdded:Connect(function(instance)
						if instance:GetAttribute('ArmorSlot') then 
							armorFunction()
							table.insert(armorobjects, instance)
						end
					end))
					table.insert(ArmorMods.Connections, lplr.CharacterAdded:Connect(function()
						for i = 1, 2 do 
							ArmorMods.ToggleButton()
						end
					end))
				end)
			else
				for i,v in next, armorhighlights do 
					pcall(function() v:Destroy() end)
				end
				for i,v in next, oldtextures do 
					pcall(function() i.Handle.TextureID = v end)
				end
				table.clear(oldtextures)
				table.clear(armorobjects)
				table.clear(armorhighlights)
			end
		end
	})
	ArmorModsColor = ArmorMods.CreateColorSlider({
		Name = 'Color',
		Function = armorFunction
	})
	ArmorModsMaterial = ArmorMods.CreateDropdown({
		Name = 'Material',
		List = GetEnumItems('Material'),
		Function = armorFunction
	})
	ArmorHighlightTrans = ArmorMods.CreateSlider({
		Name = 'Visibility',
		Min = 0,
		Max = 100,
		Default = 100,
		Function = armorFunction
	})
	ArmorModsRender = ArmorMods.CreateDropdown({
		Name = 'Render Mode',
		List = {'Part', 'Highlight'},
		Function = function(mode)
			pcall(function() ArmorHighlightTrans.Object.Visible = (mode == 'Highlight') end)
			for i = 1, 2 do 
				ArmorMods.ToggleButton()
			end
		end
	})
	local Credits
	Credits = ArmorMods.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Render'
    })
end)

task.spawn(function()
	local old = bedwars.EntityHighlightController.highlight
	bedwars.EntityHighlightController.highlight = function(...)
		if isEnabled('ArmorMods') or isEnabled('CharacterOutline') then 
			return 
		end
		return old(...)
	end
end)

local getTweenSpeed = function() return 0.49 end
getTweenSpeed = function(part)
	if not isAlive(lplr, true) then 
		return 0.49 
	end
	local localpos = (isAlive(lplr, true) and lplr.Character.HumanoidRootPart.Position or Vector3.zero) 
	return ((part.Position - localpos).Magnitude / 690) + 0.001
end
run(function()
	------ DEV NOTE: THIS MODULE WILL MAKE THE USER NEED TO PRESS THE RESTART/UNINJECT BUTTON TWICE
	local AutoRewind = {}
	local AutoRewindMode = {Value = 'Position'}
	local deathtween
	local deathposition 
	local caldelay = tick()
	AutoRewind = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoRewind',
		HoverText = 'Automatically teleports you to\nthe position you died whenever you respawn.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(AutoRewind.Connections, lplr.CharacterAdded:Connect(function()
						local speed, position = (getTweenSpeed({Position = deathposition}) + 0.3), deathposition
						repeat task.wait() until isAlive(lplr, true) 
						task.wait(0.15)
						if tweenInProgress() or not position then return end
						if AutoRewindMode.Value == 'Target' then 
							local target = GetTarget()
							if target.RootPart then 
								speed, position = getTweenSpeed(target.RootPart), target.RootPart.Position
							end
						end
						deathtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(speed + 0.5 % 0.4, Enum.EasingStyle.Linear), {CFrame = CFrame.new(position)}) 
						deathtween:Play()
						deathtween.Completed:Wait()
						deathtween = nil
					end))
					table.insert(AutoRewind.Connections, runService.Heartbeat:Connect(function()
						if caldelay > tick() then 
							return 
						end
						if isAlive() and store.matchState ~= 0 and not deathtween then 
							local block = (gethighestblock(lplr.Character.HumanoidRootPart.Position, true) or playerRaycasted() or {}).Instance
							if block then 
								deathposition = (block.Position + Vector3.new(0, 5, 0))
							end 
							caldelay = (tick() + 0.5)
						end
					end))
				end)
			else
				deathtween:Cancel()
				deathtween = nil
			end
		end
	})
	AutoRewindMode = AutoRewind.CreateDropdown({
		Name = 'Rewind Mode',
		List = {'Position', 'Target'},
		Function = function() end
	})
	local Credits
	Credits = AutoRewind.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Render'
    })
end)

task.spawn(function()
run(function()
	local KillFeedHider = {}
	KillFeedHider = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'KillFeedHider',
		HoverText = 'Hides the kill feed frames.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					local killfeedgui = lplr.PlayerGui:WaitForChild('KillFeedGui')
					if not KillFeedHider.Enabled then 
						return 
					end
					for i,v in next, killfeedgui:GetChildren() do 
						pcall(function() v.Visible = false end) 
					end
					table.insert(KillFeedHider.Connections, killfeedgui.ChildAdded:Connect(function(gui)
						pcall(function() gui.Visible = false end) 
					end))
				end)
			end
		end
	})
	local Credits
	Credits = KillFeedHider.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Render'
    })
end)
end)

run(function()
	local HotbarMods = {}
	local HotbarRounding = {}
	local HotbarHighlight = {}
	local HotbarColorToggle = {}
	local HotbarHideSlotIcons = {}
	local HotbarSlotNumberColorToggle = {}
	local HotbarRoundRadius = {Value = 8}
	local HotbarColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarHighlightColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarSlotNumberColor = {Hue = 0, Sat = 0, Value = 0}
	local hotbarsloticons = {}
	local hotbarobjects = {}
	local hotbarcoloricons = {}
	local HotbarModsGradient = {}
	local hotbarslotgradients = {}
	local HotbarModsGradientColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarModsGradientColor2 = {Hue = 0, Sat = 0, Value = 0}
	local function hotbarFunction()
		local inventoryicons = ({pcall(function() return lplr.PlayerGui.hotbar['1'].ItemsHotbar end)})[2]
		if inventoryicons and type(inventoryicons) == 'userdata' then
			for i,v in next, inventoryicons:GetChildren() do 
				local sloticon = ({pcall(function() return v:FindFirstChildWhichIsA('ImageButton'):FindFirstChildWhichIsA('TextLabel') end)})[2]
				if type(sloticon) ~= 'userdata' then 
					continue
				end
				if HotbarColorToggle.Enabled and not HotbarModsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value)
					table.insert(hotbarcoloricons, sloticon.Parent) 
				end
				if HotbarModsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					if sloticon.Parent:FindFirstChildWhichIsA('UIGradient') == nil then 
						local gradient = Instance.new('UIGradient') 
						local color = Color3.fromHSV(HotbarModsGradientColor.Hue, HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)
						local color2 = Color3.fromHSV(HotbarModsGradientColor2.Hue, HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value)
						gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color2)})
						gradient.Parent = sloticon.Parent
						table.insert(hotbarslotgradients, gradient)
						table.insert(hotbarcoloricons, sloticon.Parent) 
					end
				end
				if HotbarRounding.Enabled then 
					local uicorner = Instance.new('UICorner')
					uicorner.Parent = sloticon.Parent
					uicorner.CornerRadius = UDim.new(0, HotbarRoundRadius.Value)
					table.insert(hotbarobjects, uicorner)
				end
				if HotbarHighlight.Enabled then
					local highlight = Instance.new('UIStroke')
					highlight.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value)
					highlight.Thickness = 1.3 
					highlight.Parent = sloticon.Parent
					table.insert(hotbarobjects, highlight)
				end
				if HotbarHideSlotIcons.Enabled then 
					sloticon.Visible = false 
				end
				table.insert(hotbarsloticons, sloticon)
			end 
		end
	end
	HotbarMods = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'HotbarMods',
		HoverText = 'Add customization to your hotbar.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(HotbarMods.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'hotbar' then
							hotbarFunction()
						end
					end))
					hotbarFunction()
				end)
			else
				for i,v in hotbarsloticons do 
					pcall(function() v.Visible = true end)
				end
				for i,v in hotbarcoloricons do 
					pcall(function() v.BackgroundColor3 = Color3.fromRGB(29, 36, 46) end)
				end
				for i,v in hotbarobjects do
					pcall(function() v:Destroy() end)
				end
				for i,v in next, hotbarslotgradients do 
					pcall(function() v:Destroy() end)
				end
				table.clear(hotbarobjects)
				table.clear(hotbarsloticons)
				table.clear(hotbarcoloricons)
			end
		end
	})
	HotbarColorToggle = HotbarMods.CreateToggle({
		Name = 'Slot Color',
		Function = function(calling)
			pcall(function() HotbarColor.Object.Visible = calling end)
			pcall(function() HotbarColorToggle.Object.Visible = calling end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarModsGradient = HotbarMods.CreateToggle({
		Name = 'Gradient Slot Color',
		Function = function(calling)
			pcall(function() HotbarModsGradientColor.Object.Visible = calling end)
			pcall(function() HotbarModsGradientColor2.Object.Visible = calling end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarModsGradientColor = HotbarMods.CreateColorSlider({
		Name = 'Gradient Color',
		Function = function(h, s, v)
			for i,v in next, hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarModsGradientColor.Hue, HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarModsGradientColor2.Hue, HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value))}) end)
			end
		end
	})
	HotbarModsGradientColor2 = HotbarMods.CreateColorSlider({
		Name = 'Gradient Color 2',
		Function = function(h, s, v)
			for i,v in next, hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarModsGradientColor.Hue, HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarModsGradientColor2.Hue, HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value))}) end)
			end
		end
	})
	HotbarColor = HotbarMods.CreateColorSlider({
		Name = 'Slot Color',
		Function = function(h, s, v)
			for i,v in next, hotbarcoloricons do
				if HotbarColorToggle.Enabled then
					pcall(function() v.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value) end) -- for some reason the 'h, s, v' didn't work :(
				end
			end
		end
	})
	HotbarRounding = HotbarMods.CreateToggle({
		Name = 'Rounding',
		Function = function(calling)
			pcall(function() HotbarRoundRadius.Object.Visible = calling end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarRoundRadius = HotbarMods.CreateSlider({
		Name = 'Corner Radius',
		Min = 1,
		Max = 20,
		Function = function(calling)
			for i,v in next, hotbarobjects do 
				pcall(function() v.CornerRadius = UDim.new(0, calling) end)
			end
		end
	})
	HotbarHighlight = HotbarMods.CreateToggle({
		Name = 'Outline Highlight',
		Function = function(calling)
			pcall(function() HotbarHighlightColor.Object.Visible = calling end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarHighlightColor = HotbarMods.CreateColorSlider({
		Name = 'Highlight Color',
		Function = function(h, s, v)
			for i,v in next, hotbarobjects do 
				if v:IsA('UIStroke') and HotbarHighlight.Enabled then 
					pcall(function() v.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value) end)
				end
			end
		end
	})
	HotbarHideSlotIcons = HotbarMods.CreateToggle({
		Name = 'No Slot Numbers',
		Function = function()
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarColor.Object.Visible = false
	HotbarRoundRadius.Object.Visible = false
	HotbarHighlightColor.Object.Visible = false
	local Credits
	Credits = HotbarMods.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Render'
    })
end)

--[[run(function()
	local VapePrivateDetector = {Enabled = false}
	local VPLeave = {Enabled = false}
	local alreadydetected = {}
	VapePrivateDetector = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "VapePrivateDetector",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if not shared.vapewhitelist.loaded then 
						repeat task.wait() until shared.vapewhitelist.loaded or not VapePrivateDetector.Enabled
					end
					if not VapePrivateDetector.Enabled then 
						return 
					end
					for i,v in pairs(playersService:GetPlayers()) do
						if v ~= lplr then
							local rank = shared.vapewhitelist:get(v)
							if rank > 0 and not table.find(alreadydetected, v) then
								local rankstring = rank == 1 and "Private Member" or rank > 1 and "Owner"
								warningNotification("VapePrivateDetector", "Vape "..rankstring.." Detected! | "..v.DisplayName, 120)
								table.insert(alreadydetected, v)
								if VPLeave.Enabled then
									local newserver = nil
									repeat newserver = findnewserver() until newserver 
									game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, newserver, lplr)
								end
							end
						end
					end
					table.insert(VapePrivateDetector.Connections, playersService.PlayerAdded:Connect(function(v)
						local rank = shared.vapewhitelist:get(v)
						if rank > 0 and not table.find(alreadydetected, v) then
						local rankstring = rank == 1 and "Private Member" or rank > 1 and "Owner"
						warningNotification("VapePrivateDetector", "Vape "..rankstring.." Detected! | "..v.DisplayName, 120)
						table.insert(alreadydetected, v)
						if VPLeave.Enabled then
							local newserver = nil
							repeat newserver = findnewserver() until newserver 
							game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, newserver, lplr)
						end
						end
					end))
				end)
			end
		end
	})
	VPLeave = VapePrivateDetector.CreateToggle({
		Name = "ServerHop",
		HoverText = "switches servers on detection.",
		Function = function() end
	})
	task.spawn(function()
		repeat task.wait() until shared.vapewhitelist.loaded 
		if shared.vapewhitelist:get(lplr) ~= 0 then 
			pcall(GuiLibrary.RemoveObject, "VapePrivateDetectorOptionsButton")
		end
	end)
end)--]]

run(function()
	local ChosenPack = {Value = "Realistic Pack"}
	local TexturePacks = {Enabled = false}
	TexturePacks = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "Texture Packs",
		HoverText = "Replaces the boring sword with a better texture pack.",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0
					local function killPlayer(player)
						local character = player.Character
						if character then
							local humanoid = character:FindFirstChildOfClass("Humanoid")
							if humanoid then
								humanoid.Health = 0
							end
						end
					end
					local canRespawn = function() end
					canRespawn = function()
						local success, response = pcall(function() 
							return lplr.leaderstats.Bed.Value == '✅' 
						end)
						return success and response 
					end
					warningNotification("Texture packs", "Reset for the pack to work", 3)
					--if canRespawn() then warningNotification("Texture packs", "Resetting for the texture to get applied", 5) killPlayer(lplr) else warningNotification("Texture packs", "Unable to reset your chatacter! Please do it manually", 3) end
					TexturePacks.Enabled = false 
					TexturePacks.Enabled = true 
					if ChosenPack.Value == "Realistic Pack" then
						local Services = {
							Storage = game:GetService("ReplicatedStorage"),
							Workspace = game:GetService("Workspace"),
							Players = game:GetService("Players")
						}
						
						local ASSET_ID = "rbxassetid://14431940695"
						local PRIMARY_ROTATION = CFrame.Angles(0, -math.pi/4, 0)
						
						local ToolMaterials = {
							sword = {"wood", "stone", "iron", "diamond", "emerald"},
							pickaxe = {"wood", "stone", "iron", "diamond"},
							axe = {"wood", "stone", "iron", "diamond"}
						}
						
						local Offsets = {
							sword = CFrame.Angles(0, -math.pi/2, -math.pi/2),
							pickaxe = CFrame.Angles(0, -math.pi, -math.pi/2),
							axe = CFrame.Angles(0, -math.pi/18, -math.pi/2)
						}
						
						local ToolIndex = {}
						
						local function initializeToolIndex(asset)
							for toolType, materials in pairs(ToolMaterials) do
								for _, material in ipairs(materials) do
									local identifier = material .. "_" .. toolType
									local toolModel = asset:FindFirstChild(identifier)
						
									if toolModel then
										--print("Found tool in initializeToolIndex:", identifier)
										table.insert(ToolIndex, {
											Name = identifier,
											Offset = Offsets[toolType],
											Model = toolModel
										})
									else
										--warn("Model for " .. identifier .. " not found in initializeToolIndex!")
									end
								end
							end
						end
						
						local function adjustAppearance(part)
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
						
						local function attachModel(target, data, modifier)
							local clonedModel = data.Model:Clone()
							clonedModel.CFrame = target:FindFirstChild("Handle").CFrame * data.Offset * PRIMARY_ROTATION * (modifier or CFrame.new())
							clonedModel.Parent = target
						
							local weld = Instance.new("WeldConstraint", clonedModel)
							weld.Part0 = clonedModel
							weld.Part1 = target:FindFirstChild("Handle")
						end
						
						local function processTool(tool)
							if not tool:IsA("Accessory") then return end
						
							for _, toolData in ipairs(ToolIndex) do
								if toolData.Name == tool.Name then
									for _, child in pairs(tool:GetDescendants()) do
										adjustAppearance(child)
									end
									attachModel(tool, toolData)
						
									local playerTool = Services.Players.LocalPlayer.Character:FindFirstChild(tool.Name)
									if playerTool then
										for _, child in pairs(playerTool:GetDescendants()) do
											adjustAppearance(child)
										end
										attachModel(playerTool, toolData, CFrame.new(0.4, 0, -0.9))
									end
								end
							end
						end
						
						
						local loadedTools = game:GetObjects(ASSET_ID)
						local mainAsset = loadedTools[1]
						mainAsset.Parent = Services.Storage
						
						wait(1)
						
						
						for _, child in pairs(mainAsset:GetChildren()) do
							--print("Found tool in asset:", child.Name)
						end
						
						initializeToolIndex(mainAsset)
						Services.Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(processTool)
					elseif ChosenPack.Value == "32x Pack" then 
						local Services = {
							Storage = game:GetService("ReplicatedStorage"),
							Workspace = game:GetService("Workspace"),
							Players = game:GetService("Players")
						}
						
						local ASSET_ID = "rbxassetid://14421314747"
						local PRIMARY_ROTATION = CFrame.Angles(0, -math.pi/4, 0)
						
						local ToolMaterials = {
							sword = {"wood", "stone", "iron", "diamond", "emerald"},
							pickaxe = {"wood", "stone", "iron", "diamond"},
							axe = {"wood", "stone", "iron", "diamond"}
						}
						
						local Offsets = {
							sword = CFrame.Angles(0, -math.pi/2, -math.pi/2),
							pickaxe = CFrame.Angles(0, -math.pi, -math.pi/2),
							axe = CFrame.Angles(0, -math.pi/18, -math.pi/2)
						}
						
						local ToolIndex = {}
						
						local function initializeToolIndex(asset)
							for toolType, materials in pairs(ToolMaterials) do
								for _, material in ipairs(materials) do
									local identifier = material .. "_" .. toolType
									local toolModel = asset:FindFirstChild(identifier)
						
									if toolModel then
										--print("Found tool in initializeToolIndex:", identifier)
										table.insert(ToolIndex, {
											Name = identifier,
											Offset = Offsets[toolType],
											Model = toolModel
										})
									else
										--warn("Model for " .. identifier .. " not found in initializeToolIndex!")
									end
								end
							end
						end
						
						local function adjustAppearance(part)
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
						
						local function attachModel(target, data, modifier)
							local clonedModel = data.Model:Clone()
							clonedModel.CFrame = target:FindFirstChild("Handle").CFrame * data.Offset * PRIMARY_ROTATION * (modifier or CFrame.new())
							clonedModel.Parent = target
						
							local weld = Instance.new("WeldConstraint", clonedModel)
							weld.Part0 = clonedModel
							weld.Part1 = target:FindFirstChild("Handle")
						end
						
						local function processTool(tool)
							if not tool:IsA("Accessory") then return end
						
							for _, toolData in ipairs(ToolIndex) do
								if toolData.Name == tool.Name then
									for _, child in pairs(tool:GetDescendants()) do
										adjustAppearance(child)
									end
									attachModel(tool, toolData)
						
									local playerTool = Services.Players.LocalPlayer.Character:FindFirstChild(tool.Name)
									if playerTool then
										for _, child in pairs(playerTool:GetDescendants()) do
											adjustAppearance(child)
										end
										attachModel(playerTool, toolData, CFrame.new(0.4, 0, -0.9))
									end
								end
							end
						end
						
						
						local loadedTools = game:GetObjects(ASSET_ID)
						local mainAsset = loadedTools[1]
						mainAsset.Parent = Services.Storage
						
						wait(1)
						
						
						for _, child in pairs(mainAsset:GetChildren()) do
							--print("Found tool in asset:", child.Name)
						end
						
						initializeToolIndex(mainAsset)
						Services.Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(processTool)
					elseif ChosenPack.Value == "16x Pack" then 
						local Services = {
							Storage = game:GetService("ReplicatedStorage"),
							Workspace = game:GetService("Workspace"),
							Players = game:GetService("Players")
						}
						
						local ASSET_ID = "rbxassetid://14474879594"
						local PRIMARY_ROTATION = CFrame.Angles(0, -math.pi/4, 0)
						
						local ToolMaterials = {
							sword = {"wood", "stone", "iron", "diamond", "emerald"},
							pickaxe = {"wood", "stone", "iron", "diamond"},
							axe = {"wood", "stone", "iron", "diamond"}
						}
						
						local Offsets = {
							sword = CFrame.Angles(0, -math.pi/2, -math.pi/2),
							pickaxe = CFrame.Angles(0, -math.pi, -math.pi/2),
							axe = CFrame.Angles(0, -math.pi/18, -math.pi/2)
						}
						
						local ToolIndex = {}
						
						local function initializeToolIndex(asset)
							for toolType, materials in pairs(ToolMaterials) do
								for _, material in ipairs(materials) do
									local identifier = material .. "_" .. toolType
									local toolModel = asset:FindFirstChild(identifier)
						
									if toolModel then
										--print("Found tool in initializeToolIndex:", identifier)
										table.insert(ToolIndex, {
											Name = identifier,
											Offset = Offsets[toolType],
											Model = toolModel
										})
									else
										--warn("Model for " .. identifier .. " not found in initializeToolIndex!")
									end
								end
							end
						end
						
						local function adjustAppearance(part)
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
						
						local function attachModel(target, data, modifier)
							local clonedModel = data.Model:Clone()
							clonedModel.CFrame = target:FindFirstChild("Handle").CFrame * data.Offset * PRIMARY_ROTATION * (modifier or CFrame.new())
							clonedModel.Parent = target
						
							local weld = Instance.new("WeldConstraint", clonedModel)
							weld.Part0 = clonedModel
							weld.Part1 = target:FindFirstChild("Handle")
						end
						
						local function processTool(tool)
							if not tool:IsA("Accessory") then return end
						
							for _, toolData in ipairs(ToolIndex) do
								if toolData.Name == tool.Name then
									for _, child in pairs(tool:GetDescendants()) do
										adjustAppearance(child)
									end
									attachModel(tool, toolData)
						
									local playerTool = Services.Players.LocalPlayer.Character:FindFirstChild(tool.Name)
									if playerTool then
										for _, child in pairs(playerTool:GetDescendants()) do
											adjustAppearance(child)
										end
										attachModel(playerTool, toolData, CFrame.new(0.4, 0, -0.9))
									end
								end
							end
						end
						
						
						local loadedTools = game:GetObjects(ASSET_ID)
						local mainAsset = loadedTools[1]
						mainAsset.Parent = Services.Storage
						
						wait(1)
						
						
						for _, child in pairs(mainAsset:GetChildren()) do
							--print("Found tool in asset:", child.Name)
						end
						
						initializeToolIndex(mainAsset)
						Services.Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(processTool)
					elseif ChosenPack.Value == "Garbage" then 
						local Services = {
							Storage = game:GetService("ReplicatedStorage"),
							Workspace = game:GetService("Workspace"),
							Players = game:GetService("Players")
						}
						
						local ASSET_ID = "rbxassetid://14336548540"
						local PRIMARY_ROTATION = CFrame.Angles(0, -math.pi/4, 0)
						
						local ToolMaterials = {
							sword = {"wood", "stone", "iron", "diamond", "emerald"},
							pickaxe = {"wood", "stone", "iron", "diamond"},
							axe = {"wood", "stone", "iron", "diamond"}
						}
						
						local Offsets = {
							sword = CFrame.Angles(0, -math.pi/2, -math.pi/2),
							pickaxe = CFrame.Angles(0, -math.pi, -math.pi/2),
							axe = CFrame.Angles(0, -math.pi/18, -math.pi/2)
						}
						
						local ToolIndex = {}
						
						local function initializeToolIndex(asset)
							for toolType, materials in pairs(ToolMaterials) do
								for _, material in ipairs(materials) do
									local identifier = material .. "_" .. toolType
									local toolModel = asset:FindFirstChild(identifier)
						
									if toolModel then
										--print("Found tool in initializeToolIndex:", identifier)
										table.insert(ToolIndex, {
											Name = identifier,
											Offset = Offsets[toolType],
											Model = toolModel
										})
									else
										--warn("Model for " .. identifier .. " not found in initializeToolIndex!")
									end
								end
							end
						end
						
						local function adjustAppearance(part)
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
						
						local function attachModel(target, data, modifier)
							local clonedModel = data.Model:Clone()
							clonedModel.CFrame = target:FindFirstChild("Handle").CFrame * data.Offset * PRIMARY_ROTATION * (modifier or CFrame.new())
							clonedModel.Parent = target
						
							local weld = Instance.new("WeldConstraint", clonedModel)
							weld.Part0 = clonedModel
							weld.Part1 = target:FindFirstChild("Handle")
						end
						
						local function processTool(tool)
							if not tool:IsA("Accessory") then return end
						
							for _, toolData in ipairs(ToolIndex) do
								if toolData.Name == tool.Name then
									for _, child in pairs(tool:GetDescendants()) do
										adjustAppearance(child)
									end
									attachModel(tool, toolData)
						
									local playerTool = Services.Players.LocalPlayer.Character:FindFirstChild(tool.Name)
									if playerTool then
										for _, child in pairs(playerTool:GetDescendants()) do
											adjustAppearance(child)
										end
										attachModel(playerTool, toolData, CFrame.new(0.4, 0, -0.9))
									end
								end
							end
						end
						
						
						local loadedTools = game:GetObjects(ASSET_ID)
						local mainAsset = loadedTools[1]
						mainAsset.Parent = Services.Storage
						
						wait(1)
						
						
						for _, child in pairs(mainAsset:GetChildren()) do
							--print("Found tool in asset:", child.Name)
						end
						
						initializeToolIndex(mainAsset)
						Services.Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(processTool)
					end
				end)
			end
		end
	})
	ChosenPack = TexturePacks.CreateDropdown({
        Name = "Pack",
        List = {
            "Realistic Pack",
            "32x Pack",
            "16x Pack",
            "Garbage",
        },
        Function = function() end,
    })
end)

--[[run(function()
	local HannahExploit = {Enabled = false}
	HannahExploit = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "HannahExploit",
		Function = function(callback)
			if callback then
				if tostring(store.queueType) == "training_room" or store.equippedKit == "hannah" then
					RunLoops:BindToHeartbeat("hannah",function()
						for i,v in pairs(game.Players:GetChildren()) do
							local args = {
								[1] = {
									["user"] = game:GetService("Players").LocalPlayer,
									["victimEntity"] = v.Character
								}
							}
		
							game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("HannahPromptTrigger"):InvokeServer(unpack(args))
							task.wait(0.1)
						end
					end)
				else
					HannahExploit["ToggleButton"](false) 
					warningNotification("HannahExploit", "Hannah kit required for this to work!", 7)
				end
			else
				RunLoops:UnbindFromHeartbeat("hannah")
			end
		end,
		HovorText = "Sometimes you will teleport across the map with Hannah"
	})
	local Credits
	Credits = HannahExploit.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'CatV5'
    })
end)--]]

--[[run(function() -- thank you SystemXVoid for letting me use this
    local enchantexploit = {};
    local enchantexploit = {}
	local enchantnum = 0
	local et = 0
    local effects = {
        "fire_3", "forest_3", "void_3", "static_3", "updraft_2", 
        "shield_gen_3", "anti_knockback_2", "rapid_regen_3", "execute_3", 
        "wind_3", "plunder_2", "critical_strike_3", "volley_3", 
        "grounded_3", "clingy_3", "life_steal_3", "fortune_1", "fortune_2", "fortune_3"
	   }
	local function addEnchants()
	end
    enchantexploit = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = 'Dupe',
        HoverText = 'Gives u stuff.',
        Function = function(calling)
            if calling then 
				pcall(function()
					if shared.GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Enabled then else
						shared.GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.ToggleButton()
				   end
				end)
				warningNotification("Dupe", "This module might not work every time! Use it before the match starts", 5)
				et = 0
				RunLoops:BindToStepped("enchant",function()
					et = et + 1
					if et == 45 then
						for i,v in effects do 
							bedwars.Client:Get("RequestFortuneDoubleDown").instance:FireServer({statusEffectType = v})
						end
						et = 0
					end
				end)
			else
				RunLoops:UnbindFromStepped("enchant")
            end
			task.spawn(function()
				repeat 
					local args = {
						[1] = {
							["statusEffectType"] = "fortune_1",
							["fortuneStacks"] = 9999999999999999
						}
					}
					game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("RequestFortuneCashOut"):FireServer(unpack(args))
					task.wait(0.1)
					local args = {
						[1] = {
							["player"] = game:GetService("Players").LocalPlayer
						}
					}
					
					game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("FortuneEnchantRequestDoubleDownAmount"):InvokeServer(unpack(args))						
				until not enchantexploit.Enabled
			end)
        end
    })
	local Credits
	Credits = enchantexploit.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Render/CatV5'
    })
end)--]]

run(function()
	local lplr = game:GetService("Players").LocalPlayer
	local lplr_gui = lplr.PlayerGui

	local function handle_tablist(ui)
		local frame = ui:FindFirstChild("TabListFrame")
		if frame then
			local plrs_frame = frame:FindFirstChild("4"):FindFirstChild("3"):FindFirstChild("1")
			if plrs_frame then
				local side_1 = plrs_frame:WaitForChild("2")
				local side_2 = plrs_frame:WaitForChild("3")
				local sides = {side_1, side_2}

				for _, side in pairs(sides) do
					if side then
						--print("Processing side:", side.Name)
						local side_teams = {}
						local side_teams_players = {}

						for _, child in pairs(side:GetChildren()) do
							if child:IsA("Frame") then
								table.insert(side_teams, child)
							end
						end

						for _, team in pairs(side_teams) do
							local team_plrs_list = team:WaitForChild("3")
							local plrs = team_plrs_list:GetChildren()

							for _, plr in pairs(plrs) do
								if plr:IsA("Frame") and plr.Name == "PlayerRowContainer" then
									table.insert(side_teams_players, plr)
								end
							end
						end

						for _, player_row in pairs(side_teams_players) do
							local plr_name_frame = player_row:WaitForChild("Content"):WaitForChild("PlayerRow"):WaitForChild("3"):WaitForChild("PlayerNameContainer"):WaitForChild("3"):WaitForChild("2"):FindFirstChild("PlayerName")

							if plr_name_frame then
								local function extract_name(formatted_text)
									local name = formatted_text:match("</font>%s*(.+)")
									return name
								end

								local current_text = plr_name_frame.Text
								local name = extract_name(current_text)
								local streamer_mode = true

								for _, player in pairs(game:GetService("Players"):GetPlayers()) do
									if player.DisplayName == name then
										streamer_mode = false
										break
									end
								end

								if not streamer_mode then
									local needed_plr
									for i,v in pairs(game:GetService("Players"):GetPlayers()) do
										if game:GetService("Players"):GetPlayers()[i].DisplayName == name then
											needed_plr = game:GetService("Players"):GetPlayers()[i]
										end
									end
									if needed_plr then
										local function get_player_rank(player)
											local rank = shared.vapewhitelist:get(player)
											if rank == 1 then
												return "INF"
											elseif rank == 2 then
												return "Owner"
											else
												return "Showcaser"
											end
										end
										local rank = get_player_rank(needed_plr)
										local function add_colored_text(existing_text, new_text, color3)
											local r = math.floor(color3.R * 255)
											local g = math.floor(color3.G * 255)
											local b = math.floor(color3.B * 255)
											local new_colored_text = string.format('<font color="rgb(%d,%d,%d)">[%s]</font> ', r, g, b, new_text)
											local updated_text = new_colored_text .. existing_text
											return updated_text
										end

										local tag_data = shared.vapewhitelist:tag(needed_plr)
										if tag_data and #tag_data > 0 then
											if tag_data[1]["text"] == "VOIDWARE USER" then rank = "Normal" end
											local tag_text = tag_data[1]["text"].." - "..rank
											local tag_color = tag_data[1]["color"]
											local updated_text = add_colored_text(current_text, tag_text, tag_color)
											
											if updated_text then
												plr_name_frame.Text = updated_text
											end
										else
											print("Tag data missing for player:", name)
										end
									end
								else
									print("Streamer mode is on for player:", name)
								end
							else
								print("PlayerName frame not found for player row")
							end
						end
					else
						print("Side is nil")
					end
				end
			else
				print("Players frame not found")
			end
		else
			print("TabListFrame not found")
		end
	end

	local function handle_new_ui(ui)
		if tostring(ui) == "TabListScreenGui" then
			handle_tablist(ui)
		end
	end

	lplr_gui.ChildAdded:Connect(handle_new_ui)
end)
--[[run(function()
	local JellyFishExploit = {}
	JellyFishExploit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'JellyFishExploit',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat
						local args = {
							[1] = "electrify_jellyfish"
						}
						
						game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"):WaitForChild("useAbility"):FireServer(unpack(args))
						wait(0.1)
					until not JellyFishExploit.Enabled						
				end)
			end
		end
	})
end)--]]

--[[run(function()
	local FortunaExploit = {}
	FortunaExploit = GuiLibrary.ObjectsThatCanBeSaved.VoidwareDevWindow.Api.CreateOptionsButton({
		Name = 'test_fortuna_Exploit',
		Function = function(calling)
			if calling then 
				warningNotification("FortunaExploit", "This just spams some remotes which are used when u have fortuna kit equipped", 5)
				task.spawn(function()
					repeat
						local args = {
							[1] = "CARD_THROW"
						}
						
						game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"):WaitForChild("useAbility"):FireServer(unpack(args))
						
						local args = {
							[1] = {
								["targetEntityInstance"] = workspace:WaitForChild("EntityHitbox")
							}
						}
						
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("AttemptCardThrow"):FireServer(unpack(args))

						local args = {
							[1] = {
								["upgrade"] = "oversized"
							}
						}
						
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("CardSelectUpgrade"):FireServer(unpack(args))

						local args = {
							[1] = {
								["upgrade"] = "explosion"
							}
						}
						
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("CardSelectUpgrade"):FireServer(unpack(args))

						local args = {
							[1] = {
								["upgrade"] = "critical_hit"
							}
						}
						
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("CardSelectUpgrade"):FireServer(unpack(args))						
						
						local args = {
							[1] = {
								["upgrade"] = "minisized"
							}
						}
						
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("CardSelectUpgrade"):FireServer(unpack(args))						
						task.wait()
					until not FortunaExploit.Enabled						
				end)
			end
		end
	})
end)--]]

--[[run(function()
	local AutoUpgradeEra = {}
	AutoUpgradeEra = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'AutoUpgradeEra',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat task.wait(0.5)
						local args = {
							[1] = {
								["era"] = "iron_era"
							}
						}
						
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("RequestPurchaseEra"):InvokeServer(unpack(args))
	
						local args = {
							[1] = {
								["era"] = "diamond_era"
							}
						}
						
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("RequestPurchaseEra"):InvokeServer(unpack(args))
	
						local args = {
							[1] = {
								["era"] = "emerald_era"
							}
						}
						
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("RequestPurchaseEra"):InvokeServer(unpack(args))
					until (not AutoUpgradeEra.Enabled)
				end)
			end
		end
	})
	local Credits
	Credits = AutoUpgradeEra.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Aurora'
    })
end)--]]

--[[run(function()
	local TPHighJump = {Enabled = false} --- sup nebula :)

	local function PerformHighJump()
		local character = game.Players.LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		
		if humanoidRootPart then
			local jumpDistance = TPHighJumpDistance.Value
			local initialHeight = humanoidRootPart.Position.Y
			for i = 1, 3 do  
				humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, jumpDistance, 0))
				wait(0.1) 
				
				local currentHeight = humanoidRootPart.Position.Y - initialHeight
				warningNotification("TPHighJump", "Currently " .. tostring(currentHeight) .. " studs in the air", 3)
			end
		end
	end

	TPHighJump = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "TPHighJump",
		Function = function(callback)
			if callback then
				PerformHighJump()

		wait(0.6)
		TPHighJump.ToggleButton(false)

			end
		end,
		HoverText = "x3 the number that you put in height"
	})

	TPHighJumpDistance = TPHighJump.CreateSlider({
		Name = "Jump Height (studs)",
		Min = 1,
		Max = 350,
		Default = 50,
		Function = function(value)
			TPHighJumpDistance.Value = value
		end
	})
end)--]]

--[[run(function()
	local insta = {Enabled = false}
	insta = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "EmberExploit",
		Function = function(callback)
			if callback then
				warningNotification("EmberExploit", "Ember blade is required for this to work", 3)
				task.spawn(function()
					repeat
						task.wait()
						game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.HellBladeRelease:FireServer({
							["chargeTime"] = 0.999,
							["player"] = game:GetService("Players").LocalPlayer,
							["weapon"] =game:GetService("ReplicatedStorage").Inventories:FindFirstChild(lplr.Name.."infernal_saber"),
						})
					until (not insta.Enabled)
				end)
			end
		end, 
		HoverText = "🔥ember"
	})
end)--]]

run(function()
	local Anime = {}
	local Anime_table = {
		["AnimeWaifu1"] = 18498989965,
		["Anime2"] = {
			["ID"] = 18499238992,
			["Size"] = UDim2.new(0, 150, 0, 200)
		},
		["Anime3"] = {
			["ID"] = 18499361548,
			["Size"] = UDim2.new(0, 150, 0, 200)
		},
		["Anime4"] = 18499384179,
		["Anime5"] = 18499402527
	}
	local default_table = {
		["Size"] = UDim2.new(0, 100, 0, 200),
		["Position"] = UDim2.new(0.9, 0, 0, 0)
	}
	local anime_image_label
	local AnimeSelection = {Value = "AnimeWaifu1"}
	Anime = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'AnimeImages',
		Function = function(calling)
			if calling then 
				pcall(function()
					if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ANIMEIMAGESSCREENGUI") then game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ANIMEIMAGESSCREENGUI"):Destroy() end
				end)

				local chosenid = Anime_table[AnimeSelection.Value]

				local a = Instance.new("ScreenGui")
				a.Name = "ANIMEIMAGESSCREENGUI"
				a.Parent = game:GetService("Players").LocalPlayer.PlayerGui

				local b = Instance.new("ImageLabel")
				b.Parent = a
				b.BackgroundTransparency = 1

				--- CUSTOM ---
				if type(Anime_table[AnimeSelection.Value]) == "table" then
					b.Image = "rbxassetid://"..tostring(chosenid["ID"])
					b.Position = UDim2.new(0.9, 0, 0, 0)
					b.Size = UDim2.new(0, 100, 0, 200)
					for i,v in pairs(chosenid) do
						if i ~= "ID" then
							b[i] = chosenid[i]
						end
					end
				else
					b.Image = "rbxassetid://"..tostring(chosenid)
					b.Position = UDim2.new(0.9, 0, 0, 0)
					b.Size = UDim2.new(0, 100, 0, 200)
				end

				anime_image_label = b

				shared.GuiLibrary.SelfDestructEvent.Event:Connect(function()
					game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ANIMEIMAGESSCREENGUI"):Destroy()
				end)
			else
				game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ANIMEIMAGESSCREENGUI"):Destroy()
			end
		end
	})
	local options = {}
	for i,v in pairs(Anime_table) do table.insert(options, i) end
	AnimeSelection = Anime.CreateDropdown({
		Name = "Selection",
		Function = function()
			if anime_image_label then 
				local chosenid = Anime_table[AnimeSelection.Value]
				if type(Anime_table[AnimeSelection.Value]) == "table" then
					anime_image_label.Image = "rbxassetid://"..tostring(chosenid["ID"])
					anime_image_label.Position = UDim2.new(0.9, 0, 0, 0)
					anime_image_label.Size = UDim2.new(0, 100, 0, 200)
					for i,v in pairs(chosenid) do
						if i ~= "ID" then
							anime_image_label[i] = chosenid[i]
						end
					end
				else
					anime_image_label.Image = "rbxassetid://"..tostring(chosenid)
					anime_image_label.Position = UDim2.new(0.9, 0, 0, 0)
					anime_image_label.Size = UDim2.new(0, 100, 0, 200)
				end
			end
		end,
		List = options
	})
end)

warningNotification('Voidware ' .. void.version, 'Loaded in ' .. string.format('%.1f', void.round(tick() - void.load))..'s. Logged in as ' .. lplr.Name .. '.', 7)
shared.GlobalStore = store
local ProtectedModules
task.spawn(function()
	pcall(function()
		if shared.ProtectedModules then ProtectedModules = shared.ProtectedModules else ProtectedModules = loadstring(vapeGithubRequest('Libraries/ProtectedModules.lua'))() end
		ProtectedModules.LoadModules(6872274481)
	end)
end)
--[[task.spawn(function()
	local suc, err = pcall(function()
		loadstring(vapeGithubRequest('vape/Libraries/Protected_6872274481.lua'))()
	end)
	if err then if shared.VapeDeveloper then InfoNotification("Voidware Whitelist", "Failure loading whitelist modules. Error: "..tostring(err), 7) end warn("VoidwareWhitelist_ErrorReport: "..tostring(err)) end
end)--]]
--[[task.spawn(function()
	repeat task.wait() until shared.VapeFullyLoaded 
	pcall(function()
		if shared.GuiLibrary.ObjectsThatCanBeSaved["Extra modeToggle"].Api.Enabled == true then
			local suc, err = pcall(function()
				loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/vapevoidware/main/Libraries/ExtraModules.lua", true))()
			end)
			if err then if shared.VapeDeveloper then InfoNotification("ExtraModules", "Failure loading! Error: "..tostring(err)) end warn("[ExtraModules] Failure loading! Error: "..tostring(err)) end
		end
	end)
end)--]]