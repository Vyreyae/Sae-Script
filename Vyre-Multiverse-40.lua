--[[
	Vyre Hub | Multiverse Script Sae
	Script launcher + Config (scale / themes)
	Minimize to compact bar
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
	{ name = "Source Hub V1", url = "https://pastefy.app/Lk0vDMmN/raw" },
	{ name = "Source Hub V2", url = "https://api.obscuravm.com/scripts/7924424523909516877" },
	{ name = "Source Hub V3", url = "https://api.obscuravm.com/scripts/2007463552086815334" },
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
}

-- BONUS NO KEY
local bonusKeyless = {
	{ name = "Rene Baterbonia", url = "https://raw.githubusercontent.com/sabscrip-arch/srver/refs/heads/main/Stealanegg" },
	{ name = "Chocola Spawner", url = "https://raw.githubusercontent.com/chocolascript-glitch/Chocola-Pet-Spawner-steal-an-egg/refs/heads/main/script.lua" },
	{ name = "Exploit Hub", url = "https://raw.githubusercontent.com/Main-Scripts-Ready-V9/Exploiter-Loader/refs/heads/main/New.lua" },
	{ name = "Private Server", url = "https://raw.githubusercontent.com/raw-roblox/PrivateServerBypass/refs/heads/main/lua" },
}

-- BONUS KEY
local bonusKey = {
	{ name = "Infinite Robux", url = "https://pastefy.app/CkaV7ET8/raw" },
	{ name = "All Games Script", url = "https://raw.githubusercontent.com/leenZzZzZ/ScriptHUB/refs/heads/main/Script%20Hub" },
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
	{ name = "Dark", color = Color3.fromRGB(120, 120, 140) },
	{ name = "Red", color = Color3.fromRGB(255, 60, 80) },
	{ name = "Purple", color = Color3.fromRGB(180, 70, 255) },
	{ name = "Blue", color = Color3.fromRGB(60, 140, 255) },
	{ name = "Cyan", color = Color3.fromRGB(50, 230, 255) },
	{ name = "Green", color = Color3.fromRGB(50, 255, 140) },
	{ name = "Gold", color = Color3.fromRGB(255, 200, 50) },
	{ name = "Pink", color = Color3.fromRGB(255, 90, 180) },
	{ name = "Orange", color = Color3.fromRGB(255, 140, 40) },
	{ name = "White", color = Color3.fromRGB(240, 240, 255) },
}
local currentTheme = themes[3].color
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

local loadBarCorner = Instance.new("UICorner")
loadBarCorner.CornerRadius = UDim.new(1, 0)
loadBarCorner.Parent = loadBarBg

local loadBarFill = Instance.new("Frame")
loadBarFill.Size = UDim2.new(0, 0, 1, 0)
loadBarFill.BackgroundColor3 = Color3.fromRGB(180, 70, 255)
loadBarFill.BorderSizePixel = 0
loadBarFill.ZIndex = 102
loadBarFill.Parent = loadBarBg

local loadFillCorner = Instance.new("UICorner")
loadFillCorner.CornerRadius = UDim.new(1, 0)
loadFillCorner.Parent = loadBarFill

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

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

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

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 12)
topBarCorner.Parent = topBar

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

local logoDotCorner = Instance.new("UICorner")
logoDotCorner.CornerRadius = UDim.new(1, 0)
logoDotCorner.Parent = logoDot

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

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

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

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

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

local tabList = Instance.new("UIListLayout")
tabList.Padding = UDim.new(0, 6)
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Parent = tabScroll

local tabPad = Instance.new("UIPadding")
tabPad.PaddingTop = UDim.new(0, 10)
tabPad.PaddingLeft = UDim.new(0, 8)
tabPad.PaddingRight = UDim.new(0, 8)
tabPad.Parent = tabScroll

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
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = b
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
pagesContainer.Parent = contentArea

-- Scripts page
local function runScript(data)
	local url = data.url
	if type(url) ~= "string" or url == "" then
		warn("[Vyre Hub] No URL set for: " .. tostring(data.name))
		return
	end
	local ok, err = pcall(function()
		loadstring(game:HttpGet(url))()
	end)
	if not ok then
		warn("[Vyre Hub] Failed to run " .. data.name .. ": " .. tostring(err))
	end
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

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchBox


local searchPad = Instance.new("UIPadding")
searchPad.PaddingLeft = UDim.new(0, 12)
searchPad.Parent = searchBox

-- Scripts page itself: no scrollbar (ScrollingEnabled off)
scriptsPage.ScrollingEnabled = true
scriptsPage.CanvasSize = UDim2.new(0, 0, 0, 0)
scriptsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Dual columns container (fills remaining height under search)
local dual = Instance.new("Frame")
dual.Name = "DualColumns"
dual.Size = UDim2.new(1, -20, 0, 200)
dual.Position = UDim2.new(0, 10, 0, 48)
dual.BackgroundTransparency = 1
dual.Parent = scriptsPage

local dualLayout = Instance.new("UIListLayout")
dualLayout.FillDirection = Enum.FillDirection.Horizontal
dualLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
dualLayout.Padding = UDim.new(0, 12)
dualLayout.SortOrder = Enum.SortOrder.LayoutOrder
dualLayout.Parent = dual

local function makeSection(title, titleColor, order)
	local col = Instance.new("Frame")
	col.Size = UDim2.new(0.5, -6, 1, 0)
	col.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	col.BorderSizePixel = 0
	col.LayoutOrder = order
	col.Parent = dual

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
		runScript(data)
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
bonusTitle.Size = UDim2.new(1, -20, 0, 18)
bonusTitle.Position = UDim2.new(0, 10, 0, 255)
bonusTitle.BackgroundTransparency = 1
bonusTitle.Font = Enum.Font.GothamBold
bonusTitle.Text = "BONUS"
bonusTitle.TextColor3 = Color3.fromRGB(255, 200, 80)
bonusTitle.TextSize = 12
bonusTitle.TextXAlignment = Enum.TextXAlignment.Left
bonusTitle.Parent = scriptsPage

local dualBonus = Instance.new("Frame")
dualBonus.Name = "DualBonus"
dualBonus.Size = UDim2.new(1, -20, 0, 160)
dualBonus.Position = UDim2.new(0, 10, 0, 275)
dualBonus.BackgroundTransparency = 1
dualBonus.Parent = scriptsPage

local dualBonusLayout = Instance.new("UIListLayout")
dualBonusLayout.FillDirection = Enum.FillDirection.Horizontal
dualBonusLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
dualBonusLayout.Padding = UDim.new(0, 12)
dualBonusLayout.Parent = dualBonus

-- temporarily parent makeSection to dualBonus
local function makeBonusSection(title, titleColor, order)
	local col = Instance.new("Frame")
	col.Size = UDim2.new(0.5, -6, 1, 0)
	col.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	col.BorderSizePixel = 0
	col.LayoutOrder = order
	col.Parent = dualBonus

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
favsHint.TextColor3 = Color3.fromRGB(140, 140, 150)
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
local favsLayout = Instance.new("UIListLayout")
favsLayout.Padding = UDim.new(0, 8)
favsLayout.Parent = favsList

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

local function makeToolButton(label, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 40)
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

makeToolButton("Rejoin Server", 44, function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end)
end)

makeToolButton("Private Server Finder", 94, function()
    runScript({ name = "Private Server", url = "https://raw.githubusercontent.com/raw-roblox/PrivateServerBypass/refs/heads/main/lua" })
end)

-- Placeholder only: this button is marked Soon and intentionally has no effect.
makeToolButton("Performance Boost (Soon)", 144, function()
    -- Feature not implemented yet.
end)

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
dragNote.Text = "Drag zone: Title bar + left sidebar only\\n(Scale / Scripts body are not drag handles)"
dragNote.TextColor3 = Color3.fromRGB(130, 130, 140)
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

local infoPad = Instance.new("UIPadding")
infoPad.PaddingTop = UDim.new(0, 10)
infoPad.PaddingBottom = UDim.new(0, 14)
infoPad.PaddingLeft = UDim.new(0, 12)
infoPad.PaddingRight = UDim.new(0, 12)
infoPad.Parent = infoPage

local infoLayout = Instance.new("UIListLayout")
infoLayout.SortOrder = Enum.SortOrder.LayoutOrder
infoLayout.Padding = UDim.new(0, 10)
infoLayout.Parent = infoPage

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

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = currentTheme
    stroke.Thickness = 1
    stroke.Transparency = 0.65
    stroke.Parent = card
    registerStroke(stroke)

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

local configPad = Instance.new("UIPadding")
configPad.PaddingTop = UDim.new(0, 16)
configPad.PaddingLeft = UDim.new(0, 16)
configPad.PaddingRight = UDim.new(0, 16)
configPad.PaddingBottom = UDim.new(0, 16)
configPad.Parent = configPage

-- Config layout: clean containers for Adjustable, Game Info, Themes
local function makeConfigCard(name, size, position)
	local card = Instance.new("Frame")
	card.Name = name
	card.Size = size
	card.Position = position
	card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	card.BackgroundTransparency = 0.08
	card.BorderSizePixel = 0
	card.ZIndex = 1
	card.Parent = configPage

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
	UDim2.new(0.54, -6, 0, 92),
	UDim2.new(0, 0, 0, 0)
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

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetScaleBtn

local scaleSliderBg = Instance.new("Frame")
scaleSliderBg.Size = UDim2.new(1, -24, 0, 8)
scaleSliderBg.Position = UDim2.new(0, 12, 0, 60)
scaleSliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 44)
scaleSliderBg.BorderSizePixel = 0
scaleSliderBg.ZIndex = 2
scaleSliderBg.Parent = adjustableCard

local scaleSliderCorner = Instance.new("UICorner")
scaleSliderCorner.CornerRadius = UDim.new(1, 0)
scaleSliderCorner.Parent = scaleSliderBg

local scaleSliderFill = Instance.new("Frame")
scaleSliderFill.Size = UDim2.new(1, 0, 1, 0)
scaleSliderFill.BackgroundColor3 = currentTheme
scaleSliderFill.BorderSizePixel = 0
scaleSliderFill.ZIndex = 2
scaleSliderFill.Parent = scaleSliderBg

local scaleFillCorner = Instance.new("UICorner")
scaleFillCorner.CornerRadius = UDim.new(1, 0)
scaleFillCorner.Parent = scaleSliderFill

local scaleKnob = Instance.new("Frame")
scaleKnob.Name = "ScaleKnob"
scaleKnob.Size = UDim2.fromOffset(16, 16)
scaleKnob.Position = UDim2.new(1, -8, 0.5, -8)
scaleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
scaleKnob.BorderSizePixel = 0
scaleKnob.ZIndex = 4
scaleKnob.Parent = scaleSliderBg

local scaleKnobCorner = Instance.new("UICorner")
scaleKnobCorner.CornerRadius = UDim.new(1, 0)
scaleKnobCorner.Parent = scaleKnob

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
	UDim2.new(0.44, -2, 0, 92),
	UDim2.new(0.56, 2, 0, 0)
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

-- Themes container
local themeCard = makeConfigCard(
	"ThemesContainer",
	UDim2.new(1, -4, 0, 126),
	UDim2.new(0, 0, 0, 104)
)

local themeLabel = Instance.new("TextLabel")
themeLabel.Size = UDim2.new(1, -24, 0, 18)
themeLabel.Position = UDim2.new(0, 12, 0, 10)
themeLabel.BackgroundTransparency = 1
themeLabel.Font = Enum.Font.GothamBold
themeLabel.Text = "Themes"
themeLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
themeLabel.TextSize = 12
themeLabel.TextXAlignment = Enum.TextXAlignment.Left
themeLabel.ZIndex = 2
themeLabel.Parent = themeCard

local themeContainer = Instance.new("Frame")
themeContainer.Size = UDim2.new(1, -24, 0, 76)
themeContainer.Position = UDim2.new(0, 12, 0, 36)
themeContainer.BackgroundTransparency = 1
themeContainer.Parent = themeCard

local themeLayout = Instance.new("UIGridLayout")
themeLayout.CellSize = UDim2.new(0.19, -4, 0, 26)
themeLayout.CellPadding = UDim2.fromOffset(6, 6)
themeLayout.FillDirectionMaxCells = 5
themeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
themeLayout.SortOrder = Enum.SortOrder.LayoutOrder
themeLayout.Parent = themeContainer

-- Transparent background option stays below the theme card.
local bgTransparent = false
local transparentBtn = Instance.new("TextButton")
transparentBtn.Size = UDim2.new(1, -4, 0, 32)
transparentBtn.Position = UDim2.new(0, 0, 0, 240)
transparentBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
transparentBtn.Font = Enum.Font.GothamBold
transparentBtn.Text = "Transparent Background  ·  OFF"
transparentBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
transparentBtn.TextSize = 11
transparentBtn.Parent = configPage

local transparentCorner = Instance.new("UICorner")
transparentCorner.CornerRadius = UDim.new(0, 8)
transparentCorner.Parent = transparentBtn

local transparentStroke = Instance.new("UIStroke")
transparentStroke.Color = currentTheme
transparentStroke.Transparency = 0.5
transparentStroke.Thickness = 1
transparentStroke.Parent = transparentBtn
registerStroke(transparentStroke)

local function applyBackgroundTransparency()
	if bgTransparent then
		mainFrame.BackgroundTransparency = 0.45
		topBar.BackgroundTransparency = 0.35
		tabRail.BackgroundTransparency = 0.35
		transparentBtn.Text = "Transparent Background  ·  ON"
		transparentBtn.TextColor3 = Color3.fromRGB(80, 255, 140)
	else
		mainFrame.BackgroundTransparency = 0
		topBar.BackgroundTransparency = 0
		tabRail.BackgroundTransparency = 0
		transparentBtn.Text = "Transparent Background  ·  OFF"
		transparentBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
	end
end

transparentBtn.MouseButton1Click:Connect(function()
	bgTransparent = not bgTransparent
	applyBackgroundTransparency()
end)

local applyTheme

for _, theme in ipairs(themes) do
	local chip = Instance.new("TextButton")
	chip.Size = UDim2.new(1, 0, 0, 26)
	chip.BackgroundColor3 = theme.color
	chip.Font = Enum.Font.GothamBold
	chip.Text = theme.name
	chip.TextColor3 = themeTextColor(theme.color)
	chip.TextSize = 10
	chip.AutoButtonColor = true
	chip.ZIndex = 3
	chip.Parent = themeContainer

	local chipCorner = Instance.new("UICorner")
	chipCorner.CornerRadius = UDim.new(0, 8)
	chipCorner.Parent = chip

	local chipStroke = Instance.new("UIStroke")
	chipStroke.Color = theme.color
	chipStroke.Transparency = 0.25
	chipStroke.Thickness = 1
	chipStroke.Parent = chip
	registerStroke(chipStroke)

	chip.MouseButton1Click:Connect(function()
		applyTheme(theme.color)
	end)
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

local compactCorner = Instance.new("UICorner")
compactCorner.CornerRadius = UDim.new(0, 10)
compactCorner.Parent = compactBar

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

local compactLogoCorner = Instance.new("UICorner")
compactLogoCorner.CornerRadius = UDim.new(1, 0)
compactLogoCorner.Parent = compactLogo

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

local compactCloseCorner = Instance.new("UICorner")
compactCloseCorner.CornerRadius = UDim.new(0, 6)
compactCloseCorner.Parent = compactClose

local function tweenColor(obj, prop, color, t)
	if not obj then return end
	pcall(function()
		TweenService:Create(obj, TweenInfo.new(t or 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			[prop] = color
		}):Play()
	end)
end

applyTheme = function(color)
	currentTheme = color
	local t = 0.4

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
	if keyPage then keyPage.ScrollBarImageColor3 = color end

	-- Active tab color
	local active = scriptsTabBtn
	for name, page in pairs(allPages or {}) do
		if page and page.Visible and tabBtnByName and tabBtnByName[name] then
			active = tabBtnByName[name]
		end
	end
	for _, b in ipairs(allTabButtons or { scriptsTabBtn, configTabBtn, ownerTabBtn }) do
		if b == active then
			tweenColor(b, "BackgroundColor3", color, t)
			b.TextColor3 = themeTextColor(color)
			b.Font = Enum.Font.GothamBold
		else
			tweenColor(b, "BackgroundColor3", Color3.fromRGB(30, 30, 38), t)
			b.TextColor3 = Color3.fromRGB(170, 170, 180)
			b.Font = Enum.Font.GothamSemibold
		end
	end

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
	for _, b in ipairs(allTabButtons) do
		if b then
			if b == activeBtn then
				b.BackgroundColor3 = currentTheme
				b.TextColor3 = themeTextColor(currentTheme)
				b.Font = Enum.Font.GothamBold
			else
				b.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
				b.TextColor3 = Color3.fromRGB(170, 170, 180)
				b.Font = Enum.Font.GothamSemibold
			end
		end
	end
end

local function showTab(name)
	playClick()
	for n, page in pairs(allPages) do
		if page then page.Visible = (n == name) end
	end
	local btn = tabBtnByName[name] or scriptsTabBtn
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

	if isCollapsed then
		collapseBtn.Text = "↑"
		contentArea.Visible = false
		local dur = (settingsState and settingsState.animations) and 0.22 or 0
		collapseTween = TweenService:Create(
			mainFrame,
			TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = COLLAPSED_SIZE }
		)
		collapseTween:Play()
	else
		collapseBtn.Text = "↓"
		local dur = (settingsState and settingsState.animations) and 0.22 or 0
		collapseTween = TweenService:Create(
			mainFrame,
			TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = FULL_SIZE }
		)
		collapseTween:Play()
		contentArea.Visible = true
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

		local scale = uiScale.Scale
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
	mainFrame.Size = isCollapsed and COLLAPSED_SIZE or FULL_SIZE
	mainFrame.AnchorPoint = Vector2.new(0, 0)
	-- NEVER touch Position
end

function clampMainToViewport()
	if not mainFrame or not mainFrame.Parent then return end
	local viewport = getViewportSize()
	local scale = uiScale.Scale
	if scale < 0.05 then scale = 1 end
	local visualW = (isCollapsed and BAR_H and FULL_W or FULL_W) * scale
	local visualH = (isCollapsed and BAR_H or FULL_H) * scale
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
	mainFrame.Size = isCollapsed and COLLAPSED_SIZE or FULL_SIZE
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

local sideAvatarCorner = Instance.new("UICorner")
sideAvatarCorner.CornerRadius = UDim.new(1, 0)
sideAvatarCorner.Parent = sideAvatar

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
