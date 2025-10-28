local EventId =
{
    CSLuaManagerShutdown = 0, -- 见 C# 侧 LuaManager.Shutdown()

    -- EnterModule = "EnterModule",
    -- ExitModule = "ExitModule",
    -- AvgStart = "StoryDialog_DialogStart",
    -- AvgEnd = "StoryDialog_DialogEnd",

    TemporaryBlockInput = 1, -- 设置一个短暂的禁止操作，会自动解除。
    MainViewUIVisible = 2, -- 设置主界面UI显隐。
    MarkFullRectWH = 3, -- 记录当前画布经过适配缩放后全屏 Rect 的宽和高。
    UIOperate = 4,  --触发UI操作
    HideProloguePanle = 5, -- 序章结束时在播AVG之前先隐藏界面。

    --埋点相关事件
    UserEvent_CreateRole = 6.001, -- 埋点：创角成功。

    -- UI
    OpenPanel = 10, -- 打开某个全屏界面。
    ClosePanel = 11, -- 关闭某个全屏界面，返回上一个全屏界面。
    CloesCurPanel = 11.1, -- 关闭当前界面（可能是 主panel 可能是非主panel）
    OpenMessageBox = 12, -- 根据传参，显示提示框，或二次确认框，支持回调。
    CloseMessageBox = 12.1, -- 强制提示框
    ClosePopupTips = 12.2, -- 强制关闭飘字提示
    OpenLoading = 13, -- 根据传参，显示全屏进度条，或仅转菊花，支持回调。
    BlockInput = 14, -- 屏蔽玩家操作界面。
    UIBackConfirm = 15, -- TopBar 点击返回上一界面按钮，广播消息做二次确认弹窗。
    UIHomeConfirm = 16, -- TopBar 点击返回主菜单界面，广播消息做二次确认弹窗。
    ShopPurchaseSuccess = 17, -- 商店物品购买成功。
    UpdateEnergy = 18, -- 需要刷新体力。
    UpdateEnergyBattery = 18.1, -- 需要刷新体力储藏。
    UpdateWorldClass = 19, -- 需要刷新世界等级。
    WorldMapOpenMonsterDetail = 20, -- 打开敌人信息列表。
    WorldMapOpenRewardDetail = 20.1, -- 打开奖励信息列表。
    SetSubTitle = 22, -- 设置 topbar 的副标题文字
    ClickWord = 22.1, -- 点击关键词
    StarTowerPass = 22.2, -- 星塔通关
    OpenLampNotice=23, --显示跑马灯
    CloseLampNotice=24,--关闭跑马灯
    DoTweenPauseAll=25, --暂停所有Dotween动画

    FormationLoadModel = 21, -- 编队界面加载模型时

    EquipmentChangeLockState = 47, --装备锁定状态改变

    DepotRefreshList = 53, -- 背包刷新物品列表

    RogueBossRewardOpenDetail = 55,--打开地区boss奖励预览
    RogueBossPausePanel = 56,--地区boss暂停界面
    DelBuildItemId = 57,--删除buildItem

    OpenCharacterScreenPanel = 58, -- 打开角色筛选界面
    CharacterScreenConfirm = 59, -- 角色筛选界面确认筛选条件
    
    CharacterSkinChange = 59.1,  --角色更换皮肤

    JumptoClick = 60, -- 點擊了界面跳轉
    ClickStoneAdd = 61, -- 點擊了增加源石

    OpenShopToggle = 62, -- 打开了某个商店页签
    QuestDataRefresh = 63,
    DailyQuestReceived = 63.1,
    TourQuestReceived = 63.2,
    TRChallengeQusetReceived = 63.3,
    TRNormalQusetReceived = 63.4,
    TourGroupReceived = 63.5,
    DailyQuestActiveReceived = 63.6,
    TutorialQuestReceived = 63.7,

    IsNewDay = 64, --到了每日刷新点
    NewFuncUnlockWorldClass = 65, -- 世界等级提升有个新类型功能解锁

    OpenFixedRoguelikeShop = 67,
    FixedRogueOpenTalentSkillSelect = 68,
    FixedRogueSelectTalentSkill = 69,
    OpenFixedRoguelikeDepotBtn = 70, --点击了打开遗迹背包
    OpenFixedRoguelikeDepotPanel = 71, --打开遗迹背包
    FixedRoguelikeNotify = 72, --遗迹用notify
    FixedRoguelikeTeamLevelUp = 72.5, --遗迹用notify
    FixedRoguelikeQuestUpdate = 72.6, --遗迹用notify
    FixedRoguelikeQuestComplet = 72.7, --遗迹用notify
    FixedRoguelikeLevelUpNotify = 72.4, --遗迹用notify
    GMFixedRoguelikeNotify = 72.1, --GM遗迹返回数据
    GMAddPerkEffect = 72.2, --GM遗迹添加信条
    GMChangeTalent = 72.3, --GM遗迹修改天赋
    FixedRogueShowCompound = 73, --显示合成动画
    FixedRogueShowLevelUp = 74,--显示天赋升级

    AvgClearAllChar = 90, -- Avg清理所有在场角色立绘（离场）
    AvgClearTalk = 91.1, -- Avg清理常规对话框内容（文字+黑底都清除）
    AvgClearStage = 91.2, -- Avg清理舞台
    AvgSetCurtain = 91.3, -- Avg最最最最最靠前的开、闭幕
    AvgEnableStageCamera = 91.4, -- 一些专属性的功能是全屏时，可以关掉舞台相机
    AvgShowHideTalkUI = 92, -- Avg菜单按钮功能，显隐对话框。
    AvgAllMenuBtnEnable = 92.1, -- Avg电影黑幕功能，显隐菜单按钮。
    AvgSetAutoPlay = 93, -- Avg菜单切换设置自动播放
    AvgShowHideLog = 94, -- Avg日志显隐
    AvgMarkLog = 94.1, -- Avg记录文本日志，包括：对话，旁白，选项等。
    AvgLogBtnEnable = 94.2, -- 约束打开日志按钮，与对话和手机的“点击翻页”同步。
    AvgChoiceToReplyPhoneMessage = 94.3, -- 选项指令结合手机指令实现供玩家选择回复手机消息功能。
    AvgSkip = 95, -- Avg_6_MenuCtrl 中广播，跳过AVG播放，直接结束。
    AvgSkipCheck = 95.1, -- 检查是否可以跳过
    AvgSkipCheckIntro = 95.2, -- 检查跳过的最后检查是否需要弹梗概
    AvgChoiceMainRoleOS_In = 97, -- 选项指令，显示主角独白立绘，进入
    AvgChoiceMainRoleOS_Out = 98, -- 选项指令，显示主角独白立绘，离开
    AvgMainRoleTalk_Set = 98.1,
    AvgMainRoleTalk_Switch = 98.2,
    AvgMainRoleTalk_SetEmoji = 98.3,
    AvgMainRoleTalk_Shake = 98.4,
    AvgMainRoleTalk_Reset = 98.5,
    -- AvgFilterFxApplyToAll = 98.6,
    AvgTryResume = 98.6,
    AvgSpeedUp = 98.7, -- 速播
    AvgResetSpeed = 98.8, -- 复位播放倍速
    AvgShowNextPhoneMessage = 99, -- 显示下一条手机信息
    AvgSelectPhoneMsgChoice = 99.1, -- 选择手机消息选项
    AvgSetToPhoneMsgChoiceEnd = 99.3, -- 显示下一条手机信息
    AvgRefreshActionBar = 99.4, -- avg菜单手柄ui切换

    AvgBubbleShutDown = 96, -- 气泡对话中断后淡出
    AvgBubbleExit = "AvgBubbleExit", -- 气泡对话关闭
    AvgBubbleShow = "AvgBubbleShow", -- 气泡对话需要先经过道具掉落界面处的清空才可以显示，清空后通知气泡对话开始进行

    AvgL2DAnimEvent_Start = "start", -- L2D动画在L2D编辑器中可以打事件点，相当于 SetTalk 指令
    AvgL2DAnimEvent_Next = "next", -- 相当于 SetGoOn 指令
    AvgL2DAnimEvent_End = "end", -- 相当于玩家点击翻页
    AvgL2DAnimEvent_Done = "done", -- 当前动画结束需玩家点击以继续
    AvgL2DAnimEvent_FX = "cgfx", -- 播一个非循环特效，播完自停
    AvgL2DAnimEvent_LFX_ON = "lcgfx_on", -- 播一个循环特效
    AvgL2DAnimEvent_LFX_OFF = "lcgfx_off", -- 停一个循环特效

    AvgVoiceDuration = "AvgVoiceDuration",  -- Avg语音时长
    AvgVoiceEnd = "AvgVoiceEnd",    --Avg语音结束

    WWiseVoiceEnd = "WWiseVoiceEnd",   --角色语音结束

    CoinResChange = 100, -- 货币资源数量变更。

    SetTopBarVisible = 101, -- 设置 top bar 是否可见
    SetCoinVisible = 101.1,
    SetEnergyVisible = 101.2,
    ShowSelectPerkPanel = 102, --打开秘宝选择界面
    ShowSelectThemePerkPanel = 102.1, --打开秘宝选择界面
    SelectPerk = 103, --完成秘宝选择
    OpenOrCloseRogueBossPanel = 104,--显示或隐藏地区boss界面
    BattleDashboardVisible = 105,--Lua侧的UI中触发，用来显隐战斗摇杆操作面板界面。

    PasueAvgBubble = 199, -- 主线战斗关卡打开暂停界面时，通知气泡AVG暂停或恢复。
    MoveAvgBubbleRoot = 199.1,

    SendMsgEnterBattle = 200, -- 战前编队(选队伍界面)进战斗(仅适用于主线关卡)。
    EnterMainline = 201, -- C#侧模块场景切换流程中AfterEnter时触发。
    AbandonBattle = 202, -- 放弃关卡战斗(仅主线关卡)。
    ChoseMainlineStory = 203,  -- 选中主线的某一关

    SendMsgEnterRoguelike = 300, -- 战前编队（选队伍界面）进战斗（仅适用于遗迹关卡（随机关卡））。
    AbandonRoguelike = 301, -- 放弃 Roguelike 关卡。
    EnterRoguelike = 302, -- 当进入 Roguelike 关卡时（用于在关卡开始时选择遗迹天赋）。
    ShowRoguelikeDrop = 303, -- Roguelike 关卡展示掉落物品。

    RoguelikePause = 305, -- 显示 Roguelike 暂停。
    AfterEnterMain  = 306, --当 MainMenuModule 加载结束。
    RefrushMailView = 307,--凌晨4点刷新邮件UI

    ShowCharacterSkillTips = 308, -- 显示技能Tips
    ShowCharacterTalentTips = 308.1, -- 显示天赋Tips
    ShowTalentSkillTips = 308.2, -- 显示天赋技能Tips
    ShowMonsterSkillTips = 308.3, -- 显示怪物技能Tips
    ShowItemTips = 308.4, -- 显示道具Tips

    SetTransition = 309, -- 通用动画转场
    TransAnimInClear = 309.1, -- 通用动画转场的前段动画播放完毕
    TransAnimOutClear = 309.2, -- 通用动画转场的后段动画播放完毕

    RefreshFateView = 310, -- 刷新命座panel
    RefreshFatePerkView = 311, -- 刷新命座panel

    WeaponRefresh = 312, -- 刷新武器界面

    RoguelikeMap = 313, -- 显示 Roguelike 地图

    BoardItemDragStart = 314, --看板界面顺序调整
    BoardItemDragging = 315, --看板界面顺序调整
    BoardItemDragEnd = 316, --看板界面顺序调整
    BoardItemOrderFinish = 317,  --看板界面顺序调整
    BoardSelectItem = 318,  --看板界面选中左侧看板列表
    BoardStartHangTimer = 319,  --启动看板放置语音timer

    ShowBubbleVoiceText = "ShowBubbleVoiceText", -- 显示气泡语音文本

    CharBgRefresh = 330, -- 刷新角色相关背景显示
    CharRelatePanelOpen = 331,  -- 角色关联界面打开
    CharRelatePanelClose = 332,  -- 角色关联界面关闭
    CharRelatePanelAdvance = 333,  -- 角色关联界面切换
    CharRelatePanelBack = 334,  -- 角色关联界面切换
    PlayWeaponFadeAnim = 335,
    SubSkillDisplayInit = 336,
    AffinityQuestReceived = 337,
    AffinityChange = 338,
    ActivityDataChange = 340,       -- 刷新活动数据
    LookUpCharStory = 341,
    JumpToSuccess = 350,        -- 跳转成功事件通知
    HideCharBgActor = 351,         -- 隐藏角色信息界面中的立绘
    RevertCharBgActor = 352,         -- 恢复角色信息界面中的立绘
    StarTowerLeave = 353,        --星塔暂离
    StarTowerMap = 401, -- 显示 StarTower 地图
    StarTowerDepot = 402, -- 显示 StarTower 背包

    FilterConfirm = 501, --筛选界面确认关闭

    DispatchOpenCharList = 502,  --打开派遣角色选择界面
    DispatchOpenBuildList = 503,  --打开派遣构筑选择界面
    DispatchReceiveReward = 504,   --领取派遣报酬
    DispatchCloseResultPanel = 505,  --派遣结果界面关闭
    DispatchRefreshPanel = 506,     --派遣状态刷新界面

    SettingsBattleClose = 510,    --关闭设置的战斗界面

    CharTalentUIVisible = 511, -- 角色天赋界面为了凸出展示角色天赋专属L2D可控制UI显隐

    GMToolShow = 998, -- 启动GM工具后显示GM入口。
    GMToolClose = 998.1, -- 退出GM工具。
    GMToolClosePanel = 998.2, -- 启动GM工具后关闭GM面板。
    GMToolSelectOrder = 998.3, -- 选中目标指令。
    GMToolOpen = 999, -- 登录时启动GM工具。
}
return EventId
