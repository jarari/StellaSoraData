
---是用来缓存以及处理塔防玩法关卡内角色数据

local TowerDefenseLevelData = class("TowerDefenseLevelData")

local mapEventConfig = {
    LoadLevelRefresh = "OnEvent_LoadLevelRefresh",
    AdventureModuleEnter = "OnEvent_AdventureModuleEnter",
    BattlePause = "OnEvent_Pause",
    JointDrill_StartTiming = "OnEvent_BattleStart",
    JointDrill_MonsterSpawn = "OnEvent_MonsterSpawn",           -- 怪物出生
    JointDrill_BattleLvsToggle = "OnEvent_BattleLvsToggle",    -- 转阶段
    ADVENTURE_LEVEL_UNLOAD_COMPLETE = "OnEvent_UnloadComplete",
    JointDrill_Gameplay_Time = "OnEvent_JointDrill_Gameplay_Time",
    JointDrill_DamageValue = "OnEvent_GiveUpBattle",
    RestartJointDrill = "OnEvent_RestartJointDrill",    -- 重开
    RetreatJointDrill = "OnEvent_RetreatJointDrill",    -- 撤退
    JointDrill_Result = "OnEvent_JointDrill_Result",
    InputEnable = "OnEvent_InputEnable",
}


---@diagnostic disable-next-line: duplicate-set-field
function TowerDefenseLevelData:ctor()
    
end

function TowerDefenseLevelData:InitData(nLevelId,tbCharacter,nItemId,nActId)
    self.nLevelId=nLevelId
    self.tbCharacterData={}
    self.nActId=nActId

    self.tbCharacterId=tbCharacter   --记录当前进入当前关卡 玩家选的角色
    self.nItemId=nItemId             --记录当前进入当前关卡 玩家选的道具

    self.bRestart=false

    self:BindEvent()
end
function TowerDefenseLevelData:Restart()
    self.tbCharacterData={}
    self.bRestart=true
end

function TowerDefenseLevelData:AddCharacter(nCharacterId,nEntityId)
    local characterData={
        nCharacterId=nCharacterId,
        nEntityId=nEntityId,
        nLevel=1,
        tbPotentialList={},
        nCD=ConfigTable.GetData("TowerDefenseCharacter",nCharacterId).SkillCd//10000
    }
    self.tbCharacterData[nCharacterId]=characterData
end
function TowerDefenseLevelData:CharacterLevelUp(nCharacterId)
    if self.tbCharacterData[nCharacterId] ==nil then
        return 
    end
    local nLevel=self.tbCharacterData[nCharacterId].nLevel
    nLevel=math.min(6,nLevel+1)
    self.tbCharacterData[nCharacterId].nLevel=nLevel
    EventManager.Hit("TowerDefenseChar_levelUp",nCharacterId,self.tbCharacterData[nCharacterId].nLevel)
end
function TowerDefenseLevelData:AddPotential(nCharacterId,nPotentialId)
    if self.tbCharacterData[nCharacterId] ==nil then
        return 
    end
    local stPerkInfo = CS.Lua2CSharpInfo_TPPerkInfo()
    stPerkInfo.perkId = nPotentialId
    stPerkInfo.nCount = 1
    local bChange=false
    if #self.tbCharacterData[nCharacterId].tbPotentialList>=1 then
        bChange=true
    end
    safe_call_cs_func(CS.AdventureModuleHelper.ChangePersonalPerkIds,{stPerkInfo},nCharacterId,bChange)
    table.insert(self.tbCharacterData[nCharacterId].tbPotentialList,nPotentialId)
end
function TowerDefenseLevelData:RefreshCharSkillCd(nCharacterId,nCD)
    if self.tbCharacterData[nCharacterId] ==nil then
        return 
    end
    self.tbCharacterData[nCharacterId].nCD=nCD
end
function TowerDefenseLevelData:GetCharSkillCD(nCharacterId)
    if self.tbCharacterData[nCharacterId]==nil then
        return nil
    end
    return self.tbCharacterData[nCharacterId].nCD
end
function TowerDefenseLevelData:GetPotentialByChar(nCharacterId)
    if self.tbCharacterData[nCharacterId]==nil then
        return nil
    end
    return self.tbCharacterData[nCharacterId].tbPotentialList
end
function TowerDefenseLevelData:GetCharacterLevel(nCharacterId)
    if self.tbCharacterData[nCharacterId]==nil then
        return nil
    end
    return self.tbCharacterData[nCharacterId].nLevel
end
function TowerDefenseLevelData:GetCharacterEntityId(nCharacterId)
    if self.tbCharacterData[nCharacterId]==nil then
        return nil
    end
    return self.tbCharacterData[nCharacterId].nEntityId
end
function TowerDefenseLevelData:OnEvent_UnloadComplete()
    if not self.bRestart then
        EventManager.Hit(EventId.ClosePanel,PanelId.TowerDefensePanel)
        NovaAPI.EnterModule("MainMenuModuleScene", true)
        self:UnBindEvent()
        return
    end 
    if self.nLevelId ==0 or self.nLevelId==nil  then
        return
    end
    self.bRestart=false
    local levelConfig=ConfigTable.GetData("TowerDefenseLevel",self.nLevelId)
    if levelConfig==nil then
        return
    end
    EventManager.Hit(EventId.ClosePanel,PanelId.TowerDefensePanel)
    --CS.AdventureModuleHelper.EnterDynamic(levelConfig.FloorId,{},GameEnum.dynamicLevelType.TowerDefense,params)
    local sItem=tostring(self.nItemId)
    local sChar=""
    for index, value in ipairs(self.tbCharacterId) do
        sChar=sChar..tostring(value)
        if index ~=#self.tbCharacterId then
            sChar=sChar..","
        end
    end
    local param={}
    table.insert(param,sItem)
    table.insert(param,sChar)
    CS.AdventureModuleHelper.EnterTowerDefenseLevel(levelConfig.FloorId, param)
    -- NovaAPI.EnterModule("AdventureModuleScene", true, 17)
    EventManager.Hit(EventId.OpenPanel,PanelId.TowerDefensePanel,self.nActId,self.nLevelId)
end
function TowerDefenseLevelData:OnEvent_AdventureModuleEnter()
    EventManager.Hit(EventId.OpenPanel,PanelId.TowerDefensePanel,self.nActId,self.nLevelId)
end


function TowerDefenseLevelData:BindEvent()
    if type(mapEventConfig) ~= "table" then
        return
    end
    for nEventId, sCallbackName in pairs(mapEventConfig) do
        local callback = self[sCallbackName]
        if type(callback) == "function" then
            EventManager.Add(nEventId, self, callback)
        end
    end
end

function TowerDefenseLevelData:UnBindEvent()
    if type(mapEventConfig) ~= "table" then
        return
    end
    for nEventId, sCallbackName in pairs(mapEventConfig) do
        local callback = self[sCallbackName]
        if type(callback) == "function" then
            EventManager.Remove(nEventId, self, callback)
        end
    end
end



return TowerDefenseLevelData