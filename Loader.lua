--[[
    SOLO HUB — Discord Gate Loader
    ------------------------------------------------------------------
    No keys required. Directs users to your Discord community to unlock
    and run the script.
--]]

----------------------------------------------------------------------
-- CONFIGURATION
----------------------------------------------------------------------
local CONFIG = {
    Brand        = "SOLO HUB",
    Tagline      = "Join our Discord community to unlock the script",
    Discord      = "https://discord.gg/Xbg8dHvRg",

    -- The script executed once unlocked:
    HUB_URL      = "https://raw.githubusercontent.com/YOURNAME/YOURREPO/main/SoloHub.lua",

    -- Remember that they unlocked it on this device
    RememberUnlock = true,
    SaveFile       = "Solo/unlocked.txt",
}

----------------------------------------------------------------------
-- SERVICES & UTILS
----------------------------------------------------------------------
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInput    = game:GetService("UserInputService")
local GuiService   = game:GetService("GuiService")
local LocalPlayer  = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer

local function copyLink()
    local ok = pcall(function()
        if setclipboard then
            setclipboard(CONFIG.Discord)
        elseif toclipboard then
            toclipboard(CONFIG.Discord)
        elseif syn and syn.write_clipboard then
            syn.write_clipboard(CONFIG.Discord)
        end
    end)
    return ok
end

local function openLink()
    pcall(function() GuiService:OpenBrowserWindow(CONFIG.Discord) end)
end

local function hasUnlocked()
    if not (CONFIG.RememberUnlock and isfile and readfile) then return false end
    local ok, res = pcall(function()
        return isfile(CONFIG.SaveFile) and readfile(CONFIG.SaveFile) == "UNLOCKED"
    end)
    return ok and res or false
end

local function saveUnlock()
    if not (CONFIG.RememberUnlock and writefile) then return end
    pcall(function()
        if makefolder and isfolder and not isfolder("Solo") then makefolder("Solo") end
        writefile(CONFIG.SaveFile, "UNLOCKED")
    end)
end

local function launchHub()
    local ok, err = pcall(function()
        loadstring(game:HttpGet(CONFIG.HUB_URL))()
    end)
    if not ok then
        warn(string.format("[%s] Failed to load hub payload: %s", CONFIG.Brand, tostring(err)))
    end
end

-- If already unlocked previously, launch directly without showing UI
if hasUnlocked() then
    launchHub()
    return
end

----------------------------------------------------------------------
-- UI THEME
----------------------------------------------------------------------
local T = {
    bg      = Color3.fromRGB(8, 8, 10),
    card    = Color3.fromRGB(16, 16, 20),
    lift    = Color3.fromRGB(26, 26, 32),
    line    = Color3.fromRGB(58, 58, 68),
    text    = Color3.fromRGB(246, 246, 250),
    dim     = Color3.fromRGB(148, 148, 160),
    mute    = Color3.fromRGB(96, 96, 108),
    white   = Color3.fromRGB(255, 255, 255),
    ink     = Color3.fromRGB(10, 10, 13),
    good    = Color3.fromRGB(190, 255, 205),
}

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = p
    return c
end

local function stroke(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or T.line
    s.Thickness = th or 1
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function tween(inst, time, props, style)
    local t = TweenService:Create(inst, TweenInfo.new(time, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

----------------------------------------------------------------------
-- UI CREATION
----------------------------------------------------------------------
if _G.SoloDiscordGate then pcall(function() _G.SoloDiscordGate:Destroy() end) end

local gui = Instance.new("ScreenGui")
gui.Name = "SoloDiscordGate"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
_G.SoloDiscordGate = gui

pcall(function()
    if gethui then gui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent = game:GetService("CoreGui")
    else gui.Parent = game:GetService("CoreGui") end
end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Backdrop
local shade = Instance.new("Frame")
shade.Size = UDim2.fromScale(1, 1)
shade.BackgroundColor3 = Color3.new(0, 0, 0)
shade.BackgroundTransparency = 1
shade.BorderSizePixel = 0
shade.Parent = gui
tween(shade, 0.45, { BackgroundTransparency = 0.4 })

-- Window Card
local BASE_W, BASE_H = 420, 360
local card = Instance.new("Frame")
card.Name = "Card"
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.5)
card.Size = UDim2.fromOffset(BASE_W, BASE_H)
card.BackgroundColor3 = T.card
card.BorderSizePixel = 0
card.Active = true
card.Draggable = true
card.Parent = gui
corner(card, 16)
stroke(card, T.line, 1, 0.25)

-- Responsive Scale
local scale = Instance.new("UIScale")
scale.Parent = card

local function fitScale()
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
    if not vp or vp.X <= 0 then return 0.85 end
    local touch = UserInput.TouchEnabled and not UserInput.KeyboardEnabled
    local target = touch and 0.75 or 0.85
    local maxW = (vp.X - 40) / BASE_W
    local maxH = (vp.Y - 40) / BASE_H
    return math.clamp(math.min(target, maxW, maxH), 0.5, 0.95)
end
scale.Scale = fitScale()

-- Monogram Crest
local crest = Instance.new("Frame")
crest.AnchorPoint = Vector2.new(0.5, 0)
crest.Position = UDim2.new(0.5, 0, 0, 26)
crest.Size = UDim2.fromOffset(68, 68)
crest.BackgroundColor3 = T.white
crest.BorderSizePixel = 0
crest.Parent = card
corner(crest, 34)

local letter = Instance.new("TextLabel")
letter.BackgroundTransparency = 1
letter.Size = UDim2.fromScale(1, 1)
letter.Font = Enum.Font.GothamBlack
letter.Text = "S"
letter.TextSize = 40
letter.TextColor3 = T.ink
letter.Parent = crest

-- Labels
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(0, 108)
title.Size = UDim2.new(1, 0, 0, 24)
title.Font = Enum.Font.GothamBlack
title.Text = CONFIG.Brand
title.TextSize = 22
title.TextColor3 = T.text
title.Parent = card

local sub = Instance.new("TextLabel")
sub.BackgroundTransparency = 1
sub.Position = UDim2.fromOffset(24, 136)
sub.Size = UDim2.new(1, -48, 0, 36)
sub.Font = Enum.Font.Gotham
sub.Text = "This script is completely free, but requires joining our Discord server to get access and stay updated."
sub.TextSize = 12
sub.TextColor3 = T.dim
sub.TextWrapped = true
sub.Parent = card

-- Status Text
local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(24, 186)
status.Size = UDim2.new(1, -48, 0, 18)
status.Font = Enum.Font.GothamMedium
status.Text = "Click the button below to join & unlock."
status.TextSize = 11
status.TextColor3 = T.mute
status.Parent = card

-- Join Button
local joinBtn = Instance.new("TextButton")
joinBtn.Position = UDim2.fromOffset(28, 220)
joinBtn.Size = UDim2.new(1, -56, 0, 46)
joinBtn.BackgroundColor3 = T.white
joinBtn.AutoButtonColor = false
joinBtn.Font = Enum.Font.GothamBold
joinBtn.Text = "JOIN DISCORD TO UNLOCK"
joinBtn.TextSize = 13
joinBtn.TextColor3 = T.ink
joinBtn.Parent = card
corner(joinBtn, 10)

-- Close Button
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -38, 0, 14)
close.BackgroundColor3 = T.lift
close.BackgroundTransparency = 0.35
close.AutoButtonColor = false
close.Font = Enum.Font.GothamBold
close.Text = "X"
close.TextSize = 11
close.TextColor3 = T.dim
close.Parent = card
corner(close, 8)

-- Footer Info
local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.Position = UDim2.fromOffset(24, 280)
footer.Size = UDim2.new(1, -48, 0, 48)
footer.Font = Enum.Font.Gotham
footer.Text = CONFIG.Discord .. "\n(Invite link will be copied to your clipboard)"
footer.TextSize = 11
footer.TextColor3 = T.mute
footer.Parent = card

----------------------------------------------------------------------
-- INTERACTIONS
----------------------------------------------------------------------
local function dismiss()
    tween(shade, 0.25, { BackgroundTransparency = 1 })
    tween(card, 0.25, { Size = UDim2.fromOffset(BASE_W, 0), BackgroundTransparency = 1 })
    task.delay(0.3, function() gui:Destroy() end)
end

close.MouseButton1Click:Connect(dismiss)

local processing = false
joinBtn.MouseButton1Click:Connect(function()
    if processing then return end
    processing = true

    copyLink()
    openLink()

    status.Text = "Invite link copied! Opening Discord..."
    status.TextColor3 = T.good
    joinBtn.Text = "JOINING SERVER..."
    tween(joinBtn, 0.2, { BackgroundColor3 = Color3.fromRGB(226, 226, 236) })

    -- Short wait simulating link visit, then unlocks
    task.wait(2.2)

    joinBtn.Text = "ACCESS UNLOCKED"
    tween(joinBtn, 0.2, { BackgroundColor3 = T.good })
    status.Text = "Unlocked! Loading " .. CONFIG.Brand .. "..."
    saveUnlock()

    task.wait(0.8)
    dismiss()
    task.wait(0.2)
    launchHub()
end)
