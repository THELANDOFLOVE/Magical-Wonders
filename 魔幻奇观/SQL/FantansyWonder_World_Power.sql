--------------------------------------------------------------------------------------------------------------------
-- 世界强权健康度
--------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ROG_GlobalUserSettings (Type text default null, Value integer default 0);
INSERT INTO Improvement_ResourceType_Yields (ResourceType,	ImprovementType,					YieldType,				Yield)
SELECT	 'RESOURCE_WHEAT', 'IMPROVEMENT_POLDER', 'YIELD_HEALTH', 1 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);--圩田改造小麦健康度兼容

INSERT INTO Building_LakePlotYieldChanges (BuildingType,	YieldType,	Yield)
SELECT	 'BUILDING_EMERALD_POOLS', 'YIELD_HEALTH', 2 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);--祖母绿水池湖泊给予健康度

INSERT INTO Building_SpecialistYieldChanges (BuildingType,	SpecialistType,	YieldType,	Yield)
SELECT	 'BUILDING_EMERALD_POOLS', 'SPECIALIST_SCIENTIST', 'YIELD_HEALTH', 1 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL --强权额外给予科学家健康度
SELECT	 'BUILDING_EMERALD_POOLS', 'SPECIALIST_DOCTOR', 'YIELD_SCIENCE', 1 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);--兼容强权医学家产出

INSERT INTO Building_YieldModifiers (BuildingType,	YieldType,	Yield)
SELECT	 'BUILDING_EMERALD_POOLS', 'YIELD_HEALTH', 5 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);--祖母绿水池全局健康加成
--------------------------------------------------------------------------------------------------------------------
-- 健康度或医学家替换
--------------------------------------------------------------------------------------------------------------------
DELETE FROM Building_YieldChanges WHERE BuildingType='BUILDING_EMERALD_POOLS' AND EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1); 
INSERT INTO Building_YieldChanges(BuildingType,	YieldType,	Yield)
SELECT	 'BUILDING_EMERALD_POOLS',	'YIELD_FOOD', 0 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL --祖母绿水池食物替换健康
SELECT	 'BUILDING_EMERALD_POOLS', 'YIELD_HEALTH', 8 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL --祖母绿水池食物替换健康
SELECT	 'BUILDING_EMERALD_POOLS_BUFF', 'YIELD_HEALTH', 1 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);--兼容强额外给予健康度

UPDATE Buildings SET SpecialistType = 'SPECIALIST_DOCTOR', SpecialistCount = 3, PrereqTech = 'TECH_NATURAL_MEDICINE'
WHERE	 Type='BUILDING_EMERALD_POOLS' AND EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);--强权科学家替换医学家并额外给予专家槽位
--------------------------------------------------------------------------------------------------------------------