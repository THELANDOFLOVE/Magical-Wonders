include("IconSupport")
include("InstanceManager")
include("UtilityFunctions.lua")

local selectedPromo = nil  
local targetUnitID = -1    
function ShowPromoDialog(unitID)
    targetUnitID = unitID
    ContextPtr:SetHide(false)
end
function HidePromoDialog()
    ContextPtr:SetHide(true)
    selectedPromo = nil
end
function OnPromoSelected(promoType)
    selectedPromo = promoType
end
function OnConfirm()
    if selectedPromo and targetUnitID ~= -1 then
        local pPlayer = Players[Game.GetActivePlayer()]
        local pUnit = pPlayer:GetUnitByID(targetUnitID)
        if pUnit then
            pUnit:SetHasPromotion(GameInfo.UnitPromotions.PROMOTION_OLDONES_BLESS.ID, false)
            pUnit:SetHasPromotion(GameInfo.UnitPromotions[selectedPromo].ID, true)
        end
    end
    HidePromoDialog()
end
function Initialize()
    Controls.Promo1:RegisterCallback(Mouse.eLClick, function() OnPromoSelected("PROMOTION_GRYMLOQ") end)
    Controls.Promo2:RegisterCallback(Mouse.eLClick, function() OnPromoSelected("PROMOTION_GELTBLOM") end)
    Controls.Promo3:RegisterCallback(Mouse.eLClick, function() OnPromoSelected("PROMOTION_GARGANTULZAN") end)
    Controls.ConfirmButton:RegisterCallback(Mouse.eLClick, OnConfirm)
    ContextPtr:SetHide(true)
end
GameEvents.CityTrained.Add(function(iPlayer, iCity, iUnit, bGold, bFaith)
    local pPlayer = Players[iPlayer]
    local pUnit = pPlayer:GetUnitByID(iUnit)
    if pUnit and 
       pUnit:GetUnitType() == GameInfo.Units.UNIT_FERAL_CARNOSAUR.ID and
       pUnit:IsHasPromotion(GameInfo.UnitPromotions.PROMOTION_OLDONES_BLESS.ID) 
    then
        if not pPlayer:IsHuman() then
            pUnit:SetHasPromotion(GameInfo.UnitPromotions.PROMOTION_OLDONES_BLESS.ID, false)
            pUnit:SetHasPromotion(GameInfo.UnitPromotions.PROMOTION_GELTBLOM.ID, true)
            pUnit:SetHasPromotion(GameInfo.UnitPromotions.PROMOTION_GARGANTULZAN.ID, true)
            pUnit:SetHasPromotion(GameInfo.UnitPromotions.PROMOTION_GRYMLOQ.ID, true)
        elseif iPlayer == Game.GetActivePlayer() then
            ShowPromoDialog(iUnit)
        end
    end
end)
Initialize()