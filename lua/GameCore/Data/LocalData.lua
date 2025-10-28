-- 本地临时数据管理（存于客户端本地，非关键数据，允许数据失效）

--[[
    简介
    main key：登陆前使用自定义的 key name 作为主键，登陆后使用玩家唯一 id 作为主键，string 类型，不能重复。
    sub key：自定义的 key name 作为辅键，一般对应需要记录的值的作用来命名，string 类型，不能重复。
    value：想要记录的值，string 类型，可以是 json string。

    整体结构大致如下：
    [main key] = { [sub key] = "1234567890", [sub key] = "abcdefghjk" }

    此处备注一下，所有目前已记录并使用的本地数据。

    1.登陆界面，记录玩家上次登录的账号名，及所选的服务器。
    main key: LoginUIData (string)
    sub key 1: LastSrvIndex (string)
    value 1: 最近一次成功登陆时选择的服务器索引 (number to string)
    sub key 2: LastUserName (string)
    value 2: 最近一次成功登陆时输入的账号名 (string)
    
    2.天赋球（房间）界面，记录当前登陆玩家的各个角色，上一次离开该界面时选择的天赋球Id（房间Id）。
    main key: PlayerId (number to string)
    sub key: LastTalentRoomIndex (string)
    value: 各个角色最近一次离开天赋球界面时选择的房间Id (table to json string)

    3.PlayerCharData记录一个全局设置，角色立绘或立绘 Live2D 使用的偏移数据，是否为半身像（即放大一些的效果）。
    main key: PlayerId (number to string)
    sub key: HalfFullBody(string)
    value: 是否使用半身像偏移数据（bool）

    4.PlayerCharList记录玩家筛选排序偏好
    main key:PlayerId (number to string)
    sub key：SortFunc(string)
    value:排序方式(string)
    sub key:SortOrder(string)
    value:升序或降序(number)
    sub key:MapFilter(string)
    value:筛选条件(table to json string)

    5.AVG界面，记录当前登陆玩家的菜单栏状态，上一次离开该界面时菜单栏按钮的选择状态。
    main key: PlayerId (number to string)
    sub key: StateAuto(string)
    value: 是否点击自动按钮（bool）
    sub key: StateMenu(string)
    value: 是否点击菜单栏展开按钮（bool）

    6.设置界面，记录玩家设置偏好
    main key: GameSystemSettingsData (number to string)
    sub key: OpenMusic(string)
    value: 是否打开音乐（bool）
    sub key: NumMusic(string)
    value: 音乐音量（bool）
    sub key: OpenVfx(string)
    value: 是否打开音效（bool）
    sub key: NumVfx(string)
    value: 音效音量（bool）
    sub key: OpenChar(string)
    value: 是否打开角色语音（bool）
    sub key: NumChar(string)
    value: 角色语音音量（bool）
    sub key: Animation(string)
    value: 动画设置 1-一天显示一次 2-开启 3-关闭（number）
    sub key: Mouse(string)
    value: 鼠标快捷键方向引导（bool）
    sub key: JoyStick(string)
    value: 动态摇杆（bool）
    sub key: Gizmos(string)
    value: 攻击范围（bool）

    7.PlayerCharData记录每个角色的全屏Live2D设置，当角色解锁了全屏Live2D后，可以选是否默认使用它，每个角色单独记录。
    main key: PlayerId (number to string)
    sub key: CharacterPortraitSettings(string)
    value: 在角色的全屏 Live2D 解锁/觉醒后，是否默认显示全屏 /觉醒Live2D (table to json string)。1普通2觉醒3全屏（int）

    8.战斗关卡的AVG播放情况
    main key: PlayerId (number to string)
    sub key: PlayedAvgNodeId(string)
    value: 是否播放过战前/后avg的关卡（table to json string）[nodeid] = {["Before"] = true,["After"] = true}

    9.本次登录内经验材料的选择范围
    main key: UpgradeMat (number to string)
    sub key: Presents(string)/Outfit(string)
    value: 选择第几个

    10.当前的每日弹窗情况
    main key: PlayerId (number to string)
    sub key: DailyPanelQueue (string)
    value: 每日弹窗队列（table to json string）

    11.当前的每日弹窗时间
    main key: PlayerId (number to string)
    sub key: DailyPanelTime (string)
    value: 每日弹窗时间（number to string）
    
    12.背包界面
    main key: PlayerId (number to string)
    sub key: Outfit_Dismantle_Select (string)
    value: 星盘拆解品质选择（number to string）
     sub key: Presents_Dismantle_Select (string)
    value: 礼装拆解品质选择（number to string）
    
    13.活动界面
     main key: PlayerId
     sub key: Act_PopUp (string)+ActId(number to string)
     value: 弹出的时间戳

    14.角色档案
    main key:PlayerId
    sub key: CharacterArchive/CharacterArchiveVoice/Plot_Id(number to string)
    value: 档案状态（0.未解锁， 1.已解锁未查看， 2.已查看）
    
    15.手机界面（临时版本，后面数据要存服务器）
     main key:Phone_Chat_ChatId(number to string)
     sub key:Progress(string)
     value:ProgressTable（table to json string）

    16.日常副本奖励类型
     main key:PlayerId
     sub key:DailyRewardType
     value:DailyRewardType(number to string)

    17.主线关卡（旅行故事/分歧系统）
    main key: PlayerId
    sub key: "RecentStoryId"
    value: 每一章最近一次打的关卡id

    18.荣誉称号
    main key: PlayerId
    sub key:HonorTitle
    value:honortitle id

    19.主线故事解锁动效
    main key: PlayerId
    sub key: MainlineUnlock_StoryId
    value: 是否看过解锁动效（0/1）

    20.活动期内不再弹窗
    main key: PlayerId
    sub key: Act_PopUp_DontShow+Activity_ActId (string)
    value: 是否看过（true/false）

    21.活动剧情红点
    main key: PlayerId
    sub key: Act_Story_New+ActivityId+StoryId (string)
    value: 是否看过（true/false）
]]
local RapidJson = require "rapidjson"

local String = CS.System.String
local PlayerPrefs = CS.UnityEngine.PlayerPrefs

local LocalData = {}

function LocalData.SetLocalData(sMainKey, sSubKey, sValue)
    local sJson = PlayerPrefs.GetString(sMainKey)
    local mapData = nil
    if String.IsNullOrEmpty(sJson) == true then
        mapData = {}
        mapData[sSubKey] = sValue
    else
        mapData = RapidJson.decode(sJson)
        mapData[sSubKey] = sValue
    end
    sJson = RapidJson.encode(mapData)
    PlayerPrefs.SetString(sMainKey, sJson)
    PlayerPrefs.Save()
end

function LocalData.GetLocalData(sMainKey, sSubKey)
    local sJson = PlayerPrefs.GetString(sMainKey)
    if String.IsNullOrEmpty(sJson) == true then
        return nil
    else
        local mapData = RapidJson.decode(sJson)
        return mapData[sSubKey]
    end
end

function LocalData.DelLocalData(sMainKey, sSubKey)
    local sJson = PlayerPrefs.GetString(sMainKey)
    if String.IsNullOrEmpty(sJson) == false then
        local mapData = RapidJson.decode(sJson)
        mapData[sSubKey] = nil
        sJson = RapidJson.encode(mapData)
        PlayerPrefs.SetString(sMainKey, sJson)
        PlayerPrefs.Save()
    end
end

function LocalData.SetPlayerLocalData(sKey, sValue)
    local nPlayerId = PlayerData.Base:GetPlayerId()
    if type(nPlayerId) == "number" then
        LocalData.SetLocalData(tostring(nPlayerId), sKey, sValue)
    end
end

function LocalData.GetPlayerLocalData(sKey)
    local nPlayerId = PlayerData.Base:GetPlayerId()
    if type(nPlayerId) == "number" then
        return LocalData.GetLocalData(tostring(nPlayerId), sKey)
    end
end

function LocalData.DelPlayerLocalData(sKey)
    local nPlayerId = PlayerData.Base:GetPlayerId()
    if type(nPlayerId) == "number" then
        LocalData.DelLocalData(tostring(nPlayerId), sKey)
    end
end

return LocalData
