require "GameCore.GameCore"

local RapidJson = require "rapidjson"
local GMToolManager = require "GameCore.Module.GMToolManager"
local AvgManager = require "GameCore.Module.AvgManager"

local BootConfigLoadType = CS.AdventureModuleLevelLoadParams.BootConfigLoadType

local goLaunchUI = GameObject.Find("==== Builtin UI ====/LaunchUI")
GameObject.Destroy(goLaunchUI)

local loadType, mapId, id, floor, actors, fixedRoguelikeRoomData, affixes, breakCounts, levels,stageId,outfitList,isFirstHalf,noteList, skins = NovaAPI.GetLoadParam()
if id ~= nil and actors ~= nil then
    local nId = tonumber(id)
    if type(nId) ~= "number" then
        print("关卡 id 有误，请检查 boot config 配置。")
        return
    end

    AvgManager.Init() -- 初始化Avg管理器
    if GMToolManager ~= nil then
        GMToolManager.Init() -- 初始化GM工具
    end
    EventManager.Hit(EventId.GMToolOpen, true)
    -- 序章
    if loadType == BootConfigLoadType.Prologue then
        if ConfigTable.GetData("MainlineFloor", nId) == nil then
            print(string.format("MainlineFloor.xlsx 配置表中未找到 id = %d，请检查 boot config 配置。", nId))
            return
        end
        -- 目前伪造角色数据，只有角色id和技能天赋（分支），没有详细的角色养成数据（天赋、礼装、礼物等）
        PlayerData.Mainline:EnterPrologue()
        return
    end

    local tbTeamCharId = {}
    for i = 0, actors.Count - 1 do
        if actors[i] > 0 then
            tbTeamCharId[i + 1] = actors[i]
        end
    end
    if #tbTeamCharId <= 0 then
        print("未设置队伍成员，请检查 boot config 配置。")
        return
    end
    local tbSkinId = {}
    for i = 0, skins.Count - 1 do
        if skins[i] > 0 then
            tbSkinId[tbTeamCharId[i + 1]] = skins[i]
        end
    end

    local advances = {}
    if breakCounts ~= nil then
        for i = 0, breakCounts.Length - 1 do
            table.insert(advances, breakCounts[i])
        end
    end

    local cLevels = {}
    if levels ~= nil then
        for i = 0, levels.Length - 1 do
            table.insert(cLevels, levels[i])
        end
    end
    local tbOutfit = {}
    if outfitList ~= nil then
        local tbOutfitCacheData = {}
        for i = 0, outfitList.Count - 1 do
            table.insert(tbOutfit,outfitList[i].Id)
            table.insert(tbOutfitCacheData,{
                Id = outfitList[i].Id,
                Level = outfitList[i].level,
                Exp = 0,
                Phase = outfitList[i].phase,
                Star = outfitList[i].star,
                Read = false,
                CreateTime = 0,
            })
        end
        PlayerData.Disc:CacheDiscData(tbOutfitCacheData)
    end
    local tbNote = {}
    if noteList then
        for i = 0, noteList.Count - 1 do
            tbNote[noteList[i].Id] = noteList[i].count
        end
    end
    PlayerData.Char:TempCreateCharDataForBattleTest(tbTeamCharId, advances, cLevels) -- 伪造角色数据

    if loadType == BootConfigLoadType.Mainline then
        if ConfigTable.GetData("MainlineFloor", nId) == nil then
            print(string.format("MainlineFloor.xlsx 配置表中未找到 id = %d，请检查 boot config 配置。", nId))
            return
        end
        -- 目前伪造角色数据，只有角色id和技能天赋（分支），没有详细的角色养成数据（天赋、礼装、礼物等）
        PlayerData.Mainline:EnterMainlineEditor(nId, tbTeamCharId, {}, tbOutfit, tbNote, tbSkinId)
    elseif loadType == BootConfigLoadType.RegionBoss then
        PlayerData.RogueBoss:EnterRoguelikeEditor(nId, tbTeamCharId, tbOutfit, tbNote)
        print("load type = FixedRoguelike_ByFixedId_ThroughBootConfig")
    elseif loadType == BootConfigLoadType.BattleTestBedComboClip then
        PlayerData.Mainline:EnterTestBattleComboClipEditor(nId, tbTeamCharId, {}, tbOutfit, tbNote, tbSkinId)
    elseif loadType == BootConfigLoadType.TravelerDuelEditor then
        print("load type = TravelerDuelEditor")
        PlayerData.TravelerDuel:EnterTravelerDuelEditor(tonumber(mapId), tbTeamCharId, affixes, tbOutfit, tbNote)
    elseif loadType == BootConfigLoadType.DailyInstance_BootConfig then
        print("load type = DailyInstance_BootConfig")
        PlayerData.DailyInstance:EnterDailyInstanceEditor(tonumber(id), tbTeamCharId, tbOutfit, tbNote)
    elseif loadType == BootConfigLoadType.InfinityTower_BootConfig then
        print("load type = InfinityTower_BootConfig")
        PlayerData.InfinityTower:EnterInfinityTowerEditor(tonumber(id), tbTeamCharId, tbOutfit, tbNote)
    elseif loadType == BootConfigLoadType.EquipmentInstance_BootConfig then
        print("load type = EquipmentInstance_BootConfig")
        PlayerData.EquipmentInstance:EnterEquipmentInstanceEditor(tonumber(id), tbTeamCharId, tbOutfit, tbNote)
    elseif loadType == BootConfigLoadType.StarTower_Formal then
        PlayerData.StarTower:EnterTowerEditor(floor,tonumber(mapId),nId,stageId,tbTeamCharId, tbOutfit, tbNote)
    elseif loadType == BootConfigLoadType.StarTower_Limitless then
        PlayerData.StarTower:EnterTowerEditor(floor,tonumber(mapId),nId,stageId,tbTeamCharId, tbOutfit, tbNote)
    elseif loadType == BootConfigLoadType.VampireSurvivor_BootConfig then
        PlayerData.VampireSurvivor:EnterVampireEditor(tonumber(id), tbTeamCharId,isFirstHalf, tbOutfit, tbNote)
    elseif loadType == BootConfigLoadType.ScoreBoss_BootConfig then
        PlayerData.ScoreBoss:EnterScoreBossInstanceEditor(tonumber(id), tbTeamCharId, tbOutfit, tbNote)
    elseif loadType == BootConfigLoadType.DynamicLevel then
        local dynamicLevel = NovaAPI.GetDynamicLevelTypeBootConfig()
        if GameEnum.dynamicLevelType.Trial == dynamicLevel then
            PlayerData.Trial:EnterTrialEditor(tonumber(id))
            return
        end

        local luaClass =  require "Game.Adventure.DynamicBootConfig.DynamicLevelEditor"
        --printError(dynamicLevel)
        luaClass:Init(tonumber(id), tbTeamCharId, tbOutfit, tbNote,dynamicLevel)
    elseif loadType == BootConfigLoadType.AutoBattleBalance_BootConfig then
        local eetType = NovaAPI.GetAutoBattleBalanceEET()
        local luaClass =  require "Game.Adventure.AutoBattleBalance.AutoBattleBalanceEditor"
        --printError(dynamicLevel)
        luaClass:Init(eetType)
    elseif loadType == BootConfigLoadType.BreakOut_BootConfig then
          NovaAPI.EnterModule("AdventureModuleScene", true)
    end
end

--[[
local sJson_BootConfigMetaData = tostring(GameController.Instance.metaData)
if type(sJson_BootConfigMetaData) == "string" then
    local mapMetaData = RapidJson.decode(sJson_BootConfigMetaData)
    if type(mapMetaData) == "table" then
        PlayerData.Char:TempCreateCharDataForBattleTest(mapMetaData.team)
        GameController.Instance:EnterModule("AdventureModuleScene", true)
    else
        print("---- boot config 错误 meta data 解析成 LuaTable 失败 ----")
    end
else
    print("---- boot config 错误 meta data 是有一定格式约定的 json string ----")
end
]]

