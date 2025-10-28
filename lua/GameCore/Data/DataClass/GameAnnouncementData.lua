local GameAnnouncementData = class("GameAnnouncementData")

local LocalData = require "GameCore.Data.LocalData"

-- 公告服务器的Channel
local AnnServerChannel_CN={[1]="cn_android_official",[2]="cn_ios_official",[4]="cn_android_bilibili",[8]="cn_harmony_official",[16]="cn_pc_official",[32]="cn_pc_bilibili"}

local AnnServerChannel_JP={[1]="jp_android_official",[2]="jp_ios_official",[4]="jp_android_onestore",[8]="jp_pc_official"}
local AnnServerChannel_US={[1]="us_android_official",[2]="us_ios_official",[4]="us_android_onestore",[8]="us_pc_official"}
local AnnServerChannel_KR={[1]="kr_android_official",[2]="kr_ios_official",[4]="kr_android_onestore",[8]="kr_pc_official"}
local AnnServerChannel_TW={[1]="tw_android_official",[2]="tw_ios_official",[4]="tw_android_onestore",[8]="tw_pc_official"}

local htmlConfigId=1

function GameAnnouncementData:ctor()
end
function GameAnnouncementData:Init()
    self.tbLastAnnList=LocalData.GetLocalData("Announcement_","LastList") or {}
    self.tbCurAnnList={}

    EventManager.Add("AllAnnDataRequestDone",self,self.AllAnnResponse)
    EventManager.Add("AnnContentRequestDone",self,self.AnnContentResponse)
    EventManager.Add("AllAnnDataRequestFail",self,self.AllAnnResponse_Fail)
end
function GameAnnouncementData:ClearCache()
    self.tbTypeList={}   --一级页签{int:页签类型,tbList:排序过的公告Id}
    self.tbAnnBaseInfo={} -- 公告基本数据 
    self.tbAnnContentCache={} --缓存公告的内容  key:公告Id 界面关闭的时候会清空
end
function GameAnnouncementData:SetAutoOpen(autoOpen)
    LocalData.SetLocalData("Announcement_","AutoOpen",autoOpen)
end
function GameAnnouncementData:GetAutoOpen()
    local bAutoOpen=true
    if LocalData.GetLocalData("Announcement_","AutoOpen")==nil then
        bAutoOpen=true
    else
        bAutoOpen=LocalData.GetLocalData("Announcement_","AutoOpen")
    end
    local nTime=CS.ClientManager.Instance.serverTimeStamp
    local nLastTime=LocalData.GetLocalData("Announcement_","Time") or 0
    if nTime>nLastTime then
        if not self:IsSameWeek(nTime,nLastTime) then
            bAutoOpen=true
        end
        LocalData.SetLocalData("Announcement_","Time",nTime)
    else

    end
    return bAutoOpen 
end
function GameAnnouncementData:GetTodayisOpen()
    local bTodayIsOpen=false
    local nTime=CS.ClientManager.Instance.serverTimeStamp
    local nLastOpenTime=LocalData.GetLocalData("Announcement_","LastOpenTime") or 0
    if self:IsSameDay(nTime,nLastOpenTime) then
        if LocalData.GetLocalData("Announcement_","TodayOpened")==nil then
            bTodayIsOpen=false
        else
            bTodayIsOpen=LocalData.GetLocalData("Announcement_","TodayOpened")
        end
    else
        bTodayIsOpen=false
    end
    return bTodayIsOpen
end
function GameAnnouncementData:GetIsNeedAutoOpen()
    local bHasNew=self:CheckHasNewAnn()
    if bHasNew then
        return true
    end
    return self:GetAutoOpen() and not self:GetTodayisOpen()
end

function GameAnnouncementData:GetAnnInfoByType(nType)
    if self.tbTypeList[nType]==nil then
        return nil
    end
    return self.tbTypeList[nType]
end

function GameAnnouncementData:HasAnnouncement()
    if self.tbTypeList=={} or self.tbTypeList==nil then
        return false
    end
    if #self.tbTypeList>4 or #self.tbTypeList<2 then
        return false
    end
    return true
end
function GameAnnouncementData:GetHtmlData(nId)
    if self.tbAnnContentCache[nId]~=nil then
        return self.tbAnnContentCache[nId]
    else
        self:SendAnnContentQuest(nId)
        return nil
    end
end

--nId为0的时候 是对所有该nType下的公告做已读处理
function GameAnnouncementData:SetAnnRead(nType,nId)
    if nId==0 then
        local list=self.tbTypeList[nType]
        if list~=nil then
            for _, v in pairs( list) do
                RedDotManager.SetValid(RedDotDefine.Announcement_Content,{nType,v.Id},false)

                LocalData.SetLocalData("AnnouncementIsRead",tostring(v.Id),true)
            end 
        end
    else
        RedDotManager.SetValid(RedDotDefine.Announcement_Content,{nType,nId},false)

        LocalData.SetLocalData("AnnouncementIsRead",tostring(nId),true)
    end
end
--用来判断是否有新公告
function GameAnnouncementData:UpdateLastAnnData()
    self.tbLastAnnList= self.tbCurAnnList
    LocalData.SetLocalData("Announcement_","LastList",self.tbLastAnnList)
    LocalData.SetLocalData("Announcement_","TodayOpened",true)
    local nTime=CS.ClientManager.Instance.serverTimeStamp
    LocalData.SetLocalData("Announcement_","LastOpenTime",nTime)
end

function GameAnnouncementData:CheckHasNewAnn()
    if self.tbCurAnnList ==nil then
        return false
    end
    for _, value in pairs(self.tbCurAnnList) do
        if table.keyof(self.tbLastAnnList,value) ==nil then
            return true
        end
    end
    return false
end

function GameAnnouncementData:AllAnnResponse(listData)
    --处理Data
    self.tbAnnBaseInfo={}
    self.tbTypeList={}
    self.tbAnnContentCache={}
    self.tbCurAnnList={}
    --因为公告的tab 相对比较固定，而且刚开始的协议也是分开类型来传的，所以这里也是分开来处理
    for i = 0, listData.System.Length-1,1 do
        local v=listData.System[i]
        if UTILS.CheckChannelList(v.Channel) and v.ContentUrl~=""  then
            self.tbAnnBaseInfo[v.Id]={info=v,nType=AllEnum.AnnType.SystemAnn}
            if self.tbTypeList[AllEnum.AnnType.SystemAnn]==nil then
                local list={}
                table.insert( list, v )
                self.tbTypeList[AllEnum.AnnType.SystemAnn]=list
            else
                table.insert(self.tbTypeList[AllEnum.AnnType.SystemAnn], v )
            end
            local bIsRead= false
            if LocalData.GetLocalData("AnnouncementIsRead",tostring(v.Id) )==nil then
                bIsRead=false
            else
                bIsRead=LocalData.GetLocalData("AnnouncementIsRead",tostring(v.Id) ) 
            end
            RedDotManager.SetValid(RedDotDefine.Announcement_Content,{AllEnum.AnnType.SystemAnn,v.Id},not bIsRead)
            table.insert(self.tbCurAnnList,v.Id)
        end
    end
    for i = 0, listData.Activity.Length-1, 1 do
        local v=listData.Activity[i]
        if UTILS.CheckChannelList(v.Channel)  and v.ContentUrl~="" then
            self.tbAnnBaseInfo[v.Id]={info=v,nType=AllEnum.AnnType.ActivityAnn}
            if self.tbTypeList[AllEnum.AnnType.ActivityAnn]==nil then
                local list={}
                table.insert( list, v )
                self.tbTypeList[AllEnum.AnnType.ActivityAnn]=list
            else
                table.insert(self.tbTypeList[AllEnum.AnnType.ActivityAnn], v )
            end
            local bIsRead= false
            if LocalData.GetLocalData("AnnouncementIsRead",tostring(v.Id) )==nil then
                bIsRead=false
            else
                bIsRead=LocalData.GetLocalData("AnnouncementIsRead",tostring(v.Id) ) 
            end
            RedDotManager.SetValid(RedDotDefine.Announcement_Content,{AllEnum.AnnType.ActivityAnn,v.Id},not bIsRead) 
        end
        table.insert(self.tbCurAnnList,v.Id)
    end
    for i = 0, listData.Other1.Length-1, 1 do
        local v=listData.Other1[i]
        if UTILS.CheckChannelList(v.Channel)  and v.ContentUrl~="" then
            self.tbAnnBaseInfo[v.Id]={info=v,nType=AllEnum.AnnType.Other1}
            if self.tbTypeList[AllEnum.AnnType.Other1]==nil then
                local list={}
                table.insert( list, v )
                self.tbTypeList[AllEnum.AnnType.Other1]=list
            else
                table.insert(self.tbTypeList[AllEnum.AnnType.Other1], v )
            end
            local bIsRead= false
            if LocalData.GetLocalData("AnnouncementIsRead",tostring(v.Id) )==nil then
                bIsRead=false
            else
                bIsRead=LocalData.GetLocalData("AnnouncementIsRead",tostring(v.Id) ) 
            end
            RedDotManager.SetValid(RedDotDefine.Announcement_Content,{AllEnum.AnnType.Other1,v.Id},not bIsRead) 
        end
        table.insert(self.tbCurAnnList,v.Id)
    end
    for i = 0, listData.Other2.Length-1, 1 do
        local v=listData.Other2[i]
        if UTILS.CheckChannelList(v.Channel)  and v.ContentUrl~="" then
            self.tbAnnBaseInfo[v.Id]={info=v,nType=AllEnum.AnnType.Other2}
            if self.tbTypeList[AllEnum.AnnType.Other2]==nil then
                local list={}
                table.insert( list, v )
                self.tbTypeList[AllEnum.AnnType.Other2]=list
            else
                table.insert(self.tbTypeList[AllEnum.AnnType.Other2], v )
            end
            local bIsRead= false
            if LocalData.GetLocalData("AnnouncementIsRead",tostring(v.Id) )==nil then
                bIsRead=false
            else
                bIsRead=LocalData.GetLocalData("AnnouncementIsRead",tostring(v.Id) ) 
            end
            RedDotManager.SetValid(RedDotDefine.Announcement_Content,{AllEnum.AnnType.Other2,v.Id},not bIsRead) 
        end
        table.insert(self.tbCurAnnList,v.Id)
    end
    if self.requestAllDataCallback then
        self.requestAllDataCallback() 
        self.requestAllDataCallback=nil
    end
    self.bLoadAllData=false
    EventManager.Hit("AnnAllDataReady")
end
function GameAnnouncementData:AllAnnResponse_Fail()
    if self.requestAllDataCallback then
        self.requestAllDataCallback() 
        self.requestAllDataCallback=nil
    end
    self.bLoadAllData=false
    --EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Function_NotAvailable"))
end
function GameAnnouncementData:AnnContentResponse(nId,content)
    self.tbAnnContentCache[nId]=content
    EventManager.Hit("AnnContentReady",nId)
end
function GameAnnouncementData:SendAllDataQuest(callback_success)
    if self.bLoadAllData then
        return
    end
    self.bLoadAllData=true
    self.requestAllDataCallback=callback_success
    CS.HttpNetworkManager:RequestAllAnnData()
end

function GameAnnouncementData:SendAnnContentQuest(nId)
    local annInfo=self.tbAnnBaseInfo[nId]
    CS.HttpNetworkManager.RequestAnnContent(nId,annInfo.info.ContentUrl)
end

function GameAnnouncementData:GetHtmlFrame()
    local htmlFrame= ConfigTable.GetData("HtmlConfig", htmlConfigId)
    if htmlFrame~=nil then
        return htmlFrame.HtmlFrame
    end
    return ""
end
----------------------Tool---------------------------
local function GetCurrentYearInfo(time_s)
    local day=os.date("%d",time_s)
    local weekIndex = os.date("%W", time_s)
    local month=os.date("%m",time_s)
    local yearNum = os.date("%Y",time_s) 
    return {
        year = yearNum,
        month=month,
        weekIdx = weekIndex,
        day=day,
    }
end

function GameAnnouncementData:IsSameDay(stampA, stampB, resetHour)
    resetHour=resetHour or 5
    local resetSeconds = resetHour * 3600 
    stampA = stampA - resetSeconds
    stampB = stampB - resetSeconds
    stampA=math.max( stampA,0 )
    stampB=math.max( stampB,0 )
    local dateA = GetCurrentYearInfo(stampA)
    local dateB = GetCurrentYearInfo(stampB)
    return dateA.day == dateB.day and dateA.month==dateB.month and dateA.year == dateB.year
end
function GameAnnouncementData:IsSameWeek(stampA, stampB, resetHour)
    resetHour=resetHour or 5
    local resetSeconds = resetHour * 3600 
    stampA = stampA - resetSeconds
    stampB = stampB - resetSeconds
    stampA=math.max( stampA,0 )
    stampB=math.max( stampB,0 )
    local dateA = GetCurrentYearInfo(stampA)
    local dateB = GetCurrentYearInfo(stampB)
    return dateA.weekIdx == dateB.weekIdx and dateA.year == dateB.year
end

return GameAnnouncementData

