include("IconSupport")
include("InstanceManager")
include("UtilityFunctions.lua")
local gargantuaSelectedPromo = nil
local gargantuaTargetUnitID = -1
local gargantuaPromoList = {
    {Type = "PROMOTION_GRYMLOQ", IconAtlas = "EX_PROMOTION_A_ATLAS", IconIndex = 37, Text = "TXT_KEY_PROMOTION_GRYMLOQ"},
    {Type = "PROMOTION_GELTBLOM", IconAtlas = "EX_PROMOTION_A_ATLAS", IconIndex = 37, Text = "TXT_KEY_PROMOTION_GELTBLOM"},
    {Type = "PROMOTION_GARGANTULZAN", IconAtlas = "EX_PROMOTION_A_ATLAS", IconIndex = 37, Text = "TXT_KEY_PROMOTION_GARGANTULZAN"}
}
function GargantuaShowPromoDialog(unitID)
    gargantuaTargetUnitID = unitID
    print("GargantuaShowPromoDialog called with unitID: ", unitID)
    GargantuaInitializeDialog()
    ContextPtr:SetHide(false)
end
function GargantuaHidePromoDialog()
    print("GargantuaHidePromoDialog called")
    ContextPtr:SetHide(true)
    gargantuaSelectedPromo = nil
end
function GargantuaGetHelpText(promoID)
    local promo = GameInfo.UnitPromotions[promoID]
    if promo then
        print("GargantuaGetHelpText: Found promo with ID: ", promoID)
        return promo.Help or ""
    end
    print("GargantuaGetHelpText: Promo with ID: ", promoID, " not found")
    return ""
end
function GargantuaOnPromoSelected(promoType)
    print("GargantuaOnPromoSelected called with promoType: ", promoType)
    gargantuaSelectedPromo = promoType
    local promoInfo = nil
    for _, promo in ipairs(gargantuaPromoList) do
        if promo.Type == promoType then
            promoInfo = promo
            break
        end
    end
    if promoInfo then
        print("GargantuaOnPromoSelected: Found promoInfo for promoType: ", promoType)
        print("Selected IconIndex: ", promoInfo.IconIndex)
        print("Selected IconAtlas: ", promoInfo.IconAtlas)
        local promo = GameInfo.UnitPromotions[promoInfo.Type]
        if promo then
            Controls.GargantuaSelectList1:GetButton():SetText(Locale.ConvertTextKey(promoInfo.Text))
            local helpTextKey = promo.Help or ""
            Controls.GargantuaIconButton1:SetToolTipString(Locale.ConvertTextKey(helpTextKey))
            IconHookup(promoInfo.IconIndex, 256, promoInfo.IconAtlas, Controls.GargantuaPortrait1)
            print("GargantuaOnPromoSelected: Successfully set icon and text for promo: ", promoInfo.Type)
        else
            print("GargantuaOnPromoSelected: Error: Promotion info not found for type ", promoInfo.Type)
        end
    else
        print("GargantuaOnPromoSelected: Error: promoInfo not found for promoType: ", promoType)
    end
end
function GargantuaOnConfirm()
    print("GargantuaOnConfirm called")
    if gargantuaSelectedPromo and gargantuaTargetUnitID ~= -1 then
        local pPlayer = Players[Game.GetActivePlayer()]
        local pUnit = pPlayer:GetUnitByID(gargantuaTargetUnitID)
        if pUnit then
            local oldPromotion = GameInfo.UnitPromotions.PROMOTION_OLDONES_BLESS
            local newPromotion = GameInfo.UnitPromotions[gargantuaSelectedPromo]
            if oldPromotion and newPromotion then
                pUnit:SetHasPromotion(oldPromotion.ID, false)
                pUnit:SetHasPromotion(newPromotion.ID, true)
                print("Unit promoted successfully: ", newPromotion.Description)
            else
                print("GargantuaOnConfirm: Error: Old or new promotion info not found.")
            end
        else
            print("GargantuaOnConfirm: Error: Unit not found with ID ", gargantuaTargetUnitID)
        end
    else
        print("GargantuaOnConfirm: Error: selectedPromo or targetUnitID is invalid")
    end
    GargantuaHidePromoDialog()
end
function GargantuaInitializeDialog()
    local pPlayer = Players[Game.GetActivePlayer()]
    local leader = GameInfo.Leaders[pPlayer:GetLeaderType()]
    if leader then
        IconHookup(leader.PortraitIndex, 128, leader.IconAtlas, Controls.GargantuaLeaderPortrait)
        print("GargantuaInitializeDialog: Set leader portrait successfully")
    else
        print("GargantuaInitializeDialog: Error: Leader not found for player ", pPlayer:GetName())
    end
    IconHookup(11, 256, "EXPANSION2_PROMOTION_ATLAS", Controls.GargantuaPortrait1)
    GargantuaUpdatePromoList(Controls.GargantuaSelectList1, GargantuaOnPromoSelected)
    Controls.GargantuaSelectList1:GetButton():LocalizeAndSetText("TXT_KEY_PROMO_DIALOG_TITLE")
    Controls.GargantuaSelectList1:CalculateInternals()
    print("GargantuaInitializeDialog: Dialog initialization completed")
end
function GargantuaUpdatePromoList(ConUCSelectList, OnPromoSelectedFuc)
    print("GargantuaUpdatePromoList called")
    ConUCSelectList:ClearEntries()
    for k, v in pairs(gargantuaPromoList) do
        local entry = {}
        ConUCSelectList:BuildEntry("InstanceOne", entry)
        local promo = GameInfo.UnitPromotions[v.Type]
        if promo then
            entry.Button:SetVoid1(v.Type)
            entry.Button:SetText(Locale.ConvertTextKey(v.Text))
            print("GargantuaUpdatePromoList: Setting icon for promo: ", v.Type)
            print("IconIndex: ", v.IconIndex)
            print("IconAtlas: ", v.IconAtlas)
            IconHookup(v.IconIndex, 256, v.IconAtlas, entry.PromoIcon)

            entry.Button:RegisterCallback(Mouse.eLClick, function()
                print("Button clicked with promoType: ", v.Type)
                GargantuaOnPromoSelected(v.Type)
            end)
        else
            print("GargantuaUpdatePromoList: Error: Promotion info not found for type ", v.Type)
        end
    end
    ConUCSelectList:RegisterSelectionCallback(OnPromoSelectedFuc)
    print("GargantuaUpdatePromoList: Promotion list updated and callback registered")
end
function GargantuaInitialize()
    Controls.GargantuaConfirmButton:RegisterCallback(Mouse.eLClick, GargantuaOnConfirm)
    ContextPtr:SetHide(true)
    print("GargantuaInitialize called. Confirm button callback registered and dialog hidden.")
end
GameEvents.CityTrained.Add(function(iPlayer, iCity, iUnit, bGold, bFaith)
    local pPlayer = Players[iPlayer]
    local pUnit = pPlayer:GetUnitByID(iUnit)
    if pUnit and
       pUnit:GetUnitType() == GameInfo.Units.UNIT_FERAL_CARNOSAUR.ID and
       pUnit:IsHasPromotion(GameInfo.UnitPromotions.PROMOTION_OLDONES_BLESS.ID)
    then
        if not pPlayer:IsHuman() then
            local promotions = {"PROMOTION_GELTBLOM", "PROMOTION_GARGANTULZAN", "PROMOTION_GRYMLOQ"}
            pUnit:SetHasPromotion(GameInfo.UnitPromotions.PROMOTION_OLDONES_BLESS.ID, false)
            for _, promoType in ipairs(promotions) do
                local promo = GameInfo.UnitPromotions[promoType]
                if promo then
                    pUnit:SetHasPromotion(promo.ID, true)
                    print("CityTrained event: Auto - promoted unit with promo: ", promo.Description)
                else
                    print("CityTrained event: Error: Promotion info not found for type ", promoType)
                end
            end
        elseif iPlayer == Game.GetActivePlayer() then
            print("CityTrained event: Human player's unit found. Calling GargantuaShowPromoDialog for unitID: ", iUnit)
            GargantuaShowPromoDialog(iUnit)
        end
    end
end)
GargantuaInitialize()