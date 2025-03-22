include("FLuaVector.lua")
include("PlotIterators.lua")
include("UtilityFunctions.lua")
----------------------------------------------------------------------------------------------------------------------------
-- 世界强权前置判定
----------------------------------------------------------------------------------------------------------------------------
local GameSpeed = ((GameInfo.GameSpeeds[Game.GetGameSpeedType()].BuildPercent)/100)
function IsUsingWP()
	local WPID = "41450919-c52c-406f-8752-5ea34be32b2d"
	for _, mod in pairs(Modding.GetActivatedMods()) do
		if (mod.ID == WPID) then
			return true
		end
	end
	return false
end
local WpModActive = IsUsingWP()
----------------------------------------------------------------------------------------------------------------------------
-- 魔幻奇观：建造前提
----------------------------------------------------------------------------------------------------------------------------
function FantansyWonderOnlyHunman(iPlayer, iCity, iBuilding)
	if (iBuilding == GameInfoTypes.BUILDING_LUSTRIA) and (iBuilding == GameInfoTypes.BUILDING_QUINTEX) then
		local pPlayer = Players[iPlayer]
		local pCity = pPlayer:GetCityByID(iCity)
		if pPlayer:IsHuman() then	
			return true
		end	
		return false
	end
	return true
end
GameEvents.CityCanConstruct.Add(FantansyWonderOnlyHunman)

-- function LustriaCheck(iPlayer, iCity, iBuilding)
-- 	if (iBuilding == GameInfoTypes.BUILDING_LUSTRIA) then
-- 		local pPlayer = Players[iPlayer]
-- 		local pCity = Players[iPlayer]:GetCityByID(iCity)
-- 		for i = 0, pCity:GetNumCityPlots() - 1, 1 do
-- 		local pPlot = pCity:GetCityIndexPlot(i)
-- 			if pPlot:GetOwner() == iPlayer and (pPlot:GetFeatureType() ==GameInfoTypes.FEATURE_JUNGLE) then	
--     			return true
-- 			end  
-- 		end   
-- 		return false
-- 	end
-- 	return true
-- end
-- GameEvents.CityCanConstruct.Add(LustriaCheck)

function EmeraldPoolsCheck(iPlayer, iCity, iBuilding)
	if (iBuilding == GameInfoTypes.BUILDING_EMERALD_POOLS) then
		local pPlayer = Players[iPlayer]
		local pCity = Players[iPlayer]:GetCityByID(iCity)
		for i = 0, pCity:GetNumCityPlots() - 1, 1 do
		local pPlot = pCity:GetCityIndexPlot(i)
			if pPlot:GetOwner() == iPlayer and pPlot:IsLake() then	
				return true
			end  
		end   
		return false
	end
	return true
end
GameEvents.CityCanConstruct.Add(EmeraldPoolsCheck)

-- function QuintexCheck(iPlayer, iCity, iBuilding)
-- 	if (iBuilding == GameInfoTypes.BUILDING_QUINTEX) then
-- 		local pPlayer = Players[iPlayer]
-- 		local pCity = Players[iPlayer]:GetCityByID(iCity)
-- 		for i = 0, pCity:GetNumCityPlots() - 1, 1 do
-- 		local pPlot = pCity:GetCityIndexPlot(i)
-- 			if pPlot:GetOwner() == iPlayer and pPlot:IsMountain() then	
-- 				return true
-- 			end  
-- 		end   
-- 		return false
-- 	end
-- 	return true
-- end
-- GameEvents.CityCanConstruct.Add(QuintexCheck)
----------------------------------------------------------------------------------------------------------------------------
-- 露丝契亚：伟大守护
----------------------------------------------------------------------------------------------------------------------------
local iBuildingLustriaClass = GameInfo.BuildingClasses.BUILDINGCLASS_LUSTRIA.ID  

-- Function for checking plot damage when a unit moves  
function LustriaPlotDamageCheck(iPlayer, iUnit, iX, iY)  
    local pPlayer = Players[iPlayer]  
    local pUnit = pPlayer:GetUnitByID(iUnit)  
    local teamID = pPlayer:GetTeam()  
    local pPlayerTeam = Teams[teamID]  
    local plot = Map.GetPlot(iX, iY)  

    if plot == nil then  
        return  
    end  
    
    local plotOwner = plot:GetOwner()  -- Store the plot owner for later use  
    local otherPlayer = Players[plotOwner]  

    -- Check if the plot owner is valid and if it's not the player or if the owner is -1 (unowned)  
    if plotOwner == -1 or plotOwner == iPlayer then  
        return  
    end  

    -- Check for valid features on the plot  
    if plot:GetFeatureType() == -1 then  
        return  
    end  

    -- Check if the feature is Jungle  
    if plot:GetFeatureType() == GameInfoTypes.FEATURE_JUNGLE then  
        -- Check for the owner being a human player  
        if otherPlayer:IsHuman() then  
            local otherTeamID = otherPlayer:GetTeam()  
            if pPlayerTeam:IsAtWar(otherTeamID) then  
                if otherPlayer:GetBuildingClassCount(iBuildingLustriaClass) > 0 then  
                    pUnit:ChangeDamage(20)  
                    pUnit:SetMoves(0)  
                end  
            end  
        end  
    end  
end  

-- Function to check building completion  
function OnBuildingCompleted(iPlayer, iCity, iBuilding)  
    local pPlayer = Players[iPlayer]  
    local pCity = pPlayer:GetCity(iCity)  

    -- Check if the completed building is of class BUILDINGCLASS_LUSTRIA  
    if pCity and GameInfo.Buildings[iBuilding].BuildingClass == "BUILDINGCLASS_LUSTRIA" then  
        -- You can now set some flag or trigger an event  
        -- For example: print("Lustria Building completed!")  
    end  
end  

-- Event listeners  
GameEvents.UnitSetXY.Add(LustriaPlotDamageCheck)  
GameEvents.CityConstructed.Add(OnBuildingCompleted)  
----------------------------------------------------------------------------------------------------------------------------
-- 魔幻奇观：建造完成触发
----------------------------------------------------------------------------------------------------------------------------
function FantansyWonderConstructed(iPlayer, iCity, iBuilding)
	local player = Players[iPlayer]
	local city = player:GetCityByID(iCity)

	if player == nil or player:IsMinorCiv() or player:IsBarbarian() then
		return
	end
	
	-- 露丝契亚：生成丛林地貌与木材资源
	if iBuilding == GameInfoTypes["BUILDING_LUSTRIA"] then
		for plot in PlotAreaSpiralIterator(city:Plot(), 5, SECTOR_NORTH, DIRECTION_CLOCKWISE) do
			if plot:GetFeatureType() == -1 and plot:GetResourceType() == -1 and plot:GetImprovementType() == -1 and not plot:IsCity() and not plot:IsWater() and not plot:IsMountain() then
				plot:SetFeatureType(GameInfoTypes.FEATURE_JUNGLE);
			end
			if WpModActive and (plot:GetFeatureType() ==GameInfoTypes.FEATURE_JUNGLE) and plot:GetResourceType() == -1 and plot:GetImprovementType() == -1 then
				plot:SetResourceType(GameInfoTypes.RESOURCE_LUMBER,3)
			end
		end
	end
	
	-- 刚多林：生成圩田设施
	if iBuilding == GameInfoTypes["BUILDING_GONDOLIN"] then
		for plot in PlotAreaSpiralIterator(city:Plot(), 1, SECTOR_NORTH, DIRECTION_CLOCKWISE) do
			if plot:GetFeatureType() == -1 and plot:GetResourceType() == -1 and plot:GetImprovementType() == -1 and not plot:IsCity() and not plot:IsWater() and not plot:IsMountain() then
				plot:SetImprovementType(GameInfoTypes["IMPROVEMENT_POLDER"])
			end
			if (plot:GetFeatureType() ==GameInfoTypes.FEATURE_MARSH) and plot:GetResourceType() == -1 and plot:GetImprovementType() == -1 then
				plot:SetImprovementType(GameInfoTypes["IMPROVEMENT_POLDER"])
			end
			if (plot:GetResourceType() ==GameInfoTypes.RESOURCE_WHEAT) and plot:GetFeatureType() == -1 and plot:GetImprovementType() == -1 then
				plot:SetImprovementType(GameInfoTypes["IMPROVEMENT_POLDER"])
			end
		end
	end
	
	-- 艾森加德：生成锯木厂设施
	if iBuilding == GameInfoTypes["BUILDING_ISENGARD"] then
		for plot in PlotAreaSpiralIterator(city:Plot(), 3, SECTOR_NORTH, DIRECTION_CLOCKWISE) do
			if (plot:GetFeatureType() ==GameInfoTypes.FEATURE_FOREST) and plot:GetResourceType() == -1 and plot:GetImprovementType() == -1 and not plot:IsCity() and not plot:IsWater() and not plot:IsMountain() then
				plot:SetImprovementType(GameInfoTypes["IMPROVEMENT_LUMBERMILL"])
			end
			if WpModActive and (plot:GetFeatureType() ==GameInfoTypes.FEATURE_FOREST) and (plot:GetResourceType() ==GameInfoTypes.RESOURCE_LUMBER) and plot:GetImprovementType() == -1 then
				plot:SetImprovementType(GameInfoTypes["IMPROVEMENT_LUMBERMILL"])
			end
		end
	end
	
	-- 昆泰克斯：给予金钱
	if iBuilding == GameInfoTypes["BUILDING_QUINTEX"] then
		if not WpModActive then
			player:ChangeGold( math.ceil(200 * GameSpeed) )
		elseif WpModActive then
			player:ChangeGold( math.ceil(450 * GameSpeed) )
		end
	end
end 
GameEvents.CityConstructed.Add(FantansyWonderConstructed)
----------------------------------------------------------------------------------------------------------------------------
-- 魔幻奇观：特殊资源加成
----------------------------------------------------------------------------------------------------------------------------
function FantansyWonderResource(playerID)
    local player = Players[playerID]
    if not player or player:IsBarbarian() or player:IsMinorCiv() or player:GetNumCities() <= 0 then
        return
    end
    local wonderBuffs = {
        {resource = "RESOURCE_DINOSAUR", building = "BUILDING_LUSTRIA_DINOSAUR"},
        {resource = "RESOURCE_MEDICINE", building = "BUILDING_EMERALD_POOLS_BUFF"}
    }
    for city in player:Cities() do 
        for _, buff in ipairs(wonderBuffs) do
            local resourceType = GameInfoTypes[buff.resource]
            local buildingType = GameInfoTypes[buff.building]
            local resourceCount = math.max(0, player:GetNumResourceAvailable(resourceType, true))
            local current = city:GetNumRealBuilding(buildingType)
            local desired = resourceCount  
            if current ~= desired then
                city:SetNumRealBuilding(buildingType, desired)
            end
        end
    end
end
GameEvents.CityConstructed.Add(FantansyWonderResource)
-- local ResourceDinosaurID = GameInfoTypes["RESOURCE_DINOSAUR"]  
-- local ResourceMedicineID = GameInfoTypes["RESOURCE_MEDICINE"]  

-- local BuildingLustriaBonusID = GameInfoTypes["BUILDING_LUSTRIA_BONUS"]  
-- local BuildingEmeraldPoolsID = GameInfoTypes["BUILDING_EMERALD_POOLS"]  
-- local BuildingSizeToResources = {  
--     [GameInfoTypes["BUILDING_CITY_SIZE_TOWN"]] = 1,      
--     [GameInfoTypes["BUILDING_CITY_SIZE_SMALL"]] = 2,     
--     [GameInfoTypes["BUILDING_CITY_SIZE_MEDIUM"]] = 3,    
--     [GameInfoTypes["BUILDING_CITY_SIZE_LARGE"]] = 4,     
--     [GameInfoTypes["BUILDING_CITY_SIZE_XL"]] = 5,        
--     [GameInfoTypes["BUILDING_CITY_SIZE_XXL"]] = 6,      
--     [GameInfoTypes["BUILDING_CITY_SIZE_GLOBAL"]] = 7      
-- }  
-- function OnCityConstructed(playerID, cityID, buildingType)  
--     local player = Players[playerID]  
--     local city = player:GetCityByID(cityID)  
--     local resourceChange = 0  
--     if buildingType == BuildingLustriaBonusID then  
--         for buildingID, resourceAmount in pairs(BuildingSizeToResources) do  
--             if city:IsHasBuilding(buildingID) then  
--                 resourceChange = resourceChange + resourceAmount  
--             end  
--         end  
--         player:SetResourceType(GameInfoTypes.RESOURCE_DINOSAUR, resourceChange)  
--     elseif buildingType == BuildingEmeraldPoolsID then  
--         for buildingID, resourceAmount in pairs(BuildingSizeToResources) do  
--             if city:IsHasBuilding(buildingID) then  
--                 resourceChange = resourceChange + resourceAmount  
--             end  
--         end  
--         player:SetResourceType(GameInfoTypes.RESOURCE_MEDICINE, resourceChange) 
--     end  
-- end  
-- GameEvents.CityConstructed.Add(OnCityConstructed)  
----------------------------------------------------------------------------------------------------------------------------
-- 巴拉多：邪眼凝视友方增益
----------------------------------------------------------------------------------------------------------------------------
function BaraddurEyeBuff(playerID, unitID)
local player = Players[playerID]
if player:GetUnitByID(unitID) == nil then return end
local unit = player:GetUnitByID(unitID)
if unit:GetPlot() == nil then return end
local plot = unit:GetPlot()
local plotX = plot:GetX()
local plotY = plot:GetY()
local EvilEyeBuffID = GameInfo.UnitPromotions["PROMOTION_EVILEYE_BUFF"].ID

	if player:CountNumBuildings(GameInfoTypes["BUILDING_BARAD_DUR"])> 0 then
		if unit:IsHasPromotion(EvilEyeBuffID) then
			unit:SetHasPromotion(EvilEyeBuffID, false)
		end
		for city in player:Cities() do
			if city:IsHasBuilding(GameInfoTypes["BUILDING_BARAD_DUR"]) then
			local cPlotX = city:GetX()
			local cPlotY = city:GetY()
				if Map.PlotDistance(plotX, plotY, cPlotX, cPlotY) < 6 then
					if unit:GetDomainType() == DomainTypes.DOMAIN_LAND or unit:GetDomainType() == DomainTypes.DOMAIN_SEA then
						if unit:IsCombatUnit() then
							unit:SetHasPromotion(EvilEyeBuffID, true)
							local hex = ToHexFromGrid(Vector2(plotX, plotY))
							Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("TXT_KEY_PROMOTION_EVILEYE_BUFF"))
						end
					end
				end
			end
		end
	end
end
GameEvents.UnitSetXY.Add(BaraddurEyeBuff)
Events.SerialEventUnitCreated.Add(BaraddurEyeBuff)
----------------------------------------------------------------------------------------------------------------------------
-- 巴拉多：邪眼凝视敌方减益
----------------------------------------------------------------------------------------------------------------------------
local BaraddurID = GameInfoTypes["BUILDING_BARAD_DUR"]
local EvilEyeDebuffID = GameInfoTypes.PROMOTION_EVILEYE_DEBUFF
local g_iBaraddurPlayerID = nil
local g_iBaraddurBuildingPlot = nil

function GetBaraddurPlayerID()
for playerID = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
		local player = Players[playerID]		
		if (player:IsAlive()) then
			for city in player:Cities() do
				if city:IsHasBuilding(BaraddurID) then 
					g_iBaraddurPlayerID = playerID
					g_iBaraddurBuildingPlot = city:Plot()
					return g_iBaraddurPlayerID
				end
			end
		end
	end	
	return nil
end

function IsPlayerAtWarWithBaraddurOwner(playerID)
	local bIsSameWithBaraddur = false
	if playerID ~= g_iBaraddurPlayerID then
		local player = Players[playerID]
		local EvilEyePlayer = Players[g_iBaraddurPlayerID]
		if Teams[player:GetTeam()]:IsAtWar(EvilEyePlayer:GetTeam()) then
			bIsSameWithBaraddur = true
		end
	end
	return bIsSameWithBaraddur
end

function BaraddurCityCaptured(iOldOwner, bIsCapital, iX, iY, iNewOwner, iPop, bConquest)
	local pCity = Map.GetPlot(iX, iY):GetPlotCity()
	if pCity:IsHasBuilding(BaraddurID) then
		local pOldOwner = Players[iOldOwner]
		for unit in pOldOwner:Units() do
			if unit:GetDomainType() == DomainTypes.DOMAIN_LAND or unit:GetDomainType() == DomainTypes.DOMAIN_SEA then
				if unit:IsCombatUnit() then
					unit:SetHasPromotion(EvilEyeBuffID, false)
				end
			end
		end
		iBaraddurOwner = iNewOwner
		local pNewOwner = Players[iNewOwner]
		for unit in pNewOwner:Units() do
			if unit:GetDomainType() == DomainTypes.DOMAIN_LAND or unit:GetDomainType() == DomainTypes.DOMAIN_SEA then
				if unit:IsCombatUnit() and (Map.PlotDistance(pUnit:GetX(), pUnit:GetY(), pBaraddurPlot:GetX(), pBaraddurPlot:GetY()) <= 5) then
					unit:SetHasPromotion(EvilEyeBuffID, true)
				else
					unit:SetHasPromotion(EvilEyeDebuffID, false)
				end
			end
		end
	end
end
GameEvents.CityCaptureComplete.Add(BaraddurCityCaptured)

function BaraddurUnitMove(playerID, unitID, unitX, unitY)
	g_iBaraddurPlayerID = GetBaraddurPlayerID()
	if (g_iBaraddurPlayerID == nil) then
		return
	end
	
	local pPlayer = Players[playerID]
	local pTeam = Teams[pPlayer:GetTeam()]
	if (pPlayer:IsAlive() and IsPlayerAtWarWithBaraddurOwner(playerID) ) then
		local plotDistance = Map.PlotDistance(unitX, unitY, g_iBaraddurBuildingPlot:GetX(), g_iBaraddurBuildingPlot:GetY())
		local unit = pPlayer:GetUnitByID(unitID)
		if unit:GetDomainType() == DomainTypes.DOMAIN_LAND or unit:GetDomainType() == DomainTypes.DOMAIN_SEA then
			if unit:IsCombatUnit() then	
				if plotDistance <= 5 then
					unit:SetHasPromotion(EvilEyeDebuffID, true)
				else 	
					unit:SetHasPromotion(EvilEyeDebuffID, false)		
		    	end
			end
		end
	end
end
GameEvents.UnitSetXY.Add(BaraddurUnitMove)
----------------------------------------------------------------------------------------------------------------------------
-- 艾森加德：每座已开发的锯木厂提供加成
----------------------------------------------------------------------------------------------------------------------------
-- function IsengardIronRing(playerID, city)
-- 	local NumWorkerIsengard = 0
--     if city:IsHasBuilding(GameInfoTypes["BUILDING_ISENGARD"]) then
-- 	    for cityPlot = 0, city:GetNumCityPlots() - 1, 1 do
-- 	    	local plot = city:GetCityIndexPlot(cityPlot)
-- 	    	if plot then
-- 	    		if plot:GetOwner() == playerID then
-- 	    			if city:IsWorkingPlot(plot) then	
-- 	    				if plot:GetImprovementType() == GameInfoTypes["IMPROVEMENT_LUMBERMILL"] then 
-- 	    					NumWorkerIsengard = NumWorkerIsengard + 1
-- 	    				end
-- 						if plot:GetImprovementType() == GameInfoTypes["IMPROVEMENT_BRAZILWOOD_CAMP"] then 
-- 	    					NumWorkerIsengard = NumWorkerIsengard + 1
-- 	    				end
-- 	    			end
-- 	    		end
-- 	    	end
--         end
-- 	end
-- 	return NumWorkerIsengard
-- end

-- function IsengardIndustry(playerID)
-- 	local player = Players[playerID]
-- 	if player:IsAlive() then
-- 		for city in player:Cities() do
-- 			city:SetNumRealBuilding(GameInfoTypes["BUILDING_ISENGARD_BONUS"], IsengardIronRing(playerID, city))
-- 		end
-- 	end
-- end
-- GameEvents.PlayerDoTurn.Add(IsengardIndustry)
----------------------------------------------------------------------------------------------------------------------------
-- 卡萨拜：进入战争给予建筑
----------------------------------------------------------------------------------------------------------------------------
local KaSabarID = GameInfoTypes["BUILDING_KA_SABAR"]  
local KaSabarWarBonusID = GameInfoTypes["BUILDING_BRONZE_WAR"]  
function KaSabarWarHandler(playerID)  
    local player = Players[playerID]  

    if player == nil or player:IsBarbarian() or player:IsMinorCiv() or player:GetNumCities() <= 0 then  
        return  
    end  
    if player:CountNumBuildings(KaSabarID) > 0 then   
        for city in player:Cities() do  
            if city:IsHasBuilding(KaSabarID) then  
                local atWarCount = Teams[player:GetTeam()]:GetAtWarCount(true)  
                if atWarCount > 0 then  
                    if not city:IsHasBuilding(KaSabarWarBonusID) then  
                        city:SetNumRealBuilding(KaSabarWarBonusID, 1)  
                    end  
                else  
                    if city:IsHasBuilding(KaSabarWarBonusID) then  
                        city:SetNumRealBuilding(KaSabarWarBonusID, 0)  
                    end  
                end  
            else        
                if city:IsHasBuilding(KaSabarWarBonusID) then  
                    city:SetNumRealBuilding(KaSabarWarBonusID, 0)  
                end  
            end  
        end  
    end  
end  
function OnDeclareWar(iPlayer, iAgainstTeam, bAggressor)  
    KaSabarWarHandler(iPlayer)  
    KaSabarWarHandler(iAgainstTeam)  
end  
GameEvents.DeclareWar.Add(OnDeclareWar)  
----------------------------------------------------------------------------------------------------------------------------
-- 青铜铸造厂：范围内赤铜提供产出
----------------------------------------------------------------------------------------------------------------------------
function BronzeForgingBonus(iPlayer)
    local pPlayer = Players[iPlayer]
    for pCity in pPlayer:Cities() do
        if pCity:IsHasBuilding(GameInfoTypes.BUILDING_BRONZE_FOUNDRY) then
            local iCityCopper = 0 
            for pPlot in PlotAreaSpiralIterator(pCity:Plot(), 5, SECTOR_NORTH, DIRECTION_CLOCKWISE) do
                if pPlot:GetResourceType() == GameInfoTypes.RESOURCE_COPPER then
                    iCityCopper = iCityCopper + 1
                end
            end
            pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BRONZE_FOUNDRY_BONUS, iCityCopper)
        else
            pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_BRONZE_FOUNDRY_BONUS, 0)
        end
    end
end
GameEvents.PlayerDoTurn.Add(BronzeForgingBonus)
----------------------------------------------------------------------------------------------------------------------------
-- 瑞文戴尔：消耗伟人获得黄金时代点数
----------------------------------------------------------------------------------------------------------------------------
local RivendellID = GameInfoTypes["BUILDING_RIVENDELL"]
function RivendellGreatPeopletBonus(PlayerID, UnitType)
	local pPlayer = Players[PlayerID]
	
	if pPlayer:IsBarbarian() or pPlayer:IsMinorCiv() or pPlayer:GetNumCities() <= 0 then
		return
	end
	
	if pPlayer:IsAlive() then
		for pCity in pPlayer:Cities() do
			if pCity:IsHasBuilding(RivendellID) and not pPlayer:IsGoldenAge() then
			local NowEra = pPlayer:GetCurrentEra()
				pPlayer:ChangeGoldenAgeProgressMeter( math.ceil(( 50 + 25 * ( NowEra - 1 )) * GameSpeed) )
				if pPlayer:IsHuman() then
					Events.GameplayAlertMessage(Locale.ConvertTextKey("TXT_KEY_RIVENDELL_GREAT_PEOPLE_INFO", math.ceil(( 50 + 25 * ( NowEra - 1 )) * GameSpeed)))
				end
			elseif pCity:IsHasBuilding(RivendellID) and pPlayer:IsGoldenAge() then
				pPlayer:ChangeGoldenAgeTurns(1)
				if pPlayer:IsHuman() then
					Events.GameplayAlertMessage(Locale.ConvertTextKey("TXT_KEY_RIVENDELL_GREAT_PEOPLE_GOLDEN_AGE_INFO", 1 ))
				end
			end
		end
	end
end
GameEvents.GreatPersonExpended.Add(RivendellGreatPeopletBonus)
----------------------------------------------------------------------------------------------------------------------------
-- 瑞文戴尔：根据人口增加伟人诞生速率
----------------------------------------------------------------------------------------------------------------------------
function RivendellGreatPeopletRateModifier(playerID)
    local pPlayer = Players[playerID]
	
	if pPlayer:IsBarbarian() or pPlayer:IsMinorCiv() or pPlayer:GetNumCities() <= 0 then
		return
	end
	
    if pPlayer:IsAlive() and pPlayer:CountNumBuildings(GameInfoTypes["BUILDING_RIVENDELL"]) > 0 then
        for city in pPlayer:Cities() do
            if (city:GetNumBuilding(GameInfoTypes["BUILDING_RIVENDELL_BONUS"]) > 0) then
                city:SetNumRealBuilding(GameInfoTypes["BUILDING_RIVENDELL_BONUS"], 0);
            end
            local RivendellPopulation = math.floor(city:GetPopulation()/2)
            city:SetNumRealBuilding(GameInfoTypes["BUILDING_RIVENDELL_BONUS"], RivendellPopulation)
        end
    end
end
GameEvents.PlayerDoTurn.Add(RivendellGreatPeopletRateModifier)
----------------------------------------------------------------------------------------------------------------------------
-- 昆泰克斯古城：进入新时代获得额外金钱
----------------------------------------------------------------------------------------------------------------------------
local QuintexID = GameInfoTypes["BUILDING_QUINTEX"]
function QuintexEraChanged(nEra, PlayerID)
	local pPlayer = Players[PlayerID]
	if pPlayer:IsAlive() then
		for pCity in pPlayer:Cities() do
			if not WpModActive and pCity:IsHasBuilding(QuintexID) then
			local NowEra = pPlayer:GetCurrentEra()
				pPlayer:ChangeGold( math.ceil( 200 + 200 * NowEra * GameSpeed ) )
				if pPlayer:IsHuman() then
					Events.GameplayAlertMessage(Locale.ConvertTextKey("TXT_KEY_QUINTEX_ERA_GOLD_INFO", math.ceil( (200 + 200 * NowEra) * GameSpeed )))
				end
			elseif WpModActive and pCity:IsHasBuilding(QuintexID) then
			local NowEra = pPlayer:GetCurrentEra()
				pPlayer:ChangeGold( math.ceil( 450 + 450 * NowEra * GameSpeed ) )
				if pPlayer:IsHuman() then
					Events.GameplayAlertMessage(Locale.ConvertTextKey("TXT_KEY_QUINTEX_ERA_GOLD_INFO", math.ceil( (450 + 450 * NowEra) * GameSpeed )))
				end
			end
		end
	end
end
Events.SerialEventEraChanged.Add(QuintexEraChanged)
----------------------------------------------------------------------------------------------------------------------------
-- 昆泰克斯古城：进入新时代获得额外资源
----------------------------------------------------------------------------------------------------------------------------
function QuintexEraNum (city,player)
	local EraNum = player:GetCurrentEra()
	city:SetNumRealBuilding(GameInfoTypes["BUILDING_QUINTEX_ERA_BONUS"],EraNum)
end

function QuintexEraResource(playerID) 
	local player = Players[playerID]
	
	if player == nil or player:IsBarbarian() or player:IsMinorCiv() or player:GetNumCities() <= 0 then
		return
	end

	for city in player:Cities() do
		if city:IsHasBuilding(GameInfoTypes["BUILDING_QUINTEX"])  then
			QuintexEraNum (city,player)
		end
	end
end
GameEvents.PlayerSetEra.Add(QuintexEraResource)
----------------------------------------------------------------------------------------------------------------------------
-- 单位命名：升级时保留旧名级
----------------------------------------------------------------------------------------------------------------------------
function SetFantansyWonderUnitsName( iPlayer, iOldUnit,  iNewUnit)
	if Players[ iPlayer ] == nil or not Players[ iPlayer ]:IsAlive()
	or Players[ iPlayer ]:GetUnitByID( iOldUnit ) == nil
	or Players[ iPlayer ]:GetUnitByID( iOldUnit ):IsDead()
	or Players[ iPlayer ]:GetUnitByID( iOldUnit ):IsDelayedDeath()
	or Players[ iPlayer ]:GetUnitByID( iOldUnit ):HasName() 
	then
		return;
	end
	local pUnit = Players[ iPlayer ]:GetUnitByID( iOldUnit );
	if  pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_Bound_Spirit"].ID) then
		pUnit:SetName("TXT_KEY_UNIT_Nazgul"); -- 戒灵
	elseif pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_Herald_of_Djaf"].ID) then
		pUnit:SetName("TXT_KEY_UNIT_USHABTI_NAME0");-- 乌沙比特
	end
end
GameEvents.UnitUpgraded.Add(SetFantansyWonderUnitsName)
----------------------------------------------------------------------------------------------------------------------------