--玩家编队数据

------------------------------ local ------------------------------
local PlayerTeamData = class("PlayerTeamData")
-------------------------------------------------------------------

------------------------------ public -----------------------------
function PlayerTeamData:Init()
    self._tbTeam = nil -- { [nTeamId] = {nCaptainIndex = 1, tbTeamMemberId = {nCharId1, nCharId2, nCharId3}}}
end
function PlayerTeamData:CacheFormationInfo(mapData)
    if mapData == nil then
        return
    end
    if self._tbTeam == nil then
        self._tbTeam = {}
        for i = 1, AllEnum.Const.MAX_TEAM_COUNT, 1 do
            self._tbTeam[i] = {nCaptainIndex = 0, tbTeamMemberId = {0, 0, 0},tbTeamDiscId = {0,0,0}}
        end
    end
    if mapData.Info ~= nil then
        for k, v in pairs(mapData.Info) do
            local nTeamId = v.Number
            local mapTeamData = self._tbTeam[nTeamId]
            if mapTeamData ~= nil then 
                mapTeamData.nCaptainIndex = 1
            else
                mapTeamData = {nCaptainIndex = 1, tbTeamMemberId = {0, 0, 0},tbTeamDiscId = {0,0,0}}
            end
            for nIndex, nCharId in ipairs(v.CharIds) do
                mapTeamData.tbTeamMemberId[nIndex] = nCharId
            end
            for nIndex, nDiscId in ipairs(v.DiscIds) do
                --printError("CacheFormationInfo *** CacheFormationInfo   " .. nTeamId .. "  " .. nDiscId)
                mapTeamData.tbTeamDiscId[nIndex] = nDiscId
            end
        end
    end
end
function PlayerTeamData:UpdateFormationInfo(nTeamId,tbCharIds,tbDiscIds,callback)
    local PlayerFormationReq = {}
    PlayerFormationReq.Formation = {}
    PlayerFormationReq.Formation.Number = nTeamId
    PlayerFormationReq.Formation.Captain = 1
    PlayerFormationReq.Formation.CharIds = tbCharIds
    PlayerFormationReq.Formation.DiscIds = tbDiscIds
    local function Callback()
        if self._tbTeam == nil then
            self._tbTeam = {}
        end
        local mapTeamData = self._tbTeam[nTeamId]
        mapTeamData.nCaptainIndex = 1
        for nIndex, nCharId in ipairs(tbCharIds) do
            mapTeamData.tbTeamMemberId[nIndex] = nCharId
        end
        if tbDiscIds then
            for nIndex, nDiscId in ipairs(tbDiscIds) do
                mapTeamData.tbTeamDiscId[nIndex] = nDiscId
            end
        end
        if callback ~= nil and type(callback) == "function" then
            callback()
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.player_formation_req, PlayerFormationReq, nil, Callback)
end
function PlayerTeamData:GetTeamData(nTeamId)
    if self._tbTeam == nil then
        return nil, nil
    end
    local mapTeamData = self._tbTeam[nTeamId]
    if mapTeamData ~= nil then
        return mapTeamData.nCaptainIndex, mapTeamData.tbTeamMemberId
    else
        return nil, nil
    end
end
function PlayerTeamData:GetTeamDiscData(nTeamId)
    if self._tbTeam == nil then
        return {0,0,0,0,0,0}
    end
    local mapTeamData = self._tbTeam[nTeamId]
    if mapTeamData ~= nil then
        return mapTeamData.tbTeamDiscId
    else
        return {0,0,0,0,0,0}
    end

end
function PlayerTeamData:GetTeamCharId(nTeamId)
    local mapTeamData = self._tbTeam[nTeamId]
    local tbCharId = {}
    if mapTeamData ~= nil then
        local nCaptainId = mapTeamData.tbTeamMemberId[mapTeamData.nCaptainIndex]
        table.insert(tbCharId, nCaptainId)
        for _nIdx, _nCharId in ipairs(mapTeamData.tbTeamMemberId) do
            if _nCharId ~= 0 and _nCharId ~= nCaptainId then
                table.insert(tbCharId, _nCharId)
            end
        end
    end
    return tbCharId -- 出战的角色Id，首位是队长，数组长度即出战人数。
end
function PlayerTeamData:CheckTeamValid(nTeamId)
    if self._tbTeam == nil then
        return false
    end
    local mapTeam = self._tbTeam[nTeamId]
    if mapTeam == nil then
        return false
    else
        if type(mapTeam.tbTeamMemberId) == "table" then
            for i, nCharId in ipairs(mapTeam.tbTeamMemberId) do
                if nCharId < 1 then
                    return false
                end
            end
            return true
        else
            return false
        end
    end
end
function PlayerTeamData:TempCreateRoguelikeTeam(tbTeamCharId)
    self._tbTeam = {}
    self._tbTeam[5] = {nCaptainIndex = 1, tbTeamMemberId = tbTeamCharId}
end
-------------------------------------------------------------------
return PlayerTeamData