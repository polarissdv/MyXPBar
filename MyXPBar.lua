-- =========================================================
-- CONFIGURATION
-- =========================================================
local WIDTH = 500
local HEIGHT = 24
local BAR_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"
local MAX_LEVEL = 60 -- La barre disparaîtra à ce niveau

-- Variables pour le calcul des mobs
local lastXP = UnitXP("player")
local lastGain = 0

-- =========================================================
-- CRÉATION DU CADRE (FRAME)
-- =========================================================
local mainFrame = CreateFrame("Frame", "MyXPBarFrame", UIParent)
mainFrame:SetSize(WIDTH, HEIGHT)
mainFrame:SetPoint("CENTER", 0, -200)
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:SetClampedToScreen(true)

-- Déplacement (Shift + Clic Gauche)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then self:StartMoving() end
end)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)

-- Fond noir
local bg = mainFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(mainFrame)
bg:SetTexture(0, 0, 0, 0.6)

-- =========================================================
-- LES BARRES (VIOLETTE ET BLEUE)
-- =========================================================
-- Barre d'XP (Violette)
local xpBar = CreateFrame("StatusBar", nil, mainFrame)
xpBar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
xpBar:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, 0)
xpBar:SetStatusBarTexture(BAR_TEXTURE)
xpBar:SetStatusBarColor(0.6, 0.4, 1, 1) -- VIOLET
xpBar:SetFrameLevel(2)

-- Barre de Repos (Bleue - Arrière plan)
local restedBar = CreateFrame("StatusBar", nil, mainFrame)
restedBar:SetAllPoints(xpBar)
restedBar:SetStatusBarTexture(BAR_TEXTURE)
restedBar:SetStatusBarColor(0.2, 0.6, 1, 0.5) -- BLEU TRANSPARENT
restedBar:SetFrameLevel(1)

-- =========================================================
-- LES TEXTES
-- =========================================================
-- Niveau (Gauche)
local levelText = xpBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
levelText:SetPoint("LEFT", xpBar, "LEFT", 5, 0)
levelText:SetTextColor(1, 1, 1)

-- Valeurs XP & Kills (Centre)
local valueText = xpBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
valueText:SetPoint("CENTER", xpBar, "CENTER", 0, 0)
valueText:SetTextColor(1, 1, 1)

-- Pourcentage (Droite)
local pctText = xpBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
pctText:SetPoint("RIGHT", xpBar, "RIGHT", -5, 0)
pctText:SetTextColor(1, 1, 1)

-- Info Reposé (Dessous)
local subText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
subText:SetPoint("TOP", mainFrame, "BOTTOM", 0, -5)
subText:SetTextColor(0.8, 0.8, 0.8)

-- =========================================================
-- LOGIQUE ET MISE A JOUR
-- =========================================================
local function UpdateStatus()
    local level = UnitLevel("player")
    local currXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    local rested = GetXPExhaustion() or 0

    -- 1. Vérification Niveau Max (Cache la barre si lvl 60+)
    if level >= MAX_LEVEL then
        mainFrame:Hide()
        return -- On arrête la fonction ici, pas besoin de calculer le reste
    else
        mainFrame:Show()
    end

    -- 2. Calcul du gain d'XP et Son
    local diff = currXP - lastXP
    if diff > 0 then
        lastGain = diff
        -- Joue un son discret de quête/update
        PlaySoundFile("Sound\\Interface\\iQuestUpdate.wav") 
    elseif diff < 0 then
        -- Le joueur a probablement gagné un niveau (XP retombe à 0)
        lastGain = lastGain -- On garde la dernière estimation connue
    end
    lastXP = currXP

    -- 3. Mise à jour visuelle des barres
    xpBar:SetMinMaxValues(0, maxXP)
    xpBar:SetValue(currXP)

    restedBar:SetMinMaxValues(0, maxXP)
    restedBar:SetValue(currXP + rested)

    -- 4. Textes
    levelText:SetText("Niveau " .. level)

    -- Calcul des mobs restants
    local remainingXP = maxXP - currXP
    local mobsLeftText = ""
    
    if lastGain > 0 then
        local mobsCount = math.ceil(remainingXP / lastGain)
        -- Si le nombre est énorme (bug ou début), on n'affiche rien
        if mobsCount < 10000 then 
            mobsLeftText = string.format(" (%d Mobs)", mobsCount)
        end
    end

    valueText:SetText(string.format("%d / %d%s", currXP, maxXP, mobsLeftText))

    -- Pourcentage
    local pct = 0
    if maxXP > 0 then pct = (currXP / maxXP) * 100 end
    local totalString = string.format("%.1f%%", pct)
    
    -- Ajout du pourcentage reposé entre parenthèses
    if rested > 0 then
        local restedPct = (rested / maxXP) * 100
        local projected = pct + restedPct
        if projected > 100 then projected = 100 end
        totalString = totalString .. string.format(" (%.1f%%)", projected)
        
        -- Texte du bas
        subText:SetText(string.format("Reposé: %.1f%%", restedPct))
    else
        subText:SetText("")
    end
    
    pctText:SetText(totalString)
end

-- =========================================================
-- ÉVÉNEMENTS
-- =========================================================
mainFrame:RegisterEvent("PLAYER_XP_UPDATE")
mainFrame:RegisterEvent("PLAYER_LEVEL_UP")
mainFrame:RegisterEvent("UPDATE_EXHAUSTION")
mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

mainFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Réinitialise la mémoire d'XP à la connexion pour éviter des bugs de calcul
        lastXP = UnitXP("player")
    end
    UpdateStatus()
end)