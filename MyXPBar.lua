-- =========================================================
-- CONFIGURATION
-- =========================================================
local WIDTH = 500
local HEIGHT = 24
local BAR_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"
local MAX_LEVEL = 60 -- The bar will hide automatically at this level

-- Variables for mob calculation
local lastXP = UnitXP("player")
local lastGain = 0

-- =========================================================
-- FRAME CREATION
-- =========================================================
local mainFrame = CreateFrame("Frame", "MyXPBarFrame", UIParent)
mainFrame:SetSize(WIDTH, HEIGHT)
mainFrame:SetPoint("CENTER", 0, -200)
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:SetClampedToScreen(true)

-- Dragging logic (Shift + Left Click)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then self:StartMoving() end
end)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)

-- Black Background
local bg = mainFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(mainFrame)
bg:SetTexture(0, 0, 0, 0.6)

-- =========================================================
-- BARS (PURPLE AND BLUE)
-- =========================================================
-- XP Bar (Purple)
local xpBar = CreateFrame("StatusBar", nil, mainFrame)
xpBar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
xpBar:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, 0)
xpBar:SetStatusBarTexture(BAR_TEXTURE)
xpBar:SetStatusBarColor(0.6, 0.4, 1, 1) -- PURPLE
xpBar:SetFrameLevel(2)

-- Rested Bar (Blue - Background layer)
local restedBar = CreateFrame("StatusBar", nil, mainFrame)
restedBar:SetAllPoints(xpBar)
restedBar:SetStatusBarTexture(BAR_TEXTURE)
restedBar:SetStatusBarColor(0.2, 0.6, 1, 0.5) -- TRANSPARENT BLUE
restedBar:SetFrameLevel(1)

-- =========================================================
-- TEXT ELEMENTS
-- =========================================================
-- Level Text (Left)
local levelText = xpBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
levelText:SetPoint("LEFT", xpBar, "LEFT", 5, 0)
levelText:SetTextColor(1, 1, 1)

-- XP Values & Kills (Center)
local valueText = xpBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
valueText:SetPoint("CENTER", xpBar, "CENTER", 0, 0)
valueText:SetTextColor(1, 1, 1)

-- Percentage (Right)
local pctText = xpBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
pctText:SetPoint("RIGHT", xpBar, "RIGHT", -5, 0)
pctText:SetTextColor(1, 1, 1)

-- Rested Info (Bottom)
local subText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
subText:SetPoint("TOP", mainFrame, "BOTTOM", 0, -5)
subText:SetTextColor(0.8, 0.8, 0.8)

-- =========================================================
-- LOGIC AND UPDATES
-- =========================================================
local function UpdateStatus()
    local level = UnitLevel("player")
    local currXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    local rested = GetXPExhaustion() or 0

    -- 1. Check Max Level (Hide bar if level 60 or higher)
    if level >= MAX_LEVEL then
        mainFrame:Hide()
        return -- Stop function execution here
    else
        mainFrame:Show()
    end

    -- 2. Calculate XP Gain and Play Sound
    local diff = currXP - lastXP
    if diff > 0 then
        lastGain = diff
        -- Play subtle quest/update sound
        PlaySoundFile("Sound\\Interface\\iQuestUpdate.wav") 
    elseif diff < 0 then
        -- Player probably leveled up (XP reset to 0)
        lastGain = lastGain -- Keep last known estimation
    end
    lastXP = currXP

    -- 3. Visual update of bars
    xpBar:SetMinMaxValues(0, maxXP)
    xpBar:SetValue(currXP)

    restedBar:SetMinMaxValues(0, maxXP)
    restedBar:SetValue(currXP + rested)

    -- 4. Update Texts
    levelText:SetText("Level " .. level)

    -- Calculate remaining mobs
    local remainingXP = maxXP - currXP
    local mobsLeftText = ""
    
    if lastGain > 0 then
        local mobsCount = math.ceil(remainingXP / lastGain)
        -- If number is huge (bug or fresh start), don't show it yet
        if mobsCount < 10000 then 
            mobsLeftText = string.format(" (%d Mobs)", mobsCount)
        end
    end

    valueText:SetText(string.format("%d / %d%s", currXP, maxXP, mobsLeftText))

    -- Percentage Calculation
    local pct = 0
    if maxXP > 0 then pct = (currXP / maxXP) * 100 end
    local totalString = string.format("%.1f%%", pct)
    
    -- Add projected rested percentage in parentheses
    if rested > 0 then
        local restedPct = (rested / maxXP) * 100
        local projected = pct + restedPct
        if projected > 100 then projected = 100 end
        totalString = totalString .. string.format(" (%.1f%%)", projected)
        
        -- Bottom text update
        subText:SetText(string.format("Rested: %.1f%%", restedPct))
    else
        subText:SetText("")
    end
    
    pctText:SetText(totalString)
end

-- =========================================================
-- EVENTS
-- =========================================================
mainFrame:RegisterEvent("PLAYER_XP_UPDATE")
mainFrame:RegisterEvent("PLAYER_LEVEL_UP")
mainFrame:RegisterEvent("UPDATE_EXHAUSTION")
mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

mainFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Reset XP memory on login to avoid calculation bugs
        lastXP = UnitXP("player")
    end
    UpdateStatus()
end)
