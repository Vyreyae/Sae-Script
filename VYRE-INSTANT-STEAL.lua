--[[
    VYRE | Steal an Egg  -  Instant TP Targeted Farm  (v2)
    UI: Rayfield   |   Teleport: Character:PivotTo + momentum reset

    Flow:
      1. Hanapin ang best na egg (Map + Rarity + Size filter)
      2. Instant TP -> fire ng "Steal" prompt
      3. TP sa Hatch Area ng plot mo (drop ng egg)
      4. Walang target? Stay lang sa Treadmill mo (walang spam TP)

    Tip: kung iba ang spelling ng biome sa egg names ng game,
         dagdagan lang ang "Keys" sa BIOMES table sa baba.
]]

if not game:IsLoaded() then game.Loaded:Wait() end

----------------------------------------------------------------
-- 0. Anti-duplicate: pag nire-execute ulit, i-unload muna ang luma
----------------------------------------------------------------
local env = (getgenv and getgenv()) or _G
if env.VYRE_STEAL and type(env.VYRE_STEAL.Unload) == "function" then
    pcall(env.VYRE_STEAL.Unload)
end

----------------------------------------------------------------
-- 1. Services + Rayfield (tamang URL ay /rayfield)
----------------------------------------------------------------
local Players     = game:GetService("Players")
local Workspace   = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local okRay, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not okRay or type(Rayfield) ~= "table" then
    warn("[VYRE] Hindi na-load ang Rayfield: " .. tostring(Rayfield))
    return
end

----------------------------------------------------------------
-- 2. CONFIG + STATE
----------------------------------------------------------------
local Config = {
    Enabled        = false,
    RunId          = 0,        -- pang-iwas sa double loop

    SelectedMap    = "Forest",
    SelectedRarity = "Common",
    SelectedSize   = "Any",

    LoopDelay      = 0.4,      -- seconds sa pagitan ng scan
    GrabDelay      = 0.05,     -- hintay after TP bago i-fire ang prompt
    GrabAttempts   = 3,        -- ilang beses i-fire kung hindi pa nakuha
    DepositWait    = 1.0,      -- tagal sa Hatch Area after grab
    FailCooldown   = 8,        -- seconds na i-skip ang egg na pumalya

    ParkRadius     = 20,       -- studs: kapag lumayo ka dito sa treadmill, TP pabalik
    LiftEgg        = 3,        -- min studs sa taas ng egg pag nag-TP
    LiftBase       = 3,        -- studs sa taas ng treadmill / hatch area

    AntiAFK        = true,
    AutoDeposit    = true,     -- i-fire ang Place/Drop/Hatch prompts sa plot mo
}

local State = { Stolen = 0, FailStreak = 0, LastCarryDeliver = 0 }
local Connections = {}
local PromptCache = {}   -- [ProximityPrompt] = true
local Blacklist   = {}   -- [ProximityPrompt] = os.clock() hanggang kailan i-skip
local StatusLabel, BiomeLabel
local lastStatusText
local warned = {}

----------------------------------------------------------------
-- 3. GAME DATA (galing sa blueprint)
----------------------------------------------------------------
local BIOMES = {
    { Name = "Forest",           Speed = 0,           Guardian = "Chicken",         Keys = { "forest" } },
    { Name = "Lake",             Speed = 900,         Guardian = "Swan",            Keys = { "lake" } },
    { Name = "Desert",           Speed = 10000,       Guardian = "Scorpion",        Keys = { "desert" } },
    { Name = "Jungle",           Speed = 40000,       Guardian = "Tiger",           Keys = { "jungle" } },
    { Name = "Snow",             Speed = 170000,      Guardian = "Yeti",            Keys = { "snow" } },
    { Name = "Volcano",          Speed = 700000,      Guardian = "Cerberus",        Keys = { "volcano" } },
    { Name = "Abyss Ocean",      Speed = 2500000,     Guardian = "Moby",            Keys = { "abyss ocean", "abyss" } },
    { Name = "Prehistoric",      Speed = 18000000,    Guardian = "T-Rex",           Keys = { "prehistoric" } },
    { Name = "Cosmic",           Speed = 700000000,   Guardian = "Cosmic Skeleton", Keys = { "cosmic" } },
    { Name = "Cherry Blossom",   Speed = 2500000000,  Guardian = "Oni Tiger",       Keys = { "cherry blossom", "cherry", "blossom" } },
    { Name = "Titan Temple",     Speed = 7000000000,  Guardian = "Gorilla King",    Keys = { "titan temple", "titan", "temple" } },
    { Name = "Angels & Demons",  Speed = 20000000000, Guardian = "ArchAngel / World Burner / Aetheron",
      Keys = { "angels demons", "angels and demons", "angels", "demons", "angel", "demon" } },
    { Name = "Enchanted Forest", Speed = 50000000000, Guardian = "Enchanted Wisp",  Keys = { "enchanted forest", "enchanted" } },
}

local RARITIES = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Cosmic", "Secret", "Eternal", "Divine" }
local SIZES    = { "Small", "Medium", "Large", "Giant" }

local MapOptions, RarityOptions, SizeOptions = { "Any" }, { "Any" }, { "Any" }
for _, b in ipairs(BIOMES)   do table.insert(MapOptions, b.Name) end
for _, r in ipairs(RARITIES) do table.insert(RarityOptions, r) end
for _, s in ipairs(SIZES)    do table.insert(SizeOptions, s) end

----------------------------------------------------------------
-- 4. NAME PARSING  ("<Size> <Biome> <Rarity> Egg")
--    Fix: "Common" hindi na tumatama sa "Uncommon", "Forest" hindi na
--    tumatama sa "Enchanted Forest", at safe na ang Cosmic (map vs rarity)
----------------------------------------------------------------
local function normalize(str)
    str = string.lower(tostring(str))
    str = string.gsub(str, "[^%w]+", " ")
    str = string.gsub(str, "^%s+", "")
    str = string.gsub(str, "%s+$", "")
    return str
end

local function hasWord(norm, word)
    return string.find(" " .. norm .. " ", " " .. word .. " ", 1, true) ~= nil
end

local RARITY_RANK, SIZE_SET = {}, {}
for i, r in ipairs(RARITIES) do RARITY_RANK[string.lower(r)] = i end
for _, s in ipairs(SIZES)    do SIZE_SET[string.lower(s)] = true end

-- pinakamahabang key ang unang titingnan (para "enchanted forest" bago "forest")
local BIOME_KEYS = {}
for _, b in ipairs(BIOMES) do
    for _, k in ipairs(b.Keys) do
        table.insert(BIOME_KEYS, { Key = normalize(k), Biome = b.Name })
    end
end
table.sort(BIOME_KEYS, function(x, y) return #x.Key > #y.Key end)

local function findBiome(text)
    local padded = " " .. text .. " "
    for _, entry in ipairs(BIOME_KEYS) do
        if string.find(padded, " " .. entry.Key .. " ", 1, true) then
            return entry.Biome
        end
    end
    return nil
end

local function parseEggName(name)
    local words = {}
    for w in string.gmatch(normalize(name), "%S+") do
        words[#words + 1] = w
    end

    -- rarity = pinakahuling rarity word sa pangalan
    local rarity, rarityIdx
    for i = #words, 1, -1 do
        if RARITY_RANK[words[i]] then
            rarity = words[i]
            rarityIdx = i
            break
        end
    end

    -- size + biome = lahat ng nasa harap ng rarity
    local size
    local biomeWords = {}
    local hasEggWord = false
    for i, w in ipairs(words) do
        if w == "egg" then
            hasEggWord = true
        elseif not rarityIdx or i < rarityIdx then
            if SIZE_SET[w] then
                size = size or w
            else
                biomeWords[#biomeWords + 1] = w
            end
        end
    end

    return {
        Size       = size,
        Rarity     = rarity,
        Biome      = findBiome(table.concat(biomeWords, " ")),
        HasEggWord = hasEggWord,
    }
end

local function matchesFilters(info)
    local map, rarity, size = Config.SelectedMap, Config.SelectedRarity, Config.SelectedSize
    if map and map ~= "Any" and info.Biome ~= map then return false end
    if rarity and rarity ~= "Any" and info.Rarity ~= string.lower(rarity) then return false end
    if size and size ~= "Any" and info.Size ~= string.lower(size) then return false end
    return true
end

----------------------------------------------------------------
-- 5. WORLD HELPERS (status, character, teleport, plot, treadmill, hatch)
----------------------------------------------------------------
local function warnOnce(key, msg)
    if not warned[key] then
        warned[key] = true
        warn("[VYRE] " .. msg)
    end
end

local function setStatus(text)
    local full = string.format("Status: %s  |  Stolen: %d", text, State.Stolen)
    if full == lastStatusText then return end
    lastStatusText = full
    if StatusLabel then
        pcall(function() StatusLabel:Set(full) end)
    end
end

local function getCharacter()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then return nil end
    return char, root, hum
end

-- gumagana kahit BasePart, Attachment o Model ang parent ng prompt
local function getWorldCFrame(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst.CFrame end
    if inst:IsA("Attachment") then return inst.WorldCFrame end
    if inst:IsA("Model") then return inst:GetPivot() end
    return nil
end

local function anyCFrame(inst)
    if not inst then return nil end
    local cf = getWorldCFrame(inst)
    if cf then return cf end
    local part = inst:FindFirstChildWhichIsA("BasePart", true)
    return part and part.CFrame or nil
end

-- tuwid lagi ang character pagdating (walang tilt/roll), yaw lang ang tinitira
local function upright(cf)
    local _, ry = cf:ToOrientation()
    return CFrame.new(cf.Position) * CFrame.Angles(0, ry, 0)
end

-- Safe instant TP: zero momentum muna, tapos PivotTo (hindi HRP.CFrame)
local function safeInstantTP(target)
    if not target then return false end
    local char, root = getCharacter()
    if not char then return false end

    local cf = (typeof(target) == "Vector3") and CFrame.new(target) or target

    root.AssemblyLinearVelocity  = Vector3.new(0, 0, 0)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

    char:PivotTo(upright(cf))

    root.AssemblyLinearVelocity  = Vector3.new(0, 0, 0)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    return true
end

local function ownerMatches(value)
    if value == nil then return false end
    if value == LocalPlayer then return true end
    local t = typeof(value)
    if t == "string" then
        return value == LocalPlayer.Name or value == LocalPlayer.DisplayName
    elseif t == "number" then
        return value == LocalPlayer.UserId
    elseif t == "Instance" then
        return value == LocalPlayer.Character
    end
    return false
end

local MyPlot
local function getMyPlot()
    if MyPlot and MyPlot.Parent then
        local owner = MyPlot:FindFirstChild("Owner")
        if owner and owner:IsA("ValueBase") and ownerMatches(owner.Value) then
            return MyPlot
        end
    end
    MyPlot = nil
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local owner = plot:FindFirstChild("Owner")
            if owner and owner:IsA("ValueBase") and ownerMatches(owner.Value) then
                MyPlot = plot
                break
            end
        end
    end
    return MyPlot
end

-- Treadmill (GetPivot ang gamit, hindi PrimaryPart/.CFrame ng Model)
local function getTreadmillCFrame()
    local plot = getMyPlot()
    if plot then
        local treadmill = plot:FindFirstChild("Treadmill", true)
        local cf = anyCFrame(treadmill) or anyCFrame(plot)
        if cf then return cf * CFrame.new(0, Config.LiftBase, 0) end
    end
    local spawnLoc = LocalPlayer.RespawnLocation or Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    if spawnLoc then return spawnLoc.CFrame * CFrame.new(0, 4, 0) end
    return nil
end

-- Hatch Area = anumang part/model sa plot mo na may "hatch" sa pangalan
local HatchArea
local function getHatchCFrame()
    local plot = getMyPlot()
    if not plot then return nil end
    if not (HatchArea and HatchArea.Parent and HatchArea:IsDescendantOf(plot)) then
        HatchArea = nil
        for _, d in ipairs(plot:GetDescendants()) do
            if (d:IsA("BasePart") or d:IsA("Model"))
                and string.find(string.lower(d.Name), "hatch", 1, true) then
                HatchArea = d
                break
            end
        end
    end
    local cf = anyCFrame(HatchArea)
    if cf then return cf * CFrame.new(0, Config.LiftBase, 0) end
    return nil
end

----------------------------------------------------------------
-- 6. EGG SCANNER (naka-cache ang ProximityPrompts, hindi na buong workspace scan)
----------------------------------------------------------------
local function onDescendantAdded(inst)
    if inst:IsA("ProximityPrompt") then
        PromptCache[inst] = true
    end
end

local function onDescendantRemoving(inst)
    PromptCache[inst] = nil
end

for _, inst in ipairs(Workspace:GetDescendants()) do
    onDescendantAdded(inst)
end
Connections.Added    = Workspace.DescendantAdded:Connect(onDescendantAdded)
Connections.Removing = Workspace.DescendantRemoving:Connect(onDescendantRemoving)

-- ObjectText O ActionText = "Steal" (para sigurado)
local function isStealPrompt(prompt)
    return string.lower(prompt.ObjectText) == "steal"
        or string.lower(prompt.ActionText) == "steal"
end

-- Skip: eggs sa loob ng Plots (pati sarili mong pen) at eggs na bitbit ng kahit sino
local function isExcluded(prompt)
    local plots = Workspace:FindFirstChild("Plots")
    if plots and prompt:IsDescendantOf(plots) then return true end
    for _, plr in ipairs(Players:GetPlayers()) do
        local c = plr.Character
        if c and prompt:IsDescendantOf(c) then return true end
    end
    return false
end

-- Umakyat mula sa prompt hanggang makita ang model/part na may egg name
local function findEggNode(prompt)
    local node = prompt.Parent
    local fallback, fallbackInfo
    while node and node ~= Workspace do
        if node:IsA("Model") or node:IsA("BasePart") then
            local info = parseEggName(node.Name)
            if info.Rarity then
                if not info.Biome then
                    -- wala sa pangalan ang biome? tingnan ang folders sa taas
                    local up = node.Parent
                    while up and up ~= Workspace do
                        info.Biome = findBiome(normalize(up.Name))
                        if info.Biome then break end
                        up = up.Parent
                    end
                end
                return node, info
            elseif info.HasEggWord and not fallback then
                fallback, fallbackInfo = node, info
            end
        end
        node = node.Parent
    end
    return fallback, fallbackInfo
end

-- Taas ng TP: hindi tayo papasok sa loob ng malaking (Giant) egg
local function eggLift(prompt, egg)
    local height = 0
    if egg:IsA("Model") then
        local ok, _, size = pcall(egg.GetBoundingBox, egg)
        if ok and size then height = size.Y end
    elseif egg:IsA("BasePart") then
        height = egg.Size.Y
    end
    local maxLift = math.max(Config.LiftEgg, prompt.MaxActivationDistance - 2)
    return math.clamp(height / 2 + 2, Config.LiftEgg, maxLift)
end

local function evaluatePrompt(prompt, root, now)
    if not prompt.Parent or not prompt.Enabled then return nil end
    if not isStealPrompt(prompt) then return nil end
    local cool = Blacklist[prompt]
    if cool and cool > now then return nil end
    if isExcluded(prompt) then return nil end

    local egg, info = findEggNode(prompt)
    if not egg or not matchesFilters(info) then return nil end

    local cf = getWorldCFrame(prompt.Parent) or getWorldCFrame(egg)
    if not cf then return nil end

    return {
        Prompt   = prompt,
        Egg      = egg,
        Info     = info,
        Position = cf.Position,
        Distance = (cf.Position - root.Position).Magnitude,
    }
end

-- Pinakamataas na rarity muna (kung "Any"), tapos pinakamalapit
local function findTarget(root)
    local now = os.clock()
    for prompt, untilT in pairs(Blacklist) do
        if untilT <= now or not prompt.Parent then
            Blacklist[prompt] = nil
        end
    end

    local best, bestScore
    for prompt in pairs(PromptCache) do
        local c = evaluatePrompt(prompt, root, now)
        if c then
            local score = (RARITY_RANK[c.Info.Rarity or ""] or 0) * 1e9 - c.Distance
            if not bestScore or score > bestScore then
                best, bestScore = c, score
            end
        end
    end
    return best
end

----------------------------------------------------------------
-- 7. ACTIONS (grab, deliver sa hatch area, park sa treadmill)
----------------------------------------------------------------
local function triggerPrompt(prompt)
    if typeof(fireproximityprompt) == "function" then
        fireproximityprompt(prompt)
    else
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration + 0.05)
        prompt:InputHoldEnd()
    end
end

-- "Grabbing an egg binds it to the character model"
local function isCarryingEgg(char)
    for _, d in ipairs(char:GetDescendants()) do
        if (d:IsA("Model") or d:IsA("BasePart") or d:IsA("Tool"))
            and not d:FindFirstAncestorOfClass("Accessory") then
            local lname = string.lower(d.Name)
            if string.find(lname, "egg", 1, true) and hasWord(normalize(lname), "egg") then
                return true
            end
        end
    end
    return false
end

local function waitForGrab(target, char, carriedBefore, timeout)
    local t0 = os.clock()
    repeat
        local prompt = target.Prompt
        if not prompt:IsDescendantOf(Workspace) then return true end   -- nawala ang prompt
        if not prompt.Enabled then return true end                     -- na-disable after grab
        if target.Egg:IsDescendantOf(char) then return true end        -- nasa character na
        if not carriedBefore and isCarryingEgg(char) then return true end
        task.wait(0.05)
    until os.clock() - t0 >= timeout
    return false
end

local function grabEgg(target, carriedBefore)
    local char = getCharacter()
    if not char then return false end

    local prompt = target.Prompt
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
    end)

    local grabCF = CFrame.new(target.Position + Vector3.new(0, eggLift(prompt, target.Egg), 0))
    safeInstantTP(grabCF)
    task.wait(Config.GrabDelay)

    for _ = 1, Config.GrabAttempts do
        if not prompt.Parent then return false end
        pcall(triggerPrompt, prompt)
        if waitForGrab(target, char, carriedBefore, 0.4) then return true end
        safeInstantTP(grabCF)   -- baka natulak tayo palayo, ulit
    end
    return false
end

local DEPOSIT_WORDS = { "place", "drop", "deposit", "put", "hatch", "incubat" }

-- Kung prompt ang gamit ng game para i-drop ang egg sa pen mo
local function fireDepositPrompts()
    local plot = getMyPlot()
    local _, root = getCharacter()
    if not plot or not root then return end

    local list = {}
    for prompt in pairs(PromptCache) do
        if prompt.Parent and prompt.Enabled and not isStealPrompt(prompt)
            and prompt:IsDescendantOf(plot) then
            local text = string.lower(prompt.ActionText .. " " .. prompt.ObjectText)
            for _, word in ipairs(DEPOSIT_WORDS) do
                if string.find(text, word, 1, true) then
                    list[#list + 1] = prompt
                    break
                end
            end
        end
    end

    for _, prompt in ipairs(list) do
        local cf = getWorldCFrame(prompt.Parent)
        if cf and (cf.Position - root.Position).Magnitude <= prompt.MaxActivationDistance + 15 then
            pcall(function() prompt.HoldDuration = 0 end)
            pcall(triggerPrompt, prompt)
        end
    end
end

local function deliverEgg()
    local cf = getHatchCFrame() or getTreadmillCFrame()
    if not cf then
        warnOnce("nobase", "Hindi makita ang Hatch Area/plot mo. Check: workspace.Plots.<plot>.Owner")
        return false
    end
    State.LastCarryDeliver = os.clock()
    safeInstantTP(cf)
    task.wait(Config.DepositWait)
    if Config.AutoDeposit then fireDepositPrompts() end
    return true
end

-- Walang target: stay sa treadmill. TP lang kung lumayo ka na.
local function parkAtBase()
    local cf = getTreadmillCFrame()
    local _, root = getCharacter()
    if not root then return end
    if not cf then
        setStatus("Base not found")
        warnOnce("nobase", "Hindi ma-detect ang Base Plot mo. Check: workspace.Plots.<plot>.Owner")
        return
    end
    if (root.Position - cf.Position).Magnitude > Config.ParkRadius then
        safeInstantTP(cf)
        setStatus("No target -> back at treadmill")
    else
        setStatus("Waiting for target egg (at treadmill)")
    end
end

----------------------------------------------------------------
-- 8. MAIN FARM LOOP
----------------------------------------------------------------
local function farmStep()
    local char, root = getCharacter()
    if not char then
        setStatus("Waiting for character...")
        return
    end

    -- may bitbit pang egg? i-deliver muna (max 1x kada 6s para hindi ma-stuck)
    local carrying = isCarryingEgg(char)
    if carrying and (os.clock() - State.LastCarryDeliver) > 6 then
        setStatus("Carrying egg -> delivering...")
        deliverEgg()
        return
    end

    local target = findTarget(root)
    if not target then
        parkAtBase()
        return
    end

    setStatus("Grabbing: " .. target.Egg.Name)
    local ok = grabEgg(target, carrying)
    Blacklist[target.Prompt] = os.clock() + Config.FailCooldown

    if ok then
        State.Stolen = State.Stolen + 1
        State.FailStreak = 0
        setStatus("Delivering to hatch area...")
        deliverEgg()
    else
        State.FailStreak = State.FailStreak + 1
        setStatus("Grab failed, next egg...")
        if State.FailStreak == 5 then
            Rayfield:Notify({
                Title = "Grab keeps failing",
                Content = "Check kung kaya na ng Speed mo ang biome, o kung may ibang prompt text ang game.",
                Duration = 6,
                Image = 4483362458,
            })
        end
    end
end

local function startFarm()
    Config.RunId = Config.RunId + 1
    local myId = Config.RunId
    task.spawn(function()
        while Config.Enabled and Config.RunId == myId do
            local ok, err = pcall(farmStep)
            if not ok then
                warn("[VYRE] farmStep error: " .. tostring(err))
                task.wait(1)
            end
            task.wait(Config.LoopDelay)
        end
    end)
end

-- Debug: ilista lahat ng nakitang "Steal" eggs at kung tumatama sa filter
local function scanEggs()
    local total, matched = 0, 0
    for prompt in pairs(PromptCache) do
        if prompt.Parent and isStealPrompt(prompt) and not isExcluded(prompt) then
            local egg, info = findEggNode(prompt)
            if egg then
                total = total + 1
                local ok = matchesFilters(info)
                if ok then matched = matched + 1 end
                print(string.format("[VYRE] %s | biome=%s rarity=%s size=%s | match=%s",
                    egg.Name, tostring(info.Biome), tostring(info.Rarity), tostring(info.Size), tostring(ok)))
            end
        end
    end
    print(string.format("[VYRE] Scan: %d egg(s), %d match", total, matched))

    local content = string.format("%d egg(s) found, %d match your filter. Details sa console.", total, matched)
    if total == 0 then
        content = "Walang 'Steal' egg na nakita. Baka night phase, iba ang prompt text, o wala pa sa client ang eggs."
    end
    Rayfield:Notify({ Title = "Egg Scan", Content = content, Duration = 5, Image = 4483362458 })
end

----------------------------------------------------------------
-- 9. UI
----------------------------------------------------------------
local function selection(opt)
    if type(opt) == "table" then return opt[1] end   -- Rayfield: table ang binabalik
    return opt
end

local function formatNumber(n)
    local s = string.format("%.0f", n)
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (out:gsub("^,", ""))
end

local function biomeInfoText(mapName)
    if mapName == "Any" then
        return "Any biome (hindi limitado sa isang map)"
    end
    for _, b in ipairs(BIOMES) do
        if b.Name == mapName then
            return string.format("%s: needs %s Speed  |  Guardian: %s",
                b.Name, formatNumber(b.Speed), b.Guardian)
        end
    end
    return ""
end

local Window = Rayfield:CreateWindow({
    Name = "VYRE | Steal an Egg",
    LoadingTitle = "VYRE Instant Steal",
    LoadingSubtitle = "Targeted Auto-Farm v2",
    ConfigurationSaving = { Enabled = false },
})

local FarmTab = Window:CreateTab("Targeted Farm", 4483362458)

FarmTab:CreateSection("Target")

FarmTab:CreateDropdown({
    Name = "1. Select Target Map/Biome",
    Options = MapOptions,
    CurrentOption = { Config.SelectedMap },
    MultipleOptions = false,
    Callback = function(opt)
        Config.SelectedMap = selection(opt)
        if BiomeLabel then
            pcall(function() BiomeLabel:Set(biomeInfoText(Config.SelectedMap)) end)
        end
    end,
})

BiomeLabel = FarmTab:CreateLabel(biomeInfoText(Config.SelectedMap))

FarmTab:CreateDropdown({
    Name = "2. Select Target Rarity",
    Options = RarityOptions,
    CurrentOption = { Config.SelectedRarity },
    MultipleOptions = false,
    Callback = function(opt)
        Config.SelectedRarity = selection(opt)
    end,
})

FarmTab:CreateDropdown({
    Name = "3. Egg Size (optional)",
    Options = SizeOptions,
    CurrentOption = { Config.SelectedSize },
    MultipleOptions = false,
    Callback = function(opt)
        Config.SelectedSize = selection(opt)
    end,
})

FarmTab:CreateSection("Auto-Farm")

FarmTab:CreateToggle({
    Name = "Start Targeted Auto-Farm",
    CurrentValue = false,
    Callback = function(value)
        Config.Enabled = value and true or false
        if Config.Enabled then
            startFarm()
        else
            Config.RunId = Config.RunId + 1   -- patayin agad ang loop
            setStatus("Stopped")
        end
    end,
})

local initialStatus = "Status: Idle  |  Stolen: 0"
StatusLabel = FarmTab:CreateLabel(initialStatus)
lastStatusText = initialStatus

FarmTab:CreateSection("Settings")

FarmTab:CreateSlider({
    Name = "Scan Interval",
    Range = { 0.1, 3 },
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = Config.LoopDelay,
    Callback = function(v) Config.LoopDelay = v end,
})

FarmTab:CreateSlider({
    Name = "Hatch Area Wait",
    Range = { 0.2, 5 },
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = Config.DepositWait,
    Callback = function(v) Config.DepositWait = v end,
})

FarmTab:CreateToggle({
    Name = "Auto-fire Place/Hatch prompts sa plot",
    CurrentValue = Config.AutoDeposit,
    Callback = function(v) Config.AutoDeposit = v end,
})

FarmTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = Config.AntiAFK,
    Callback = function(v) Config.AntiAFK = v end,
})

FarmTab:CreateSection("Tools")

FarmTab:CreateButton({
    Name = "Scan Eggs Now (print sa console)",
    Callback = function() scanEggs() end,
})

FarmTab:CreateButton({
    Name = "TP to My Treadmill",
    Callback = function()
        local cf = getTreadmillCFrame()
        if cf then
            safeInstantTP(cf)
        else
            Rayfield:Notify({
                Title = "Base not found",
                Content = "Hindi ma-detect ang plot mo sa workspace.Plots.",
                Duration = 4,
                Image = 4483362458,
            })
        end
    end,
})

----------------------------------------------------------------
-- 10. ANTI-AFK + UNLOAD
----------------------------------------------------------------
Connections.Idled = LocalPlayer.Idled:Connect(function()
    if not Config.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

local function Unload()
    Config.Enabled = false
    Config.RunId = Config.RunId + 1
    for key, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
        Connections[key] = nil
    end
    pcall(function() Rayfield:Destroy() end)
    if env.VYRE_STEAL and env.VYRE_STEAL.Unload == Unload then
        env.VYRE_STEAL = nil
    end
end
env.VYRE_STEAL = { Unload = Unload }

FarmTab:CreateButton({
    Name = "Unload Script",
    Callback = function() Unload() end,
})

Rayfield:Notify({
    Title = "VYRE Loaded",
    Content = "Pili ng Map + Rarity, tapos i-on ang Start Targeted Auto-Farm.",
    Duration = 5,
    Image = 4483362458,
})
