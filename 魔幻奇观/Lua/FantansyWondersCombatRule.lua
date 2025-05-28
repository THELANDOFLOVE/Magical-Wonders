print("---------------------------------------------------------------")
print("----------------魔幻奇观合集 Combat Lua Loaded------------------")
print("---------------------------------------------------------------")
include("FLuaVector.lua")
include("PlotIterators")
include("UtilityFunctions")
local g_DoFantansyWSEffect = nil;
function FantansyWSEffectStarted(iType, iPlotX, iPlotY)
	if iType == GameInfoTypes["BATTLETYPE_MELEE"]
	or iType == GameInfoTypes["BATTLETYPE_RANGED"]
	or iType == GameInfoTypes["BATTLETYPE_AIR"]
	or iType == GameInfoTypes["BATTLETYPE_SWEEP"]
	then
		g_DoFantansyWSEffect = {
			attPlayerID = -1,
			attUnitID   = -1,
			defPlayerID = -1,
			defUnitID   = -1,
			attODamage  = 0,
			defODamage  = 0,
			PlotX = iPlotX,
			PlotY = iPlotY,
			bIsCity = false,
			defCityID = -1,
			battleType = iType,
		};
		--print("战斗开始.")
	end
end

GameEvents.BattleStarted.Add(FantansyWSEffectStarted);
function FantansyWSEffectJoined(iPlayer, iUnitOrCity, iRole, bIsCity)
	if g_DoFantansyWSEffect == nil
	or Players[ iPlayer ] == nil or not Players[ iPlayer ]:IsAlive()
	or (not bIsCity and Players[ iPlayer ]:GetUnitByID(iUnitOrCity) == nil)
	or (bIsCity and (Players[ iPlayer ]:GetCityByID(iUnitOrCity) == nil or iRole == GameInfoTypes["BATTLEROLE_ATTACKER"]))
	or iRole == GameInfoTypes["BATTLEROLE_BYSTANDER"]
	then
		return;
	end
	if bIsCity then
		g_DoFantansyWSEffect.defPlayerID = iPlayer;
		g_DoFantansyWSEffect.defCityID = iUnitOrCity;
		g_DoFantansyWSEffect.bIsCity = bIsCity;
	elseif iRole == GameInfoTypes["BATTLEROLE_ATTACKER"] then
		g_DoFantansyWSEffect.attPlayerID = iPlayer;
		g_DoFantansyWSEffect.attUnitID = iUnitOrCity;
		g_DoFantansyWSEffect.attODamage = Players[ iPlayer ]:GetUnitByID(iUnitOrCity):GetDamage();
	elseif iRole == GameInfoTypes["BATTLEROLE_DEFENDER"] or iRole == GameInfoTypes["BATTLEROLE_INTERCEPTOR"] then
		g_DoFantansyWSEffect.defPlayerID = iPlayer;
		g_DoFantansyWSEffect.defUnitID = iUnitOrCity;
		g_DoFantansyWSEffect.defODamage = Players[ iPlayer ]:GetUnitByID(iUnitOrCity):GetDamage();
	end
	
	-- Prepare for Capture Unit!
	if not bIsCity and g_DoFantansyWSEffect.battleType == GameInfoTypes["BATTLETYPE_MELEE"]
	and Players[g_DoFantansyWSEffect.attPlayerID] ~= nil and Players[g_DoFantansyWSEffect.attPlayerID]:GetUnitByID(g_DoFantansyWSEffect.attUnitID) ~= nil
	and Players[g_DoFantansyWSEffect.defPlayerID] ~= nil and Players[g_DoFantansyWSEffect.defPlayerID]:GetUnitByID(g_DoFantansyWSEffect.defUnitID) ~= nil
	then
		local attPlayer = Players[g_DoFantansyWSEffect.attPlayerID];
		local attUnit   = attPlayer:GetUnitByID(g_DoFantansyWSEffect.attUnitID);
		local defPlayer = Players[g_DoFantansyWSEffect.defPlayerID];
		local defUnit   = defPlayer:GetUnitByID(g_DoFantansyWSEffect.defUnitID);
	
		if attUnit:GetCaptureChance(defUnit) > 0 then
			local unitClassType = defUnit:GetUnitClassType();
			local unitPlot = defUnit:GetPlot();
			local unitOriginalOwner = defUnit:GetOriginalOwner();
		
			local sCaptUnitName = nil;
			if defUnit:HasName() then
				sCaptUnitName = defUnit:GetNameNoDesc();
			end
			
			local unitLevel = defUnit:GetLevel();
			local unitEXP   = attUnit:GetExperience();
			local attMoves = attUnit:GetMoves();
			print("attacking Unit remains moves:"..attMoves);
		
			tCaptureSPUnits = {unitClassType, unitPlot, g_DoFantansyWSEffect.attPlayerID, unitOriginalOwner, sCaptUnitName, unitLevel, unitEXP, attMoves};
		end
	end
end
GameEvents.BattleJoined.Add(FantansyWSEffectJoined);
function FantansyWSEffectEffect()
 	 --Defines and status checks
	if g_DoFantansyWSEffect == nil or Players[ g_DoFantansyWSEffect.defPlayerID ] == nil
	or Players[ g_DoFantansyWSEffect.attPlayerID ] == nil or not Players[ g_DoFantansyWSEffect.attPlayerID ]:IsAlive()
	or Players[ g_DoFantansyWSEffect.attPlayerID ]:GetUnitByID(g_DoFantansyWSEffect.attUnitID) == nil
	or Players[ g_DoFantansyWSEffect.attPlayerID ]:GetUnitByID(g_DoFantansyWSEffect.attUnitID):IsDead()
	or Map.GetPlot(g_DoFantansyWSEffect.PlotX, g_DoFantansyWSEffect.PlotY) == nil
	then
		return;
	end
	
	local attPlayerID = g_DoFantansyWSEffect.attPlayerID;
	local attPlayer = Players[ attPlayerID ];
	local defPlayerID = g_DoFantansyWSEffect.defPlayerID;
	local defPlayer = Players[ defPlayerID ];
	
	local attUnit = attPlayer:GetUnitByID(g_DoFantansyWSEffect.attUnitID);
	local attPlot = attUnit:GetPlot();
	
	local plotX = g_DoFantansyWSEffect.PlotX;
	local plotY = g_DoFantansyWSEffect.PlotY;
	local batPlot = Map.GetPlot(plotX, plotY);
	local batType = g_DoFantansyWSEffect.battleType;
	
	local bIsCity = g_DoFantansyWSEffect.bIsCity;
	local defUnit = nil;
	local defPlot = nil;
	local defCity = nil;
	
	local attFinalUnitDamage = attUnit:GetDamage();
	local defFinalUnitDamage = 0;
	local attUnitDamage = attFinalUnitDamage - g_DoFantansyWSEffect.attODamage;
	local defUnitDamage = 0;
	
	if not bIsCity and defPlayer:GetUnitByID(g_DoFantansyWSEffect.defUnitID) then
		defUnit = defPlayer:GetUnitByID(g_DoFantansyWSEffect.defUnitID);
		defPlot = defUnit:GetPlot();
		defFinalUnitDamage = defUnit:GetDamage();
		defUnitDamage = defFinalUnitDamage - g_DoFantansyWSEffect.defODamage;
	elseif bIsCity and defPlayer:GetCityByID(g_DoFantansyWSEffect.defCityID) then
		defCity = defPlayer:GetCityByID(g_DoFantansyWSEffect.defCityID);
	end
	
	g_DoFantansyWSEffect = nil;
		--Complex Effects Only for Human VS AI(reduce time and enhance stability)
	if not attPlayer:IsHuman() and not defPlayer:IsHuman() then
		return;
	end
	-- Not for Barbarins
	if attPlayer:IsBarbarian() then
		return;
	end

    local MamToothID = GameInfo.UnitPromotions["PROMOTION_MAMMOTH_TOOTH"].ID
	local BlackGuardID = GameInfo.UnitPromotions["PROMOTION_SON_OF_NAGGAROND"].ID
	local JungleOverlordID = GameInfo.UnitPromotions["PROMOTION_JUNGLE_OVERLORD"].ID
	local JungleOverlordExID = GameInfo.UnitPromotions["PROMOTION_JUNGLE_OVERLORD_EX"].ID
	local PromotionGrymloqID = GameInfo.UnitPromotions["PROMOTION_GRYMLOQ"].ID
	local PromotionGeltblomID = GameInfo.UnitPromotions["PROMOTION_GELTBLOM"].ID
	local PromotionGeltblomBonusID = GameInfo.UnitPromotions["PROMOTION_GELTBLOM_BONUS"].ID
	local PromotionGargantulzanID = GameInfo.UnitPromotions["PROMOTION_GARGANTULZAN"].ID
	local TombstrikeID = GameInfo.UnitPromotions["PROMOTION_Herald_of_Djaf"].ID
	local WrathCreatorID = GameInfo.UnitPromotions["PROMOTION_WRATH_CREATOR"].ID

	---------------------猛犸牙导弹：免疫空军游猎伤害
	if not bIsCity and not attUnit:IsDead() and not defUnit:IsDead() and defUnit:IsCombatUnit()
    and defUnit:IsHasPromotion(MamToothID)
	and batType == GameInfoTypes["BATTLETYPE_SWEEP"]
	then
	print ("Apocalypse Tank Deffend Airsweep!")
	
	print ("Airsweep and the defender is Apocalypse Tank!")
	
	local attDamageInflicted = defUnit:GetRangeCombatDamage(defUnit,nil,false) * 0.5
	local defDamageInflicted = attUnit:GetRangeCombatDamage(defUnit,nil,false)
	
	------------Defender exempt from damage

	defDamageInflicted = 0
	print ("This Apocalypse Tank unit is exempted from Air-sweep damage!")

	
	------------In case of the AA unit is a melee unit
	if not defUnit:IsRanged() then
		attDamageInflicted = defDamageInflicted * 0.25;
	end
	
	---------------fix embarked unit bug
	if defUnit:IsEmbarked() then
		attDamageInflicted = 1;
		print ("Air-sweep embarked unit!");
	end
	
	local defDamageInflicted = attUnit:GetCombatDamage(defUnitStrength, attUnitStrength, defUnit:GetDamage(),false,false, false)
	
	--------------Death Animation
	defUnit:PushMission(MissionTypes.MISSION_DIE_ANIMATION)
	attUnit:PushMission(MissionTypes.MISSION_DIE_ANIMATION)
	
	------------Notifications
	local text = nil;
	local attUnitName = attUnit:GetName();
	local defUnitName = defUnit:GetName();
	
	if     attDamageInflicted >= attUnit:GetCurrHitPoints() then
		attDamageInflicted = attUnit:GetCurrHitPoints();
		local eUnitType = attUnit:GetUnitType();
		UnitDeathCounter(defPlayerID, attPlayerID, eUnitType);
		print ("Airsweep Unit died!")
		
		if     defPlayerID == Game.GetActivePlayer() then
			text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_AIRSWEEP_KILLED_ENEMY_FIGHTER", attUnitName, defUnitName);
		elseif attPlayerID == Game.GetActivePlayer() then
			text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_AIRSWEEP_KILLED_BY_ENEMY", attUnitName, defUnitName);
		end
	elseif attDamageInflicted > 0 then
		attDamageInflicted = math.ceil(attDamageInflicted);
		attUnit:ChangeExperience(4)
		if     attPlayerID == Game.GetActivePlayer() then
			text = Locale.ConvertTextKey( "TXT_KEY_SP_NOTIFICATION_AIRSWEEP_TO_ENEMY", attUnitName, defUnitName, tostring(attDamageInflicted));
		end
	end
	
	if attPlayer:IsHuman() then
		Events.GameplayAlertMessage( text )
	end
	
	print ("Air Sweep Damage Dealt: "   ..attDamageInflicted);
	print ("Air Sweep Damage Received: "..-defDamageInflicted);
	
	attUnit:ChangeDamage(attDamageInflicted,defPlayer);
	defUnit:SetDamage(defUnit:GetDamage() - defDamageInflicted,attPlayer);
	end

	---------------------纳迦隆德之子：近战攻击反伤
	if not bIsCity and not attUnit:IsDead() and not defUnit:IsDead() and defUnit:IsHasPromotion(BlackGuardID)
	and batType == GameInfoTypes["BATTLETYPE_MELEE"]
	then
		if  15 >= attUnit:GetCurrHitPoints() then
			local DamageFinal = attUnit:GetCurrHitPoints();
			local eUnitType = attUnit:GetUnitType();
			UnitDeathCounter(defPlayerID, attUnit:GetOwner(), eUnitType);
		end
		attUnit:ChangeDamage(15, defPlayer)
	end

	---------------------丛林霸主：攻击后根据造成的伤害恢复生命，最高不超过15
	if not bIsCity then
		if attUnit:IsHasPromotion(JungleOverlordID) or attUnit:IsHasPromotion(JungleOverlordExID) then
			local attheal = math.min(15, defUnitDamage)
			attUnit:ChangeDamage(-attheal)
			print("SuckBloodAndHeal:"..attheal)
		end
	end
	
	---------------------横扫千军诗章：近战同格穿透
-- 	local SequenceofAnnihilation = GameInfoTypes.PROMOTION_SEQUENCE_OF_ANNIHILATION
--    ------ Collateral damage (both melee and ranged)!
-- 	    if attUnit:IsHasPromotion(SequenceofAnnihilation) 
-- 		and batPlot:GetNumUnits() > 1 then
-- 		-- print("Melee or Ranged attack and Available for Collateral Damage!")
-- 		local unitCount = batPlot:GetNumUnits()
-- 		for i = 0, unitCount - 1, 1 do
-- 			local pFoundUnit = batPlot:GetUnit(i)
-- 			if (pFoundUnit and pFoundUnit ~= defUnit and pFoundUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR) then
-- 				local pPlayer = Players[pFoundUnit:GetOwner()]
-- 				if PlayersAtWar(attPlayer,pPlayer) then
-- 					local CollDamageOri = 0;
-- 					if batType == GameInfoTypes["BATTLETYPE_MELEE"] then
-- 						local attUnitStrength = attUnit:GetMaxAttackStrength(attPlot, defPlot, defUnit);
			
-- 						local pFoundUnitStrength = pFoundUnit:GetMaxDefenseStrength(batPlot, attUnit);
				
-- 						CollDamageOri = attUnit:GetCombatDamage(attUnitStrength, pFoundUnitStrength, attFinalUnitDamage, false, false, false);
-- 					else
-- 						CollDamageOri = attUnit:GetRangeCombatDamage(pFoundUnit,nil,false);
-- 					end
							
-- 					local text = nil;
-- 					local attUnitName = attUnit:GetName();
-- 					local defUnitName = pFoundUnit:GetName();
					

-- 					local CollDamageFinal = math.floor(CollDamageOri);
-- 					if     CollDamageFinal >= pFoundUnit:GetCurrHitPoints() then
-- 						CollDamageFinal = pFoundUnit:GetCurrHitPoints();
-- 						local eUnitType = pFoundUnit:GetUnitType();
-- 						UnitDeathCounter(attPlayerID, pFoundUnit:GetOwner(), eUnitType);
						
-- 						-- Notification
-- 						if     defPlayerID == Game.GetActivePlayer() then
-- 							-- local heading = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_UNIT_DESTROYED_SHORT")
-- 							text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_COLL_DAMAGE_DEATH", attUnitName, defUnitName);
-- 							-- defPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC , text, heading, plotX, plotY)
-- 						elseif attPlayerID == Game.GetActivePlayer() then
-- 							text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_COLL_DAMAGE_ENEMY_DEATH", attUnitName, defUnitName);
-- 						end
-- 					elseif CollDamageFinal > 0 then
-- 						-- Notification
-- 						if     defPlayerID == Game.GetActivePlayer() then
-- 							text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_COLL_DAMAGE", attUnitName, defUnitName, CollDamageFinal);
-- 						elseif attPlayerID == Game.GetActivePlayer() then
-- 							text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_COLL_DAMAGE_ENEMY", attUnitName, defUnitName, CollDamageFinal);
-- 						end
-- 					end
-- 					if text then
-- 						Events.GameplayAlertMessage( text );
-- 					end
-- 					pFoundUnit:ChangeDamage(CollDamageFinal,attPlayer)
-- 				end
-- 			end
-- 		end
-- 	end
	
	---------------------伊奇之迅：50%概率返还全部攻击次数和1移动力
	local commitPercent = 0.51
	local percent = commitPercent * 10000
	
	local randomNum = math.random(1,10000)
	print("--randomNum--"..randomNum.."--commitPercent--"..percent)
	
	if not bIsCity then
		if attUnit and not attUnit:IsDead() 
		and (attUnit:IsHasPromotion(PromotionGrymloqID)) then
			if randomNum <= percent then
				print("--true--")
				attUnit:SetMadeAttack(false);
				attUnit:SetMoves(attUnit:MovesLeft() + GameDefines["MOVE_DENOMINATOR"])
				local hex = ToHexFromGrid(Vector2(plotX, plotY))
				Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("[COLOR_NEGATIVE_TEXT]Now We Hunt![ENDCOLOR]"))
				
				if attPlayer:IsHuman() then
					Events.GameplayAlertMessage( Locale.ConvertTextKey( "TXT_KEY_MESSAGE_PROMOTION_GRYMLOQ", attUnit:GetName()) )
				end
			end
		end
	end
	
	---------------------猎群之首：杀敌返还全部攻击次数和1移动力
	if defUnit and attUnit:IsHasPromotion(PromotionGeltblomID) or attUnit:IsHasPromotion(PromotionGeltblomBonusID) then
		print ("DefUnit Damage:"..defFinalUnitDamage);
		if  defUnitDamage >= 35 then
			attUnit:SetMoves(attUnit:MovesLeft()+GameDefines["MOVE_DENOMINATOR"]);
			attUnit:SetMadeAttack(false);
		end
 	end
	
	---------------------无前狂怒：每次战斗获得递增晋升
	if attUnit and not attUnit:IsDead() and attUnit:IsHasPromotion(PromotionGargantulzanID) then
		if attUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF4)  then
         	attUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF5"], true)
		 	attUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF4"], false)
		end
		if attUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF3)  then
         	attUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF4"], true)
		 	attUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF3"], false)
		end
		if attUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF2)  then
         	attUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF3"], true)
		 	attUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF2"], false)
		end
		if attUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF1)  then
         	attUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF2"], true)
		 	attUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF1"], false)
		end
		if (not attUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF1)) 
	     	and (not attUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF2)) 
		 	and (not attUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF3))
		 	and (not attUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF4))
		 	and (not attUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF5)) then
         	attUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF1"], true)
		end
	elseif not bIsCity then
		if not defUnit:IsDead() and defUnit:IsHasPromotion(PromotionGargantulzanID) then
			if defUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF4)  then
         		defUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF5"], true)
		 		defUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF4"], false)
			end
			if defUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF3)  then
         		defUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF4"], true)
		 		defUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF3"], false)
			end
			if defUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF2)  then
        		defUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF3"], true)
				defUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF2"], false)
			end
			if defUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF1)  then
        		defUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF2"], true)
				defUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF1"], false)
			end
			if (not defUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF1)) 
	     		and (not defUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF2)) 
		 		and (not defUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF3))
		 		and (not defUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF4))
		 		and (not defUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN_BUFF5)) then
         		defUnit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF1"], true)
			end
		end
	end
	
	---------------------古墓之击：近战范围溅射并对波及目标施加DEBUFF
	if (attUnit:IsHasPromotion(TombstrikeID)) then
		for i = 0, 5 do
			local adjPlot = Map.PlotDirection(plotX, plotY, i)
			if (adjPlot ~= nil and not adjPlot:IsCity()) then
				print("Available for AOE Damage!")
	
				local pUnit = adjPlot:GetUnit(0)
				if pUnit and pUnit:GetDomainType() == DomainTypes.DOMAIN_LAND then
					local pCombat = pUnit:GetBaseCombatStrength()
					local pPlayer = Players[pUnit:GetOwner()]
					
					if PlayersAtWar(attPlayer, pPlayer) then
						local SplashDamageOri = defUnitDamage
						
						local AOEmod = 0.5
							
						local text = nil;
						local attUnitName = attUnit:GetName();
						local defUnitName = pUnit:GetName();
							
						local SplashDamageFinal = math.floor(SplashDamageOri * AOEmod);
						if     SplashDamageFinal >= pUnit:GetCurrHitPoints() then
							SplashDamageFinal = pUnit:GetCurrHitPoints();
							local eUnitType = pUnit:GetUnitType();
							UnitDeathCounter(attPlayerID, pUnit:GetOwner(), eUnitType);
								
							if     defPlayerID == Game.GetActivePlayer() then
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_DEATH", attUnitName, defUnitName);
							elseif attPlayerID == Game.GetActivePlayer() then
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_ENEMY_DEATH", attUnitName, defUnitName);
							end
						elseif SplashDamageFinal > 0 then
							if     defPlayerID == Game.GetActivePlayer() then
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE", attUnitName, defUnitName, SplashDamageFinal);
							elseif attPlayerID == Game.GetActivePlayer() then
								text = Locale.ConvertTextKey("TXT_KEY_SP_NOTIFICATION_SPLASH_DAMAGE_ENEMY", attUnitName, defUnitName, SplashDamageFinal);
							end
						end
						if text then
							Events.GameplayAlertMessage( text );
						end
						pUnit:ChangeDamage(SplashDamageFinal, attPlayer)
						if not pUnit:IsDead() then
							pUnit:SetHasPromotion(WrathCreatorID, true)
						end
						print("Splash Damage="..SplashDamageFinal)
					end
				end
			end
		end
	end
	---------------------古墓之击：对主目标施加DEBUFF
	if not bIsCity then
		if  not defUnit:IsDead() and attUnit:IsHasPromotion(TombstrikeID) then
			defUnit:SetHasPromotion(WrathCreatorID, true)
		end
	end
	
end
GameEvents.BattleFinished.Add(FantansyWSEffectEffect)
----------------------------------------------------------------------------------------------------------------------
-- 戒灵：黑息每回合伤害相邻敌军
----------------------------------------------------------------------------------------------------------------------
-- function NazgulNearbyUnitsLostHP(playerID)
-- 	local player = Players[playerID]
-- 	local NazgulID = GameInfo.UnitPromotions["PROMOTION_Nightmare_Advent"].ID

-- 	if player == nil then
-- 		return
-- 	end
	
-- 	if player:IsBarbarian() or player:IsMinorCiv() then
--     	return
-- 	end

-- 	for unit in player:Units() do 	
-- 		if unit:IsHasPromotion(NazgulID) then	
-- 			local plot = unit:GetPlot()
-- 			local plotX = plot:GetX()
-- 			local plotY = plot:GetY()
-- 			for i = 0, 5 do
-- 				local adjPlot = Map.PlotDirection(plotX, plotY, i)
-- 				if (adjPlot ~= nil and not adjPlot:IsCity()) then
-- 					local pUnit = adjPlot:GetUnit(0)
-- 					if pUnit and (pUnit:GetDomainType() == DomainTypes.DOMAIN_LAND or pUnit:GetDomainType() == DomainTypes.DOMAIN_SEA) then
-- 						local pCombat = pUnit:GetBaseCombatStrength()
-- 						local pPlayer = Players[pUnit:GetOwner()]
-- 						if PlayersAtWar(player, pPlayer) then									
-- 							local SplashDamageFinal = 15;
-- 							if     SplashDamageFinal >= pUnit:GetCurrHitPoints() then
-- 								SplashDamageFinal = pUnit:GetCurrHitPoints();
-- 								local eUnitType = pUnit:GetUnitType();
-- 								UnitDeathCounter(playerID, pUnit:GetOwner(), eUnitType);
-- 							end
-- 							pUnit:ChangeDamage(SplashDamageFinal, player)
-- 							print("Nazgul Splash Damage="..SplashDamageFinal)
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end
-- GameEvents.PlayerDoTurn.Add(NazgulNearbyUnitsLostHP)
----------------------------------------------------------------------------------------------------------------------
-- 戒灵：黑息扣除移动力
----------------------------------------------------------------------------------------------------------------------
function NazgulBlackBreath(iPlayer)
	local pPlayer = Players[iPlayer]
	for pUnit in pPlayer:Units() do
		if  pUnit:IsHasPromotion(GameInfo.UnitPromotions["PROMOTION_Nightmare_Advent"].ID) then
			for pAdjPlot in PlotAreaSpiralIterator(pUnit:GetPlot(),1, SECTOR_NORTH, DIRECTION_CLOCKWISE, DIRECTION_OUTWARDS, CENTRE_INCLUDE) do
        		for iVal = 0,(pAdjPlot:GetNumUnits() - 1) do
				local loopUnit = pAdjPlot:GetUnit(iVal)
					if loopUnit:GetOwner() ~= iPlayer and (loopUnit:GetDomainType() == DomainTypes.DOMAIN_LAND or loopUnit:GetDomainType() == DomainTypes.DOMAIN_SEA) then
						if Teams[pPlayer:GetTeam()]:IsAtWar(Players[loopUnit:GetOwner()]:GetTeam()) then
							loopUnit:ChangeMoves(-180)				
				        end
				    end
				end
			end
	    end
	end
end
GameEvents.PlayerDoneTurn.Add(NazgulBlackBreath)
----------------------------------------------------------------------------------------------------------------------
-- 洛瑟恩海卫：海岸、沿河地块晋升加成
----------------------------------------------------------------------------------------------------------------------
function SeaGuardRiverCoastBonus(playerID, unitID, unitX, unitY)
	local player = Players[playerID]
	local StormRidersID = GameInfo.UnitPromotions["PROMOTION_Storm_Riders"].ID
	local SeaGuardBonusID = GameInfo.UnitPromotions["PROMOTION_SEA_GUARD_BOUNS"].ID
	if (player:IsAlive() and not (player:IsBarbarian()) and not (player:IsMinorCiv())) then 
		local unit = player:GetUnitByID(unitID)
		if (unit:GetPlot() and (unit:IsHasPromotion(SeaGuardBonusID) or unit:IsHasPromotion(StormRidersID))) then
			local plot = unit:GetPlot()
			if (plot:IsAdjacentToShallowWater() or plot:IsRiverSide()) then
				if not (unit:IsHasPromotion(SeaGuardBonusID)) then	
					unit:SetHasPromotion(SeaGuardBonusID, true)
					unit:SetHasPromotion(StormRidersID, false)
				end
			else
				if unit:IsHasPromotion(SeaGuardBonusID) then
					unit:SetHasPromotion(SeaGuardBonusID, false)
					unit:SetHasPromotion(StormRidersID, true)
				end
			end
		end
	end
end
GameEvents.UnitSetXY.Add(SeaGuardRiverCoastBonus)
----------------------------------------------------------------------------------------------------------------------
-- 野生暴龙：根据时代变更战斗力
----------------------------------------------------------------------------------------------------------------------
function FeralCarnosaurCombatStrength()
	for i,player in pairs(Players) do
		local combat_str = 30
		if (player:GetCurrentEra()==GameInfoTypes.ERA_ANCIENT) then combat_str = 30
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_CLASSICAL) then combat_str = 35
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_MEDIEVAL) then combat_str = 50
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_RENAISSANCE) then combat_str = 60
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_INDUSTRIAL) then combat_str = 80
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_MODERN) then combat_str = 100
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_WORLDWAR) then combat_str = 150
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_POSTMODERN) then combat_str = 200
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_INFORMATION) then combat_str = 250
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_FUTURE) then combat_str = 300
		else combat_str = 30 end
        for unit in player:Units() do
			if (unit:GetUnitType()==GameInfoTypes.UNIT_FERAL_CARNOSAUR) then
				unit:SetBaseCombatStrength(combat_str)
			end
		end
    end
end
Events.ActivePlayerTurnStart.Add(FeralCarnosaurCombatStrength)
Events.SerialEventUnitCreated.Add(FeralCarnosaurCombatStrength)
GameEvents.TeamSetEra.Add(FeralCarnosaurCombatStrength)
----------------------------------------------------------------------------------------------------------------------
-- 丛林霸主：丛林、森林地貌晋升加成
----------------------------------------------------------------------------------------------------------------------
-- function FeralCarnosaurJungleBonus(playerID, unitID, unitX, unitY)
-- 	local player = Players[playerID]
-- 	local JungleOverlordNotBonusID = GameInfo.UnitPromotions["PROMOTION_JUNGLE_OVERLORD"].ID
-- 	local JungleOverlordBonusID = GameInfo.UnitPromotions["PROMOTION_JUNGLE_OVERLORD_EX"].ID
-- 	if (player:IsAlive() and not (player:IsBarbarian()) and not (player:IsMinorCiv())) then 
-- 		local unit = player:GetUnitByID(unitID)
-- 		if (unit:GetPlot() and (unit:IsHasPromotion(JungleOverlordBonusID) or unit:IsHasPromotion(JungleOverlordNotBonusID))) then
-- 			local plot = unit:GetPlot()
-- 			if (plot:GetFeatureType() ==GameInfoTypes.FEATURE_JUNGLE or plot:GetFeatureType() ==GameInfoTypes.FEATURE_FOREST) then
-- 				if not (unit:IsHasPromotion(JungleOverlordBonusID)) then	
-- 					unit:SetHasPromotion(JungleOverlordBonusID, true)
-- 					unit:SetHasPromotion(JungleOverlordNotBonusID, false)
-- 				end
-- 			else
-- 				if unit:IsHasPromotion(JungleOverlordBonusID) then
-- 					unit:SetHasPromotion(JungleOverlordBonusID, false)
-- 					unit:SetHasPromotion(JungleOverlordNotBonusID, true)
-- 				end
-- 			end
-- 		end
-- 	end
-- end
-- GameEvents.UnitSetXY.Add(FeralCarnosaurJungleBonus)
----------------------------------------------------------------------------------------------------------------------
-- 野生暴龙：屏蔽冲锋晋升
----------------------------------------------------------------------------------------------------------------------
function FeralCarnosaurCanHavePromotion(iPlayer, iUnit, iPromotionType)
  local pUnit = Players[iPlayer]:GetUnitByID(iUnit)

  if iPromotionType == GameInfoTypes.PROMOTION_CHARGE_1 then
  if pUnit:GetUnitType() == GameInfoTypes["UNIT_FERAL_CARNOSAUR"]  then 
  return false
     end
  end
    return true
end
GameEvents.CanHavePromotion.Add(FeralCarnosaurCanHavePromotion)
----------------------------------------------------------------------------------------------------------------------
-- 猎群之首：赋予掠食集群晋升
----------------------------------------------------------------------------------------------------------------------
-- local LustriaMonsterID = GameInfo.UnitPromotions["PROMOTION_LUSTRIA_MONSTER"].ID
-- local PromotionGeltblom2ID = GameInfo.UnitPromotions["PROMOTION_GELTBLOM"].ID
-- local PromotionGeltblomBonus2ID = GameInfo.UnitPromotions["PROMOTION_GELTBLOM_BONUS"].ID

-- function CheckGeltblom(pPlayer)
-- 	local GeltblomCheck = 0;
-- 	for pUnit in pPlayer:Units() do
-- 		if pUnit:IsHasPromotion(PromotionGeltblom2ID) then
-- 			GeltblomCheck = 1;
-- 			break
-- 		end
-- 	end
-- 	return GeltblomCheck;
-- end

-- function GeltblomOther(playerID)
-- 	local pPlayer = Players[playerID]
-- 		local GeltblomCheck = CheckGeltblom(pPlayer)
-- 		if GeltblomCheck == 1 then
-- 			for pUnit in pPlayer:Units() do
-- 				local Patronage = 0;
-- 				if (pUnit:GetDomainType() == DomainTypes.DOMAIN_LAND) and pUnit:IsCombatUnit() and not pUnit:IsEmbarked() and not pUnit:IsHasPromotion(PromotionGeltblom2ID) and pUnit:IsHasPromotion(LustriaMonsterID) then 
-- 					for sUnit in pPlayer:Units() do
-- 						if sUnit:IsHasPromotion(PromotionGeltblom2ID) then
-- 							if Map.PlotDistance(pUnit:GetX(), pUnit:GetY(), sUnit:GetX(), sUnit:GetY()) < 3 then
-- 								Patronage = 1;
-- 							end
-- 						end
-- 					end			
-- 					if Patronage == 1 then
-- 						if not pUnit:IsHasPromotion(PromotionGeltblomBonus2ID) then
-- 							pUnit:SetHasPromotion(PromotionGeltblomBonus2ID, true)
-- 						end
-- 					else
-- 						if pUnit:IsHasPromotion(PromotionGeltblomBonus2ID) and not pUnit:IsHasPromotion(PromotionGeltblom2ID) then
-- 							pUnit:SetHasPromotion(PromotionGeltblomBonus2ID, false)
-- 						end
-- 					end		
-- 				else
-- 					if pUnit:IsHasPromotion(PromotionGeltblomBonus2ID) and not pUnit:IsHasPromotion(PromotionGeltblom2ID) then
-- 						pUnit:SetHasPromotion(PromotionGeltblomBonus2ID, false)
-- 					end
-- 				end
-- 			end
-- 		end
-- 	--end
-- end
-- GameEvents.UnitSetXY.Add(GeltblomOther) 
-- Events.SerialEventUnitCreated.Add(GeltblomOther)
----------------------------------------------------------------------------------------------------------------------
-- 无前狂怒：赋予人造意志晋升
----------------------------------------------------------------------------------------------------------------------
function FeralCarnosaurAntiDebuffPromotion(iPlayer, iUnit) 
	local pUnit = Players[iPlayer]:GetUnitByID(iUnit)
	local PromotionGargantulzan2ID = GameInfo.UnitPromotions["PROMOTION_GARGANTULZAN"].ID
	local PromotionAntiDebuffID = GameInfo.UnitPromotions["PROMOTION_ANTI_DEBUFF"].ID
	
	if pUnit:IsHasPromotion(PromotionGargantulzan2ID) then
		pUnit:SetHasPromotion(PromotionAntiDebuffID, true)
	end
end
GameEvents.UnitPromoted.Add(FeralCarnosaurAntiDebuffPromotion)
----------------------------------------------------------------------------------------------------------------------
-- 无前狂怒：回合结束清除狂怒层数
----------------------------------------------------------------------------------------------------------------------
function GargantulzanCombatDoTurn(playerID)
	local player = Players[playerID]
	if  player:IsAlive() then
		for unit in player:Units() do
			if unit:IsHasPromotion(GameInfoTypes.PROMOTION_GARGANTULZAN)  then
			   unit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF1"], false)
			   unit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF2"], false)
			   unit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF3"], false)
			   unit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF4"], false)
			   unit:SetHasPromotion(GameInfoTypes["PROMOTION_GARGANTULZAN_BUFF5"], false)
			end
		end
	end
end
GameEvents.PlayerDoTurn.Add(GargantulzanCombatDoTurn)
----------------------------------------------------------------------------------------------------------------------
-- 赤色潮汐：回合结束恢复2格范围内步兵单位生命
----------------------------------------------------------------------------------------------------------------------
-- local UnionHealID = GameInfo.UnitPromotions["PROMOTION_UNION_BEHEMOTH"].ID

-- function ApoctankDoneTurn(playerID)
-- 	local player = Players[playerID];
--     if player == nil then return end;
--     if (not player:IsAlive()) then return end;
-- 	if player:IsBarbarian() or player:IsMinorCiv() then return end;
	
--     for unit in player:Units() do
--         if unit:IsHasPromotion( UnionHealID ) then
--             local iunit = GameInfo.Units[unit:GetUnitType()]; 
-- 			local plot = unit:GetPlot();
--             local ihealth_bonus = 0;

--             local unitCount = plot:GetNumUnits();
--             local uniqueRange = 2;
-- 			if unitCount >= 1 then
-- 				for i = 0, unitCount-1, 1 do
-- 					local pFoundUnit = plot:GetUnit(i)
-- 					if pFoundUnit ~= nil and pFoundUnit:GetID() ~= unit:GetID() then
-- 						local pPlayer = Players[pFoundUnit:GetOwner()];
-- 						if pPlayer == player and pFoundUnit:IsHasPromotion(GameInfoTypes.PROMOTION_INFANTRY_COMBAT) or pFoundUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GUNPOWDER_INFANTRY_COMBAT) then
-- 							pFoundUnit:ChangeDamage(-20);
-- 						end
-- 					end
-- 				end
-- 			end
            
-- 			for dx = -uniqueRange, uniqueRange, 1 do
-- 				for dy = -uniqueRange, uniqueRange, 1 do
-- 					local adjPlot = Map.PlotXYWithRangeCheck(plot:GetX(), plot:GetY(), dx, dy, uniqueRange);
--                     if (adjPlot ~= nil) then
-- 			    	    unitCount = adjPlot:GetNumUnits();
-- 			    	    if unitCount >= 1 then
-- 			    	    	for i = 0, unitCount-1, 1 do
-- 			    	    		local pFoundUnit = adjPlot:GetUnit(i);
-- 			    	    		if pFoundUnit ~= nil and pFoundUnit:GetID() ~= unit:GetID() then
-- 			    	    			local pPlayer = Players[pFoundUnit:GetOwner()];
-- 			    	    			if pPlayer == player and pFoundUnit:IsHasPromotion(GameInfoTypes.PROMOTION_INFANTRY_COMBAT) or pFoundUnit:IsHasPromotion(GameInfoTypes.PROMOTION_GUNPOWDER_INFANTRY_COMBAT) then
--                                         pFoundUnit:ChangeDamage(-20);
-- 			    	    			end
-- 			    	    		end
-- 			    	    	end
-- 			    	    end
--                     end
-- 			    end
--             end

-- 		end
-- 	end
-- end
-- GameEvents.PlayerDoneTurn.Add(ApoctankDoneTurn);
----------------------------------------------------------------------------------------------------------------------
-- 乌沙比特：根据时代变更战斗力
----------------------------------------------------------------------------------------------------------------------
function UshabtiCombatStrength()
	for i,player in pairs(Players) do
		local combat_str = 30
		if (player:GetCurrentEra()==GameInfoTypes.ERA_ANCIENT) then combat_str = 30
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_CLASSICAL) then combat_str = 35
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_MEDIEVAL) then combat_str = 45
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_RENAISSANCE) then combat_str = 55
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_INDUSTRIAL) then combat_str = 70
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_MODERN) then combat_str = 90
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_WORLDWAR) then combat_str = 140
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_POSTMODERN) then combat_str = 180
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_INFORMATION) then combat_str = 240
		elseif (player:GetCurrentEra()==GameInfoTypes.ERA_FUTURE) then combat_str = 300
		else combat_str = 30 end
        for unit in player:Units() do
			if (unit:GetUnitType()==GameInfoTypes.UNIT_USHABTI) then
				unit:SetBaseCombatStrength(combat_str)
			end
		end
    end
end
Events.ActivePlayerTurnStart.Add(UshabtiCombatStrength)
Events.SerialEventUnitCreated.Add(UshabtiCombatStrength)
GameEvents.TeamSetEra.Add(UshabtiCombatStrength)
----------------------------------------------------------------------------------------------------------------------
-- 乌沙比特：神赐华服驻扎城市产出
----------------------------------------------------------------------------------------------------------------------
local iCityBonusGameSpeed = ((GameInfo.GameSpeeds[Game.GetGameSpeedType()].BuildPercent)/100)
function UshabtiDoneTurn(playerID)
	local player = Players[playerID];
    if player == nil then return end;
    if (not player:IsAlive()) then return end;
	if player:IsBarbarian() or player:IsMinorCiv() then return end;
	local pEraType = player:GetCurrentEra();
	local pEraID = GameInfo.Eras[pEraType].ID;
	
	for unit in player:Units() do
		if unit:IsHasPromotion(GameInfoTypes["PROMOTION_Herald_of_Djaf"]) then
		local plot = unit:GetPlot();
			if plot:GetPlotCity() and player:GetCityByID(plot:GetPlotCity()) then
				local city = plot:GetPlotCity();
				local iCityBonus = (2 * (pEraID + 1) * iCityBonusGameSpeed);
				player:ChangeFaith(iCityBonus);
				player:ChangeGoldenAgeProgressMeter(iCityBonus);
				
				local hex = ToHexFromGrid(Vector2(plot:GetX(), plot:GetY()));
				Events.AddPopupTextEvent(HexToWorld(hex), Locale.ConvertTextKey("[COLOR_WHITE]+{1_Num}[ENDCOLOR][ICON_PEACE][NEWLINE][COLOR_YIELD_GOLD]+{2_Num}[ENDCOLOR][ICON_GOLDEN_AGE]", iCityBonus, iCityBonus));
				Events.GameplayFX(hex.x, hex.y, -1);
			end
		end
	end
end
GameEvents.PlayerDoneTurn.Add(UshabtiDoneTurn);
----------------------------------------------------------------------------------------------------------------------
-- 乌沙比特：灵魂国度范围内单位死亡自身回血
----------------------------------------------------------------------------------------------------------------------
function UshabtiSoulKingdom(iPlayer, iUnit, iUnitType, iX, iY, bDelay, iByPlayer)
	local pPlayer = Players[iPlayer]
	local pUnit = pPlayer:GetUnitByID(iUnit)		
	
	if iPlayer == -1  then return end
	if pUnit == -1  then return end	
	if not pUnit:IsCombatUnit() then return end

    local Plot =  pUnit:GetPlot()		
	for pAdjacentPlot in PlotAreaSweepIterator(Plot, 5, SECTOR_NORTH, DIRECTION_CLOCKWISE, DIRECTION_OUTWARDS, CENTRE_EXCLUDE) do
		for iVal = 0,(pAdjacentPlot:GetNumUnits() - 1) do
			local loopUnit = pAdjacentPlot:GetUnit(iVal)
			if	loopUnit:IsHasPromotion(GameInfoTypes.PROMOTION_Herald_of_Djaf) then
				loopUnit:ChangeDamage(-25)
			end
        end
	end
end
GameEvents.UnitPrekill.Add(UshabtiSoulKingdom)
----------------------------------------------------------------------------------------------------------------------------
-- 乌沙比特：回合结束消除创世神之怒效果
----------------------------------------------------------------------------------------------------------------------------
function UshabtiEffect(playerID)
	local player = Players[playerID]

	if player == nil then
		return
	end
	
	local WrathCreatorID = GameInfo.UnitPromotions["PROMOTION_WRATH_CREATOR"].ID

	for unit in player:Units() do
		if unit:IsHasPromotion(WrathCreatorID) then
			unit:SetHasPromotion(WrathCreatorID, false)
		end
	end
end
GameEvents.PlayerDoneTurn.Add(UshabtiEffect)
----------------------------------------------------------------------------------------------------------------------