--------------------------------------------------------------------------------------------------------------------
-- 巴拉多黑塔：世界强权新军事建筑兼容
--------------------------------------------------------------------------------------------------------------------
-- INSERT INTO Building_BuildingClassYieldChanges (BuildingType,	BuildingClassType,			YieldType,		YieldChange)
-- SELECT	 'BUILDING_BARAD_DUR', 'BUILDINGCLASS_FW_BIOMOD_TANK', 'YIELD_PRODUCTION', 8 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);
--------------------------------------------------------------------------------------------------------------------
-- 世界强权科技树调整
--------------------------------------------------------------------------------------------------------------------
UPDATE Buildings SET PrereqTech = 'TECH_MILITARY_ORDERS'
WHERE	 Type='BUILDING_BARAD_DUR' AND EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);--巴拉多黑塔移至军事秩序
UPDATE Buildings SET PrereqTech = 'TECH_STONE_TOOLS'
WHERE	 Type='BUILDING_QUINTEX' AND EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);--昆泰克斯古城移至石器
--------------------------------------------------------------------------------------------------------------------
-- 乌沙比特：世界强权晋升兼容
--------------------------------------------------------------------------------------------------------------------
DELETE FROM Unit_FreePromotions WHERE UnitType='UNIT_USHABTI' AND EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1); 
INSERT INTO Unit_FreePromotions(UnitType,	PromotionType)
SELECT	 'UNIT_USHABTI', 'PROMOTION_ROBORT_COMBAT' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL --重装步兵替换机械步兵
SELECT	 'UNIT_USHABTI', 'PROMOTION_Herald_of_Djaf' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL --狄迦夫军锋
SELECT	 'UNIT_USHABTI', 'PROMOTION_ANTI_DEBUFF' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL --人造意志
SELECT	 'UNIT_USHABTI', 'PROMOTION_NO_CASUALTIES' WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1);--境外人力
--------------------------------------------------------------------------------------------------------------------
-- 昆泰克斯古城：世界强权资源兼容
--------------------------------------------------------------------------------------------------------------------
INSERT INTO Building_ResourceQuantity (BuildingType,	ResourceType,	Quantity)
SELECT	 'BUILDING_QUINTEX', 'RESOURCE_LUMBER', 3 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL --兼容强权木材资源
SELECT	 'BUILDING_QUINTEX', 'RESOURCE_GUNPOWDER', 3 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL --兼容强权火药资源
SELECT	 'BUILDING_QUINTEX', 'RESOURCE_TITANIUM', 3 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL --兼容强权钛资源
SELECT	 'BUILDING_QUINTEX_ERA_BONUS', 'RESOURCE_LUMBER', 3 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL --兼容强权木材资源
SELECT	 'BUILDING_QUINTEX_ERA_BONUS', 'RESOURCE_GUNPOWDER', 3 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1) UNION ALL --兼容强权火药资源
SELECT	 'BUILDING_QUINTEX_ERA_BONUS', 'RESOURCE_TITANIUM', 3 WHERE EXISTS (SELECT * FROM ROG_GlobalUserSettings WHERE Type = 'WORLD_POWER_PATCH' AND Value = 1); --兼容强权钛资源
--------------------------------------------------------------------------------------------------------------------