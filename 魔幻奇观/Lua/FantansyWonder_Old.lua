----------------------------------------------------------------------------------------------------------------------------
-- 魔幻奇观：旧版山脉定义
----------------------------------------------------------------------------------------------------------------------------
-- function Mountaineering(iPlayer)
-- 	for iPlot = 0, Map.GetNumPlots() - 1 do
-- 		local plot = Map.GetPlotByIndex(iPlot);
-- 		if plot:IsMountain() and plot:GetFeatureType() == -1 then
-- 			plot:SetFeatureType(GameInfoTypes.FEATURE_SKI);
-- 		end
-- 	end
-- end
-- Events.SequenceGameInitComplete.Add(Mountaineering);
----------------------------------------------------------------------------------------------------------------------------
-- 魔幻奇观：建筑给予政策
----------------------------------------------------------------------------------------------------------------------------
function FantansyWonderPolicies(playerID)
	local player = Players[playerID]
	
	if player == nil or player:IsBarbarian() or player:IsMinorCiv() or player:GetNumCities() <= 0 then
		return
	end
	
	if player:CountNumBuildings(GameInfoTypes["BUILDING_EIGHT_PEAKS"]) > 0 and 
	not player:HasPolicy(GameInfo.Policies["POLICY_EIGHT_PEAKS"].ID) 
	then 
		player:SetNumFreePolicies(1)
		player:SetNumFreePolicies(0)
		player:SetHasPolicy(GameInfo.Policies["POLICY_EIGHT_PEAKS"].ID,true)	 
	end
	
	if player:CountNumBuildings(GameInfoTypes["BUILDING_LAURELORN"]) > 0 and 
	not player:HasPolicy(GameInfo.Policies["POLICY_LAURELORN"].ID) 
	then 
		player:SetNumFreePolicies(1)
		player:SetNumFreePolicies(0)
		player:SetHasPolicy(GameInfo.Policies["POLICY_LAURELORN"].ID,true)	 
	end
	
	if player:CountNumBuildings(GameInfoTypes["BUILDING_GLACESTA"]) > 0 and 
	not player:HasPolicy(GameInfo.Policies["POLICY_GLACESTA"].ID) 
	then 
		player:SetNumFreePolicies(1)
		player:SetNumFreePolicies(0)
		player:SetHasPolicy(GameInfo.Policies["POLICY_GLACESTA"].ID,true)	 
	end
	
	if player:CountNumBuildings(GameInfoTypes["BUILDING_BASTION_STAIR"]) > 0 and 
	not player:HasPolicy(GameInfo.Policies["POLICY_BASTION_STAIR"].ID) 
	then 
		player:SetNumFreePolicies(1)
		player:SetNumFreePolicies(0)
		player:SetHasPolicy(GameInfo.Policies["POLICY_BASTION_STAIR"].ID,true)	 
	end
	
	if player:CountNumBuildings(GameInfoTypes["BUILDING_ISENGARD"]) > 0 and 
	not player:HasPolicy(GameInfo.Policies["POLICY_ISENGARD"].ID) 
	then 
		player:SetNumFreePolicies(1)
		player:SetNumFreePolicies(0)
		player:SetHasPolicy(GameInfo.Policies["POLICY_ISENGARD"].ID,true)	 
	end
	
	if player:CountNumBuildings(GameInfoTypes["BUILDING_MORIA"]) > 0 and 
	not player:HasPolicy(GameInfo.Policies["POLICY_MORIA"].ID) 
	then 
		player:SetNumFreePolicies(1)
		player:SetNumFreePolicies(0)
		player:SetHasPolicy(GameInfo.Policies["POLICY_MORIA"].ID,true)	 
	end
	
	if player:CountNumBuildings(GameInfoTypes["BUILDING_SHANGYANG"]) > 0 and 
	not player:HasPolicy(GameInfo.Policies["POLICY_SHANGYANG"].ID) 
	then 
		player:SetNumFreePolicies(1)
		player:SetNumFreePolicies(0)
		player:SetHasPolicy(GameInfo.Policies["POLICY_SHANGYANG"].ID,true)	 
	end
	
	if player:CountNumBuildings(GameInfoTypes["BUILDING_TOWER_OF_MALEKITH"]) > 0 and 
	not player:HasPolicy(GameInfo.Policies["POLICY_NAGGAROND"].ID) 
	then 
		player:SetNumFreePolicies(1)
		player:SetNumFreePolicies(0)
		player:SetHasPolicy(GameInfo.Policies["POLICY_NAGGAROND"].ID,true)	 
	end
	
	if player:CountNumBuildings(GameInfoTypes["BUILDING_WONDERFUL_HEAVEN"]) > 0 and 
	not player:HasPolicy(GameInfo.Policies["POLICY_WONDERFUL_HEAVEN"].ID) 
	then 
		player:SetNumFreePolicies(1)
		player:SetNumFreePolicies(0)
		player:SetHasPolicy(GameInfo.Policies["POLICY_WONDERFUL_HEAVEN"].ID,true)	 
	end
	
	if player:CountNumBuildings(GameInfoTypes["BUILDING_NONGSHENG"]) > 0 and 
	not player:HasPolicy(GameInfo.Policies["POLICY_NONGSHENG"].ID) 
	then 
		player:SetNumFreePolicies(1)
		player:SetNumFreePolicies(0)
		player:SetHasPolicy(GameInfo.Policies["POLICY_NONGSHENG"].ID,true)	 
	end
	
	if player:CountNumBuildings(GameInfoTypes["BUILDING_LOTHERN"]) > 0 and 
	not player:HasPolicy(GameInfo.Policies["POLICY_LOTHERN"].ID) 
	then 
		player:SetNumFreePolicies(1)
		player:SetNumFreePolicies(0)
		player:SetHasPolicy(GameInfo.Policies["POLICY_LOTHERN"].ID,true)	 
	end
	
end
GameEvents.PlayerDoTurn.Add(FantansyWonderPolicies)
----------------------------------------------------------------------------------------------------------------------------
-- 祖母绿水池：境内友军单位回合结束恢复生命
----------------------------------------------------------------------------------------------------------------------------
local EMERALDPOOLS = GameInfoTypes["BUILDING_EMERALD_POOLS"]
function EmeraldpoolsHeal(iPlayer)
	local pPlayer = Players[iPlayer]
	if pPlayer:IsAlive() then
		for pCity in pPlayer:Cities() do
			if pCity:IsHasBuilding(EMERALDPOOLS) then
				for i = 0, pCity:GetNumCityPlots() - 1, 1 do
					local pPlot = pCity:GetCityIndexPlot(i)
					for iPlotUnit = 0, pPlot:GetNumUnits() -1, 1 do
						local pUnit = pPlot:GetUnit(iPlotUnit)
						local iUnitOwner = pUnit:GetOwner()
						if pUnit:GetDamage() ~=0 and pUnit:GetOwner() == iPlayer then 	
							pUnit:ChangeDamage(-25)
						end
					end
				end
			end
		end
	end
end
GameEvents.PlayerDoTurn.Add(EmeraldpoolsHeal)
----------------------------------------------------------------------------------------------------------------------------
local direction_types = {
            DirectionTypes["DIRECTION_NORTHEAST"],
            DirectionTypes["DIRECTION_NORTHWEST"],
            DirectionTypes["DIRECTION_EAST"],
            DirectionTypes["DIRECTION_SOUTHEAST"],
            DirectionTypes["DIRECTION_SOUTHWEST"],
            DirectionTypes["DIRECTION_WEST"]
            }
     
    function Reed_GetNumAdjacentOasis(city)
            local numAdjacentOasis = 0
            if Map.GetPlot(city:GetX(), city:GetY()) then
                    for loop, direction in ipairs(direction_types) do
                            local adjPlot = Map.PlotDirection(city:GetX(), city:GetY(), direction)
                            if adjPlot:GetFeatureType() == GameInfoTypes["FEATURE_SKI"] then      
                                    numAdjacentOasis = numAdjacentOasis + 1
                            end
                    end
            end
           
            return numAdjacentOasis     
    end
	
	function Reed_GetNumAdjacentRiverTiles(city)
            local numAdjacentRiverTiles = 0
            if Map.GetPlot(city:GetX(), city:GetY()) then
                    for loop, direction in ipairs(direction_types) do
                            local adjPlot = Map.PlotDirection(city:GetX(), city:GetY(), direction)
                            if adjPlot:IsRiver() then     
                                    numAdjacentRiverTiles = numAdjacentRiverTiles + 1
                            end
                    end
            end
           
            return numAdjacentRiverTiles     
    end
     
    function Reed_WaterGardensOasis(playerID, unitID, unitX, unitY)
            local player = Players[playerID]
            if player:IsAlive() then
                    for city in player:Cities() do
                            if city:IsHasBuilding(GameInfoTypes["BUILDING_EIGHT_PEAKS"]) and Reed_GetNumAdjacentOasis(city) >= 0 then
                                    city:SetNumRealBuilding(GameInfoTypes["BUILDING_EIGHT_PEAKS_BOUNS"], Reed_GetNumAdjacentOasis(city))
                            end
                    end
            end
    end
    GameEvents.PlayerDoTurn.Add(Reed_WaterGardensOasis)
	function Reed_WaterGardensOasis(playerID, unitID, unitX, unitY)
            local player = Players[playerID]
            if player:IsAlive() then
                    for city in player:Cities() do
                            if city:IsHasBuilding(GameInfoTypes["BUILDING_SHANGYANG"]) and Reed_GetNumAdjacentOasis(city) >= 0 then
                                    city:SetNumRealBuilding(GameInfoTypes["BUILDING_SHANGYANG_BOUNS"], Reed_GetNumAdjacentOasis(city))
                            end
                    end
            end
    end
    GameEvents.PlayerDoTurn.Add(Reed_WaterGardensOasis)
     
    -- function Reed_RiverrunDefense(playerID, unitID, unitX, unitY)
    --         local player = Players[playerID]
    --         if player:IsAlive() then
    --                 for city in player:Cities() do
    --                         if city:IsHasBuilding(GameInfoTypes["BUILDING_MOTHER_RIVER"]) and Reed_GetNumAdjacentRiverTiles(city) >= 4 then
    --                                 city:SetNumRealBuilding(GameInfoTypes["BUILDING_MOTHER_RIVER_BONUS"], 1)
    --                         end
    --                 end
    --         end
    -- end
GameEvents.PlayerDoTurn.Add(Reed_RiverrunDefense)
----------------------------------------------------------------------------------------------------------------------------
local iWonder = GameInfoTypes.BUILDING_BASTION_STAIR
local iMod = ((GameInfo.GameSpeeds[Game.GetGameSpeedType()].BuildPercent)/100)
local iDelta = math.ceil(300 * iMod)
function CityCaptureComplete(oldPlayerID, isCapital, plotX, plotY, newPlayerID, isConquest)
        local pPlayer = Players[newPlayerID]
        if pPlayer:CountNumBuildings(iWonder) > 0 then
                pPlayer:ChangeGoldenAgeProgressMeter(iDelta)
        end
end
GameEvents.CityCaptureComplete.Add(CityCaptureComplete)
----------------------------------------------------------------------------------------------------------------------------
-- function BloodGodTraining(iPlayer)
-- 	local pPlayer = Players[iPlayer]
-- 	if pPlayer:IsAlive() then
-- 		for pUnit in pPlayer:Units() do 
-- 			if pUnit:GetBaseCombatStrength() >= 1 then 
-- 				local pPlot = pUnit:GetPlot() 
-- 				if pPlot:GetPlotCity() and pPlot:GetPlotCity():IsHasBuilding(GameInfoTypes["BUILDING_BASTION_STAIR"]) then
-- 					pUnit:ChangeExperience(5) 
-- 				end
-- 			end
-- 		end
-- 	end
-- end
-- GameEvents.PlayerDoTurn.Add(BloodGodTraining)
----------------------------------------------------------------------------------------------------------------------------
-- function StellarPyramidsSlann(playerID) 
-- 	local player = Players[playerID]
	
-- 	if player == nil or player:IsBarbarian() or player:IsMinorCiv() or player:GetNumCities() <= 0 then
-- 		return
-- 	end

-- 	for city in player:Cities() do
-- 		if city:IsHasBuilding(GameInfoTypes["BUILDING_STELLAR_PYRAMIDS"])  then
-- 			print ("南天星辰金字塔时代加成")
-- 			SlannKnowledge (city,player)
-- 		end
-- 	end
	
-- end
-- GameEvents.PlayerSetEra.Add(StellarPyramidsSlann)
	
-- function SlannKnowledge (city,player)
-- 	local timeNum = player:GetCurrentEra()
-- 	print ("根据时代获取建筑:",timeNum)
-- 	city:SetNumRealBuilding(GameInfoTypes["BUILDING_SLANN_KNOWLEDGE"],timeNum)
-- end
----------------------------------------------------------------------------------------------------------------------------
-- local iBuildingMaelstromClass = GameInfo.BuildingClasses.BUILDINGCLASS_MAELSTROM.ID
-- function SeaPlotDamageCheck(iPlayer)
-- 	local pPlayer = Players[iPlayer]
-- 	local teamID = pPlayer:GetTeam()
-- 	local pPlayerTeam = Teams[teamID]
-- 	if pPlayer:IsAlive() then
-- 		for unit in pPlayer:Units() do
-- 		local plot = unit:GetPlot()
-- 		if plot:IsWater()   then
-- 		if not plot:IsLake() then 
-- 		local eplot = plot
-- 		if ( eplot:GetOwner() ~= iPlayer ) then
-- 		local eOwner = eplot:GetOwner()
-- 		if Players[eOwner] == nil then return end
-- 		local otherPlayer = Players[eOwner]
-- 		local otherTeamID = otherPlayer:GetTeam()
-- 		if pPlayerTeam:IsAtWar(otherTeamID) then
-- 		if otherPlayer:GetBuildingClassCount(iBuildingMaelstromClass) > 0 then
-- 		   unit:ChangeDamage(15)
-- 			end
-- 		  end
-- 	    end
--       end
--      end
--    end
--   end
-- end
-- GameEvents.PlayerDoTurn.Add(SeaPlotDamageCheck)

-- local iBuildingWhirlpoolClass = GameInfo.BuildingClasses.BUILDINGCLASS_WHIRLPOOL.ID
-- function SeaPlotDamageCheck(iPlayer)
-- 	local pPlayer = Players[iPlayer]
-- 	local teamID = pPlayer:GetTeam()
-- 	local pPlayerTeam = Teams[teamID]
-- 	if pPlayer:IsAlive() then
-- 		for unit in pPlayer:Units() do
-- 		local plot = unit:GetPlot()
-- 		if plot:IsWater()   then
-- 		if not plot:IsLake() then 
-- 		local eplot = plot
-- 		if ( eplot:GetOwner() ~= iPlayer ) then
-- 		local eOwner = eplot:GetOwner()
-- 		if Players[eOwner] == nil then return end
-- 		local otherPlayer = Players[eOwner]
-- 		local otherTeamID = otherPlayer:GetTeam()
-- 		if pPlayerTeam:IsAtWar(otherTeamID) then
-- 		if otherPlayer:GetBuildingClassCount(iBuildingWhirlpoolClass) > 0 then
-- 		   unit:ChangeDamage(10)
-- 			end
-- 		  end
-- 	    end
--       end
--      end
--    end
--   end
-- end
-- GameEvents.PlayerDoTurn.Add(SeaPlotDamageCheck)
----------------------------------------------------------------------------------------------------------------------------
-- function BloodGodWar(playerID)
--     local player = Players[playerID]
--     if player:CountNumBuildings(GameInfoTypes["BUILDING_BASTION_STAIR"]) > 0 and player:IsAlive() then
--         for city in player:Cities() do
--             if (city:GetNumBuilding(GameInfoTypes["BUILDING_BLOOD_GOD_WAR"]) > 0) then
--                 city:SetNumRealBuilding(GameInfoTypes["BUILDING_BLOOD_GOD_WAR"], 0);
--             end
--             local spartapopulationAmount = math.floor(city:GetPopulation())
--             city:SetNumRealBuilding(GameInfoTypes["BUILDING_BLOOD_GOD_WAR"], spartapopulationAmount)
--         end
--     end
-- end
-- GameEvents.PlayerDoTurn.Add(BloodGodWar)
----------------------------------------------------------------------------------------------------------------------------
-- local GreatVortex = GameInfoTypes["BUILDING_GREAT_VORTEX_EYES"]
-- local GreatVortexBouns = GameInfoTypes["BUILDING_GREAT_VORTEX_EYES_BOUNS"]
-- function GreatVortexScienceProduction(PlayerID)
-- 	local pPlayer = Players[PlayerID]
-- 	if pPlayer:IsAlive() then
-- 		for pCity in pPlayer:Cities() do
-- 			if pCity:IsHasBuilding(GreatVortex) then
-- 				local CityFaithPerTurn = pCity:GetYieldRate(5, true)
-- 				print("转化类型信仰 : " .. CityFaithPerTurn)
-- 				local ProductionYield = math.floor(CityFaithPerTurn / 5)
-- 				pCity:SetNumRealBuilding(GreatVortexBouns, ProductionYield)
-- 				print("根据信仰转化为产能科研 : " .. ProductionYield)
-- 			end
-- 		end
-- 	end
-- end
-- GameEvents.PlayerDoTurn.Add(GreatVortexScienceProduction)
----------------------------------------------------------------------------------------------------------------------------