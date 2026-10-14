--[[
	Vyre Hub | Multiverse Script Sae
	Script launcher + Config (scale / themes)
	Minimize to compact bar
	Motion background: rotating + breathing black hole (Config > Default / Inferno rows)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local guiName = "VyreHubMultiverseSaw"

local parentContainer = playerGui
pcall(function()
	if typeof(gethui) == "function" then
		local h = gethui()
		if typeof(h) == "Instance" then
			parentContainer = h
		end
	end
end)

if parentContainer:FindFirstChild(guiName) then
	parentContainer[guiName]:Destroy()
end

-- ======================
-- SCRIPT LIST (put your raw URLs here later)
-- url = "" means empty for now
-- ======================
-- NO KEY REQUIRED (main)
local scriptsData = {
	{ name = "Miranda OP", url = "https://raw.githubusercontent.com/miirandahub/loader/refs/heads/main/stealeggies" },
	{ name = "Miranda AFK", url = "https://raw.githubusercontent.com/miirandahub/loader/refs/heads/main/afkk" },
	{ name = "Polluted Hub", url = "https://raw.githubusercontent.com/PollutedHub/Sae/main/SaePolluted" },
	{ name = "Chilli Hub", url = "https://raw.githubusercontent.com/tienkhanh1/Chilli-Hub-Script/refs/heads/main/StealAnEgg" },
	{ name = "Universal SAE", url = "https://raw.githubusercontent.com/sabscrip-arch/srver/refs/heads/main/Stealanegg" },
	{ name = "Blyxo Hub", url = "https://flowauth.net/v1/loaders/69d3463240384f3a73fbe32c178093a2.lua" },
	{ name = "Source Anti Hit", url = "https://gist.githubusercontent.com/sourceshubs/df6e17b3672213791b47a0a8c5398b6e/raw/SourcesHubAntiHitNewest" },
	{ name = "Source Instant Steal", url = "https://gist.githubusercontent.com/sourceshubs/9c70c7c483019f2de5d7119ae05ba3f8/raw/SourcesHubStealAnEgg" },
	{ name = "Sources Instant", url = "https://gist.githubusercontent.com/sourceshubs/1737c14cdba5c6fb472a995d555a50f1/raw/SourcesHubInstantStealNew" },
	{ name = "Fox", url = "https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/Fn-stealanegg.lua" },
	{ name = "Virex", url = "https://cdn.luaprotect.dev/u/8660b0/AvrC3cs5mZ38jbnD" },
	{ name = "Decode", url = "https://raw.githubusercontent.com/ItzYumi/Decode/refs/heads/main/DE%3ACODE.lua" },
	{ name = "Lennon Hub V3", url = "https://raw.githubusercontent.com/lennonxscripts/lennonhubv3/refs/heads/main/stealanegg.lua" },
	{ name = "Yokudo Hub", url = "https://raw.githubusercontent.com/betdoyvaka/stealanegg/main/Loader.lua" },
	{ name = "Virex V2", url = "https://gist.githubusercontent.com/virexx55/836653079c73281295d6bfb5c10be5d9/raw/128b0220c9a36354b5c6504c3669f328e5354805/virex.lua" },
	-- only NEW kept in Main Keyless
	{ name = "NEW · Clout Hub", url = "https://raw.githubusercontent.com/ClouthubOnTop/Loader/main/main.lua" },
}

-- KEY REQUIRED (main)
local scriptsDataKey = {
	{ name = "FYY Hub", url = "https://FyyCommunity.my.id" },
	{ name = "Zeroin Hub", url = "https://zeroinhub.com/api/script" },
	{ name = "Bigfoot Bf", url = "https://raw.githubusercontent.com/hanniii1/Loader/refs/heads/main/BFLoader.lua" },
	{ name = "Clover Hub", url = "https://cloverhub.app/clover.lua" },
	{ name = "Titanic Hub", url = "https://raw.githubusercontent.com/TITANIC-HUB/StealAnEgg/main/Loader.lua" },
	{ name = "Limbo Hub", url = "https://limbohub.my.id/loader.lua" },
	{ name = "Kira Hub", url = "https://raw.githubusercontent.com/shebetterlol889/shh/refs/heads/main/shh" },
	{ name = "Equinox Hub", url = "https://api.jnkie.com/api/v1/luascripts/public/338ceeba573ee21d1ce80a020b7923d8bde36038de4511162b01f325b16b9c3f/download" },
	{ name = "Ajjan Hub", url = "https://api.luarmor.net/files/v4/loaders/359e97f8618e9008afe5f496184ebb7c.lua" },
	{ name = "Nasi Rendang Hub", url = "https://raw.githubusercontent.com/JualNasiRendang/loader/refs/heads/main/main.lua" },
	{ name = "Axon Hub", url = "https://api.luarmor.net/files/v3/loaders/97c3f6db55a2cf72141537a85458e5a7.lua" },
	{ name = "Speed Hub X", url = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua" },
	{ name = "Neptune Hub", url = "https://api.luarmor.net/files/v4/loaders/ed76667e766b5afc5bbfe2761bed56b7.lua" },
}

-- BONUS NO KEY
local bonusKeyless = {
	{ name = "Rene Baterbonia", url = "https://raw.githubusercontent.com/sabscrip-arch/srver/refs/heads/main/Stealanegg" },
	{ name = "Chocola Spawner", url = "https://raw.githubusercontent.com/chocolascript-glitch/Chocola-Pet-Spawner-steal-an-egg/refs/heads/main/script.lua" },
	{ name = "Exploit Hub", url = "https://raw.githubusercontent.com/Main-Scripts-Ready-V9/Exploiter-Loader/refs/heads/main/New.lua" },
	{ name = "Private Server", url = "https://raw.githubusercontent.com/raw-roblox/PrivateServerBypass/refs/heads/main/lua" },
	{ name = "Source Hub V1", url = "https://pastefy.app/Lk0vDMmN/raw" },
	{ name = "Source Hub V2", url = "https://api.obscuravm.com/scripts/7924424523909516877" },
	{ name = "Source Hub V3", url = "https://api.obscuravm.com/scripts/2007463552086815334" },
	{ name = "Shader", url = "https://raw.githubusercontent.com/robloxscripts2026/simple-shader/refs/heads/main/lua" },
}

-- BONUS KEY
local bonusKey = {
	{ name = "Infinite Robux", url = "https://pastefy.app/CkaV7ET8/raw" },
	{ name = "All Games Script", url = "https://raw.githubusercontent.com/leenZzZzZ/ScriptHUB/refs/heads/main/Script%20Hub" },
	{ name = "Flowauth", url = "https://flowauth.net/v1/loaders/6824c37a4078d7d311677732e231edaa.lua" },
}


-- ===== Hub preferences (Favorites / Settings) =====
local favorites = {} -- [scriptName] = true
local FAVORITES_FILE = "VyreHub_Favorites.json"

-- Keep favorites for the current session and, when file APIs are available,
-- restore them on the next launch. File access is optional.
local function loadFavorites()
    if type(isfile) ~= "function" or type(readfile) ~= "function" then
        return
    end

    pcall(function()
        if not isfile(FAVORITES_FILE) then return end

        local HttpService = game:GetService("HttpService")
        local decoded = HttpService:JSONDecode(readfile(FAVORITES_FILE))

        if type(decoded) ~= "table" then return end

        for name, enabled in pairs(decoded) do
            if enabled == true and type(name) == "string" then
                favorites[name] = true
            end
        end
    end)
end

local function saveFavorites()
    if type(writefile) ~= "function" then
        return
    end

    pcall(function()
        local HttpService = game:GetService("HttpService")
        writefile(FAVORITES_FILE, HttpService:JSONEncode(favorites))
    end)
end

local settingsState = {
	animations = true,
	sound = false,
	defaultTab = "Scripts",
	motionBackground = "inferno", -- "off" or a motion background id (see buildMotionBackground)
}
local SETTINGS_FILE = "VyreHub_Settings.json"
local VALID_DEFAULT_TABS = {
	Scripts = true, Favorites = true, Tools = true, Config = true,
	Settings = true, Information = true, Owner = true,
}

local function loadSettings()
	if type(isfile) ~= "function" or type(readfile) ~= "function" then return end
	pcall(function()
		if not isfile(SETTINGS_FILE) then return end
		local HttpService = game:GetService("HttpService")
		local decoded = HttpService:JSONDecode(readfile(SETTINGS_FILE))
		if type(decoded) ~= "table" then return end
		if type(decoded.animations) == "boolean" then settingsState.animations = decoded.animations end
		if type(decoded.sound) == "boolean" then settingsState.sound = decoded.sound end
		if type(decoded.defaultTab) == "string" and VALID_DEFAULT_TABS[decoded.defaultTab] then
			settingsState.defaultTab = decoded.defaultTab
		end
		if type(decoded.motionBackground) == "string" then
			settingsState.motionBackground = decoded.motionBackground -- validated in buildMotionBackground
		end
	end)
end

local function saveSettings()
	if type(writefile) ~= "function" then return end
	pcall(function()
		local HttpService = game:GetService("HttpService")
		writefile(SETTINGS_FILE, HttpService:JSONEncode({
			animations = settingsState.animations,
			sound = settingsState.sound,
			defaultTab = settingsState.defaultTab,
			motionBackground = settingsState.motionBackground,
		}))
	end)
end

loadSettings()
local allScriptIndex = {}
local function indexScripts(list)
	for _, d in ipairs(list) do
		if d and d.name then allScriptIndex[d.name] = d end
	end
end
indexScripts(scriptsData)
indexScripts(scriptsDataKey)
indexScripts(bonusKeyless)
indexScripts(bonusKey)

loadFavorites()

-- Remove favorites for scripts that no longer exist in the current catalog.
for name in pairs(favorites) do
    if not allScriptIndex[name] then
        favorites[name] = nil
    end
end
saveFavorites()

local function playClick()
	if not settingsState.sound then return end
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://6895079853"
		s.Volume = 0.35
		s.Parent = workspace
		s:Play()
		task.delay(1.2, function() pcall(function() s:Destroy() end) end)
	end)
end

local themes = {
	{ name = "Mono", color = Color3.fromRGB(240, 240, 250), alt = Color3.fromRGB(105, 110, 128) },
	{ name = "Gold Storm", color = Color3.fromRGB(255, 195, 35), alt = Color3.fromRGB(40, 115, 255) },
	{ name = "Cyber Blue", color = Color3.fromRGB(40, 150, 255), alt = Color3.fromRGB(35, 65, 255) },
	{ name = "Solar Flare", color = Color3.fromRGB(255, 140, 40), alt = Color3.fromRGB(235, 35, 60) },
	{ name = "Neon Mint", color = Color3.fromRGB(45, 240, 140), alt = Color3.fromRGB(40, 110, 255) },
	{ name = "Royal Violet", color = Color3.fromRGB(165, 95, 255), alt = Color3.fromRGB(65, 75, 240) },
	{ name = "Crimson Night", color = Color3.fromRGB(255, 55, 75), alt = Color3.fromRGB(255, 140, 30) },
	{ name = "Ice", color = Color3.fromRGB(165, 215, 255), alt = Color3.fromRGB(55, 115, 255) },
	{ name = "Sakura", color = Color3.fromRGB(255, 105, 185), alt = Color3.fromRGB(140, 70, 240) },
	{ name = "Aurora", color = Color3.fromRGB(60, 255, 200), alt = Color3.fromRGB(150, 80, 255) },
}
local currentTheme = themes[6].color -- Royal Violet (default)
local allThemeStrokes = {} -- every UIStroke that follows theme
local allThemeScrollbars = {}
local allThemeButtons = {} -- accent buttons that follow the selected theme
local settingsThemeLabels = {} -- Settings page text that follows theme
local settingsThemeToggles = {} -- ON/OFF + default-tab chips in Settings

local rainbowStrokes = {} -- the four script-section outlines use a rainbow animation
local rainbowButtons = {} -- Execute buttons use the same animated rainbow effect

local function registerRainbowStroke(stroke)
	if stroke then
		table.insert(rainbowStrokes, stroke)
	end
	return stroke
end

local function registerRainbowButton(button)
	if button then
		table.insert(rainbowButtons, button)
	end
	return button
end

local function themeTextColor(color)
	local luminance = (0.2126 * color.R) + (0.7152 * color.G) + (0.0722 * color.B)
	return luminance > 0.72 and Color3.fromRGB(20, 20, 24) or Color3.fromRGB(255, 255, 255)
end

local function registerThemeButton(button)
	if button then
		table.insert(allThemeButtons, button)
		button.BackgroundColor3 = currentTheme
	end
	return button
end

local function registerStroke(stroke)
	if stroke then
		table.insert(allThemeStrokes, stroke)
		stroke.Color = currentTheme
	end
	return stroke
end

-- Motion-background hooks. One table keeps the feature to a single top-level local (the main chunk is close
-- to the 200-local limit). The engine itself is buildMotionBackground(), further down.
local motionHooks = {
	glass = {}, -- { frame, base, glass }: panels that turn translucent while a motion background plays
	active = false, -- true while a motion background is on screen
	refresh = nil, -- re-checks run / freeze state (set by the engine)
	onStateChanged = nil, -- Transparent BG or theme changed (set by the engine)
}

function motionHooks.registerGlass(frame, glassTransparency)
	if frame then
		table.insert(motionHooks.glass, {
			frame = frame,
			base = frame.BackgroundTransparency, -- value restored when the motion background is off
			glass = glassTransparency,
		})
		if motionHooks.active then
			frame.BackgroundTransparency = glassTransparency -- created while a motion background is already playing
		end
	end
	return frame
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 1000
screenGui.Parent = parentContainer

-- ===== Loading overlay (before UI) =====
local loadOverlay = Instance.new("Frame")
loadOverlay.Size = UDim2.fromScale(1, 1)
loadOverlay.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
loadOverlay.BorderSizePixel = 0
loadOverlay.ZIndex = 100
loadOverlay.Parent = screenGui

local loadTitle = Instance.new("TextLabel")
loadTitle.AnchorPoint = Vector2.new(0.5, 0.5)
loadTitle.Position = UDim2.new(0.5, 0, 0.42, 0)
loadTitle.Size = UDim2.new(0, 280, 0, 36)
loadTitle.BackgroundTransparency = 1
loadTitle.Font = Enum.Font.GothamBold
loadTitle.Text = "Vyre Hub"
loadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadTitle.TextSize = 28
loadTitle.ZIndex = 101
loadTitle.Parent = loadOverlay

local loadBarBg = Instance.new("Frame")
loadBarBg.AnchorPoint = Vector2.new(0.5, 0)
loadBarBg.Position = UDim2.new(0.5, 0, 0.5, 10)
loadBarBg.Size = UDim2.new(0, 220, 0, 8)
loadBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
loadBarBg.BorderSizePixel = 0
loadBarBg.ZIndex = 101
loadBarBg.Parent = loadOverlay

do
	local loadBarCorner = Instance.new("UICorner")
	loadBarCorner.CornerRadius = UDim.new(1, 0)
	loadBarCorner.Parent = loadBarBg
end

local loadBarFill = Instance.new("Frame")
loadBarFill.Size = UDim2.new(0, 0, 1, 0)
loadBarFill.BackgroundColor3 = Color3.fromRGB(180, 70, 255)
loadBarFill.BorderSizePixel = 0
loadBarFill.ZIndex = 102
loadBarFill.Parent = loadBarBg

do
	local loadFillCorner = Instance.new("UICorner")
	loadFillCorner.CornerRadius = UDim.new(1, 0)
	loadFillCorner.Parent = loadBarFill
end

local loadPct = Instance.new("TextLabel")
loadPct.AnchorPoint = Vector2.new(0.5, 0)
loadPct.Position = UDim2.new(0.5, 0, 0.5, 28)
loadPct.Size = UDim2.new(0, 100, 0, 20)
loadPct.BackgroundTransparency = 1
loadPct.Font = Enum.Font.GothamBold
loadPct.Text = "0%"
loadPct.TextColor3 = Color3.fromRGB(180, 180, 200)
loadPct.TextSize = 13
loadPct.ZIndex = 101
loadPct.Parent = loadOverlay

-- Scale applies to main window + compact bar only (avoids layout stretch)
local uiScale = Instance.new("UIScale")
uiScale.Scale = 1

-- Main window
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromOffset(580, 380)
-- Top-left anchor: collapsing only reduces height — title bar stays put (like Sources Hub)
mainFrame.AnchorPoint = Vector2.new(0, 0)
mainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Parent = screenGui
uiScale.Parent = mainFrame
mainFrame.Visible = false

do
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 12)
	mainCorner.Parent = mainFrame
end

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = currentTheme
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.35
mainStroke.Parent = mainFrame
registerStroke(mainStroke)

-- Top bar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

do
	local topBarCorner = Instance.new("UICorner")
	topBarCorner.CornerRadius = UDim.new(0, 12)
	topBarCorner.Parent = topBar
end

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 12)
topBarFix.Position = UDim2.new(0, 0, 1, -12)
topBarFix.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
topBarFix.BorderSizePixel = 0
topBarFix.Parent = topBar

local logoDot = Instance.new("Frame")
logoDot.Size = UDim2.fromOffset(10, 10)
logoDot.Position = UDim2.new(0, 14, 0.5, -5)
logoDot.BackgroundColor3 = currentTheme
logoDot.BorderSizePixel = 0
logoDot.Parent = topBar

do
	local logoDotCorner = Instance.new("UICorner")
	logoDotCorner.CornerRadius = UDim.new(1, 0)
	logoDotCorner.Parent = logoDot
end

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -300, 1, 0)
titleLabel.Position = UDim2.new(0, 32, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Vyre Hub  <font color=\"#888888\">|</font>  <font color=\"#CCCCCC\">Multiverse Script Sae</font>"
titleLabel.RichText = true
titleLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- Live performance readout in the title bar (FPS + network ping).
local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "LivePerformanceStats"
statsLabel.Size = UDim2.new(0, 110, 0, 28)
statsLabel.Position = UDim2.new(1, -184, 0, 6)
statsLabel.BackgroundTransparency = 1
statsLabel.Font = Enum.Font.GothamSemibold
statsLabel.Text = "FPS: -- | Ping: --"
statsLabel.TextColor3 = Color3.fromRGB(190, 190, 205)
statsLabel.TextSize = 12
statsLabel.TextXAlignment = Enum.TextXAlignment.Center
statsLabel.TextYAlignment = Enum.TextYAlignment.Center
statsLabel.TextTruncate = Enum.TextTruncate.AtEnd
statsLabel.Parent = topBar

local fpsFrames = 0
local fpsElapsed = 0
local displayedFPS = 0
local displayedPing = "--"
local statsUpdateElapsed = 0
local statsConnection = RunService.RenderStepped:Connect(function(dt)
    fpsFrames = fpsFrames + 1
    fpsElapsed = fpsElapsed + dt
    statsUpdateElapsed = statsUpdateElapsed + dt

    if fpsElapsed >= 0.5 then
        displayedFPS = math.floor((fpsFrames / fpsElapsed) + 0.5)
        fpsFrames = 0
        fpsElapsed = 0
    end

    if statsUpdateElapsed >= 1 then
        statsUpdateElapsed = 0
        local pingText = "--"
        pcall(function()
            local stats = game:GetService("Stats")
            local network = stats:FindFirstChild("Network")
            local serverStats = network and network:FindFirstChild("ServerStatsItem")
            local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")
            if dataPing then
                local value = dataPing:GetValueString()
                local number = tonumber(string.match(value, "[%d%.]+"))
                if number then
                    pingText = tostring(math.floor(number + 0.5)) .. " ms"
                else
                    pingText = value
                end
            end
        end)
        displayedPing = pingText
        if statsLabel and statsLabel.Parent then
            statsLabel.Text = string.format("FPS: %d | Ping: %s", displayedFPS, displayedPing)

            -- Performance colors: green = healthy, yellow = moderate, red = poor.
            local fpsColor
            if displayedFPS >= 55 then
                fpsColor = Color3.fromRGB(80, 235, 125)
            elseif displayedFPS >= 30 then
                fpsColor = Color3.fromRGB(255, 205, 70)
            else
                fpsColor = Color3.fromRGB(255, 85, 85)
            end

            local pingNumber = tonumber(string.match(displayedPing, "[%d%.]+"))
            local pingColor = Color3.fromRGB(190, 190, 205)
            if pingNumber then
                if pingNumber < 100 then
                    pingColor = Color3.fromRGB(80, 235, 125)
                elseif pingNumber < 200 then
                    pingColor = Color3.fromRGB(255, 205, 70)
                else
                    pingColor = Color3.fromRGB(255, 85, 85)
                end
            end

            -- RichText lets FPS and ping show independent status colors.
            local fpsHex = string.format("#%02X%02X%02X", math.floor(fpsColor.R * 255), math.floor(fpsColor.G * 255), math.floor(fpsColor.B * 255))
            local pingHex = string.format("#%02X%02X%02X", math.floor(pingColor.R * 255), math.floor(pingColor.G * 255), math.floor(pingColor.B * 255))
            statsLabel.RichText = true
            statsLabel.Text = string.format('<font color="%s">FPS: %d</font>  <font color="#888888">|</font>  <font color="%s">Ping: %s</font>', fpsHex, displayedFPS, pingHex, displayedPing)
        else
            if statsConnection then statsConnection:Disconnect() end
        end
    end
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.TextSize = 12
closeBtn.Parent = topBar

do
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn
end

local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.fromOffset(28, 28)
collapseBtn.Position = UDim2.new(1, -66, 0, 6)
collapseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.Text = "↓"
collapseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
collapseBtn.TextSize = 14
collapseBtn.Parent = topBar
local minBtn = collapseBtn -- compat alias if referenced

do
	local minCorner = Instance.new("UICorner")
	minCorner.CornerRadius = UDim.new(0, 6)
	minCorner.Parent = minBtn
end

-- Content
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, 0, 1, -40)
contentArea.Position = UDim2.new(0, 0, 0, 40)
-- avatar sits on mainFrame bottom-left (not inside config)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

local tabRail = Instance.new("Frame")
tabRail.Size = UDim2.new(0, 120, 1, 0)
tabRail.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
tabRail.BorderSizePixel = 0
tabRail.Parent = contentArea

-- Compact multi-tabs (scroll if needed)
local tabScroll = Instance.new("ScrollingFrame")
tabScroll.Size = UDim2.new(1, 0, 1, -44)
tabScroll.Position = UDim2.new(0, 0, 0, 0)
tabScroll.BackgroundTransparency = 1
tabScroll.BorderSizePixel = 0
tabScroll.ScrollBarThickness = 2
tabScroll.ScrollingDirection = Enum.ScrollingDirection.Y
tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabScroll.Parent = tabRail

do
	local tabList = Instance.new("UIListLayout")
	tabList.Padding = UDim.new(0, 6)
	tabList.SortOrder = Enum.SortOrder.LayoutOrder
	tabList.Parent = tabScroll
end

do
	local tabPad = Instance.new("UIPadding")
	tabPad.PaddingTop = UDim.new(0, 10)
	tabPad.PaddingLeft = UDim.new(0, 8)
	tabPad.PaddingRight = UDim.new(0, 8)
	tabPad.Parent = tabScroll
end

local function makeTabBtn(name, order, active)
	local b = Instance.new("TextButton")
	b.Name = "Tab_" .. name
	b.Size = UDim2.new(1, 0, 0, 28)
	b.BackgroundColor3 = active and currentTheme or Color3.fromRGB(30, 30, 38)
	b.Font = active and Enum.Font.GothamBold or Enum.Font.GothamSemibold
	b.Text = name
	b.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 180)
	b.TextSize = 11
	b.LayoutOrder = order
	b.AutoButtonColor = true
	b.Parent = tabScroll
	b:SetAttribute("Active", active == true)

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = b

	-- Selected-tab indicator: vertical bar at the left end of the button. It follows the
	-- selected appearance colour (never fixed gold) and only shows on the active tab.
	local ind = Instance.new("Frame")
	ind.Name = "Indicator"
	ind.AnchorPoint = Vector2.new(0, 0.5)
	ind.Position = UDim2.new(0, -6, 0.5, 0)
	ind.Size = UDim2.fromOffset(3, active and 16 or 0)
	ind.BackgroundColor3 = currentTheme
	ind.BackgroundTransparency = active and 0 or 1
	ind.BorderSizePixel = 0
	ind.Parent = b

	local indCorner = Instance.new("UICorner")
	indCorner.CornerRadius = UDim.new(1, 0)
	indCorner.Parent = ind
	return b
end

local scriptsTabBtn = makeTabBtn("Scripts", 1, true)
local favsTabBtn = makeTabBtn("Favorites", 2, false)
local toolsTabBtn = makeTabBtn("Tools", 3, false)
local configTabBtn = makeTabBtn("Config", 4, false)
local settingsTabBtn = makeTabBtn("Settings", 5, false)
local infoTabBtn = makeTabBtn("Information", 6, false)
local ownerTabBtn = makeTabBtn("Owner", 7, false)

local allTabButtons = { scriptsTabBtn, favsTabBtn, toolsTabBtn, configTabBtn, settingsTabBtn, infoTabBtn, ownerTabBtn }

local pagesContainer = Instance.new("Frame")
pagesContainer.Size = UDim2.new(1, -120, 1, -4)
pagesContainer.Position = UDim2.new(0, 120, 0, 0)
pagesContainer.BackgroundTransparency = 1
pagesContainer.ClipsDescendants = true
pagesContainer.Parent = contentArea

-- Scripts page
local function runScript(data)
	local url = data.url
	if type(url) ~= "string" or url == "" then
		warn("[Vyre Hub] No URL set for: " .. tostring(data.name))
		return false
	end
	-- Stage 1: download + compile (this is what "Successfully Loaded" means)
	local fetched, chunk, compileErr = pcall(function()
		return loadstring(game:HttpGet(url))
	end)
	if not fetched or type(chunk) ~= "function" then
		warn("[Vyre Hub] Failed to load " .. tostring(data.name) .. ": " .. tostring(fetched and compileErr or chunk))
		return false
	end
	-- Stage 2: run in its own thread so scripts that never return can't freeze the hub / loader
	task.spawn(function()
		local ran, err = pcall(chunk)
		if not ran then
			warn("[Vyre Hub] Failed to run " .. tostring(data.name) .. ": " .. tostring(err))
		end
	end)
	return true
end

-- Execute loading HUD: "Executing Script..." + spinner -> green "Execute Done!" -> fade out
local function executeWithLoader(data)
	local old = screenGui:FindFirstChild("VyreExecLoader")
	if old then
		old:Destroy()
	end

	local GREEN = Color3.fromRGB(80, 255, 140)

	local panel = Instance.new("Frame")
	panel.Name = "VyreExecLoader"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.Size = UDim2.fromOffset(270, 64)
	panel.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
	panel.BackgroundTransparency = 1
	panel.BorderSizePixel = 0
	panel.ZIndex = 50
	panel.Parent = screenGui

	local panelScale = Instance.new("UIScale")
	panelScale.Scale = math.clamp(uiScale.Scale, 0.6, 1.1)
	panelScale.Parent = panel

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 12)
	panelCorner.Parent = panel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	panelStroke.Color = currentTheme
	panelStroke.Thickness = 1.5
	panelStroke.Transparency = 1
	panelStroke.Parent = panel

	-- spinner: ring whose stroke gradient is rotated every frame
	local ring = Instance.new("Frame")
	ring.Name = "Spinner"
	ring.AnchorPoint = Vector2.new(0, 0.5)
	ring.Position = UDim2.new(0, 18, 0.5, 0)
	ring.Size = UDim2.fromOffset(24, 24)
	ring.BackgroundTransparency = 1
	ring.BorderSizePixel = 0
	ring.ZIndex = 51
	ring.Parent = panel

	local ringCorner = Instance.new("UICorner")
	ringCorner.CornerRadius = UDim.new(1, 0)
	ringCorner.Parent = ring

	local ringStroke = Instance.new("UIStroke")
	ringStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ringStroke.Color = currentTheme
	ringStroke.Thickness = 3
	ringStroke.Parent = ring

	local ringGradient = Instance.new("UIGradient")
	ringGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.55, 0.1),
		NumberSequenceKeypoint.new(0.8, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
	ringGradient.Parent = ringStroke

	local label = Instance.new("TextLabel")
	label.Name = "Status"
	label.Position = UDim2.new(0, 54, 0, 0)
	label.Size = UDim2.new(1, -66, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = "Executing Script..."
	label.TextColor3 = Color3.fromRGB(240, 240, 245)
	label.TextTransparency = 1
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.ZIndex = 51
	label.Parent = panel

	local animated = settingsState and settingsState.animations
	local function tweenTo(obj, props, duration)
		TweenService:Create(
			obj,
			TweenInfo.new(animated and duration or 0, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			props
		):Play()
	end

	tweenTo(panel, { BackgroundTransparency = 0.04 }, 0.18)
	tweenTo(panelStroke, { Transparency = 0.2 }, 0.18)
	tweenTo(label, { TextTransparency = 0 }, 0.18)

	local spinning = true
	local angle = 0
	local spinConn
	spinConn = RunService.RenderStepped:Connect(function(dt)
		if not panel.Parent then
			spinConn:Disconnect()
			return
		end
		if spinning then
			angle = (angle + dt * 420) % 360
			ringGradient.Rotation = angle
		end
	end)

	task.spawn(function()
		local minWait = 0.8 + math.random() * 0.4 -- 0.8 to 1.2s
		local startedAt = os.clock()
		local ok = runScript(data)
		local remaining = minWait - (os.clock() - startedAt)
		if remaining > 0 then
			task.wait(remaining)
		end
		if not panel.Parent then return end

		spinning = false
		ringGradient.Enabled = false
		if ok then
			ringStroke.Color = GREEN
			label.TextColor3 = GREEN
			label.Text = "Execute Done! Successfully Loaded."
		else
			ringStroke.Color = Color3.fromRGB(255, 95, 95)
			label.TextColor3 = Color3.fromRGB(255, 120, 120)
			label.Text = "Execute Failed. Check console (F9)."
		end

		task.wait(1)
		if not panel.Parent then return end
		tweenTo(panel, { BackgroundTransparency = 1 }, 0.35)
		tweenTo(panelStroke, { Transparency = 1 }, 0.35)
		tweenTo(ringStroke, { Transparency = 1 }, 0.35)
		tweenTo(label, { TextTransparency = 1 }, 0.35)
		task.wait(0.4)
		if panel.Parent then
			panel:Destroy()
		end
	end)
end

local scriptsPage = Instance.new("ScrollingFrame")
scriptsPage.Size = UDim2.new(1, 0, 1, 0)
scriptsPage.BackgroundTransparency = 1
scriptsPage.BorderSizePixel = 0
scriptsPage.ScrollBarThickness = 3
scriptsPage.ScrollBarImageColor3 = currentTheme
scriptsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
scriptsPage.CanvasSize = UDim2.new(0, 0, 0, 0)
scriptsPage.Visible = true
scriptsPage.Parent = pagesContainer

-- Search bar
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -24, 0, 32)
searchBox.Position = UDim2.new(0, 12, 0, 10)
searchBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
searchBox.BorderSizePixel = 0
searchBox.Font = Enum.Font.GothamBold
searchBox.PlaceholderText = "Search scripts..."
searchBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 125)
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(245, 245, 250)
searchBox.TextSize = 13
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = scriptsPage

do
	local searchCorner = Instance.new("UICorner")
	searchCorner.CornerRadius = UDim.new(0, 8)
	searchCorner.Parent = searchBox
end


do
	local searchPad = Instance.new("UIPadding")
	searchPad.PaddingLeft = UDim.new(0, 12)
	searchPad.Parent = searchBox
end

-- Scripts page itself: no scrollbar (ScrollingEnabled off)
scriptsPage.ScrollingEnabled = true
scriptsPage.CanvasSize = UDim2.new(0, 0, 0, 0)
scriptsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Dual columns container (fills remaining height under search)
local dual = Instance.new("Frame")
dual.Name = "DualColumns"
-- Spacing system for this page: one 12px gutter (search bar, columns, BONUS row) and one vertical rhythm:
-- search 10-42 | 8px | columns 50-250 | 12px | BONUS title 262-280 | 4px | BONUS columns 284-444 | 12px bottom
dual.Size = UDim2.new(1, -24, 0, 200)
dual.Position = UDim2.new(0, 12, 0, 50)
dual.BackgroundTransparency = 1
dual.Parent = scriptsPage

do
	local dualLayout = Instance.new("UIListLayout")
	dualLayout.FillDirection = Enum.FillDirection.Horizontal
	dualLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dualLayout.Padding = UDim.new(0, 12)
	dualLayout.SortOrder = Enum.SortOrder.LayoutOrder
	dualLayout.Parent = dual
end

local function makeSection(title, titleColor, order)
	local col = Instance.new("Frame")
	col.Size = UDim2.new(0.5, -6, 1, 0)
	col.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	col.BorderSizePixel = 0
	col.LayoutOrder = order
	col.Parent = dual
	motionHooks.registerGlass(col, 0.3)

	local colCorner = Instance.new("UICorner")
	colCorner.CornerRadius = UDim.new(0, 10)
	colCorner.Parent = col

	local colStroke = Instance.new("UIStroke")
	colStroke.Color = currentTheme
	colStroke.Transparency = 0.35
	colStroke.Thickness = 1.5
	colStroke.Parent = col
	registerStroke(colStroke)
	registerRainbowStroke(colStroke)

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -16, 0, 22)
	header.Position = UDim2.new(0, 8, 0, 8)
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.GothamBold
	header.Text = title
	header.TextColor3 = titleColor
	header.TextSize = 11
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = col

	-- Own scrollbar per column
	local cardsFrame = Instance.new("ScrollingFrame")
	cardsFrame.Name = "Cards"
	cardsFrame.Size = UDim2.new(1, -12, 1, -36)
	cardsFrame.Position = UDim2.new(0, 6, 0, 32)
	cardsFrame.BackgroundTransparency = 1
	cardsFrame.BorderSizePixel = 0
	cardsFrame.ScrollBarThickness = 3
	cardsFrame.ScrollBarImageColor3 = currentTheme
	cardsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	cardsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	cardsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	cardsFrame.Parent = col

	local cardsPad = Instance.new("UIPadding")
	cardsPad.PaddingBottom = UDim.new(0, 8)
	cardsPad.PaddingRight = UDim.new(0, 4)
	cardsPad.Parent = cardsFrame

	local cardsList = Instance.new("UIListLayout")
	cardsList.SortOrder = Enum.SortOrder.LayoutOrder
	cardsList.Padding = UDim.new(0, 6)
	cardsList.Parent = cardsFrame

	return col, cardsFrame, colStroke
end

local keylessCol, keylessCards, keylessStroke = makeSection("NO KEY REQUIRED", Color3.fromRGB(80, 255, 140), 1)
local keyCol, keyCards, keyStroke = makeSection("KEY REQUIRED", Color3.fromRGB(255, 180, 70), 2)
if keylessCards then table.insert(allThemeScrollbars, keylessCards) end
if keyCards then table.insert(allThemeScrollbars, keyCards) end

local scriptCards = {}
local sectionStrokes = { keylessStroke, keyStroke }

local function createScriptCard(data, parent, order)
	local hasUrl = type(data.url) == "string" and data.url ~= ""

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -4, 0, 56)
	card.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
	card.BorderSizePixel = 0
	card.LayoutOrder = order
	card.Parent = parent

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = currentTheme
	cardStroke.Transparency = 0.55
	cardStroke.Thickness = 1
	cardStroke.Parent = card
	registerStroke(cardStroke)

	local starBtn = Instance.new("TextButton")
	starBtn.Size = UDim2.fromOffset(22, 22)
	starBtn.Position = UDim2.new(0, 4, 0, 2)
	starBtn.BackgroundTransparency = 1
	starBtn.Text = favorites[data.name] and "★" or "☆"
	starBtn.TextColor3 = favorites[data.name] and Color3.fromRGB(255, 200, 60) or Color3.fromRGB(120, 120, 130)
	starBtn.TextSize = 14
	starBtn.Font = Enum.Font.GothamBold
	starBtn.ZIndex = 5
	starBtn.Parent = card

	local nameLbl = Instance.new("TextLabel")
	-- Keep the script name above the Execute button instead of vertically centering it.
	nameLbl.Size = UDim2.new(1, -72, 0, 22)
	nameLbl.Position = UDim2.new(0, 28, 0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.Text = data.name
	nameLbl.TextColor3 = Color3.fromRGB(235, 235, 240)
	nameLbl.TextSize = 12
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nameLbl.Parent = card

	local statusLbl = Instance.new("TextLabel")
	statusLbl.Size = UDim2.new(0, 58, 0, 12)
	statusLbl.Position = UDim2.new(1, -66, 0, 4)
	statusLbl.BackgroundTransparency = 1
	statusLbl.Font = Enum.Font.GothamBold
	statusLbl.Text = hasUrl and "WORKING" or "EMPTY"
	statusLbl.TextColor3 = hasUrl and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(120, 120, 130)
	statusLbl.TextSize = 9
	statusLbl.TextXAlignment = Enum.TextXAlignment.Right
	statusLbl.Parent = card

	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(7, 7)
	dot.Position = UDim2.new(1, -16, 0, 18)
	dot.BackgroundColor3 = hasUrl and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(80, 80, 90)
	dot.BorderSizePixel = 0
	dot.Parent = card

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = dot

	local execBtn = Instance.new("TextButton")
	execBtn.Size = UDim2.new(1, -16, 0, 20)
	execBtn.Position = UDim2.new(0, 8, 1, -24)
	execBtn.BackgroundColor3 = hasUrl and currentTheme or Color3.fromRGB(50, 50, 58)
	execBtn.Font = Enum.Font.GothamBold
	execBtn.Text = "Execute"
	execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	execBtn.TextSize = 11
	execBtn.ZIndex = 4
	execBtn.AutoButtonColor = true
	execBtn.Parent = card
	if hasUrl then
		registerThemeButton(execBtn)
		registerRainbowButton(execBtn)
	end

	local execCorner = Instance.new("UICorner")
	execCorner.CornerRadius = UDim.new(0, 6)
	execCorner.Parent = execBtn

	execBtn.MouseButton1Click:Connect(function()
		executeWithLoader(data)
	end)

	starBtn.MouseButton1Click:Connect(function()
		if favorites[data.name] then
			favorites[data.name] = nil
			starBtn.Text = "☆"
			starBtn.TextColor3 = Color3.fromRGB(120, 120, 130)
		else
			favorites[data.name] = true
			starBtn.Text = "★"
			starBtn.TextColor3 = Color3.fromRGB(255, 200, 60)
		end
		saveFavorites()
		playClick()
		if refreshFavoritesPage then refreshFavoritesPage() end
	end)

	local entry = {
		card = card,
		stroke = cardStroke,
		status = statusLbl,
		dot = dot,
		name = data.name,
		nameLower = string.lower(data.name),
		star = starBtn,
		data = data,
	}
	if not parent or parent.Name ~= "FavsList" then
		table.insert(scriptCards, entry)
	end
	return entry
end

for i, data in ipairs(scriptsData) do
	createScriptCard(data, keylessCards, i)
end

for i, data in ipairs(scriptsDataKey) do
	createScriptCard(data, keyCards, i)
end

-- BONUS section (second dual columns)
local bonusTitle = Instance.new("TextLabel")
bonusTitle.Size = UDim2.new(1, -24, 0, 18)
bonusTitle.Position = UDim2.new(0, 12, 0, 262)
bonusTitle.BackgroundTransparency = 1
bonusTitle.Font = Enum.Font.GothamBold
bonusTitle.Text = "BONUS"
bonusTitle.TextColor3 = Color3.fromRGB(255, 200, 80)
bonusTitle.TextSize = 12
bonusTitle.TextXAlignment = Enum.TextXAlignment.Left
bonusTitle.Parent = scriptsPage

local dualBonus = Instance.new("Frame")
dualBonus.Name = "DualBonus"
dualBonus.Size = UDim2.new(1, -24, 0, 160)
dualBonus.Position = UDim2.new(0, 12, 0, 284)
dualBonus.BackgroundTransparency = 1
dualBonus.Parent = scriptsPage

-- Bottom breathing room: the canvas is auto-sized from its children, so a 1px spacer 12px under the BONUS
-- row stops the columns from ending flush with the window edge when scrolled all the way down.
do
	local scriptsBottomPad = Instance.new("Frame")
	scriptsBottomPad.Name = "BottomPadding"
	scriptsBottomPad.Size = UDim2.new(1, 0, 0, 1)
	scriptsBottomPad.Position = UDim2.new(0, 0, 0, 284 + 160 + 12)
	scriptsBottomPad.BackgroundTransparency = 1
	scriptsBottomPad.BorderSizePixel = 0
	scriptsBottomPad.Parent = scriptsPage
end

do
	local dualBonusLayout = Instance.new("UIListLayout")
	dualBonusLayout.FillDirection = Enum.FillDirection.Horizontal
	dualBonusLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dualBonusLayout.Padding = UDim.new(0, 12)
	dualBonusLayout.Parent = dualBonus
end

-- temporarily parent makeSection to dualBonus
local function makeBonusSection(title, titleColor, order)
	local col = Instance.new("Frame")
	col.Size = UDim2.new(0.5, -6, 1, 0)
	col.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	col.BorderSizePixel = 0
	col.LayoutOrder = order
	col.Parent = dualBonus
	motionHooks.registerGlass(col, 0.3)

	local colCorner = Instance.new("UICorner")
	colCorner.CornerRadius = UDim.new(0, 10)
	colCorner.Parent = col

	local colStroke = Instance.new("UIStroke")
	colStroke.Color = currentTheme
	colStroke.Transparency = 0.35
	colStroke.Thickness = 1.5
	colStroke.Parent = col
	registerStroke(colStroke)
	registerRainbowStroke(colStroke)

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -16, 0, 22)
	header.Position = UDim2.new(0, 8, 0, 8)
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.GothamBold
	header.Text = title
	header.TextColor3 = titleColor
	header.TextSize = 11
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = col

	local cardsFrame = Instance.new("ScrollingFrame")
	cardsFrame.Name = "Cards"
	cardsFrame.Size = UDim2.new(1, -12, 1, -36)
	cardsFrame.Position = UDim2.new(0, 6, 0, 32)
	cardsFrame.BackgroundTransparency = 1
	cardsFrame.BorderSizePixel = 0
	cardsFrame.ScrollBarThickness = 3
	cardsFrame.ScrollBarImageColor3 = currentTheme
	cardsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	cardsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	cardsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	cardsFrame.Parent = col
	table.insert(allThemeScrollbars, cardsFrame)

	local cardsPad = Instance.new("UIPadding")
	cardsPad.PaddingBottom = UDim.new(0, 8)
	cardsPad.PaddingRight = UDim.new(0, 4)
	cardsPad.Parent = cardsFrame

	local cardsList = Instance.new("UIListLayout")
	cardsList.SortOrder = Enum.SortOrder.LayoutOrder
	cardsList.Padding = UDim.new(0, 6)
	cardsList.Parent = cardsFrame

	return col, cardsFrame, colStroke
end

local bonusKeylessCol, bonusKeylessCards = makeBonusSection("NO KEY REQUIRED", Color3.fromRGB(80, 255, 140), 1)
local bonusKeyCol, bonusKeyCards = makeBonusSection("KEY REQUIRED", Color3.fromRGB(255, 180, 70), 2)

for i, data in ipairs(bonusKeyless) do
	createScriptCard(data, bonusKeylessCards, i)
end
for i, data in ipairs(bonusKey) do
	createScriptCard(data, bonusKeyCards, i)
end

-- Search filter
local function applySearch()
	local q = string.lower(searchBox.Text or "")
	for _, item in ipairs(scriptCards) do
		if q == "" or string.find(item.nameLower, q, 1, true) then
			item.card.Visible = true
		else
			item.card.Visible = false
		end
	end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

-- hide old keyPage if referenced later
local keyPage = Instance.new("Frame")
keyPage.Visible = false
keyPage.Parent = pagesContainer

-- Owner page
local ownerPage = Instance.new("Frame")
ownerPage.Size = UDim2.new(1, 0, 1, 0)
ownerPage.BackgroundTransparency = 1
ownerPage.Visible = false
ownerPage.Parent = pagesContainer

local ownerInfo = Instance.new("TextLabel")
ownerInfo.Size = UDim2.new(1, -24, 0, 80)
ownerInfo.Position = UDim2.new(0, 12, 0, 16)
ownerInfo.BackgroundTransparency = 1
ownerInfo.Font = Enum.Font.GothamBold
ownerInfo.Text = "Owner\nVyre Hub | Multiverse Script Sae\nContact / credits soon"
ownerInfo.TextColor3 = Color3.fromRGB(200, 200, 210)
ownerInfo.TextSize = 13
ownerInfo.TextXAlignment = Enum.TextXAlignment.Left
ownerInfo.TextYAlignment = Enum.TextYAlignment.Top
ownerInfo.Parent = ownerPage

-- Config page

-- Favorites page
local favsPage = Instance.new("ScrollingFrame")
favsPage.Name = "FavoritesPage"
favsPage.Size = UDim2.new(1, 0, 1, 0)
favsPage.BackgroundTransparency = 1
favsPage.BorderSizePixel = 0
favsPage.ScrollBarThickness = 3
favsPage.ScrollBarImageColor3 = currentTheme
favsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
favsPage.CanvasSize = UDim2.new(0, 0, 0, 0)
favsPage.Visible = false
favsPage.Parent = pagesContainer

local favsTitle = Instance.new("TextLabel")
favsTitle.Size = UDim2.new(1, -20, 0, 28)
favsTitle.Position = UDim2.new(0, 12, 0, 8)
favsTitle.BackgroundTransparency = 1
favsTitle.Font = Enum.Font.GothamBold
favsTitle.Text = "★  Favorites"
favsTitle.TextColor3 = Color3.fromRGB(255, 210, 80)
favsTitle.TextSize = 14
favsTitle.TextXAlignment = Enum.TextXAlignment.Left
favsTitle.Parent = favsPage

local favsHint = Instance.new("TextLabel")
favsHint.Name = "FavsHint"
favsHint.Size = UDim2.new(1, -24, 0, 40)
favsHint.Position = UDim2.new(0, 12, 0, 40)
favsHint.BackgroundTransparency = 1
favsHint.Font = Enum.Font.Gotham
favsHint.Text = "Tap ☆ on any script to pin it here."
favsHint.TextColor3 = Color3.fromRGB(175, 175, 185)
favsHint.TextSize = 12
favsHint.TextXAlignment = Enum.TextXAlignment.Left
favsHint.Parent = favsPage

local favsList = Instance.new("Frame")
favsList.Name = "FavsList"
favsList.Size = UDim2.new(1, -20, 0, 0)
favsList.Position = UDim2.new(0, 10, 0, 80)
favsList.BackgroundTransparency = 1
favsList.AutomaticSize = Enum.AutomaticSize.Y
favsList.Parent = favsPage
do
	local favsLayout = Instance.new("UIListLayout")
	favsLayout.Padding = UDim.new(0, 8)
	favsLayout.Parent = favsList
end

function refreshFavoritesPage()
	for _, ch in ipairs(favsList:GetChildren()) do
		if not ch:IsA("UIListLayout") then ch:Destroy() end
	end
	local count = 0
	for name, on in pairs(favorites) do
		if on and allScriptIndex[name] then
			count += 1
			createScriptCard(allScriptIndex[name], favsList, count)
		end
	end
	favsHint.Text = count == 0 and "Tap ☆ on any script to pin it here." or (tostring(count) .. " favorite(s)")
end

-- Tools page
local toolsPage = Instance.new("ScrollingFrame")
toolsPage.Name = "ToolsPage"
toolsPage.Size = UDim2.new(1, 0, 1, 0)
toolsPage.BackgroundTransparency = 1
toolsPage.BorderSizePixel = 0
toolsPage.ScrollBarThickness = 3
toolsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
toolsPage.Visible = false
toolsPage.ScrollBarImageColor3 = currentTheme
toolsPage.Parent = pagesContainer

local toolsTitle = Instance.new("TextLabel")
toolsTitle.Size = UDim2.new(1, -20, 0, 28)
toolsTitle.Position = UDim2.new(0, 12, 0, 8)
toolsTitle.BackgroundTransparency = 1
toolsTitle.Font = Enum.Font.GothamBold
toolsTitle.Text = "Tools"
toolsTitle.TextColor3 = Color3.fromRGB(235, 235, 240)
toolsTitle.TextSize = 14
toolsTitle.TextXAlignment = Enum.TextXAlignment.Left
toolsTitle.TextStrokeTransparency = 1
toolsTitle.Parent = toolsPage

-- Tools layout variables: change these to restyle the whole stack of tool buttons
local TOOLS_LAYOUT = { top = 44, height = 40, gap = 10, count = 0 }

local function makeToolButton(label, callback)
	local y = TOOLS_LAYOUT.top + TOOLS_LAYOUT.count * (TOOLS_LAYOUT.height + TOOLS_LAYOUT.gap)
	TOOLS_LAYOUT.count = TOOLS_LAYOUT.count + 1

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -24, 0, TOOLS_LAYOUT.height)
	btn.Position = UDim2.new(0, 12, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
	btn.Font = Enum.Font.GothamBold
	btn.Text = label
	btn.TextColor3 = Color3.fromRGB(240, 240, 245)
	btn.TextSize = 13
	btn.TextStrokeTransparency = 1 -- Keep tool labels crisp, without a text outline.
	btn.Parent = toolsPage

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	local st = Instance.new("UIStroke")
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border -- outline the button, never the text
	st.Color = currentTheme
	st.Transparency = 0.5
	st.Parent = btn
	registerStroke(st)

	btn.MouseButton1Click:Connect(function()
		playClick()
		callback()
	end)
	return btn
end

makeToolButton("Rejoin Server", function()
	pcall(function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, player)
	end)
end)

makeToolButton("Private Server Finder", function()
	runScript({ name = "Private Server", url = "https://raw.githubusercontent.com/raw-roblox/PrivateServerBypass/refs/heads/main/lua" })
end)

-- ======================================================================
-- PERFORMANCE BOOST: real-time, reversible, time-sliced low-graphics toggle.
-- Everything lives inside this do-block so it adds no top-level locals.
-- ======================================================================
do
	local function createPerformanceBoost(onStatus)
		local Lighting = game:GetService("Lighting")
		local Workspace = game:GetService("Workspace")

		local SLICE_SECONDS = 0.003 -- max time spent per frame while scanning / restoring
		local CHECK_EVERY = 64      -- instances processed between clock checks
		local RESCAN_SECONDS = 20   -- slow safety re-scan while the boost is ON

		-- ClassName -> how to boost it. Exact class names = one table lookup per instance (no IsA chains).
		local PROPERTY_RULES = {
			Decal = { prop = "Transparency", boosted = 1 },
			Texture = { prop = "Transparency", boosted = 1 },
			ParticleEmitter = { prop = "Enabled", boosted = false },
			Trail = { prop = "Enabled", boosted = false },
			Smoke = { prop = "Enabled", boosted = false },
			Sparkles = { prop = "Enabled", boosted = false },
		}
		local ATMOSPHERE_PROPS = { "Density", "Haze", "Glare" }

		local enabled = false
		local generation = 0 -- bumped on every toggle; running workers stop when it no longer matches theirs
		local connections = {}
		local savedShadows = nil
		-- weak keys: instances the game destroys can be garbage collected while the boost is ON
		local saved = setmetatable({}, { __mode = "k" })
		local savedAtmosphere = setmetatable({}, { __mode = "k" })

		local function setProperty(inst, prop, value)
			inst[prop] = value
		end

		local function setQuality(level)
			pcall(function()
				settings().Rendering.QualityLevel = level
			end)
		end

		local function boostInstance(inst)
			local className = inst.ClassName
			local rule = PROPERTY_RULES[className]
			if rule then
				local current = inst[rule.prop]
				if current ~= rule.boosted then
					saved[inst] = current -- only remember what we actually change
					inst[rule.prop] = rule.boosted
				end
			elseif className == "Atmosphere" then
				if savedAtmosphere[inst] == nil then
					local snapshot = {}
					for _, name in ipairs(ATMOSPHERE_PROPS) do
						snapshot[name] = inst[name]
					end
					savedAtmosphere[inst] = snapshot
				end
				for _, name in ipairs(ATMOSPHERE_PROPS) do
					inst[name] = 0
				end
			end
		end

		-- Scans Workspace + Lighting (Atmosphere lives in Lighting). Time-sliced: yields a frame whenever
		-- the budget is used up, and stops immediately if the toggle changed. Returns false if cancelled.
		local function scanRoots(myGen)
			local sliceStart = os.clock()
			local processed = 0
			for _, root in ipairs({ Workspace, Lighting }) do
				local descendants = root:GetDescendants()
				for index = 1, #descendants do
					pcall(boostInstance, descendants[index])
					processed = processed + 1
					if processed % CHECK_EVERY == 0 and os.clock() - sliceStart > SLICE_SECONDS then
						task.wait()
						if not enabled or generation ~= myGen then
							return false
						end
						sliceStart = os.clock()
					end
				end
			end
			return true
		end

		local function hookRoot(root)
			return root.DescendantAdded:Connect(function(inst)
				if enabled then
					pcall(boostInstance, inst)
				end
			end)
		end

		local function restoreAll(myGen)
			local sliceStart = os.clock()
			local processed = 0

			-- returns false when a newer toggle took over
			local function pace()
				processed = processed + 1
				if processed % CHECK_EVERY == 0 and os.clock() - sliceStart > SLICE_SECONDS then
					task.wait()
					if enabled or generation ~= myGen then
						return false
					end
					sliceStart = os.clock()
				end
				return true
			end

			for inst, value in pairs(saved) do
				saved[inst] = nil
				local rule = PROPERTY_RULES[inst.ClassName]
				if rule and inst.Parent ~= nil then -- skip anything the game already destroyed
					pcall(setProperty, inst, rule.prop, value)
				end
				if not pace() then
					return false
				end
			end

			for inst, snapshot in pairs(savedAtmosphere) do
				savedAtmosphere[inst] = nil
				if inst.Parent ~= nil then
					for _, name in ipairs(ATMOSPHERE_PROPS) do
						pcall(setProperty, inst, name, snapshot[name])
					end
				end
				if not pace() then
					return false
				end
			end
			return true
		end

		local function enable()
			enabled = true
			generation = generation + 1
			local myGen = generation
			onStatus("Optimizing")

			task.spawn(function()
				-- engine-level settings first: instant FPS gain before the (sliced) scan finishes
				if savedShadows == nil then
					savedShadows = Lighting.GlobalShadows
				end
				pcall(setProperty, Lighting, "GlobalShadows", false)
				setQuality(Enum.QualityLevel.Level01)

				-- hook first so nothing added during the scan is missed
				connections = { hookRoot(Workspace), hookRoot(Lighting) }

				local ok, finished = pcall(scanRoots, myGen)
				if not ok then
					warn("[Vyre Hub] Performance Boost scan error: " .. tostring(finished))
				end
				if not enabled or generation ~= myGen then
					return
				end
				onStatus("ON")

				-- slow safety re-scan for anything a game script switched back on
				while enabled and generation == myGen do
					local waited = 0
					while waited < RESCAN_SECONDS and enabled and generation == myGen do
						task.wait(1)
						waited = waited + 1
					end
					if not enabled or generation ~= myGen then
						break
					end
					pcall(scanRoots, myGen)
				end
			end)
		end

		local function disable()
			enabled = false
			generation = generation + 1
			local myGen = generation

			for _, connection in ipairs(connections) do
				connection:Disconnect()
			end
			connections = {}
			onStatus("Restoring")

			-- engine settings go back immediately
			setQuality(Enum.QualityLevel.Automatic)
			if savedShadows ~= nil then
				pcall(setProperty, Lighting, "GlobalShadows", savedShadows)
				savedShadows = nil
			end

			task.spawn(function()
				local ok, finished = pcall(restoreAll, myGen)
				if not ok then
					warn("[Vyre Hub] Performance Boost restore error: " .. tostring(finished))
				end
				if not enabled and generation == myGen then
					onStatus("OFF")
				end
			end)
		end

		return {
			toggle = function()
				if enabled then
					disable()
				else
					enable()
				end
			end,
			isEnabled = function()
				return enabled
			end,
			shutdown = function()
				if enabled then
					disable()
				end
			end,
		}
	end

	local PERF_TEXT = {
		OFF = "Performance Boost: OFF",
		Optimizing = "Performance Boost: Optimizing...",
		ON = "Performance Boost: ON",
		Restoring = "Performance Boost: Restoring...",
	}
	local perfButton

	-- Button label + colours follow the engine state; ON uses the live theme colour.
	local function showPerfState(state)
		if not perfButton then
			return
		end
		local isOn = (state == "ON" or state == "Optimizing")
		perfButton.Text = PERF_TEXT[state] or PERF_TEXT.OFF
		perfButton:SetAttribute("BoostOn", isOn) -- read by applyTheme so theme changes recolour it instantly
		local info = TweenInfo.new((settingsState and settingsState.animations) and 0.15 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(perfButton, info, {
			BackgroundColor3 = isOn and currentTheme or Color3.fromRGB(32, 32, 40),
			TextColor3 = isOn and themeTextColor(currentTheme) or Color3.fromRGB(240, 240, 245),
		}):Play()
		local stroke = perfButton:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Transparency = isOn and 0.1 or 0.5
		end
	end

	local boost = createPerformanceBoost(showPerfState)
	perfButton = makeToolButton(PERF_TEXT.OFF, function()
		boost.toggle()
	end)
	perfButton.Name = "PerformanceBoostBtn"

	-- closing the hub puts the game's graphics back exactly as they were
	screenGui.Destroying:Connect(function()
		boost.shutdown()
	end)
end

-- Settings page
local settingsPage = Instance.new("ScrollingFrame")
settingsPage.Name = "SettingsPage"
settingsPage.Size = UDim2.new(1, 0, 1, 0)
settingsPage.BackgroundTransparency = 1
settingsPage.BorderSizePixel = 0
settingsPage.ScrollBarThickness = 3
settingsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
settingsPage.Visible = false
settingsPage.Parent = pagesContainer

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, -20, 0, 28)
settingsTitle.Position = UDim2.new(0, 12, 0, 8)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.Text = "Settings"
settingsTitle.TextColor3 = Color3.fromRGB(235, 235, 240)
settingsTitle.TextSize = 14
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Parent = settingsPage
table.insert(settingsThemeLabels, settingsTitle)

local function makeToggleRow(label, y, key)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -24, 0, 40)
	row.Position = UDim2.new(0, 12, 0, y)
	row.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	row.BorderSizePixel = 0
	row.Parent = settingsPage
	local rc = Instance.new("UICorner")
	rc.CornerRadius = UDim.new(0, 8)
	rc.Parent = row
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -80, 1, 0)
	lbl.Position = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamSemibold
	lbl.Text = label
	lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row
	table.insert(settingsThemeLabels, lbl)
	local tog = Instance.new("TextButton")
	tog.Size = UDim2.fromOffset(56, 26)
	tog.Position = UDim2.new(1, -66, 0.5, -13)
	tog.BackgroundColor3 = settingsState[key] and currentTheme or Color3.fromRGB(50, 50, 58)
	tog.Font = Enum.Font.GothamBold
	tog.Text = settingsState[key] and "ON" or "OFF"
	tog.TextColor3 = themeTextColor(currentTheme)
	tog.TextSize = 11
	tog.Parent = row
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(0, 6)
	tc.Parent = tog
	table.insert(settingsThemeToggles, { btn = tog, kind = "toggle", key = key })
	tog.MouseButton1Click:Connect(function()
		settingsState[key] = not settingsState[key]
		tog.Text = settingsState[key] and "ON" or "OFF"
		tog.BackgroundColor3 = settingsState[key] and currentTheme or Color3.fromRGB(50, 50, 58)
		tog.TextColor3 = settingsState[key] and themeTextColor(currentTheme) or Color3.fromRGB(200, 200, 210)
		saveSettings()
		playClick()
		if motionHooks.refresh then
			motionHooks.refresh() -- Animations OFF freezes the motion background, ON resumes it
		end
	end)
	return tog
end

makeToggleRow("Animations (theme / collapse)", 44, "animations")
makeToggleRow("Click sound", 94, "sound")

local defLabel = Instance.new("TextLabel")
defLabel.Size = UDim2.new(1, -24, 0, 22)
defLabel.Position = UDim2.new(0, 12, 0, 148)
defLabel.BackgroundTransparency = 1
defLabel.Font = Enum.Font.GothamSemibold
defLabel.Text = "Default tab on open"
defLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
defLabel.TextSize = 12
defLabel.TextXAlignment = Enum.TextXAlignment.Left
defLabel.Parent = settingsPage
table.insert(settingsThemeLabels, defLabel)

local defTabs = { "Scripts", "Favorites", "Tools", "Config", "Settings", "Information", "Owner" }
for i, name in ipairs(defTabs) do
	local b = Instance.new("TextButton")
	local col = (i - 1) % 4
	local row = math.floor((i - 1) / 4)
	b.Size = UDim2.new(0, 90, 0, 28)
	b.Position = UDim2.new(0, 12 + col * 96, 0, 176 + row * 34)
	b.BackgroundColor3 = settingsState.defaultTab == name and currentTheme or Color3.fromRGB(40, 40, 48)
	b.Font = Enum.Font.GothamBold
	b.Text = name
	b.TextColor3 = settingsState.defaultTab == name and themeTextColor(currentTheme) or Color3.fromRGB(200, 200, 210)
	b.TextSize = 10
	b.Parent = settingsPage
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 6)
	bc.Parent = b
	table.insert(settingsThemeToggles, { btn = b, kind = "defaultTab", name = name })
	b.MouseButton1Click:Connect(function()
		settingsState.defaultTab = name
		saveSettings()
		playClick()
		for _, entry in ipairs(settingsThemeToggles) do
			if entry.kind == "defaultTab" and entry.btn then
				local on = entry.name == name
				entry.btn.BackgroundColor3 = on and currentTheme or Color3.fromRGB(40, 40, 48)
				entry.btn.TextColor3 = on and themeTextColor(currentTheme) or Color3.fromRGB(200, 200, 210)
			end
		end
	end)
end

local dragNote = Instance.new("TextLabel")
dragNote.Size = UDim2.new(1, -24, 0, 50)
dragNote.Position = UDim2.new(0, 12, 0, 250)
dragNote.BackgroundTransparency = 1
dragNote.Font = Enum.Font.Gotham
dragNote.Text = "Drag zone: Title bar + left sidebar only\n(Scale / Scripts body are not drag handles)"
dragNote.TextColor3 = Color3.fromRGB(165, 165, 175)
dragNote.TextSize = 11
dragNote.TextXAlignment = Enum.TextXAlignment.Left
dragNote.TextYAlignment = Enum.TextYAlignment.Top
dragNote.Parent = settingsPage
table.insert(settingsThemeLabels, dragNote)

-- Information page: consolidated hub details, changelog, guides, status, and credits.
local infoPage = Instance.new("ScrollingFrame")
infoPage.Name = "InformationPage"
infoPage.Size = UDim2.new(1, 0, 1, 0)
infoPage.BackgroundTransparency = 1
infoPage.BorderSizePixel = 0
infoPage.ScrollBarThickness = 3
infoPage.ScrollBarImageColor3 = currentTheme
infoPage.ScrollingDirection = Enum.ScrollingDirection.Y
infoPage.CanvasSize = UDim2.new(0, 0, 0, 0)
infoPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
infoPage.Visible = false
infoPage.Parent = pagesContainer

do
	local infoPad = Instance.new("UIPadding")
	infoPad.PaddingTop = UDim.new(0, 10)
	infoPad.PaddingBottom = UDim.new(0, 14)
	infoPad.PaddingLeft = UDim.new(0, 12)
	infoPad.PaddingRight = UDim.new(0, 12)
	infoPad.Parent = infoPage
end

do
	local infoLayout = Instance.new("UIListLayout")
	infoLayout.SortOrder = Enum.SortOrder.LayoutOrder
	infoLayout.Padding = UDim.new(0, 10)
	infoLayout.Parent = infoPage
end

local infoHeader = Instance.new("TextLabel")
infoHeader.Name = "InformationTitle"
infoHeader.Size = UDim2.new(1, 0, 0, 26)
infoHeader.BackgroundTransparency = 1
infoHeader.Font = Enum.Font.GothamBold
infoHeader.Text = "Information Center"
infoHeader.TextColor3 = Color3.fromRGB(240, 240, 245)
infoHeader.TextSize = 16
infoHeader.TextXAlignment = Enum.TextXAlignment.Left
infoHeader.LayoutOrder = 1
infoHeader.Parent = infoPage

local function makeInfoSection(name, order, titleText, bodyText)
    local card = Instance.new("Frame")
    card.Name = name
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = infoPage
    motionHooks.registerGlass(card, 0.25)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = currentTheme
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = card
    registerStroke(stroke)
    registerRainbowStroke(stroke) -- rainbow like the Scripts columns (replaces the purple theme outline)

    local title = Instance.new("TextLabel")
    title.Name = "SectionTitle"
    title.Size = UDim2.new(1, -24, 0, 20)
    title.Position = UDim2.new(0, 12, 0, 10)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(235, 235, 242)
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.TextStrokeTransparency = 1
    title.Parent = card

    local body = Instance.new("TextLabel")
    body.Name = "SectionBody"
    body.Size = UDim2.new(1, -24, 0, 0)
    body.Position = UDim2.new(0, 12, 0, 36)
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.BackgroundTransparency = 1
    body.Font = Enum.Font.Gotham
    body.Text = bodyText
    body.TextColor3 = Color3.fromRGB(190, 190, 200)
    body.TextSize = 12
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.TextStrokeTransparency = 1
    body.Parent = card

    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = card
    return card
end

makeInfoSection("HubOverviewCard", 2, "Vyre Hub · Overview",
    "A central place for script entries, favorites, tools, themes, and UI settings. Use the tabs on the left to navigate the hub. External scripts may have their own behavior and requirements.")

makeInfoSection("BuildInfoCard", 3, "Build Information",
    "Project: Vyre Hub\nBuild label: Information Center update\nRelease channel: Not specified\nOwner / developer: Vyre Hub project owner\nNote: The filename alone does not confirm a public release version.")

makeInfoSection("ChangelogCard", 4, "Changelog · Recent Changes",
    "Current UI update\n• Replaced the Changelog tab with Information.\n• Consolidated project details and help sections in one scrollable page.\n• Kept the existing tabs and script catalog layout.\n• Performance Boost remains a Soon placeholder and has no effect.\n\nEarlier recorded changes\n• Favorites and configuration options.\n• Theme selection and adjustable UI scale.\n• Loading overlay, minimize controls, and title-bar FPS / ping readout.\n• Script entries organized into main and bonus lists.")

makeInfoSection("ReleaseNotesCard", 5, "Release Notes",
    "This build focuses on documentation and navigation rather than adding new gameplay functions. Sections below describe the current UI and known limitations; they do not guarantee that every external script is available or compatible.")

makeInfoSection("FeatureDirectoryCard", 6, "Feature Directory",
    "Scripts: browse the configured script catalog.\nFavorites: pin entries for quicker access.\nTools: Rejoin Server, Private Server Finder, and Performance Boost (Soon).\nConfig: adjust available UI layout and theme options.\nSettings: choose supported UI preferences.\nInformation: read changelog, guides, status, and project notes.\nOwner: project information panel.")

makeInfoSection("FeatureStatusCard", 7, "Feature Status",
    "Scripts catalog: entries are listed; each external URL may change or stop working.\nFavorites: available in the UI; saving across sessions depends on executor file APIs.\nRejoin Server: requests a teleport back to the current place.\nPrivate Server Finder: opens the configured external script; behavior depends on that source.\nPerformance Boost: SOON — display-only placeholder with no effect.\nFPS / Ping: shown when the client exposes usable measurements.")

makeInfoSection("UpcomingFeaturesCard", 8, "Upcoming Features",
    "• Performance Boost — Soon placeholder only.\n• More detailed feature descriptions.\n• Expanded troubleshooting notes.\nThese are ideas / planned items, not promises or active functions. Add or revise this list when development plans are confirmed.")

makeInfoSection("ControlsGuideCard", 9, "Controls & Quick Guide",
    "• Use the left-side tabs to switch pages.\n• Use the script cards to select an entry.\n• Use the star control on a script card to manage Favorites.\n• Use the title-bar controls to minimize or close the UI when available.\n• Scroll within a page when its content extends below the visible area.\n• Review a script's source and trustworthiness before running it.")

makeInfoSection("SettingsGuideCard", 10, "Settings Guide",
    "Animations: toggles supported UI animation behavior.\nSound: controls optional UI click sounds.\nDefault tab: selects which page opens when the hub starts.\nScale: changes the interface size within the available range.\nTheme: changes the selected accent color; some rainbow accents may remain animated by design.")

makeInfoSection("PerformanceGuideCard", 11, "Performance Guide",
    "For smoother play, close unused apps, keep the device cool, and lower Roblox graphics settings if needed. FPS is frame rate; higher and steadier values generally feel smoother. Ping is network latency; lower values usually mean faster response. High ping can come from Wi-Fi, routing, or server conditions. The Performance Boost button is not implemented and changes nothing.")

makeInfoSection("KnownIssuesCard", 12, "Known Issues & Limitations",
    "• External script URLs may become unavailable, change behavior, or require keys.\n• Some scripts may conflict with one another or with Roblox updates.\n• FPS and ping measurements can be unavailable or approximate on some clients.\n• Favorite persistence depends on executor file functions.\n• The UI has not been runtime-tested in every Delta / Roblox version.\n• No claim is made that every listed external script is safe or reliable.")

makeInfoSection("FAQCard", 13, "FAQ & Troubleshooting",
    "Why does a script fail? Its URL may be unavailable, the source may require a key, or the game/client may have changed.\n\nWhy does ping show --? The client may not expose a readable Data Ping statistic.\n\nWhy did Favorites reset? Persistent saving requires supported file APIs.\n\nWhat does Soon mean? The feature is only a placeholder and does not run any function.\n\nWhat if the UI errors? Rejoin the experience and test with a clean copy; check the executor output for the exact error before changing code.")

makeInfoSection("CompatibilityCard", 14, "Compatibility",
    "Designed for a Roblox client environment that supports the APIs used by this UI. Executor-specific functions such as loadstring, HttpGet, gethui, and file APIs are not available in every environment. Compatibility with Delta or a particular Roblox update cannot be guaranteed without testing that exact version.")

makeInfoSection("NoticesCard", 15, "Notices & Responsible Use",
    "Review external code before running it and only use scripts where you have permission. Third-party scripts are not authored or verified by this UI. Avoid sharing account credentials, authentication cookies, or private information with script sources. This information panel does not collect or transmit user data by itself.")

makeInfoSection("CreditsCard", 16, "Credits & Contributors",
    "Project: Vyre Hub.\nOwner / developer: project owner.\nThird-party libraries and script sources: credit their original authors when known and follow their published licenses or terms.\nNo individual contributor names are listed here because confirmed names have not been provided.")

makeInfoSection("UICreditsCard", 17, "UI Credits & Acknowledgements",
    "The interface uses Roblox GUI instances, UI layouts, strokes, and tweening APIs. Add specific font, icon, library, or contributor credits here when those dependencies are confirmed. Keep original author credits when reusing code or assets.")

makeInfoSection("AboutCard", 18, "About Vyre Hub",
    "Vyre Hub is a custom Roblox interface project that organizes script entries, favorites, utility buttons, and settings in one UI. The Information page is intended to document the project and make feature availability clearer.")

makeInfoSection("VersionHistoryCard", 19, "Version History",
    "Recent recorded milestones\n• Information tab consolidates documentation and changelog.\n• FPS / ping indicators were added to the title bar in a prior UI iteration.\n• Tools page includes Rejoin Server, Private Server Finder, and a non-functional Performance Boost (Soon) button.\n\nOlder numbered entries are retained in the changelog only where they were recorded in the source file.")

makeInfoSection("SupportCard", 20, "Support & Troubleshooting Checklist",
    "Before reporting an issue, note the Roblox version, executor version, exact error text, which button was pressed, and whether the issue happens after a fresh restart. Never include passwords, cookies, or other account secrets in a bug report.")

local configPage = Instance.new("ScrollingFrame")
configPage.Size = UDim2.new(1, 0, 1, 0)
configPage.BackgroundTransparency = 1
configPage.BorderSizePixel = 0
configPage.ScrollBarThickness = 3
configPage.Visible = false
configPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
configPage.CanvasSize = UDim2.new(0, 0, 0, 0)
configPage.Parent = pagesContainer

do
	local configPad = Instance.new("UIPadding")
	configPad.PaddingTop = UDim.new(0, 16)
	configPad.PaddingLeft = UDim.new(0, 0)
	configPad.PaddingRight = UDim.new(0, 0)
	configPad.PaddingBottom = UDim.new(0, 16)
	configPad.Parent = configPage
end

-- Body: UIPadding on a ScrollingFrame did not shrink child Size scales (cards overflowed on the right),
-- so every config card lives inside this auto-sizing body instead. Frame parents scale correctly.
do
	local body = Instance.new("Frame")
	body.Name = "Body"
	body.Size = UDim2.new(1, -24, 0, 0) -- 12px gutter, same as every other page
	body.Position = UDim2.new(0, 12, 0, 0)
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.Parent = configPage
end

-- Config layout variables: every card size / gap below is derived from these two numbers
local CONFIG_LAYOUT = { cardH = 92, gap = 12 }

-- Structural spacing: Body is a vertical stack, so every gap (and the slide when the Appearance card hides /
-- opens) comes from this one UIListLayout instead of hand-calculated Y offsets.
do
	local body = configPage:FindFirstChild("Body")
	if body then
		local stack = Instance.new("UIListLayout")
		stack.FillDirection = Enum.FillDirection.Vertical
		stack.SortOrder = Enum.SortOrder.LayoutOrder
		stack.Padding = UDim.new(0, CONFIG_LAYOUT.gap)
		stack.Parent = body

		local tail = Instance.new("Frame") -- guaranteed breathing room under the last card
		tail.Name = "BottomSpacer"
		tail.Size = UDim2.new(1, 0, 0, 4)
		tail.BackgroundTransparency = 1
		tail.BorderSizePixel = 0
		tail.LayoutOrder = 99
		tail.Parent = body
	end
end

-- Top row holder: Adjustable + Game Info sit side by side as ONE item of the stack
local topRow = Instance.new("Frame")
topRow.Name = "TopRow"
topRow.Size = UDim2.new(1, 0, 0, CONFIG_LAYOUT.cardH)
topRow.BackgroundTransparency = 1
topRow.BorderSizePixel = 0
topRow.LayoutOrder = 1
topRow.Parent = configPage:FindFirstChild("Body") or configPage

-- Config layout: clean containers for Adjustable, Game Info, Themes
local function makeConfigCard(name, size, position, parent)
	local card = Instance.new("Frame")
	card.Name = name
	card.Size = size
	card.Position = position
	card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	card.BackgroundTransparency = 0.08
	card.BorderSizePixel = 0
	card.ZIndex = 1
	card.Parent = parent or configPage:FindFirstChild("Body") or configPage
	motionHooks.registerGlass(card, 0.3) -- turns translucent while a motion background plays

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = currentTheme
	stroke.Thickness = 1
	stroke.Transparency = 0.45
	stroke.Parent = card
	registerStroke(stroke)

	return card
end

-- Top row: Adjustable controls + organized status text
local adjustableCard = makeConfigCard(
	"AdjustableContainer",
	UDim2.new(0.5, -CONFIG_LAYOUT.gap / 2, 0, CONFIG_LAYOUT.cardH),
	UDim2.new(0, 0, 0, 0),
	topRow
)

local adjustableTitle = Instance.new("TextLabel")
adjustableTitle.Size = UDim2.new(1, -24, 0, 18)
adjustableTitle.Position = UDim2.new(0, 12, 0, 10)
adjustableTitle.BackgroundTransparency = 1
adjustableTitle.Font = Enum.Font.GothamBold
adjustableTitle.Text = "Adjustable"
adjustableTitle.TextColor3 = Color3.fromRGB(235, 235, 245)
adjustableTitle.TextSize = 12
adjustableTitle.TextXAlignment = Enum.TextXAlignment.Left
adjustableTitle.ZIndex = 2
adjustableTitle.Parent = adjustableCard

local scaleLabel = Instance.new("TextLabel")
scaleLabel.Size = UDim2.new(1, -92, 0, 18)
scaleLabel.Position = UDim2.new(0, 12, 0, 31)
scaleLabel.BackgroundTransparency = 1
scaleLabel.Font = Enum.Font.GothamSemibold
scaleLabel.Text = "Scale  ·  100%"
scaleLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
scaleLabel.TextSize = 11
scaleLabel.TextXAlignment = Enum.TextXAlignment.Left
scaleLabel.ZIndex = 2
scaleLabel.Parent = adjustableCard

local resetScaleBtn = Instance.new("TextButton")
resetScaleBtn.Size = UDim2.fromOffset(56, 20)
resetScaleBtn.Position = UDim2.new(1, -68, 0, 29)
resetScaleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
resetScaleBtn.Font = Enum.Font.GothamBold
resetScaleBtn.Text = "RESET"
resetScaleBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
resetScaleBtn.TextSize = 9
resetScaleBtn.ZIndex = 2
resetScaleBtn.Parent = adjustableCard

do
	local resetCorner = Instance.new("UICorner")
	resetCorner.CornerRadius = UDim.new(0, 6)
	resetCorner.Parent = resetScaleBtn
end

local scaleSliderBg = Instance.new("Frame")
scaleSliderBg.Size = UDim2.new(1, -24, 0, 8)
scaleSliderBg.Position = UDim2.new(0, 12, 0, 60)
scaleSliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 44)
scaleSliderBg.BorderSizePixel = 0
scaleSliderBg.ZIndex = 2
scaleSliderBg.Parent = adjustableCard

do
	local scaleSliderCorner = Instance.new("UICorner")
	scaleSliderCorner.CornerRadius = UDim.new(1, 0)
	scaleSliderCorner.Parent = scaleSliderBg
end

local scaleSliderFill = Instance.new("Frame")
scaleSliderFill.Size = UDim2.new(1, 0, 1, 0)
scaleSliderFill.BackgroundColor3 = currentTheme
scaleSliderFill.BorderSizePixel = 0
scaleSliderFill.ZIndex = 2
scaleSliderFill.Parent = scaleSliderBg

do
	local scaleFillCorner = Instance.new("UICorner")
	scaleFillCorner.CornerRadius = UDim.new(1, 0)
	scaleFillCorner.Parent = scaleSliderFill
end

local scaleKnob = Instance.new("Frame")
scaleKnob.Name = "ScaleKnob"
scaleKnob.Size = UDim2.fromOffset(16, 16)
scaleKnob.Position = UDim2.new(1, -8, 0.5, -8)
scaleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
scaleKnob.BorderSizePixel = 0
scaleKnob.ZIndex = 4
scaleKnob.Parent = scaleSliderBg

do
	local scaleKnobCorner = Instance.new("UICorner")
	scaleKnobCorner.CornerRadius = UDim.new(1, 0)
	scaleKnobCorner.Parent = scaleKnob
end

local scaleSliderBtn = Instance.new("TextButton")
scaleSliderBtn.Size = UDim2.new(1, 0, 1, 12)
scaleSliderBtn.Position = UDim2.new(0, 0, 0, -6)
scaleSliderBtn.BackgroundTransparency = 1
scaleSliderBtn.Text = ""
scaleSliderBtn.ZIndex = 5
scaleSliderBtn.Parent = scaleSliderBg

-- Game info text container
local infoPanel = makeConfigCard(
	"GameInfoContainer",
	UDim2.new(0.5, -CONFIG_LAYOUT.gap / 2, 0, CONFIG_LAYOUT.cardH),
	UDim2.new(0.5, CONFIG_LAYOUT.gap / 2, 0, 0),
	topRow
)

local infoHeader = Instance.new("TextLabel")
infoHeader.Size = UDim2.new(1, -24, 0, 16)
infoHeader.Position = UDim2.new(0, 12, 0, 9)
infoHeader.BackgroundTransparency = 1
infoHeader.Font = Enum.Font.GothamBold
infoHeader.Text = "Game Info"
infoHeader.TextColor3 = Color3.fromRGB(235, 235, 245)
infoHeader.TextSize = 12
infoHeader.TextXAlignment = Enum.TextXAlignment.Left
infoHeader.ZIndex = 2
infoHeader.Parent = infoPanel

local gameTitle = Instance.new("TextLabel")
gameTitle.Size = UDim2.new(0.48, -6, 0, 16)
gameTitle.Position = UDim2.new(0, 12, 0, 31)
gameTitle.BackgroundTransparency = 1
gameTitle.Font = Enum.Font.GothamBold
gameTitle.Text = "Steal An Egg"
gameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
gameTitle.TextSize = 12
gameTitle.TextXAlignment = Enum.TextXAlignment.Left
gameTitle.ZIndex = 2
gameTitle.Parent = infoPanel

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(0.52, -6, 0, 16)
timeLabel.Position = UDim2.new(0.48, 0, 0, 31)
timeLabel.BackgroundTransparency = 1
timeLabel.Font = Enum.Font.Gotham
timeLabel.Text = "Time Playing: 0s"
timeLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
timeLabel.TextSize = 10
timeLabel.TextXAlignment = Enum.TextXAlignment.Right
timeLabel.ZIndex = 2
timeLabel.Parent = infoPanel

local statusWorking = Instance.new("TextLabel")
statusWorking.Size = UDim2.new(0.33, -4, 0, 16)
statusWorking.Position = UDim2.new(0, 12, 0, 55)
statusWorking.BackgroundTransparency = 1
statusWorking.Font = Enum.Font.GothamBold
statusWorking.Text = "Working"
statusWorking.TextColor3 = Color3.fromRGB(80, 255, 140)
statusWorking.TextSize = 10
statusWorking.TextXAlignment = Enum.TextXAlignment.Left
statusWorking.ZIndex = 2
statusWorking.Parent = infoPanel

local statusMulti = Instance.new("TextLabel")
statusMulti.Size = UDim2.new(0.34, -4, 0, 16)
statusMulti.Position = UDim2.new(0.33, 0, 0, 55)
statusMulti.BackgroundTransparency = 1
statusMulti.Font = Enum.Font.Gotham
statusMulti.Text = "Multi Script"
statusMulti.TextColor3 = Color3.fromRGB(200, 200, 210)
statusMulti.TextSize = 10
statusMulti.TextXAlignment = Enum.TextXAlignment.Center
statusMulti.ZIndex = 2
statusMulti.Parent = infoPanel

local statusFree = Instance.new("TextLabel")
statusFree.Size = UDim2.new(0.33, -4, 0, 16)
statusFree.Position = UDim2.new(0.67, 0, 0, 55)
statusFree.BackgroundTransparency = 1
statusFree.Font = Enum.Font.Gotham
statusFree.Text = "free only"
statusFree.TextColor3 = Color3.fromRGB(160, 160, 175)
statusFree.TextSize = 10
statusFree.TextXAlignment = Enum.TextXAlignment.Right
statusFree.ZIndex = 2
statusFree.Parent = infoPanel

-- Transparent background control stays below the theme card.
-- Two separate buttons: left = permanent "ON" switch, right = permanent "OFF" switch.
local bgTransparent = false
local transparentBtn = Instance.new("Frame") -- holder (kept under this name so the Appearance slide can move it)
transparentBtn.Name = "TransparentBackground"
transparentBtn.Size = UDim2.new(1, 0, 0, 32)
transparentBtn.LayoutOrder = 3 -- stack position; the UIListLayout keeps it under the Appearance card
transparentBtn.BackgroundTransparency = 1
transparentBtn.Parent = configPage:FindFirstChild("Body") or configPage

local function applyBackgroundTransparency()
	-- Title bar / sidebar turn translucent for Transparent BG and while a motion background plays, so the
	-- animation shows through. topBarFix (the square-corner strip under the bar) must match the bar,
	-- otherwise a solid band stays visible at the bottom of the title bar.
	local barT = (bgTransparent or motionHooks.active) and 0.35 or 0
	mainFrame.BackgroundTransparency = bgTransparent and 0.45 or 0
	topBar.BackgroundTransparency = barT
	topBarFix.BackgroundTransparency = barT
	tabRail.BackgroundTransparency = barT

	-- the selected side lights up in the current theme colour
	for _, side in ipairs({ { "OnBtn", bgTransparent }, { "OffBtn", not bgTransparent } }) do
		local btn = transparentBtn:FindFirstChild(side[1])
		if btn then
			local selected = side[2]
			btn.BackgroundColor3 = selected and currentTheme or Color3.fromRGB(32, 32, 40)
			btn.TextColor3 = selected and themeTextColor(currentTheme) or Color3.fromRGB(200, 200, 210)
			btn.Font = selected and Enum.Font.GothamBold or Enum.Font.GothamSemibold
		end
	end

	-- the motion background follows Transparent BG (picture see-through) and the theme (chip colours)
	if motionHooks.onStateChanged then
		motionHooks.onStateChanged()
	end
end

for _, def in ipairs({
	{ name = "OnBtn", text = "Transparent BG  ·  ON", scale = 0, offset = 0, value = true },
	{ name = "OffBtn", text = "Transparent BG  ·  OFF", scale = 0.5, offset = 4, value = false },
}) do
	local btn = Instance.new("TextButton")
	btn.Name = def.name
	btn.Size = UDim2.new(0.5, -4, 1, 0)
	btn.Position = UDim2.new(def.scale, def.offset, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
	btn.AutoButtonColor = false
	btn.Font = Enum.Font.GothamSemibold
	btn.Text = def.text
	btn.TextColor3 = Color3.fromRGB(200, 200, 210)
	btn.TextSize = 11
	btn.Parent = transparentBtn

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	local btnStroke = Instance.new("UIStroke")
	btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border -- outline the button, never the text
	btnStroke.Color = currentTheme
	btnStroke.Transparency = 0.5
	btnStroke.Thickness = 1
	btnStroke.Parent = btn
	registerStroke(btnStroke)

	btn.MouseButton1Click:Connect(function()
		bgTransparent = def.value
		applyBackgroundTransparency()
	end)
end

applyBackgroundTransparency()

local applyTheme
local refreshThemeSelection -- assigned below; applyTheme calls it so the glow follows any theme change

-- Built inside its own function so its many locals do not count toward the main chunk's 200-local limit.
local function buildAppearanceSection()
	-- ===== VYRE APPEARANCE: collapsible card | 5 x 2 pill grid | animated outlines =====
	local APPEARANCE_GOLD = Color3.fromRGB(255, 200, 50)
	local WHITE = Color3.fromRGB(255, 255, 255)
	local PILL_IDLE_STROKE = Color3.fromRGB(52, 52, 66)
	local PILL_SPLIT_ANGLE = 30    -- tilt of the diagonal split (degrees)
	local PILL_SPLIT_POINT = 0.55  -- how much of the pill the dominant colour covers

	-- layout maths (pixels)
	local ROWS, PILL_H, ROW_GAP = 5, 28, 6
	local GRID_Y, HEADER_H = 42, 44
	local GRID_H = ROWS * PILL_H + (ROWS - 1) * ROW_GAP
	local CARD_OPEN_H = GRID_Y + GRID_H + 14

	local function animOn()
		return settingsState and settingsState.animations
	end

	local function pillTween(obj, props, duration, style, direction)
		local d = animOn() and duration or 0
		local ok, tween = pcall(function()
			return TweenService:Create(
				obj,
				TweenInfo.new(d, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
				props
			)
		end)
		if ok and tween then
			tween:Play()
			return tween
		end
		return nil
	end

	-- ---------- card (outline uses the same rainbow animation as the Scripts columns) ----------
	local themeCard = makeConfigCard(
		"ThemesContainer",
		UDim2.new(1, 0, 0, CARD_OPEN_H),
		UDim2.new(0, 0, 0, 0)
	)
	themeCard.LayoutOrder = 2 -- stack: TopRow (1) > Appearance (2) > Transparent BG (3) > Default (4) > Inferno (5)
	themeCard.ClipsDescendants = true

	local cardStroke = themeCard:FindFirstChildOfClass("UIStroke")
	if cardStroke then
		cardStroke.Thickness = 1.5
		cardStroke.Transparency = 0.2
		registerRainbowStroke(cardStroke)
	end

	-- ---------- header: gold bar | title | chevron (click anywhere on the row to hide / open) ----------
	local header = Instance.new("TextButton")
	header.Name = "AppearanceHeader"
	header.Size = UDim2.new(1, -24, 0, 24)
	header.Position = UDim2.new(0, 12, 0, 10)
	header.BackgroundTransparency = 1
	header.AutoButtonColor = false
	header.Text = ""
	header.ZIndex = 3
	header.Parent = themeCard

	local themeBar = Instance.new("Frame")
	themeBar.Name = "IndicatorBar"
	themeBar.Size = UDim2.fromOffset(4, 18)
	themeBar.AnchorPoint = Vector2.new(0, 0.5)
	themeBar.Position = UDim2.new(0, 0, 0.5, 0)
	themeBar.BackgroundColor3 = APPEARANCE_GOLD
	themeBar.BorderSizePixel = 0
	themeBar.ZIndex = 4
	themeBar.Parent = header

	local themeBarCorner = Instance.new("UICorner")
	themeBarCorner.CornerRadius = UDim.new(0, 2)
	themeBarCorner.Parent = themeBar

	local themeLabel = Instance.new("TextLabel")
	themeLabel.Name = "Title"
	themeLabel.Size = UDim2.new(1, -52, 1, 0)
	themeLabel.Position = UDim2.new(0, 14, 0, 0)
	themeLabel.BackgroundTransparency = 1
	themeLabel.Font = Enum.Font.GothamBold
	themeLabel.Text = "VYRE APPEARANCE"
	themeLabel.TextColor3 = WHITE
	themeLabel.TextSize = 13
	themeLabel.TextXAlignment = Enum.TextXAlignment.Left
	themeLabel.ZIndex = 4
	themeLabel.Parent = header

	-- chevron built from two rotated bars (no font glyph needed); rotating the holder flips it
	local chevron = Instance.new("Frame")
	chevron.Name = "Chevron"
	chevron.Size = UDim2.fromOffset(14, 8)
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -14, 0.5, 0)
	chevron.BackgroundTransparency = 1
	chevron.Rotation = 0
	chevron.ZIndex = 4
	chevron.Parent = header

	local chevronBars = {}
	for _, arm in ipairs({ { x = 4, rot = 45 }, { x = 10, rot = -45 } }) do
		local bar = Instance.new("Frame")
		bar.Size = UDim2.fromOffset(9, 2)
		bar.AnchorPoint = Vector2.new(0.5, 0.5)
		bar.Position = UDim2.fromOffset(arm.x, 3)
		bar.Rotation = arm.rot
		bar.BackgroundColor3 = APPEARANCE_GOLD
		bar.BorderSizePixel = 0
		bar.ZIndex = 4
		bar.Parent = chevron

		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(1, 0)
		barCorner.Parent = bar

		table.insert(chevronBars, bar)
	end

	local function tintChevron(color)
		for _, bar in ipairs(chevronBars) do
			pillTween(bar, { BackgroundColor3 = color }, 0.15)
		end
	end
	header.MouseEnter:Connect(function() tintChevron(WHITE) end)
	header.MouseLeave:Connect(function() tintChevron(APPEARANCE_GOLD) end)

	-- ---------- 5 rows x 2 columns grid ----------
	local themeContainer = Instance.new("Frame")
	themeContainer.Name = "ThemeGrid"
	themeContainer.Size = UDim2.new(1, -24, 0, GRID_H)
	themeContainer.Position = UDim2.new(0, 12, 0, GRID_Y)
	themeContainer.BackgroundTransparency = 1
	themeContainer.Parent = themeCard

	local themeLayout = Instance.new("UIGridLayout")
	themeLayout.CellSize = UDim2.new(0.49, 0, 0, PILL_H)
	themeLayout.CellPadding = UDim2.new(0.02, 0, 0, ROW_GAP)
	themeLayout.FillDirection = Enum.FillDirection.Horizontal
	themeLayout.FillDirectionMaxCells = 2
	themeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	themeLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	themeLayout.SortOrder = Enum.SortOrder.LayoutOrder
	themeLayout.Parent = themeContainer

	-- ---------- pills ----------
	local themePills = {}

	local function linearChannel(v)
		if v <= 0.03928 then
			return v / 12.92
		end
		return ((v + 0.055) / 1.055) ^ 2.4
	end

	local function relLum(c)
		return 0.2126 * linearChannel(c.R) + 0.7152 * linearChannel(c.G) + 0.0722 * linearChannel(c.B)
	end

	local function contrastRatio(a, b)
		if a < b then
			a, b = b, a
		end
		return (a + 0.05) / (b + 0.05)
	end

	local function glowSequence(base, alt)
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, base),
			ColorSequenceKeypoint.new(0.35, base),
			ColorSequenceKeypoint.new(0.5, alt),
			ColorSequenceKeypoint.new(0.65, base),
			ColorSequenceKeypoint.new(1, base),
		})
	end

	-- idle = thin dim border | hover = neon border | selected = thick neon border + halo.
	-- While lit, the border's UIGradient (base -> alt -> base) is spun by the loop further down.
	local function updatePill(entry)
		local lit = entry.selected or entry.hovering
		local strokeProps, haloProps
		if entry.selected then
			strokeProps = { Thickness = 3, Transparency = 0, Color = WHITE }
			haloProps = { BackgroundTransparency = 0.78, Size = UDim2.new(1, 10, 1, 10) }
		elseif entry.hovering then
			strokeProps = { Thickness = 2, Transparency = 0.15, Color = WHITE }
			haloProps = { BackgroundTransparency = 0.9, Size = UDim2.new(1, 6, 1, 6) }
		else
			strokeProps = { Thickness = 1, Transparency = 0.25, Color = PILL_IDLE_STROKE }
			haloProps = { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) }
		end

		if lit then
			entry.strokeGradient.Enabled = true
		end
		local strokeTween = pillTween(entry.stroke, strokeProps, 0.2)
		pillTween(entry.halo, haloProps, 0.28)

		if not lit then
			if strokeTween then
				strokeTween.Completed:Connect(function()
					if not (entry.selected or entry.hovering) then
						entry.strokeGradient.Enabled = false
					end
				end)
			else
				entry.strokeGradient.Enabled = false
			end
		end
	end

	for index, theme in ipairs(themes) do
		local baseColor = theme.color
		local altColor = theme.alt or baseColor:Lerp(Color3.new(0, 0, 0), 0.45)

		local cell = Instance.new("Frame")
		cell.Name = "Cell_" .. theme.name
		cell.BackgroundTransparency = 1
		cell.LayoutOrder = index
		cell.ZIndex = 2
		cell.Parent = themeContainer

		-- soft halo behind the pill (colour-cycling gradient, fades in when selected / hovered)
		local halo = Instance.new("Frame")
		halo.Name = "Halo"
		halo.AnchorPoint = Vector2.new(0.5, 0.5)
		halo.Position = UDim2.fromScale(0.5, 0.5)
		halo.Size = UDim2.fromScale(1, 1)
		halo.BackgroundColor3 = WHITE
		halo.BackgroundTransparency = 1
		halo.BorderSizePixel = 0
		halo.ZIndex = 2
		halo.Parent = cell

		local haloCorner = Instance.new("UICorner")
		haloCorner.CornerRadius = UDim.new(1, 0)
		haloCorner.Parent = halo

		local haloGradient = Instance.new("UIGradient")
		haloGradient.Color = glowSequence(baseColor, altColor)
		haloGradient.Parent = halo

		-- the pill itself
		local pill = Instance.new("TextButton")
		pill.Name = theme.name
		pill.Size = UDim2.fromScale(1, 1)
		pill.BackgroundColor3 = WHITE
		pill.BorderSizePixel = 0
		pill.AutoButtonColor = false
		pill.Text = ""
		pill.ZIndex = 3
		pill.Parent = cell

		local pillCorner = Instance.new("UICorner")
		pillCorner.CornerRadius = UDim.new(1, 0)
		pillCorner.Parent = pill

		-- hard-stop diagonal split: dominant colour first, second colour after
		local fillGradient = Instance.new("UIGradient")
		fillGradient.Rotation = PILL_SPLIT_ANGLE
		fillGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, baseColor),
			ColorSequenceKeypoint.new(PILL_SPLIT_POINT, baseColor),
			ColorSequenceKeypoint.new(PILL_SPLIT_POINT + 0.001, altColor),
			ColorSequenceKeypoint.new(1, altColor),
		})
		fillGradient.Parent = pill

		-- NOT registered with allThemeStrokes: each pill keeps its own colours
		local pillStroke = Instance.new("UIStroke")
		pillStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		pillStroke.Color = PILL_IDLE_STROKE
		pillStroke.Thickness = 1
		pillStroke.Transparency = 0.25
		pillStroke.Parent = pill

		local strokeGradient = Instance.new("UIGradient")
		strokeGradient.Color = glowSequence(baseColor, altColor)
		strokeGradient.Enabled = false
		strokeGradient.Parent = pillStroke

		-- label is a separate TextLabel so the gradient never tints the text.
		-- Plain flat text (no outline): white or near-black, whichever reads better on BOTH colours.
		local inkColor = Color3.fromRGB(18, 18, 26)
		local lumBase, lumAlt, lumInk = relLum(baseColor), relLum(altColor), relLum(inkColor)
		local whiteScore = math.min(contrastRatio(1, lumBase), contrastRatio(1, lumAlt))
		local inkScore = math.min(contrastRatio(lumInk, lumBase), contrastRatio(lumInk, lumAlt))
		local pillLabel = Instance.new("TextLabel")
		pillLabel.Name = "Label"
		pillLabel.Size = UDim2.fromScale(1, 1)
		pillLabel.BackgroundTransparency = 1
		pillLabel.Font = Enum.Font.GothamBold
		pillLabel.Text = theme.name
		pillLabel.TextSize = 11
		pillLabel.TextColor3 = (inkScore >= whiteScore) and inkColor or WHITE
		pillLabel.TextStrokeTransparency = 1
		pillLabel.ZIndex = 4
		pillLabel.Parent = pill

		local entry = {
			theme = theme,
			pill = pill,
			stroke = pillStroke,
			strokeGradient = strokeGradient,
			fillGradient = fillGradient,
			haloGradient = haloGradient,
			halo = halo,
			fillRot = PILL_SPLIT_ANGLE,
			spin = 0,
			selected = false,
			hovering = false,
		}
		table.insert(themePills, entry)

		pill.MouseEnter:Connect(function()
			entry.hovering = true
			updatePill(entry)
		end)

		pill.MouseLeave:Connect(function()
			entry.hovering = false
			updatePill(entry)
		end)

		pill.MouseButton1Click:Connect(function()
			applyTheme(baseColor)
			-- quick neon flash on click, then settle back into the selected state
			local flash = pillTween(entry.stroke, { Thickness = 5 }, 0.09)
			if flash then
				flash.Completed:Connect(function()
					updatePill(entry)
				end)
			end
		end)
	end

	refreshThemeSelection = function(color)
		for _, entry in ipairs(themePills) do
			local isSelected = (entry.theme.color == color)
			if entry.selected ~= isSelected then
				entry.selected = isSelected
				updatePill(entry)
			end
		end
	end

	refreshThemeSelection(currentTheme)

	-- ---------- hide / open (chevron flips, card slides, button below follows) ----------
	local expanded = true

	local function setExpanded(state)
		expanded = state
		local d = animOn() and 0.18 or 0
		local slide = TweenInfo.new(d, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local flip = TweenInfo.new(d, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

		if state then
			themeContainer.Visible = true
		else
			for _, entry in ipairs(themePills) do
				if entry.hovering then
					entry.hovering = false
					updatePill(entry)
				end
			end
		end

		TweenService:Create(themeCard, slide, {
			Size = UDim2.new(1, 0, 0, state and CARD_OPEN_H or HEADER_H)
		}):Play()
		-- everything below the card follows by itself (UIListLayout), no second tween needed
		TweenService:Create(chevron, flip, { Rotation = state and 0 or 180 }):Play()

		if not state then
			task.delay(d, function()
				if not expanded then
					themeContainer.Visible = false
				end
			end)
		end
	end

	header.MouseButton1Click:Connect(function()
		setExpanded(not expanded)
	end)

	-- ---------- ambient animation: spinning neon borders, drifting split, pulsing gold bar ----------
	local clock = 0
	local fxConn
	fxConn = RunService.RenderStepped:Connect(function(dt)
		if not screenGui.Parent then
			fxConn:Disconnect()
			return
		end
		if not configPage.Visible or not themeContainer.Visible or not animOn() then
			return
		end

		clock = clock + dt
		themeBar.BackgroundTransparency = 0.3 * (1 - ((math.sin(clock * 3) + 1) / 2))

		for _, entry in ipairs(themePills) do
			if entry.selected or entry.hovering then
				entry.spin = (entry.spin + dt * (entry.selected and 140 or 70)) % 360
				entry.strokeGradient.Rotation = entry.spin
				entry.haloGradient.Rotation = -entry.spin
			end
			local target = entry.selected and (PILL_SPLIT_ANGLE + math.sin(clock * 1.8) * 22) or PILL_SPLIT_ANGLE
			entry.fillRot = entry.fillRot + (target - entry.fillRot) * math.min(1, dt * 8)
			entry.fillGradient.Rotation = entry.fillRot
		end
	end)
end

do
	local built, buildErr = pcall(buildAppearanceSection)
	if not built then
		warn("[Vyre Hub] Appearance section failed to build: " .. tostring(buildErr))
	end
end

-- ======================================================================
-- MOTION BACKGROUND  (Config rows: Default / Inferno)
-- A black-hole picture (Gargantua) rotates slowly and "breathes" behind the whole hub.
--   * ONE ImageLabel at the lowest ZIndex inside MainFrame. It is a square big enough to cover the panel at
--     ANY rotation angle (side = panel diagonal), and MainFrame's ClipsDescendants crops the overflow.
--   * Two native TweenService loops (RepeatCount = -1) that start together and share one clock:
--       - Rotation: linear 0 -> 360, very slow
--       - UIScale : gentle Sine in-out "breath" (reverses), so it never jumps
--   * No Heartbeat / RenderStepped link at all. A tween that is not playing costs nothing, so whenever the
--     panel is hidden, collapsed (or collapsing), minimized or destroyed the tweens are PAUSED. Settings ->
--     Animations OFF cancels them and shows one still frame.
--   * Everything lives in this function so it adds no top-level locals (the main chunk sits close to the
--     200-local limit). It is called under pcall: if it ever fails, the hub just has no motion background.
-- ======================================================================
local function buildMotionBackground()
	local ContentProvider = game:GetService("ContentProvider")

	-- ---------- registry (add more motion backgrounds here) ----------
	local BACKGROUNDS = {
		{
			id = "inferno",
			label = "INFERNO",
			image = "rbxassetid://16081893047", -- Gargantua black hole
			accent = Color3.fromRGB(255, 125, 40), -- glow colour of the selected card
			dots = { Color3.fromRGB(255, 190, 70), Color3.fromRGB(255, 120, 35), Color3.fromRGB(225, 45, 45) },
			rotateSeconds = 90, -- one full 360 degree turn
			pulseSeconds = 7, -- one breath in (it then reverses back out)
			pulseScale = 1.06, -- breathing depth: 100% -> 106%
		},
	}
	local DEFAULT_ID = "inferno"
	local BRIGHTNESS = 0.35 -- ImageColor3 multiplier: lower = darker picture = easier to read text on top
	local SEE_THROUGH = 0.35 -- ImageTransparency while "Transparent BG" is ON (lets the game show through)
	local OVERSCAN = 1.02 -- 2% bigger than needed, so the picture edges never show

	local byId = {}
	for _, def in ipairs(BACKGROUNDS) do
		byId[def.id] = def
	end
	-- saved value: "off" = Default (plain panel), or a background id
	if settingsState.motionBackground ~= "off" and not byId[settingsState.motionBackground] then
		settingsState.motionBackground = DEFAULT_ID
	end

	-- ---------- the background image: ONE ImageLabel, behind every other MainFrame child ----------
	local panelW = mainFrame.Size.X.Offset > 0 and mainFrame.Size.X.Offset or 580
	local panelH = mainFrame.Size.Y.Offset > 0 and mainFrame.Size.Y.Offset or 380
	local side = math.ceil(math.sqrt(panelW * panelW + panelH * panelH) * OVERSCAN)

	local image = Instance.new("ImageLabel")
	image.Name = "MotionBackground"
	image.AnchorPoint = Vector2.new(0.5, 0.5) -- rotates around the panel centre, stays centred while collapsing
	image.Position = UDim2.fromScale(0.5, 0.5)
	image.Size = UDim2.fromOffset(side, side)
	image.BackgroundTransparency = 1
	image.BorderSizePixel = 0
	image.Active = false -- never swallows clicks / touches
	image.Visible = false
	image.ImageTransparency = 1 -- fades in once the texture has loaded
	image.ImageColor3 = Color3.new(BRIGHTNESS, BRIGHTNESS, BRIGHTNESS)
	image.ScaleType = Enum.ScaleType.Crop
	-- Lowest layer: every other child of MainFrame has ZIndex >= 1. (Falls back to 0 if a client ever rejects
	-- negative values; 0 is still below everything else.)
	if not pcall(function() image.ZIndex = -1 end) then
		image.ZIndex = 0
	end
	image.Parent = mainFrame

	local breathe = Instance.new("UIScale") -- the "breathing" scale is animated on this, not on the Size
	breathe.Scale = 1
	breathe.Parent = image

	-- [[SPIN-BEGIN]]
	-- Rotation + breathing loop. Returns { start, stop, reset, destroy }.
	local function createSpinner(def)
		local rotateTween, breatheTween
		local running = false
		local api = {}

		local function build()
			rotateTween = TweenService:Create(
				image,
				TweenInfo.new(def.rotateSeconds, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0),
				{ Rotation = 360 }
			)
			breatheTween = TweenService:Create(
				breathe,
				TweenInfo.new(def.pulseSeconds, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0),
				{ Scale = def.pulseScale }
			)
		end

		-- play both loops together (they share the same start moment = synchronized)
		function api.start()
			if running then
				return
			end
			running = true
			if not rotateTween then
				build()
			end
			rotateTween:Play()
			breatheTween:Play()
		end

		-- freeze in place: paused tweens cost nothing and resume from the same pose
		function api.stop()
			if not running then
				return
			end
			running = false
			rotateTween:Pause()
			breatheTween:Pause()
		end

		-- drop the tweens and show the still pose (Animations OFF)
		function api.reset()
			running = false
			if rotateTween then
				rotateTween:Cancel()
				breatheTween:Cancel()
				rotateTween, breatheTween = nil, nil
			end
			image.Rotation = 0
			breathe.Scale = 1
		end

		function api.destroy()
			api.reset()
		end

		return api
	end
	-- [[SPIN-END]]

	-- ---------- state ----------
	local current = nil -- definition on screen (nil = Default, or its texture failed to load)
	local spinner = nil
	local loaded, loading, failed = {}, {}, {}
	local fadeTween = nil

	-- true only while the player can actually see the animation
	local function isActive()
		if not screenGui.Parent or not screenGui.Enabled or not mainFrame.Visible or not contentArea.Visible then
			return false
		end
		if mainFrame:GetAttribute("Collapsing") then
			return false -- collapse / expand slide in progress
		end
		local compact = screenGui:FindFirstChild("CompactBar")
		return not (compact and compact.Visible)
	end

	local function imageTransparencyTarget()
		return bgTransparent and SEE_THROUGH or 0
	end

	-- play only while useful, freeze (pause) otherwise
	local function syncRun()
		if not spinner or not current then
			return
		end
		if not (loaded[current.id] and isActive()) then
			spinner.stop()
		elseif settingsState.animations == false then
			spinner.reset()
		else
			spinner.start()
		end
	end

	local function revealImage()
		if fadeTween then
			fadeTween:Cancel()
			fadeTween = nil
		end
		local target = imageTransparencyTarget()
		if settingsState.animations ~= false then
			fadeTween = TweenService:Create(
				image,
				TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ ImageTransparency = target }
			)
			fadeTween:Play()
		else
			image.ImageTransparency = target
		end
	end

	local applySelection -- assigned below

	local function beginPreload(def)
		if loaded[def.id] or loading[def.id] or failed[def.id] then
			return
		end
		loading[def.id] = true
		task.spawn(function()
			local ok, rejected = pcall(function()
				local bad = false
				ContentProvider:PreloadAsync({ image }, function(_, status)
					local s = tostring(status)
					if string.find(s, "Failure", 1, true) or string.find(s, "TimedOut", 1, true) then
						bad = true
					end
				end)
				return bad
			end)
			loading[def.id] = nil
			if not screenGui.Parent then
				return
			end
			if ok and rejected then
				failed[def.id] = true
				warn("[Vyre Hub] Motion background '" .. def.label .. "' failed to load (" .. def.image
					.. "). Make sure the asset is public and is an Image asset.")
				applySelection() -- falls back to the plain panel
			else
				loaded[def.id] = true -- (also when PreloadAsync itself is unavailable: the texture just streams in)
				if current == def then
					revealImage()
					syncRun()
				end
			end
		end)
	end

	-- ---------- Config rows: row 2 = Default, row 3 = Inferno (stadium cards under the Transparent BG row) ----------
	local body = configPage:FindFirstChild("Body") or configPage
	local CARD_H = 44
	local FIRST_ORDER = 4 -- stack: TopRow (1) > Appearance (2) > Transparent BG (3) > Default (4) > Inferno (5)
	local IDLE_STROKE = Color3.fromRGB(58, 58, 74)
	local IDLE_RING = Color3.fromRGB(85, 85, 105)
	local INK_ACTIVE = Color3.fromRGB(240, 240, 245)
	local INK_IDLE = Color3.fromRGB(172, 172, 184)

	local cards = {} -- id -> entry

	local function tweenProps(obj, props, duration)
		TweenService:Create(
			obj,
			TweenInfo.new(settingsState.animations ~= false and duration or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			props
		):Play()
	end

	-- Default card: its three dots show the LIVE hub theme (dominant, second colour, soft tint)
	local function defaultDots()
		local second = currentTheme:Lerp(Color3.new(0, 0, 0), 0.45)
		for _, theme in ipairs(themes) do
			if theme.color == currentTheme and theme.alt then
				second = theme.alt
				break
			end
		end
		return { currentTheme, second, currentTheme:Lerp(Color3.new(1, 1, 1), 0.55) }
	end

	local function accentOf(entry)
		return entry.def and entry.def.accent or currentTheme
	end

	local function paintCard(entry)
		local active = settingsState.motionBackground == entry.id
		local hot = entry.hovering and not active
		local accent = accentOf(entry)

		-- selected = thick glowing border in the card's accent colour; hover = medium; idle = thin and dim
		tweenProps(entry.stroke, {
			Thickness = active and 3 or (hot and 1.75 or 1),
			Transparency = active and 0 or (hot and 0.2 or 0.3),
			Color = (active or hot) and accent or IDLE_STROKE,
		}, 0.18)

		entry.label.Font = active and Enum.Font.GothamBold or Enum.Font.GothamSemibold
		tweenProps(entry.label, { TextColor3 = active and INK_ACTIVE or INK_IDLE }, 0.18)

		-- checkmark circle: filled + tick when active, empty ring when not
		tweenProps(entry.check, { BackgroundTransparency = active and 0 or 1, BackgroundColor3 = accent }, 0.18)
		tweenProps(entry.checkStroke, {
			Color = active and accent or IDLE_RING,
			Transparency = active and 0 or 0.35,
		}, 0.18)
		for _, bar in ipairs(entry.tick) do
			tweenProps(bar, { BackgroundTransparency = active and 0 or 1, BackgroundColor3 = themeTextColor(accent) }, 0.18)
		end

		if entry.id == "off" then
			local colors = defaultDots()
			for i, dot in ipairs(entry.dots) do
				dot.BackgroundColor3 = colors[i]
			end
		end
	end

	local function updateCards()
		for _, entry in pairs(cards) do
			paintCard(entry)
		end
	end

	local function chooseBackground(id)
		if settingsState.motionBackground == id then
			return
		end
		settingsState.motionBackground = id
		saveSettings()
		playClick()
		applySelection()
	end

	local function createCard(option)
		local def = option.def
		local card = Instance.new("TextButton")
		card.Name = "Option_" .. option.id
		card.Size = UDim2.new(1, 0, 0, CARD_H)
		card.LayoutOrder = option.order
		card.AutoButtonColor = false
		card.Text = ""
		card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
		card.BackgroundTransparency = 0.08
		card.BorderSizePixel = 0
		card.ZIndex = 2
		card.Parent = body
		motionHooks.registerGlass(card, 0.3) -- turns translucent while a motion background plays

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0) -- fully rounded = stadium / pill
		corner.Parent = card

		-- NOT registered with allThemeStrokes: the card controls its own colour (accent when selected)
		local stroke = Instance.new("UIStroke")
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border -- outline the card, never the text
		stroke.Color = IDLE_STROKE
		stroke.Thickness = 1
		stroke.Transparency = 0.3
		stroke.Parent = card

		-- far left: three palette dots
		local dotRow = Instance.new("Frame")
		dotRow.Name = "Dots"
		dotRow.AnchorPoint = Vector2.new(0, 0.5)
		dotRow.Position = UDim2.new(0, 20, 0.5, 0)
		dotRow.Size = UDim2.fromOffset(40, 10)
		dotRow.BackgroundTransparency = 1
		dotRow.ZIndex = 3
		dotRow.Parent = card

		local dotLayout = Instance.new("UIListLayout")
		dotLayout.FillDirection = Enum.FillDirection.Horizontal
		dotLayout.Padding = UDim.new(0, 5)
		dotLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		dotLayout.SortOrder = Enum.SortOrder.LayoutOrder
		dotLayout.Parent = dotRow

		local startColors = def and def.dots or defaultDots()
		local dots = {}
		for i = 1, 3 do
			local dot = Instance.new("Frame")
			dot.Name = "Dot" .. i
			dot.LayoutOrder = i
			dot.Size = UDim2.fromOffset(10, 10)
			dot.BackgroundColor3 = startColors[i]
			dot.BorderSizePixel = 0
			dot.ZIndex = 3
			dot.Parent = dotRow

			local dotCorner = Instance.new("UICorner")
			dotCorner.CornerRadius = UDim.new(1, 0)
			dotCorner.Parent = dot
			dots[i] = dot
		end

		-- far right: checkmark inside a circle
		local check = Instance.new("Frame")
		check.Name = "Check"
		check.AnchorPoint = Vector2.new(1, 0.5)
		check.Position = UDim2.new(1, -14, 0.5, 0)
		check.Size = UDim2.fromOffset(22, 22)
		check.BackgroundColor3 = IDLE_RING
		check.BackgroundTransparency = 1
		check.BorderSizePixel = 0
		check.ZIndex = 3
		check.Parent = card

		local checkCorner = Instance.new("UICorner")
		checkCorner.CornerRadius = UDim.new(1, 0)
		checkCorner.Parent = check

		local checkStroke = Instance.new("UIStroke")
		checkStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		checkStroke.Color = IDLE_RING
		checkStroke.Thickness = 1.5
		checkStroke.Transparency = 0.35
		checkStroke.Parent = check

		-- the tick is drawn from two rotated bars, so it never depends on font glyph support
		local mark = Instance.new("Frame")
		mark.Name = "Tick"
		mark.AnchorPoint = Vector2.new(0.5, 0.5)
		mark.Position = UDim2.new(0.5, 0, 0.5, 0)
		mark.Size = UDim2.fromOffset(14, 12)
		mark.BackgroundTransparency = 1
		mark.ZIndex = 4
		mark.Parent = check

		local tick = {}
		for _, arm in ipairs({ { w = 5, x = 3, y = 7, rot = 45 }, { w = 10, x = 8, y = 5, rot = -45 } }) do
			local bar = Instance.new("Frame")
			bar.AnchorPoint = Vector2.new(0.5, 0.5)
			bar.Size = UDim2.fromOffset(arm.w, 2)
			bar.Position = UDim2.fromOffset(arm.x, arm.y)
			bar.Rotation = arm.rot
			bar.BackgroundColor3 = INK_ACTIVE
			bar.BackgroundTransparency = 1
			bar.BorderSizePixel = 0
			bar.ZIndex = 4
			bar.Parent = mark

			local barCorner = Instance.new("UICorner")
			barCorner.CornerRadius = UDim.new(1, 0)
			barCorner.Parent = bar
			table.insert(tick, bar)
		end

		-- circular image preview, just left of the checkmark (Inferno only)
		local labelRight = 14 + 22 + 10 -- space kept free on the right: margin + check + gap
		if def then
			local preview = Instance.new("ImageLabel")
			preview.Name = "Preview"
			preview.AnchorPoint = Vector2.new(1, 0.5)
			preview.Position = UDim2.new(1, -(14 + 22 + 10), 0.5, 0)
			preview.Size = UDim2.fromOffset(34, 34)
			preview.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
			preview.BorderSizePixel = 0
			preview.Image = def.image
			preview.ScaleType = Enum.ScaleType.Crop
			preview.ImageColor3 = Color3.fromRGB(215, 215, 215) -- subtle, never brighter than the real background
			preview.ZIndex = 3
			preview.Parent = card

			local previewCorner = Instance.new("UICorner")
			previewCorner.CornerRadius = UDim.new(1, 0) -- circular clip
			previewCorner.Parent = preview

			local previewStroke = Instance.new("UIStroke")
			previewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			previewStroke.Color = IDLE_RING
			previewStroke.Thickness = 1
			previewStroke.Transparency = 0.45
			previewStroke.Parent = preview

			labelRight = labelRight + 34 + 10
		end

		-- middle: plain name, no outline
		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Position = UDim2.new(0, 76, 0, 0)
		label.Size = UDim2.new(1, -(76 + labelRight), 1, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamSemibold
		label.Text = option.label
		label.TextColor3 = INK_IDLE
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextStrokeTransparency = 1
		label.ZIndex = 3
		label.Parent = card

		local entry = {
			id = option.id,
			def = def,
			card = card,
			stroke = stroke,
			label = label,
			check = check,
			checkStroke = checkStroke,
			tick = tick,
			dots = dots,
			hovering = false,
		}
		cards[option.id] = entry

		card.MouseEnter:Connect(function()
			entry.hovering = true
			paintCard(entry)
		end)
		card.MouseLeave:Connect(function()
			entry.hovering = false
			paintCard(entry)
		end)
		card.MouseButton1Click:Connect(function()
			chooseBackground(option.id)
		end)
	end

	createCard({ id = "off", label = "Default", order = FIRST_ORDER })
	for index, def in ipairs(BACKGROUNDS) do
		createCard({ id = def.id, label = def.label, order = FIRST_ORDER + index, def = def })
	end

	-- ---------- selection: image, glass panels, run / freeze ----------
	applySelection = function()
		local def = byId[settingsState.motionBackground]
		if def and failed[def.id] then
			def = nil
		end

		if def ~= current then
			if spinner then
				spinner.destroy()
				spinner = nil
			end
			current = def
			if def then
				image.Image = def.image
				spinner = createSpinner(def)
				beginPreload(def)
			end
		end

		image.Visible = current ~= nil
		motionHooks.active = current ~= nil

		-- Panels turn translucent while the animation plays, so it glides behind the cards and text.
		-- Script cards, buttons and inputs stay solid, which keeps all text readable.
		for _, entry in ipairs(motionHooks.glass) do
			local frame = entry.frame
			if frame and frame.Parent then
				frame.BackgroundTransparency = motionHooks.active and entry.glass or entry.base
			end
		end

		applyBackgroundTransparency() -- title bar / sidebar glass, image transparency, card colours
		syncRun()
	end

	-- Transparent BG toggled or theme changed (applyBackgroundTransparency calls this)
	motionHooks.onStateChanged = function()
		if fadeTween then
			fadeTween:Cancel()
			fadeTween = nil
		end
		if current and loaded[current.id] then
			image.ImageTransparency = imageTransparencyTarget()
		end
		updateCards()
	end

	-- Settings -> Animations toggled
	motionHooks.refresh = function()
		syncRun()
		updateCards()
	end

	-- panel hidden / shown, collapsed / expanded (and mid-slide), minimized / restored, ScreenGui toggled -> freeze / resume
	mainFrame:GetPropertyChangedSignal("Visible"):Connect(syncRun)
	contentArea:GetPropertyChangedSignal("Visible"):Connect(syncRun)
	mainFrame:GetAttributeChangedSignal("Collapsing"):Connect(syncRun)
	screenGui:GetPropertyChangedSignal("Enabled"):Connect(syncRun)
	local function watchCompactBar(child)
		if child.Name == "CompactBar" then -- created later in this file, so hook it the moment it appears
			child:GetPropertyChangedSignal("Visible"):Connect(syncRun)
		end
	end
	screenGui.ChildAdded:Connect(watchCompactBar)
	for _, child in ipairs(screenGui:GetChildren()) do
		watchCompactBar(child)
	end
	screenGui.Destroying:Connect(function()
		if spinner then
			spinner.destroy()
			spinner = nil
		end
	end)

	applySelection()
end

do
	local built, buildErr = pcall(buildMotionBackground)
	if not built then
		warn("[Vyre Hub] Motion background failed to build: " .. tostring(buildErr))
	end
end

-- Plain crisp text: no text outline anywhere. A UIStroke on a TextButton/TextLabel defaults to
-- "Contextual" (outlines the text), so any that slipped through are switched to Border mode.
do
	for _, inst in ipairs(screenGui:GetDescendants()) do
		if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
			inst.TextStrokeTransparency = 1
		elseif inst:IsA("UIStroke") then
			local owner = inst.Parent
			if owner and (owner:IsA("TextLabel") or owner:IsA("TextButton") or owner:IsA("TextBox")) then
				inst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			end
		end
	end
end

-- Rainbow outlines (same animation as the Scripts columns):
-- Adjustable card, the Game Info card beside it, and the hub's body frame.
do
	for _, frame in ipairs({ adjustableCard, infoPanel, mainFrame }) do
		local st = frame:FindFirstChildOfClass("UIStroke")
		if st then
			if frame ~= mainFrame then
				st.Thickness = 1.5
				st.Transparency = 0.2
			end
			registerRainbowStroke(st)
		end
	end
end

local compactBar, compactStroke, compactLogo

-- theme chips connected after applyTheme is fully defined (below)

-- Compact minimize bar
compactBar = Instance.new("Frame")
compactBar.Name = "CompactBar"
compactBar.Size = UDim2.new(0, 210, 0, 34)
compactBar.Position = mainFrame.Position
compactBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
compactBar.BorderSizePixel = 0
compactBar.Visible = false
compactBar.Active = true
compactBar.Parent = screenGui

local compactScale = Instance.new("UIScale")
compactScale.Scale = 1
compactScale.Parent = compactBar

do
	local compactCorner = Instance.new("UICorner")
	compactCorner.CornerRadius = UDim.new(0, 10)
	compactCorner.Parent = compactBar
end

compactStroke = Instance.new("UIStroke")
compactStroke.Color = currentTheme
compactStroke.Thickness = 1.5
compactStroke.Transparency = 0.25
compactStroke.Parent = compactBar

local compactLogo = Instance.new("Frame")
compactLogo.Size = UDim2.fromOffset(8, 8)
compactLogo.Position = UDim2.new(0, 12, 0.5, -4)
compactLogo.BackgroundColor3 = currentTheme
compactLogo.BorderSizePixel = 0
compactLogo.Parent = compactBar

do
	local compactLogoCorner = Instance.new("UICorner")
	compactLogoCorner.CornerRadius = UDim.new(1, 0)
	compactLogoCorner.Parent = compactLogo
end

local compactTitle = Instance.new("TextLabel")
compactTitle.Size = UDim2.new(1, -50, 1, 0)
compactTitle.Position = UDim2.new(0, 28, 0, 0)
compactTitle.BackgroundTransparency = 1
compactTitle.Font = Enum.Font.GothamBold
compactTitle.Text = "Vyre Hub"
compactTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
compactTitle.TextSize = 12
compactTitle.TextXAlignment = Enum.TextXAlignment.Left
compactTitle.Parent = compactBar

local compactClose = Instance.new("TextButton")
compactClose.Size = UDim2.fromOffset(26, 26)
compactClose.Position = UDim2.new(1, -30, 0, 4)
compactClose.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
compactClose.Font = Enum.Font.GothamBold
compactClose.Text = "X"
compactClose.TextColor3 = Color3.fromRGB(200, 200, 200)
compactClose.TextSize = 11
compactClose.Parent = compactBar

do
	local compactCloseCorner = Instance.new("UICorner")
	compactCloseCorner.CornerRadius = UDim.new(0, 6)
	compactCloseCorner.Parent = compactClose
end

local function tweenColor(obj, prop, color, t)
	if not obj then return end
	if t ~= nil and t <= 0 then
		-- instant (theme changes): assign directly, no tween, no delay
		pcall(function() obj[prop] = color end)
		return
	end
	pcall(function()
		TweenService:Create(obj, TweenInfo.new(t or 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			[prop] = color
		}):Play()
	end)
end

applyTheme = function(color)
	currentTheme = color
	if refreshThemeSelection then pcall(refreshThemeSelection, color) end
	local t = 0 -- instant: the whole UI recolours in the same frame

	-- FIRST thing applied: active sidebar tab + its indicator bar (direct, no tab switch needed)
	for _, b in ipairs(allTabButtons) do
		local ind = b:FindFirstChild("Indicator")
		if ind then
			ind.BackgroundColor3 = color
		end
		if b:GetAttribute("Active") then
			b.BackgroundColor3 = color
			b.TextColor3 = themeTextColor(color)
			b.Font = Enum.Font.GothamBold
		else
			b.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
			b.TextColor3 = Color3.fromRGB(170, 170, 180)
			b.Font = Enum.Font.GothamSemibold
		end
	end

	-- Performance Boost tool button: accent fill while it is ON
	local perfBtn = toolsPage:FindFirstChild("PerformanceBoostBtn")
	if perfBtn and perfBtn:GetAttribute("BoostOn") then
		perfBtn.BackgroundColor3 = color
		perfBtn.TextColor3 = themeTextColor(color)
	end

	-- Smooth outline wrap animation on main frame
	tweenColor(mainStroke, "Color", color, t)
	pcall(function()
		TweenService:Create(mainStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Thickness = 2.5,
			Transparency = 0.05
		}):Play()
		task.delay(0.2, function()
			TweenService:Create(mainStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Thickness = 1.5,
				Transparency = 0.35
			}):Play()
		end)
	end)

	tweenColor(compactStroke, "Color", color, t)
	tweenColor(compactLogo, "BackgroundColor3", color, t)
	tweenColor(logoDot, "BackgroundColor3", color, t)
	tweenColor(scaleSliderFill, "BackgroundColor3", color, t)

	scriptsPage.ScrollBarImageColor3 = color
	toolsPage.ScrollBarImageColor3 = color

	-- Update every accent button (Execute buttons)
	for _, btn in ipairs(allThemeButtons) do
		if btn and btn.Parent then
			tweenColor(btn, "BackgroundColor3", color, t)
		end
	end

	-- Update EVERY registered stroke (columns, cards, main, transparent)
	for _, st in ipairs(allThemeStrokes) do
		if st and st.Parent then
			tweenColor(st, "Color", color, t)
		end
	end
	for _, sb in ipairs(allThemeScrollbars) do
		if sb and sb.Parent then
			sb.ScrollBarImageColor3 = color
		end
	end
	scriptsPage.ScrollBarImageColor3 = color

	-- Settings page: text + ON chips follow theme (not only the tab button)
	local soft = Color3.new(
		math.clamp(color.R * 0.55 + 0.45, 0, 1),
		math.clamp(color.G * 0.55 + 0.45, 0, 1),
		math.clamp(color.B * 0.55 + 0.45, 0, 1)
	)
	local muted = Color3.new(
		math.clamp(color.R * 0.35 + 0.35, 0, 1),
		math.clamp(color.G * 0.35 + 0.35, 0, 1),
		math.clamp(color.B * 0.35 + 0.35, 0, 1)
	)
	for i, lbl in ipairs(settingsThemeLabels) do
		if lbl and lbl.Parent then
			-- first labels stronger; drag note quieter
			local c = (lbl == dragNote) and muted or soft
			tweenColor(lbl, "TextColor3", c, t)
		end
	end
	for _, entry in ipairs(settingsThemeToggles) do
		local btn = entry.btn
		if btn and btn.Parent then
			if entry.kind == "toggle" then
				local on = settingsState[entry.key]
				btn.BackgroundColor3 = on and color or Color3.fromRGB(50, 50, 58)
				btn.TextColor3 = on and themeTextColor(color) or Color3.fromRGB(200, 200, 210)
			elseif entry.kind == "defaultTab" then
				local on = settingsState.defaultTab == entry.name
				btn.BackgroundColor3 = on and color or Color3.fromRGB(40, 40, 48)
				btn.TextColor3 = on and themeTextColor(color) or Color3.fromRGB(200, 200, 210)
			end
		end
	end

	-- Transparent Background ON / OFF switch follows the theme too
	applyBackgroundTransparency()
end

-- Tabs
local allPages = {
	Scripts = scriptsPage,
	Favorites = favsPage,
	Tools = toolsPage,
	Config = configPage,
	Settings = settingsPage,
	Information = infoPage,
	Owner = ownerPage,
}
local tabBtnByName = {
	Scripts = scriptsTabBtn,
	Favorites = favsTabBtn,
	Tools = toolsTabBtn,
	Config = configTabBtn,
	Settings = settingsTabBtn,
	Information = infoTabBtn,
	Owner = ownerTabBtn,
}

local function setTabActive(activeBtn)
	local dur = (settingsState and settingsState.animations) and 0.22 or 0
	for _, b in ipairs(allTabButtons) do
		if b then
			local isActive = (b == activeBtn)
			b:SetAttribute("Active", isActive)

			if isActive then
				b.BackgroundColor3 = currentTheme
				b.TextColor3 = themeTextColor(currentTheme)
				b.Font = Enum.Font.GothamBold
			else
				b.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
				b.TextColor3 = Color3.fromRGB(170, 170, 180)
				b.Font = Enum.Font.GothamSemibold
			end

			local ind = b:FindFirstChild("Indicator")
			if ind then
				ind.BackgroundColor3 = currentTheme
				TweenService:Create(ind, TweenInfo.new(dur, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Size = UDim2.fromOffset(3, isActive and 16 or 0),
					BackgroundTransparency = isActive and 0 or 1,
				}):Play()
			end
		end
	end
end

local function showTab(name)
	playClick()
	local btn = tabBtnByName[name] or scriptsTabBtn
	local target = allPages[name]

	-- slide direction: going down the sidebar slides in from the right, going up from the left
	local oldIdx, newIdx = 0, 0
	for i, b in ipairs(allTabButtons) do
		if b:GetAttribute("Active") then oldIdx = i end
		if b == btn then newIdx = i end
	end
	local dir = (newIdx >= oldIdx) and 1 or -1
	local wasVisible = target and target.Visible

	for n, page in pairs(allPages) do
		if page then
			page.Visible = (n == name)
			if n ~= name then
				page.Position = UDim2.new(0, 0, 0, 0)
			end
		end
	end

	if target then
		if (not wasVisible) and settingsState and settingsState.animations then
			target.Position = UDim2.new(0, 36 * dir, 0, 0)
			TweenService:Create(target, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, 0, 0, 0)
			}):Play()
		else
			target.Position = UDim2.new(0, 0, 0, 0)
		end
	end

	setTabActive(btn)
	if name == "Favorites" and refreshFavoritesPage then
		refreshFavoritesPage()
	end
end

scriptsTabBtn.MouseButton1Click:Connect(function() showTab("Scripts") end)
favsTabBtn.MouseButton1Click:Connect(function() showTab("Favorites") end)
toolsTabBtn.MouseButton1Click:Connect(function() showTab("Tools") end)
configTabBtn.MouseButton1Click:Connect(function() showTab("Config") end)
settingsTabBtn.MouseButton1Click:Connect(function() showTab("Settings") end)
infoTabBtn.MouseButton1Click:Connect(function() showTab("Information") end)
ownerTabBtn.MouseButton1Click:Connect(function() showTab("Owner") end)


local applyResponsiveScale
local clampMainToViewport

-- Collapse / expand (↓ collapse, ↑ expand) — no separate minimize bar
local isCollapsed = false
-- Same WIDTH when collapsed — only height becomes top-bar (title only)
local FULL_W, FULL_H = 580, 380
local BAR_H = 40
local FULL_SIZE = UDim2.fromOffset(FULL_W, FULL_H)
local COLLAPSED_SIZE = UDim2.fromOffset(FULL_W, BAR_H)

local collapseTween = nil
collapseBtn.MouseButton1Click:Connect(function()
	-- Sources Hub style:
	-- - Title bar NEVER resizes (same width + same UIScale)
	-- - Only height animates; content shows/hides under the bar
	-- - Position never moves
	isCollapsed = not isCollapsed
	if collapseTween then
		collapseTween:Cancel()
		collapseTween = nil
	end

	-- 0.22s Cubic: one clean height slide. The "Collapsing" flag stops applyResponsiveScale() from
	-- snapping the size mid-tween (that snap was the stutter / jump).
	local dur = (settingsState and settingsState.animations) and 0.22 or 0
	local info = TweenInfo.new(dur, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	mainFrame:SetAttribute("Collapsing", true)

	if isCollapsed then
		collapseBtn.Text = "↑"
		-- content stays visible (clipped by the frame) while the height slides up, hidden once finished
		local tween = TweenService:Create(mainFrame, info, { Size = COLLAPSED_SIZE })
		collapseTween = tween
		tween.Completed:Connect(function()
			if collapseTween == tween then
				if isCollapsed then
					contentArea.Visible = false
				end
				mainFrame:SetAttribute("Collapsing", false)
			end
		end)
		tween:Play()
	else
		collapseBtn.Text = "↓"
		contentArea.Visible = true
		local tween = TweenService:Create(mainFrame, info, { Size = FULL_SIZE })
		collapseTween = tween
		tween.Completed:Connect(function()
			if collapseTween == tween then
				mainFrame:SetAttribute("Collapsing", false)
			end
		end)
		tween:Play()
	end
	-- Keep scale stable (based on FULL size) — do not rescale title
	applyResponsiveScale()
end)


local function showExitConfirm()
	-- Avoid stacking multiple dialogs
	-- Parent to screenGui (not mainFrame) so dialog stays visible when UI is collapsed
	local existing = screenGui:FindFirstChild("ExitConfirm")
	if existing then existing:Destroy() end

	local overlay = Instance.new("Frame")
	overlay.Name = "ExitConfirm"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.55
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 200
	overlay.Parent = screenGui

	-- Premium horizontal card
	local box = Instance.new("Frame")
	box.Size = UDim2.fromOffset(240, 120)
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.Position = UDim2.fromScale(0.5, 0.5)
	box.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
	box.BorderSizePixel = 0
	box.ZIndex = 201
	box.Parent = overlay

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 12)
	boxCorner.Parent = box

	-- Soft inner panel for depth
	local inner = Instance.new("Frame")
	inner.Size = UDim2.new(1, -10, 1, -10)
	inner.Position = UDim2.fromOffset(5, 5)
	inner.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	inner.BorderSizePixel = 0
	inner.ZIndex = 201
	inner.Parent = box
	local innerCorner = Instance.new("UICorner")
	innerCorner.CornerRadius = UDim.new(0, 12)
	innerCorner.Parent = inner

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = Color3.fromRGB(255, 80, 180)
	boxStroke.Thickness = 2.5
	boxStroke.Transparency = 0.05
	boxStroke.Parent = box

	-- Animated rainbow outline (same vibe as script columns)
	local rbConn
	local t0 = 0
	rbConn = RunService.RenderStepped:Connect(function(dt)
		if not boxStroke or not boxStroke.Parent then
			if rbConn then rbConn:Disconnect() end
			return
		end
		t0 = (t0 + dt * 0.35) % 1
		boxStroke.Color = Color3.fromHSV(t0, 0.9, 1)
	end)

	local msg = Instance.new("TextLabel")
	msg.Size = UDim2.new(1, -16, 0, 32)
	msg.Position = UDim2.new(0, 8, 0, 8)
	msg.BackgroundTransparency = 1
	msg.Font = Enum.Font.GothamBold
	msg.Text = "Are u sure u want to exit?"
	msg.TextColor3 = Color3.fromRGB(245, 245, 250)
	msg.TextSize = 13
	msg.TextWrapped = true
	msg.ZIndex = 202
	msg.Parent = inner

	local function makeSideBtn(label, xScale, bg, action)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0.5, -12, 0, 34)
		b.Position = UDim2.new(xScale, xScale == 0 and 8 or 4, 1, -44)
		b.BackgroundColor3 = bg
		b.Font = Enum.Font.GothamBold
		b.Text = label
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		b.TextSize = 12
		b.ZIndex = 202
		b.AutoButtonColor = true
		b.Parent = inner
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 10)
		c.Parent = b
		b.MouseButton1Click:Connect(function()
			playClick()
			if rbConn then rbConn:Disconnect() end
			action()
		end)
		return b
	end

	-- Left = CANCEL · Right = EXIT  (like reference orientation)
	makeSideBtn("CANCEL", 0, Color3.fromRGB(48, 48, 58), function()
		overlay:Destroy()
	end)

	makeSideBtn("EXIT", 0.5, Color3.fromRGB(210, 45, 60), function()
		pcall(function() screenGui:Destroy() end)
	end)
end

closeBtn.MouseButton1Click:Connect(function()
	showExitConfirm()
end)

compactClose.MouseButton1Click:Connect(function()
	showExitConfirm()
end)

-- Smooth drag + touch (tracks specific input so multi-touch is stable)
-- Drag ONLY from title bar + left sidebar (red-box areas). Not whole UI.
local function pointIn(gui, screenPos)
	if not gui or not gui.Visible then return false end
	local ap = gui.AbsolutePosition
	local as = gui.AbsoluteSize
	return screenPos.X >= ap.X and screenPos.X <= ap.X + as.X
		and screenPos.Y >= ap.Y and screenPos.Y <= ap.Y + as.Y
end

local function isInteractiveAt(screenPos)
	for _, desc in ipairs(mainFrame:GetDescendants()) do
		if desc:IsA("GuiObject") and desc.Visible then
			local isBtn = desc:IsA("TextButton") or desc:IsA("ImageButton") or desc:IsA("TextBox")
			local isSlider = desc.Name == "ScaleSliderBtn" or desc.Name == "ScaleKnob"
			if isBtn or isSlider then
				if pointIn(desc, screenPos) then
					return true
				end
			end
		end
	end
	return false
end

local function isOnDragHandle(screenPos)
	-- Title bar always
	if pointIn(topBar, screenPos) then return true end
	-- Left tab rail (when expanded)
	if contentArea.Visible and pointIn(tabRail, screenPos) then return true end
	return false
end

local function setupDraggable(frameObj)
	local dragging = false
	local startInputPos = nil
	local startPosX, startPosY = 0, 0
	local activeTouch = nil

	frameObj.Active = true
	topBar.Active = true
	tabRail.Active = true

	local function beginDrag(input)
		if dragging then return end
		if isInteractiveAt(input.Position) then return end
		if not isOnDragHandle(input.Position) then return end

		dragging = true
		startInputPos = input.Position

		-- Calibrate once per drag: are Position offsets plain screen pixels (k = 1) or UIScale-scaled
		-- units (k = scale)? Dividing by the wrong one made the window outrun the finger at 50%.
		do
			local sc = uiScale.Scale
			local k = 1
			local offX = frameObj.Position.X.Offset
			if frameObj.Position.X.Scale == 0 and math.abs(offX) > 8 and math.abs(sc - 1) > 0.02 and frameObj.Parent then
				local actual = frameObj.AbsolutePosition.X - frameObj.Parent.AbsolutePosition.X
				if math.abs(actual - offX * sc) < math.abs(actual - offX) then
					k = sc
				end
			end
			frameObj:SetAttribute("OffsetK", k)
		end
		startPosX = frameObj.Position.X.Offset
		startPosY = frameObj.Position.Y.Offset
		if input.UserInputType == Enum.UserInputType.Touch then
			activeTouch = input
		else
			activeTouch = nil
		end
	end

	local function stopDrag()
		dragging = false
		startInputPos = nil
		activeTouch = nil
	end

	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			beginDrag(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			stopDrag()
		elseif input.UserInputType == Enum.UserInputType.Touch then
			if activeTouch == nil or input == activeTouch then
				stopDrag()
			end
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or not startInputPos then return end
		local ok = false
		if activeTouch == nil and input.UserInputType == Enum.UserInputType.MouseMovement then
			ok = true
		elseif activeTouch ~= nil and (input == activeTouch or input.UserInputType == Enum.UserInputType.Touch) then
			ok = true
		end
		if not ok then return end

		local scale = frameObj:GetAttribute("OffsetK") or 1
		if scale < 0.05 then scale = 1 end
		local delta = input.Position - startInputPos
		frameObj.Position = UDim2.fromOffset(
			startPosX + (delta.X / scale),
			startPosY + (delta.Y / scale)
		)
		clampMainToViewport()
	end)
end

setupDraggable(mainFrame)

-- ======================
-- RESPONSIVE SIZE / POSITION
-- Base design size: 580 x 380 (FULL_SIZE).
-- fitScale = how much is needed so 100% fits on the current screen.
-- effectiveScale = fitScale * requestedScale  → every 1% of the slider
-- actually changes the visual size (50% ≈ half of 100%).
-- Does NOT reset Position (keeps where user dragged / collapsed).
-- ======================
local requestedScale = 1

local function getViewportSize()
	local size = screenGui.AbsoluteSize
	if size.X <= 0 or size.Y <= 0 then
		return Vector2.new(1920, 1080)
	end
	return Vector2.new(size.X, size.Y)
end

function applyResponsiveScale()
	local viewport = getViewportSize()
	-- IMPORTANT: always fit against FULL size so collapse does NOT
	-- change the visual scale of the title bar (Sources Hub style).
	local margin = 20
	local fitScale = math.min(1, (viewport.X - margin) / FULL_W, (viewport.Y - margin) / FULL_H)
	if fitScale ~= fitScale or fitScale <= 0 then
		fitScale = 1
	end
	local effectiveScale = math.clamp(fitScale * requestedScale, 0.25, 1.25)

	uiScale.Scale = effectiveScale
	if compactScale then
		compactScale.Scale = effectiveScale
	end

	-- Size height only changes on collapse; width always FULL_W
	if not mainFrame:GetAttribute("Collapsing") then
		mainFrame.Size = isCollapsed and COLLAPSED_SIZE or FULL_SIZE
	end
	mainFrame.AnchorPoint = Vector2.new(0, 0)
	-- NEVER touch Position
end

function clampMainToViewport()
	if not mainFrame or not mainFrame.Parent then return end
	local viewport = getViewportSize()
	local visualScale = uiScale.Scale
	if visualScale < 0.05 then visualScale = 1 end
	local scale = mainFrame:GetAttribute("OffsetK") or 1
	local visualW = FULL_W * visualScale
	local visualH = (isCollapsed and BAR_H or FULL_H) * visualScale
	-- Soft clamp in Position-offset space (no AbsolutePosition write → no teleport)
	local maxX = math.max(0, (viewport.X - visualW) / scale)
	local maxY = math.max(0, (viewport.Y - visualH) / scale)
	local x = math.clamp(mainFrame.Position.X.Offset, 0, maxX)
	local y = math.clamp(mainFrame.Position.Y.Offset, 0, maxY)
	mainFrame.Position = UDim2.fromOffset(x, y)
end

-- Smooth scale: freeze slider pixel metrics at press so UIScale changes
-- don't feed back into pct math (that was the glitch / "nababaliw").
local scaleTween = nil
local function updateScale(val, instant)
	local clamped = math.clamp(val, 50, 100)
	requestedScale = clamped / 100
	scaleLabel.Text = "Scale  ·  " .. math.floor(clamped) .. "%"
	local pct = (clamped - 50) / 50
	scaleSliderFill.Size = UDim2.new(pct, 0, 1, 0)
	scaleKnob.Position = UDim2.new(pct, -8, 0.5, -8)

	local viewport = getViewportSize()
	local margin = 20
	local fitScale = math.min(1, (viewport.X - margin) / FULL_W, (viewport.Y - margin) / FULL_H)
	if fitScale ~= fitScale or fitScale <= 0 then fitScale = 1 end
	local target = math.clamp(fitScale * requestedScale, 0.25, 1.25)

	if scaleTween then
		scaleTween:Cancel()
		scaleTween = nil
	end
	if instant then
		uiScale.Scale = target
	else
		scaleTween = TweenService:Create(
			uiScale,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Scale = target }
		)
		scaleTween:Play()
	end
	if not mainFrame:GetAttribute("Collapsing") then
		mainFrame.Size = isCollapsed and COLLAPSED_SIZE or FULL_SIZE
	end
end

screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	applyResponsiveScale()
	clampMainToViewport()
end)

local sliding = false
local slideTrackX = 0
local slideTrackW = 1

local function scaleFromPointer(x)
	if slideTrackW < 1 then return end
	local pct = math.clamp((x - slideTrackX) / slideTrackW, 0, 1)
	updateScale(50 + (pct * 50), false)
end

scaleSliderBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		sliding = true
		-- Freeze track geometry at press — ignores later AbsoluteSize changes from UIScale
		slideTrackX = scaleSliderBg.AbsolutePosition.X
		slideTrackW = math.max(1, scaleSliderBg.AbsoluteSize.X)
		scaleFromPointer(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if sliding then
			sliding = false
			-- Snap final scale cleanly
			updateScale(requestedScale * 100, true)
			clampMainToViewport()
		end
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not sliding then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		scaleFromPointer(input.Position.X)
	end
end)

resetScaleBtn.MouseButton1Click:Connect(function()
	updateScale(100, true)
	mainFrame.AnchorPoint = Vector2.new(0, 0)
	local vp = getViewportSize()
	mainFrame.Position = UDim2.fromOffset(
		math.max(0, (vp.X - FULL_W) / 2),
		math.max(0, (vp.Y - FULL_H) / 2)
	)
	applyResponsiveScale()
	clampMainToViewport()
end)

-- Live Time Playing counter
local playSeconds = 0
task.spawn(function()
	while screenGui.Parent do
		task.wait(1)
		playSeconds += 1
		if timeLabel and timeLabel.Parent then
			timeLabel.Text = "Time Playing: " .. tostring(playSeconds) .. "s"
		end
	end
end)



-- Avatar + name: fixed inside the left sidebar footer so it never gets clipped
-- when the main UI is moved upward/downward.
local sideAvatar = Instance.new("ImageLabel")
sideAvatar.Size = UDim2.fromOffset(28, 28)
sideAvatar.Position = UDim2.new(0, 8, 1, -36)
sideAvatar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
sideAvatar.BorderSizePixel = 0
sideAvatar.ZIndex = 5
sideAvatar.Parent = tabRail

do
	local sideAvatarCorner = Instance.new("UICorner")
	sideAvatarCorner.CornerRadius = UDim.new(1, 0)
	sideAvatarCorner.Parent = sideAvatar
end

-- Rainbow animated ring around avatar
local sideAvatarStroke = Instance.new("UIStroke")
sideAvatarStroke.Thickness = 2
sideAvatarStroke.Color = Color3.fromRGB(255, 80, 180)
sideAvatarStroke.Transparency = 0.05
sideAvatarStroke.Parent = sideAvatar
registerRainbowStroke(sideAvatarStroke)

local sideName = Instance.new("TextLabel")
sideName.Size = UDim2.new(0, 70, 0, 28)
sideName.Position = UDim2.new(0, 42, 1, -36)
sideName.BackgroundTransparency = 1
sideName.Font = Enum.Font.GothamBold
sideName.Text = player.DisplayName or player.Name
sideName.TextColor3 = Color3.fromRGB(230, 230, 240)
sideName.TextSize = 12
sideName.TextXAlignment = Enum.TextXAlignment.Left
sideName.TextTruncate = Enum.TextTruncate.AtEnd
sideName.ZIndex = 5
sideName.Parent = tabRail

task.spawn(function()
	local ok, content = pcall(function()
		return Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size48x48
		)
	end)
	if ok and content then
		sideAvatar.Image = content
	end
end)

-- Rainbow outlines for the four script columns. This is intentionally
-- separate from the selected theme so the column borders stay rainbow.
local rainbowTime = 0
RunService.RenderStepped:Connect(function(dt)
	if not screenGui.Parent then return end
	rainbowTime = (rainbowTime + dt * 0.18) % 1
	for i, stroke in ipairs(rainbowStrokes) do
		if stroke and stroke.Parent then
			local hue = (rainbowTime + ((i - 1) / math.max(1, #rainbowStrokes))) % 1
			stroke.Color = Color3.fromHSV(hue, 0.9, 1)
		end
	end

	-- Animated rainbow Execute buttons. Each button gets a slightly shifted hue
	-- so the effect flows continuously instead of flashing between colors.
	for i, button in ipairs(rainbowButtons) do
		if button and button.Parent then
			local hue = (rainbowTime + ((i - 1) / math.max(1, #rainbowButtons)) * 0.35) % 1
			button.BackgroundColor3 = Color3.fromHSV(hue, 0.9, 1)
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
end)

print("[Vyre Hub | Multiverse Script Sae] Loaded")


-- Final loading pass: reveal only after the whole UI exists.
task.spawn(function()
	for i = 0, 100 do
		if not loadOverlay or not loadOverlay.Parent then break end
		loadBarFill.Size = UDim2.new(i / 100, 0, 1, 0)
		loadPct.Text = tostring(i) .. "%"
		task.wait(0.012)
	end
	task.wait(0.15)
	if mainFrame and mainFrame.Parent then
		requestedScale = 1
		mainFrame.Size = FULL_SIZE
		mainFrame.AnchorPoint = Vector2.new(0, 0)
		local vp = getViewportSize()
		mainFrame.Position = UDim2.fromOffset(
			math.max(0, (vp.X - FULL_W) / 2),
			math.max(0, (vp.Y - FULL_H) / 2)
		)
		applyResponsiveScale()
		clampMainToViewport()
		mainFrame.Visible = true
		-- Open preferred default tab
		task.defer(function()
			if showTab and settingsState then
				showTab(settingsState.defaultTab or "Scripts")
			end
		end)
	end
	if loadOverlay and loadOverlay.Parent then
		loadOverlay:Destroy()
	end
end)
