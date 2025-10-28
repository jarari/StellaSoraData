local AllEnum = {}
AllEnum.ChannelName = {
    BanShu = "NPPA",
    Dev = "Default",
    Official = "Official",
}
AllEnum.Language = {
    CN = "zh_CN", -- 中文简�??
    TW = "zh_TW", -- 中文繁体
    JP = "ja_JP", -- 日文
    EN = "en_US", -- 英文
    KR = "ko_KR", -- 韩文
}
AllEnum.LanguageInfo = {
    -- 语言枚举,  avg编辑器下拉菜单显示的语言名字,  avg演出配置Config目录后缀,  L2D动画名语言后缀
    {AllEnum.Language.CN,"简中","_cn"},
    {AllEnum.Language.TW,"繁中","_tw"},
    {AllEnum.Language.JP,"日语","_jp"},
    {AllEnum.Language.EN,"英语","_en"},
    {AllEnum.Language.KR,"韩语","_kr"},
}
AllEnum.SortingLayerName = {
    HUD = "HUD",
    UI = "UI",
    UI_Top = "UI Top",
    UI_Video = " UI Video",
    Overlay = "Overlay"
}
AllEnum.Const = {
    MAX_TEAM_COUNT = 5,
    ICON_SCALE = 0.68, -- 所有圆形icon与品质底组合使用是，统一设置缩放值�?
}
AllEnum.CoinItemId = { -- 各货币的道具Id
    Gold = 1, -- 金币（游戏产出的普通货币）
    Jade = 2, -- 合成玉（源石购买获得�??
    STONE = 3, -- 源石（人名币充值获得）
    FREESTONE = 4, --无偿星塔�??
    Energy = 20, -- 体力
    WorldClassExp = 21, -- 世界等级经验
    RogueHardCoreTick = 28, -- 区域boss真格模式门票
    StarTowerSweepTick = 29, -- 星塔扫荡门票
    StarTowerSweepTickLimit = 30, -- 星塔扫荡门票限时
    PresentsFragment = 6, -- 礼物碎片
    BossCruTickets = 10,--地区BOSS门票道具
    FixedRogCurrency = 11, --遗迹货币
    FRRewardCurrency = 12, --星途票�?
    NormalSingleTicket = 501, -- 普池单抽�?
    LimitedSingleTicket = 502, -- 限定单抽�?
    DailyQuestActive = 61, -- 每日任务活跃点数
}
AllEnum.QuestStatus = {
    Undone = false,
    Done = true,
}
AllEnum.CharHeadIconSurfix = {
    GC = "_GC", -- 抽卡专用
    GD = "_GD", -- 新手引导专用
    L = "_L",  -- 角色小头像附带背景圆�?
    S = "_S", -- 常规界面中角色小头像（圆形）
    SK = "_SK", -- 皮肤界面
    XL = "_XL", -- 常规界面中角色大头像（长方形�??
    XXL = "_XXL", -- 常规界面中角色小头像（方�? 189*189�?
    --M = "_M", -- 常规界面中角色小头像（方�? 256*256�?
    GOODS = "_GOODS", -- 星塔出发界面的立牌
}
AllEnum.EET = {
    [GameEnum.elementType.WE] = "WEE",
    [GameEnum.elementType.FE] = "FEE",
    [GameEnum.elementType.SE] = "SEE",
    [GameEnum.elementType.AE] = "AEE",
    [GameEnum.elementType.LE] = "LEE",
    [GameEnum.elementType.DE] = "DEE",
}
AllEnum.CharAttr = {
    {sKey = "Hp", nGroup = 1, sLanguageId_Simple = "Attr_Hp_Simple"},
    {sKey = "Atk", nGroup = 2, sLanguageId_Simple = "Attr_Atk_Simple"},
    {sKey = "Def", nGroup = 3, sLanguageId_Simple = "Attr_Def_Simple"},
    {sKey = "CritRate", nGroup = 4, bPercent = true},
    {sKey = "CritPower", nGroup = 5, bPercent = true},
    {sKey = "Suppress", nGroup = 6, bPercent = true},

    {sKey = "UltraEnergy", nGroup = 7},
    {sKey = "EnergyEfficiency", nGroup = 7, bPercent = true},
    {sKey = "EnergyConvRatio", nGroup = 7, bPercent = true},

    {sKey = "DefPierce", nGroup = 8},
    {sKey = "DefIgnore", nGroup = 8, bPercent = true},

    {sKey = "WEE", nGroup = 9, bPercent = true, nEET = GameEnum.elementType.WE},
    {sKey = "WEP", nGroup = 9, nEET = GameEnum.elementType.WE},
    {sKey = "WEI", nGroup = 9, bPercent = true, nEET = GameEnum.elementType.WE},

    {sKey = "FEE", nGroup = 10, bPercent = true, nEET = GameEnum.elementType.FE},
    {sKey = "FEP", nGroup = 10, nEET = GameEnum.elementType.FE},
    {sKey = "FEI", nGroup = 10, bPercent = true, nEET = GameEnum.elementType.FE},

    {sKey = "SEE", nGroup = 11, bPercent = true, nEET = GameEnum.elementType.SE},
    {sKey = "SEP", nGroup = 11, nEET = GameEnum.elementType.SE},
    {sKey = "SEI", nGroup = 11, bPercent = true, nEET = GameEnum.elementType.SE},

    {sKey = "AEE", nGroup = 12, bPercent = true, nEET = GameEnum.elementType.AE},
    {sKey = "AEP", nGroup = 12, nEET = GameEnum.elementType.AE},
    {sKey = "AEI", nGroup = 12, bPercent = true, nEET = GameEnum.elementType.AE},

    {sKey = "LEE", nGroup = 13, bPercent = true, nEET = GameEnum.elementType.LE},
    {sKey = "LEP", nGroup = 13, nEET = GameEnum.elementType.LE},
    {sKey = "LEI", nGroup = 13, bPercent = true, nEET = GameEnum.elementType.LE},

    {sKey = "DEE", nGroup = 14, bPercent = true, nEET = GameEnum.elementType.DE},
    {sKey = "DEP", nGroup = 14, nEET = GameEnum.elementType.DE},
    {sKey = "DEI", nGroup = 14, bPercent = true, nEET = GameEnum.elementType.DE},

    {sKey = "AtkSpd", bPercent = true},
    {sKey = "WER"},
    {sKey = "SER"},
    {sKey = "AER"},
    {sKey = "FER"},
    {sKey = "LER"},
    {sKey = "DER"},
    {sKey = "EET"},
}
AllEnum.AttachAttr = {
    {sKey = "Hp"},
    {sKey = "Atk"},
    {sKey = "Def"},
    {sKey = "CritRate", bPercent = true},
    {sKey = "CritResistance", bPercent = true},
    {sKey = "CritPower", bPercent = true},
    {sKey = "HitRate", bPercent = true},
    {sKey = "Evd", bPercent = true},

    {sKey = "DefPierce"},
    {sKey = "DefIgnore", bPercent = true},

    {sKey = "WEE", bPercent = true},
    {sKey = "WEP"},
    {sKey = "WEI", bPercent = true},
    {sKey = "WER"},

    {sKey = "FEE", bPercent = true},
    {sKey = "FEP"},
    {sKey = "FEI", bPercent = true},
    {sKey = "FER"},

    {sKey = "SEE", bPercent = true},
    {sKey = "SEP"},
    {sKey = "SEI", bPercent = true},
    {sKey = "SER"},

    {sKey = "AEE", bPercent = true},
    {sKey = "AEP"},
    {sKey = "AEI", bPercent = true},
    {sKey = "AER"},

    {sKey = "LEE", bPercent = true},
    {sKey = "LEP"},
    {sKey = "LEI", bPercent = true},
    {sKey = "LER"},

    {sKey = "DEE", bPercent = true},
    {sKey = "DEP"},
    {sKey = "DEI", bPercent = true},
    {sKey = "DER"},

    {sKey = "Toughness"},
    {sKey = "Suppress", bPercent = true},

    {sKey = "NORMALDMG", bPercent = true},
    {sKey = "SKILLDMG", bPercent = true},
    {sKey = "ULTRADMG", bPercent = true},
    {sKey = "OTHERDMG", bPercent = true},
    {sKey = "RCDNORMALDMG", bPercent = true},
    {sKey = "RCDSKILLDMG", bPercent = true},
    {sKey = "RCDULTRADMG", bPercent = true},
    {sKey = "RCDOTHERDMG", bPercent = true},
    {sKey = "MARKDMG", bPercent = true},

    {sKey = "SUMMONDMG", bPercent = true},
    {sKey = "RCDSUMMONDMG", bPercent = true},
    {sKey = "PROJECTILEDMG", bPercent = true},
    {sKey = "RCDPROJECTILEDMG", bPercent = true},

    {sKey = "GENDMG"},
    {sKey = "DMGPLUS"},
    {sKey = "FINALDMG"},
    {sKey = "FINALDMGPLUS"},
    {sKey = "WEERCD"},
    {sKey = "FEERCD"},
    {sKey = "SEERCD"},
    {sKey = "AEERCD"},
    {sKey = "LEERCD"},
    {sKey = "DEERCD"},
    {sKey = "GENDMGRCD"},
    {sKey = "DMGPLUSRCD"},

    {sKey = "NormalCritRate"},
    {sKey = "SkillCritRate"},
    {sKey = "UltraCritRate"},
    {sKey = "MarkCritRate"},
    {sKey = "SummonCritRate"},
    {sKey = "ProjectileCritRate"},
    {sKey = "OtherCritRate"},
    	
    {sKey = "NormalCritPower"},
    {sKey = "SkillCritPower"},
    {sKey = "UltraCritPower"},
    {sKey = "MarkCritPower"},
    {sKey = "SummonCritPower"},
    {sKey = "ProjectileCritPower"},
    {sKey = "OtherCritPower"},
    {sKey = "ToughnessDamageAdjust"},
    --玩家属性类�?
    {sKey = "EnergyConvRatio", bPercent = true, bPlayer = true},        -- 后台能量转化�?
    {sKey = "EnergyEfficiency", bPercent = true, bPlayer = true},       -- 前台能量获取倍率
}

AllEnum.CharConfigType = {
    Attr = 1,
    Char = 2,
    Skill = 3
}

AllEnum.SkillSlotStrEnum = {
    [GameEnum.skillSlotType.A] = tostring(GameEnum.skillSlotType.A),
    [GameEnum.skillSlotType.B] = tostring(GameEnum.skillSlotType.B),
    [GameEnum.skillSlotType.C] = tostring(GameEnum.skillSlotType.C),
    [GameEnum.skillSlotType.D] = tostring(GameEnum.skillSlotType.D),
    [GameEnum.skillSlotType.NORMAL] = tostring(GameEnum.skillSlotType.NORMAL),
}
AllEnum.SkillLvPowerFactor = {
    --技能等�??  { [1]A技�??-闪避  [2]B技�??-技�??1  [3]C技�??-技�??2  [4]D技�??-必杀  [5]Normal技�??-普攻 }
    [0] = {[1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0},
    [1] = {[1] = 0, [2] = 90, [3] = 100, [4] = 120, [5] = 80},
    [2] = {[1] = 0, [2] = 135, [3] = 150, [4] = 180, [5] = 120},
    [3] = {[1] = 0, [2] = 180, [3] = 200, [4] = 240, [5] = 160},
    [4] = {[1] = 0, [2] = 225, [3] = 250, [4] = 300, [5] = 200},
}
AllEnum.WorldMapNodeType = {
    Mainline = 1,       -- 主线关卡
    Roguelike = 2,      -- 遗迹关卡
    Branchline = 3,     -- 支线关卡
    Rogueboss = 4,      -- 地区boss
    FixedRoguelike = 5, -- 固定遗迹关卡
    Prologue = 6,       -- 序章演出
    DailyInstance = 7,  -- 日常副本
    TravelerDuel = 8,   -- 旅人对决
    InfinityTower = 9,  -- 无尽�?
    EquipmentInstance = 10,  -- 装备副本
    VamireSurvivor = 11, --吸血鬼模式
    ScoreBoss = 12,     --Boss积分挑战
    SkillInstance = 13,  -- 技能素材本
    Trial = 14,         -- 试玩关
    JointDrill = 15,     -- 总力战
}
AllEnum.FrameColor_New = {
    [0] = "0",
    [GameEnum.itemRarity.SSR] = "5", -- 彩色
    [GameEnum.itemRarity.SR] = "4", -- 橙色（黄色、金色）
    [GameEnum.itemRarity.R] = "3", -- 紫色
    [GameEnum.itemRarity.M] = "2", -- 蓝色
    [GameEnum.itemRarity.N] = "1", -- 白色
}
AllEnum.BoardFrameColor = {
    [0] = "0",
    [GameEnum.itemRarity.SSR] = "5", -- 彩色
    [GameEnum.itemRarity.SR] = "4", -- 橙色（黄色、金色）
    [GameEnum.itemRarity.R] = "3", -- 蓝色
    [GameEnum.itemRarity.M] = "0", -- 绿色
    [GameEnum.itemRarity.N] = "0", -- 白色
}
AllEnum.FrameType_New = {
    Item = "rare_item_a_",
    ItemS = "rare_item_b_",
    ItemSS = "rare_item_c_",
    CharList = "rare_list_",
    CharFrame = "rare_character_",
    BoardFrame = "rare_mainchara_",
    VestigePerk = "rare_vestige_xintiao_",
    RareBag = "rare_bag_",
    Outfit = "rare_fengjing_",
    OutfitPortrait = "rare_scenery_card_", -- 礼装立绘专用：大
    PresentsSide = "rare_gift_side_", -- 礼物界面专用
    PresentsEllipse = "rare_gift_ellipse_", -- 礼物界面专用
    PresentsDB = "rare_gift_db_", -- 礼物精通界面专�??
    PresentsCircle = "rare_gift_circle_", -- 礼物精通界面专�??
    SuperscriptDB = "rare_outfit_", -- 礼物和礼装选人界面�??
    Talent = "rare_talent_", -- 天赋
    SlotPerk = "rare_vestige_slot_", -- 槽位信条
    ThemePerk = "rare_vestige_theme_", -- 主题信条
    ExclusivePerk = "db_weapon_perk_", -- 专属信条
    Text = "rare_character_text_", -- 文字稀有度
    BuildRank = "rare_build_",
    BuildRankDB = "rare_build_db_",
    BuildFormation = "rare_team_build_db_",
    ShopGoods = "db_shop_character_",
    MallGoods = "db_mall_character_",
    DiscList = "rare_outfit_list_",
    FateCard = "rare_vestige_fatecard_",
    FateCardS = "rare_vestige_fatecard_icon_",
    Potential = "rare_vestige_card_",
    PotentialS = "rare_vestige_card_s_",
    StarTowerFateCard = "rare_vestige_fatecard_icon_",
    HarmonySkillL = "rare_outfit_skill_l_",
    HarmonySkillS = "rare_outfit_skill_s_",
    RandomProperty = "rare_chargem_db_a_",
    RandomPropertyLock = "rare_chargem_db_b_",
    DiscLimitS = "rare_outfit_exceed_s_",
    DiscLimitL = "rare_outfit_exceed_l_",
    DiscFrameL = "rare_outfit_team_l_",
    DiscFrameS = "rare_outfit_team_s_",
}
AllEnum.BuildGrade = {
    S = 3,
    A = 2,
    B = 1,
    C = 0,
}
AllEnum.FrameColor = {
    --[[
        注意 key 可能对应多种情况�??
        (1)item �?? Rarity 字段，SSR SR R M N�??
        (2)character �?? Grade 字段，SSR SR R 没有 M N�??
        (3)Monster �?? EpicLv 字段，SR R M N 没有 SSR�??
        (4)PreviewMonsterList �?? EpicLv 字段，SR R M N 没有 SSR�??
        最终都是一个稀有度数值（int）�?
        稀有度数值比较奇怪，数字越小，越稀有，有时间再全项目组统一调整�??
    ]]
    [GameEnum.itemRarity.SSR] = "5", -- 彩色
    [GameEnum.itemRarity.SR] = "4", -- 橙色（黄色、金色）
    [GameEnum.itemRarity.R] = "3", -- 紫色
    [GameEnum.itemRarity.M] = "2", -- 蓝色
    [GameEnum.itemRarity.N] = "1", -- 白色
}
local colorAll = Color(0.996, 0.694, 0.945, 1) -- 彩色
local colorOrange = Color(0.996, 0.757, 0.341, 1) -- 橙色
local colorPurple = Color(0.588, 0.6, 0.996, 1) -- 紫色
local colorBlue = Color(0.435, 0.812, 0.996, 1) -- 蓝色
local colorWhite = Color(0.804, 0.804, 0.804, 1) -- 白色
AllEnum.RarityColor = { -- 主要用于礼装等级底的颜色
    [GameEnum.itemRarity.SSR] = colorAll,
    [GameEnum.itemRarity.SR] = colorOrange,
    [GameEnum.itemRarity.R] = colorPurple,
    [GameEnum.itemRarity.M] = colorBlue,
    [GameEnum.itemRarity.N] = colorWhite
}
AllEnum.FrameType = {
    Item = "daoju", -- 最多见的所有物品都有的道具态品质边�??
    CharList = "juese", -- 应该已经弃用�??
    OutfitList = "lizhuang_a_", -- 礼装格子列表专用：小
    OutfitPortrait = "lizhuang_b_", -- 礼装立绘专用：大
    OutfitCharInfo = "lizhuang_c_", -- 礼装立绘专用：角色属性界面专�??
    TipFrame = "lizhuang_d_",
    PresentsAttr = "liwu_a_", -- 礼物界面专用
    PresentsMaster = "liwu_b_", -- 礼物精通界面专�??
    Perk = "perk_" --礼物�??
}
AllEnum.OutfitIconSurfix = {
    ListGrid = "_a",
    Item = "_b",
    CharInfo = "_c",
    OutInfo = "_d",
    Gacha = "_gacha",
}
AllEnum.Actor2DType = {
    Normal = 1,         -- 立绘
    FullScreen = 2,     -- 全屏CG
}
AllEnum.Disc2DType = {
    Base = 1,           -- 星盘大图
    Main = 2,           -- 主界面资源
    L2D = 3,            -- L2D
}
AllEnum.StoryAvgType = {
    Preview = 0,         -- 通过客户端内�?? GM 工具预览�??
    PureAvg = 1,         -- 纯Avg
    BeforeBattle = 2,    -- 战前Avg
    AfterBattle = 3,     -- 战后Avg
    Plot = 4,            -- 角色好感度剧情AVG
}
AllEnum.LevelResult = {
    Succeed = 0,        -- 成功（正常过层）
    Failed = 1,         -- 失败（退出关卡）
    Teleporter = 2,     -- 传送门（关卡内切换不作处理�??
}
AllEnum.TipPosition = {
    Top = 1,
    Bottom = 2,
    Right = 3,
    Left = 4,
}
AllEnum.BattleAnimSetting = {
    DayOnce = 1,         -- 一日一�?
    Open = 2,            -- 开�?
    Close = 3,           -- 关闭
}
AllEnum.CharacterScreenType = {
    Rare = 1,
    Element = 2,
}
AllEnum.LoginTime = {
    Today = 1,          -- 今天
    Yesday = 2,         -- 昨天
    Date = 3,           -- 具体日期
}
AllEnum.PresentsCircleRarityColor = { -- 主要用于礼物圈圈的颜�??
    [GameEnum.itemRarity.SSR] = Color(198/255, 244/255, 238/255, 1),
    [GameEnum.itemRarity.SR] = Color(1, 251/255, 212/255, 0.6),
    [GameEnum.itemRarity.R] = Color(192/255, 251/255, 1, 0.6),
    [GameEnum.itemRarity.M] = Color(217/255, 1, 238/255, 0.6),
    [GameEnum.itemRarity.N] = Color(1, 1, 1, 0.6),
}
AllEnum.RewardGachaType = {
    [GameEnum.itemRarity.SSR] = "icon_roguegacha_01%s",
    [GameEnum.itemRarity.SR] = "icon_roguegacha_02%s",
    [GameEnum.itemRarity.R] = "icon_roguegacha_03%s",
    [GameEnum.itemRarity.M] = "icon_roguegacha_04%s",
}
-- 排序按钮的类�??
AllEnum.SortType = {
    Level = 1,
    Rarity = 2,
    ElementType = 3,
    Id = 4,
    Skill = 5,
    Affinity = 6,
    Time = 7,
}

AllEnum.CharSortField = {
    [AllEnum.SortType.Level] = "Level",
    [AllEnum.SortType.Rarity] = "Rare",
    [AllEnum.SortType.ElementType] = "EET",
    [AllEnum.SortType.Id] = "nId",
    [AllEnum.SortType.Time] = "CreateTime",
    [AllEnum.SortType.Skill] = "SkillLevel",
    [AllEnum.SortType.Affinity] = "Favorability",
}

AllEnum.DiscSortField = {
    [AllEnum.SortType.Level] = "nLevel",
    [AllEnum.SortType.Rarity] = "nRarity",
    [AllEnum.SortType.Time] = "nCreateTime",
    [AllEnum.SortType.ElementType] = "nEET",
    [AllEnum.SortType.Id] = "nId",
}

AllEnum.SkillElementColor = {
    [GameEnum.elementType.WE] = "#4e9fd8",
    [GameEnum.elementType.FE] = "#ef522e",
    [GameEnum.elementType.SE] = "#a1673d",
    [GameEnum.elementType.AE] = "#87bf10",
    [GameEnum.elementType.LE] = "#f3b521",
    [GameEnum.elementType.DE] = "#b15f9f",
}
AllEnum.SkillElementBgColor = {
    [GameEnum.elementType.WE] = "#3432ad",
    [GameEnum.elementType.FE] = "#791834",
    [GameEnum.elementType.SE] = "#552611",
    [GameEnum.elementType.AE] = "#186e30",
    [GameEnum.elementType.LE] = "#ac4b20",
    [GameEnum.elementType.DE] = "#561466",
}
AllEnum.ElementIconType = {
    Skill = "db_common_element_skill_", -- Skill旧的
    Icon = "icon_common_property_",
    SkillEx = "rare_character_skill_", -- Skill新的
    VestigeSkill = "rare_vestige_skill_",
    SpPotential = "Sp_Potential_0",       --特殊潜能
}
AllEnum.MessageBox = {
    Confirm = 1,    -- 两个按钮的文本弹�??
    Alert = 2,      -- 一个按钮的文本弹窗
    Tips = 3,       -- 飘字提示
    Desc = 4,       -- 说明
    Item = 5,       -- 带道�?
    ItemList = 6,   -- 全道�?
    PlainText = 7,  -- 不带确认取消按钮的说明文�?
    Char = 8,       -- 带角色
}

AllEnum.SuccessBar = {
    Blue = 1,
    Yellow = 2,
    Purple = 3,
}
AllEnum.PerkState = {
    Replace = 1,
    New = 2,
    Max = 3,
    Up = 4,
}
AllEnum.MallToggle = {
    MonthlyCard = 1,
    Package = 2,
    Gem = 3,
    Shop = 4,
    Skin = 5,
}
AllEnum.AvgBubbleShowType = {
    Avg = 1,
    Voice = 2,
}
AllEnum.SkillTypeShow = {
    [1] = {iconIndex = 1, bgIconIndex = 1, sLanguageId = "Char_Skill_Type_1", bgColor = "#4f658f"},  -- 普通攻�?
    [2] = {iconIndex = 2, bgIconIndex = 2, sLanguageId = "Char_Skill_Type_2", bgColor = "#4a59b0"},  -- 技�?
    [3] = {iconIndex = 4, bgIconIndex = 4, sLanguageId = "Char_Skill_Type_3", bgColor = "#4a59b0"}, -- 支援
    [4] = {iconIndex = 3, bgIconIndex = 3, sLanguageId = "Char_Skill_Type_4", bgColor = "#c545a2"},  -- 必杀技
}
AllEnum.CharBgPanelShowType = {
    None = 0,
    L2D = 1,
    Weapon = 2,
}
AllEnum.RedDotType = {
    Single = 1,     -- 单独红点显示（只控制节点显示隐藏�?
    Number = 2,     -- 显示数字
}
AllEnum.UIDragType = {
    DragStart = 1,     
    Drag = 2,
    DragEnd = 3,
}
AllEnum.DailyInstanceState = {
    None = 0,
    Open = 1,           --开�?
    Not_OpenDay = 2,    --未到开放时�?
    Not_WorldClass = 3, --世界等级不满�?
    Not_MainLine = 4,   --主线未通关
    Not_HardUnlock = 5, --难度未解�?
}
AllEnum.EquipmentInstanceState = {
    None = 0,
    Open = 1,           --开�?
    Not_OpenDay = 2,    --未到开放时�?
    Not_WorldClass = 3, --世界等级不满�?
    Not_MainLine = 4,   --主线未通关
    Not_HardUnlock = 5, --难度未解�?
}
AllEnum.SkillInstanceState = {
    None = 0,
    Open = 1,           --开启
    Not_WorldClass = 2, --世界等级不满�?
    Not_HardUnlock = 3, --难度未解�?
}
AllEnum.RogueBossLevelState = {
    None = 0,
    Open = 1,           --开�?
    Not_OpenDay = 2,    --未到开放时�?
    Not_RogueLike = 3,  --遗迹未通关
    Not_MainLine = 4,   --主线未通关
    Not_HardUnlock = 5, --难度未解�?
}
AllEnum.CraftingToggle = {
    Material = 1,
    Presents = 2,
}
--任务状�?
AllEnum.ActQuestStatus = {
    Complete = 1,
    UnComplete = 2,
    Received = 3,
}
--手机聊天状态
AllEnum.PhoneChatState = {
    None = 0,
    Complete = 1, --已结束
    New = 2, --未开始
    UnComplete = 3, --进行中
}

AllEnum.EnhancedPerkState = {
    On = 1, -- 进行�?
    Off = 2, -- 未揭�?
    Lock = 3, -- 冻结
    Complete = 4, -- 已获�?
}

AllEnum.SideBaner = {
    Achievement = 1,
    DictionaryReward = 2,
    DictionaryEntry = 3,
    Favour = 4,
}

AllEnum.RMBOrderType = {
    Mall = 1,
    BattlePass = 2,
}

AllEnum.AvgLogType = {
    Talk = 1,
    Choice = 2,
    Voiceover = 3,
    PhoneMsg = 4,
    PhoneMsgChoice = 5,
    Thought = 6,
}

AllEnum.DiscTab = {
    Info = 1,
    Development = 2,
    BreakLimit = 3,
    Music = 4,
}

AllEnum.DiscSucBar = {
    Upgrade = 1,
    Advance = 2,
    BreakLimit = 3,
}

AllEnum.EquipmentType = {
    [GameEnum.equipmentType.Square] = { Language = "Equipment_Type_Square", Icon = "Icon/ZZZOther/equip_a_mini", },
    [GameEnum.equipmentType.Circle] = { Language = "Equipment_Type_Circle", Icon = "Icon/ZZZOther/equip_b_mini", },
    [GameEnum.equipmentType.Pentagon] = { Language = "Equipment_Type_Pentagon", Icon = "Icon/ZZZOther/equip_c_mini", },
}

AllEnum.EquipmentToggle = {
    Basic = 1,          -- 属性（装备、替换）
    Upgrade = 2,        -- 升级
}

--装备槽位对应类型
AllEnum.EquipmentSlot = {
    [1] = GameEnum.equipmentType.Square,
    [2] = GameEnum.equipmentType.Circle,
    [3] = GameEnum.equipmentType.Pentagon,
}

--装备品质对应星星显示
AllEnum.EquipmentRarity_Star = {
    [0] = 0,
    [GameEnum.itemRarity.SSR] = 5,
    [GameEnum.itemRarity.SR] = 4,
    [GameEnum.itemRarity.R] = 3,
    [GameEnum.itemRarity.M] = 2,
    [GameEnum.itemRarity.N] = 1,
}

AllEnum.MainViewCorner = {
    Role = 1,
    Disc = 2,
    Recruit = 3,
    Mainline= 4,
}

AllEnum.EffectType = {
    Affinity  = 1,
    Talent    = 2,
    Outfit    = 3,
    FateCard  = 4,
    Potential = 5,
    Equipment = 6,
}

AllEnum.ElementColor = {
    [GameEnum.elementType.WE] = Color(70/255, 143/255 , 194/255),
    [GameEnum.elementType.FE] = Color(218/255, 73/255 , 40/255),
    [GameEnum.elementType.SE] = Color(133/255, 83/255 , 47/255),
    [GameEnum.elementType.AE] = Color(95/255, 144/255 , 11/255),
    [GameEnum.elementType.LE] = Color(225/255, 152/255 , 25/255),
    [GameEnum.elementType.DE] = Color(137/255, 69/255 , 140/255),
    [GameEnum.elementType.NONE] = Color(38/255, 66/255 , 120/255),
}

--潜能品质
AllEnum.PotentialRarityCfg = {
    [GameEnum.itemRarity.SSR] = {sColor = "#9b77e3"},
    [GameEnum.itemRarity.SR] = {sColor = "#db8104" },
    [GameEnum.itemRarity.R] = {sColor = "#325e7c"  },
}

--特殊潜能角色元素类型
AllEnum.PotentialElementColor = {
    [GameEnum.elementType.WE] = {sColor = "#4784af"},
    [GameEnum.elementType.FE] = {sColor = "#c1493a"},
    [GameEnum.elementType.SE] = {sColor = "#845640"},
    [GameEnum.elementType.AE] = {sColor = "#7a9c6c"},
    [GameEnum.elementType.LE] = {sColor = "#c68c3e"},
    [GameEnum.elementType.DE] = {sColor = "#a05793"},
}

--音符类型
AllEnum.NoteTypeCfg = {
    -- [GameEnum.noteType.A] = {sLanguage = "StarTower_Note_Red", sFxName = "red"},
    -- [GameEnum.noteType.B] = {sLanguage = "StarTower_Note_Blue", sFxName = "blue"},
    -- [GameEnum.noteType.C] = {sLanguage = "StarTower_Note_Green", sFxName = "green"},
    -- [GameEnum.noteType.D] = {sLanguage = "StarTower_Note_Yellow", sFxName = "yellow"},
    -- [GameEnum.noteType.E] = {sLanguage = "StarTower_Note_Purple", sFxName = "purple"},
    -- --随机音符
    -- [6] = {sLanguage = "StarTower_Note_Random", sFxName = "white"},
}

--星塔房间类型
AllEnum.StarTowerRoomName = {
    [GameEnum.starTowerRoomType.BattleRoom] = {Color = "#ebaf3c", Icon = "zs_vestige_map_icon_1" , SweepIcon = "zs_fastBattle_map_icon_1" , Language = "StarTower_BattleRoomName"}, ---- 普通战�?
    [GameEnum.starTowerRoomType.EliteBattleRoom]  = {Color = "#f07c3a", Icon = "zs_vestige_map_icon_2" , SweepIcon = "zs_fastBattle_map_icon_2" ,Language = "StarTower_EliteBattleRoomName"}, ---- 精英战斗
    [GameEnum.starTowerRoomType.BossRoom]  = {Color = "#e44d49", Icon = "zs_vestige_map_icon_3" , SweepIcon = "zs_fastBattle_map_icon_3" ,Language = "StarTower_BossRoomName"}, ---- 普通Boss
    [GameEnum.starTowerRoomType.FinalBossRoom] = {Color = "#e44d49", Icon = "zs_vestige_map_icon_3" , SweepIcon = "zs_fastBattle_map_icon_3" ,Language = "StarTower_FinalBossRoomName"}, ---- 最终Boss
    [GameEnum.starTowerRoomType.DangerRoom] = {Color = "#e44d49", Icon = "zs_vestige_map_icon_3" , SweepIcon = "zs_fastBattle_map_icon_3" ,Language = "StarTower_DangerRoomName"}, ---- 危险房间
    [GameEnum.starTowerRoomType.HorrorRoom] = {Color = "#e44d49", Icon = "zs_vestige_map_icon_8" , SweepIcon = "zs_fastBattle_map_icon_8" ,Language = "StarTower_HorrorRoomName"}, ---- 高危房间
    [GameEnum.starTowerRoomType.ShopRoom] = {Color = "#1aa989", Icon = "zs_vestige_map_icon_5" , SweepIcon = "zs_fastBattle_map_icon_5" ,Language = "StarTower_ShopRoomName"}, ---- 商店�?
    [GameEnum.starTowerRoomType.EventRoom] = {Color = "#41a4c9", Icon = "zs_vestige_map_icon_6" , SweepIcon = "zs_fastBattle_map_icon_6" ,Language = "StarTower_EventRoomName"}, ---- 事件�?
}

--潜能icon显示类型
AllEnum.PotentialIconSurfix = {
    A = "_A",
    B = "_B",
}

--潜能icon显示类型
AllEnum.PotentialIconSizeSurfix = {
    S = "_S",
    M = "_M",
}

--潜能角标
AllEnum.PotentialCornerIcon = {
    [GameEnum.potentialCornerType.Diamond] = {sIconA = "Icon/Potential/Potential_Diamond_A", sIconB = "Icon/Potential/Potential_Diamond_B"},
    [GameEnum.potentialCornerType.Triangle] = {sIconA = "Icon/Potential/Potential_Triangle_A", sIconB = "Icon/Potential/Potential_Triangle_B"},
    [GameEnum.potentialCornerType.Round] = {sIconA = "Icon/Potential/Potential_Round_A", sIconB = "Icon/Potential/Potential_Round_B"},
}

--星塔背包页签类型
AllEnum.StarTowerDepotTog = {
    Potential = 1,
    DiscSkill = 2,
    CharInfo = 3,
    ItemList = 4,
}

AllEnum.DiscSkillType = {
    Common = 1,
    Passive = 2,
}

------ 筛�?-----------------------
-- 角色属�?(元素类型)
AllEnum.Char_Element = {
    [GameEnum.elementType.WE] = {sLanguage = "T_Element_Attr_1", icon = "icon_common_property_1", nSort = 1}, --�?
    [GameEnum.elementType.FE] = {sLanguage = "T_Element_Attr_2", icon = "icon_common_property_2", nSort = 2}, --�?
    [GameEnum.elementType.SE] = {sLanguage = "T_Element_Attr_3", icon = "icon_common_property_3", nSort = 3}, --�?
    [GameEnum.elementType.AE] = {sLanguage = "T_Element_Attr_4", icon = "icon_common_property_4", nSort = 4}, --�?
    [GameEnum.elementType.LE] = {sLanguage = "T_Element_Attr_5", icon = "icon_common_property_5", nSort = 5}, --�?
    [GameEnum.elementType.DE] = {sLanguage = "T_Element_Attr_6", icon = "icon_common_property_6", nSort = 6}, --�?
}
-- 角色稀有度
AllEnum.Char_Rarity = {
    --[GameEnum.characterGrade.R]   = {},
    [GameEnum.characterGrade.SR]  = {nSort = 2},
    [GameEnum.characterGrade.SSR] = {nSort = 1},
}
-- 角色标签 力量风格
AllEnum.Char_PowerStyle = {
    [GameEnum.characterJobClass.Vanguard]      = {sLanguage = 101}, -- 枪弹
    [GameEnum.characterJobClass.Balance]       = {sLanguage = 102}, -- 格斗
    [GameEnum.characterJobClass.Support]       = {sLanguage = 103}, -- 奇术
}
-- 角色标签 战斗风格
AllEnum.Char_TacticalStyle = {
    [201]       = {sLanguage = 201}, -- 收集�?
    [202]       = {sLanguage = 202}, -- 稳扎稳打
    [203]       = {sLanguage = 203}, -- 冒险�?
    [204]       = {sLanguage = 204}, -- 奇思妙�?
    [205]       = {sLanguage = 205}, -- 求知心切
}
-- 角色标签 所属势�?
AllEnum.Char_AffiliatedForces = {
    [301]       = {sLanguage = 301}, -- 空白旅团
    [302]       = {sLanguage = 302}, -- 帝国卫队
    [303]       = {sLanguage = 303}, -- 白猫剧团
    [304]       = {sLanguage = 304}, -- 联合种业
    [305]       = {sLanguage = 305}, -- 白泽公署
    [306]       = {sLanguage = 306}, -- 星辉学馆
    [307]       = {sLanguage = 307}, -- 凤凰炒蛋
    [308]       = {sLanguage = 308}, -- 谷风家政
    [309]       = {sLanguage = 309}, -- 万送屋
    [310]       = {sLanguage = 310}, -- 自由旅人
    [311]       = {sLanguage = 311}, -- 灰风俱乐�?
    [312]       = {sLanguage = 312}, -- 绯曈传讯
    [314]       = {sLanguage = 314}, -- 云笈文化
    [315]       = {sLanguage = 315}, -- 恩赐意志
    [316]       = {sLanguage = 316}, -- 花令旅团
    [317]       = {sLanguage = 317}, -- 黄昏裁判
}
-- 星盘稀有度
AllEnum.Star_Rarity = {
    --[GameEnum.itemRarity.N]   = {},
    --[GameEnum.itemRarity.M]   = {},
    [GameEnum.itemRarity.R]   = {nSort = 3},
    [GameEnum.itemRarity.SR]  = {nSort = 2},
    [GameEnum.itemRarity.SSR] = {nSort = 1},
}
-- 星盘音符
AllEnum.Star_Note = {
    [90011] = {nSort = 1},
    [90012] = {nSort = 2},
    [90013] = {nSort = 3},
    [90014] = {nSort = 4},
    [90015] = {nSort = 5},
    [90016] = {nSort = 6},
    [90017] = {nSort = 7},
    [90018] = {nSort = 8},
    [90019] = {nSort = 9},
    [90020] = {nSort = 10},
    [90021] = {nSort = 11},
    [90022] = {nSort = 12},
    [90023] = {nSort = 13},
}
-- 星盘属�?(元素类型)
AllEnum.Star_Element = {
    [GameEnum.elementType.WE] = {sLanguage = "T_Element_Attr_1", icon = "icon_common_property_1", nSort = 1}, --�?
    [GameEnum.elementType.FE] = {sLanguage = "T_Element_Attr_2", icon = "icon_common_property_2", nSort = 2}, --�?
    [GameEnum.elementType.SE] = {sLanguage = "T_Element_Attr_3", icon = "icon_common_property_3", nSort = 3}, --�?
    [GameEnum.elementType.AE] = {sLanguage = "T_Element_Attr_4", icon = "icon_common_property_4", nSort = 4}, --�?
    [GameEnum.elementType.LE] = {sLanguage = "T_Element_Attr_5", icon = "icon_common_property_5", nSort = 5}, --�?
    [GameEnum.elementType.DE] = {sLanguage = "T_Element_Attr_6", icon = "icon_common_property_6", nSort = 6}, --�?
    [GameEnum.elementType.NONE] = {sLanguage = "T_Element_Attr_7", icon = "icon_common_property_7", nSort = 7}, --�?
}
-- 星盘标签
AllEnum.Star_Tag = {
    [800]       = {sLanguage = 800},
    [801]       = {sLanguage = 801},
    [802]       = {sLanguage = 802},
    [803]       = {sLanguage = 803},
    [804]       = {sLanguage = 804},
    [805]       = {sLanguage = 805},
    [806]       = {sLanguage = 806},
    [807]       = {sLanguage = 807},
}
-- 武器稀有度
AllEnum.Equip_Rarity = {
    --[GameEnum.itemRarity.N]   = {},
    --[GameEnum.itemRarity.M]   = {},
    [GameEnum.itemRarity.R]   = {},
    [GameEnum.itemRarity.SR]  = {},
    [GameEnum.itemRarity.SSR] = {},
}
-- 武器类型
AllEnum.Equip_Type = {
    [GameEnum.equipmentType.Square]   = { sLanguage = "Equipment_Type_Square", icon = "Icon/ZZZOther/equip_a_mini", },
    [GameEnum.equipmentType.Circle]   = { sLanguage = "Equipment_Type_Circle", icon = "Icon/ZZZOther/equip_b_mini", },
    [GameEnum.equipmentType.Pentagon] = { sLanguage = "Equipment_Type_Pentagon", icon = "Icon/ZZZOther/equip_c_mini", },
}
-- 武器主属性-盾形
AllEnum.Equip_Theme_Square = {
    [120081] = {sLanguage = 120081},      --暴击伤害
    [120641] = {sLanguage = 120641},      --印记伤害
    [120571] = {sLanguage = 120571},      --技能伤害倍率
}
-- 武器主属性-菱形
AllEnum.Equip_Theme_Circle = {
    [120011] = {sLanguage = 120011},      --基础攻击
    [120021] = {sLanguage = 120021},      --防御
    [120561] = {sLanguage = 120561},      --普攻伤害
}
-- 武器主属性-方形
AllEnum.Equip_Theme_Pentagon = {
    [120031] = {sLanguage = 120031},      --基础生命
    [120091] = {sLanguage = 120091},      --防御穿透
    [120581] = {sLanguage = 120581},      --大招伤害倍率
}
-- 装备随机属性标签 力量风格
AllEnum.Equip_PowerStyle = {
    [101]       = {sLanguage = 101, nSort = 2}, -- 枪弹
    [102]       = {sLanguage = 102, nSort = 3}, -- 格斗
    [103]       = {sLanguage = 103, nSort = 4}, -- 奇术
    [104]       = {sLanguage = 104, nSort = 1}, -- 空
}
-- 装备随机属性标签 战斗风格
AllEnum.Equip_TacticalStyle = {
    [201]       = {sLanguage = 201, nSort = 2}, -- 收集�?
    [202]       = {sLanguage = 202, nSort = 3}, -- 稳扎稳打
    [203]       = {sLanguage = 203, nSort = 4}, -- 冒险�?
    [204]       = {sLanguage = 204, nSort = 5}, -- 奇思妙�?
    [205]       = {sLanguage = 205, nSort = 6}, -- 求知心切
    [206]       = {sLanguage = 206, nSort = 1}, -- 空
}
-- 装备随机属性标签 所属势力
AllEnum.Equip_AffiliatedForces = {
    [301]       = {sLanguage = 301, nSort = 2}, -- 空白旅团
    [302]       = {sLanguage = 302, nSort = 3}, -- 帝国卫队
    [303]       = {sLanguage = 303, nSort = 4}, -- 白猫剧团
    [304]       = {sLanguage = 304, nSort = 5}, -- 联合种业
    [305]       = {sLanguage = 305, nSort = 6}, -- 白泽公署
    [306]       = {sLanguage = 306, nSort = 7}, -- 星辉学馆
    [307]       = {sLanguage = 307, nSort = 8}, -- 凤凰炒蛋
    [308]       = {sLanguage = 308, nSort = 9}, -- 谷风家政
    [309]       = {sLanguage = 309, nSort = 10}, -- 万送屋
    [310]       = {sLanguage = 310, nSort = 11}, -- 自由旅人
    [311]       = {sLanguage = 311, nSort = 12}, -- 灰风俱乐�?
    [312]       = {sLanguage = 312, nSort = 13}, -- 绯曈传讯
    [313]       = {sLanguage = 313, nSort = 1}, -- 空
}
-- 武器随机词条契合度
AllEnum.Equip_Match = {
    [1] = {sLanguage = "Equipment_Filter_Match_Count_1", nSort = 1},
    [2] = {sLanguage = "Equipment_Filter_Match_Count_2", nSort = 2},
    [3] = {sLanguage = "Equipment_Filter_Match_Count_3", nSort = 3},
    [4] = {sLanguage = "Equipment_Filter_Match_Count_4", nSort = 4},
}

--筛选选项
AllEnum.ChooseOption = {
    --for 角色
    Char_Element          = 1, --属�?(元素类型)
    Char_Rarity           = 2, --稀有度
    Char_PowerStyle       = 3, --角色标签 力量风格
    Char_TacticalStyle    = 4,--角色标签 战斗风格
    Char_AffiliatedForces = 5,--角色标签 所属势�?

    --for 星盘
    Star_Rarity     = 10, -- 稀有度
    Star_Note       = 11, -- 音符
    Star_Element    = 13, -- 元素类型
    Star_Tag        = 14, -- 标签

    --for 纹章
    Equip_Rarity = 20, --稀有度
    Equip_Type   = 21, --装备类型
    Equip_Theme_Square  = 22, --装备基础属性
    Equip_Theme_Circle  = 23, --装备基础属性
    Equip_Theme_Pentagon  = 24, --装备基础属性
    Equip_PowerStyle = 25,  --装备标签 力量风格
    Equip_TacticalStyle = 26,  --装备标签 战斗风格
    Equip_AffiliatedForces = 27,  --装备标签 所属势力
    Equip_Match = 28, --随机词条契合度
}

AllEnum.OptionLayout = {
    Normal = 1,         --筛选框 + 文字
    NormalWithIcon = 2, --筛选框 + 图标 + 文字
    Image  = 3,         --筛选框 + 图片
}
AllEnum.ChooseOptionCfg = {
    [AllEnum.ChooseOption.Char_Element]          = {sLanguage = "Filter_Element", layout = AllEnum.OptionLayout.NormalWithIcon, items = AllEnum.Char_Element},-- Char_Attr
    [AllEnum.ChooseOption.Char_Rarity]           = {sLanguage = "Filter_Rare", layout = AllEnum.OptionLayout.Image, items = AllEnum.Char_Rarity},-- Char_Rarity
    [AllEnum.ChooseOption.Char_PowerStyle]       = {sLanguage = "Filter_Tag1", layout = AllEnum.OptionLayout.Normal, items = AllEnum.Char_PowerStyle},-- Char_Rarity
    [AllEnum.ChooseOption.Char_TacticalStyle]    = {sLanguage = "Filter_Tag2", layout = AllEnum.OptionLayout.Normal, items = AllEnum.Char_TacticalStyle},-- Char_Rarity
    [AllEnum.ChooseOption.Char_AffiliatedForces] = {sLanguage = "Filter_Tag3", layout = AllEnum.OptionLayout.Normal, items = AllEnum.Char_AffiliatedForces},-- Char_Rarity

    [AllEnum.ChooseOption.Star_Rarity]           = {sLanguage = "Filter_Rare", layout = AllEnum.OptionLayout.Image, items = AllEnum.Star_Rarity},-- Star_Rarity
    [AllEnum.ChooseOption.Star_Note]             = {sLanguage = "Filter_Note", layout = AllEnum.OptionLayout.NormalWithIcon, items = AllEnum.Star_Note},-- Star_Note
    [AllEnum.ChooseOption.Star_Element]          = {sLanguage = "Filter_Element", layout = AllEnum.OptionLayout.NormalWithIcon, items = AllEnum.Star_Element},-- Star_Element
    [AllEnum.ChooseOption.Star_Tag]              = {sLanguage = "Filter_Tag1", layout = AllEnum.OptionLayout.Normal, items = AllEnum.Star_Tag},-- Star_Tag

    [AllEnum.ChooseOption.Equip_Rarity]       = {sLanguage = "Filter_Rare", layout = AllEnum.OptionLayout.Image, items = AllEnum.Equip_Rarity},-- Equip_Rarity
    [AllEnum.ChooseOption.Equip_Type]         = {sLanguage = "Filter_EquipmentType", layout = AllEnum.OptionLayout.NormalWithIcon, items = AllEnum.Equip_Type},-- Equip_Type
    [AllEnum.ChooseOption.Equip_Theme_Square] = {sLanguage = "Equipment_Filter_Main_Attr", layout = AllEnum.OptionLayout.Normal, items = AllEnum.Equip_Theme_Square},-- Equip_Theme_Square
    [AllEnum.ChooseOption.Equip_Theme_Circle] = {sLanguage = "Equipment_Filter_Main_Attr", layout = AllEnum.OptionLayout.Normal, items = AllEnum.Equip_Theme_Circle},-- Equip_Theme_Circle
    [AllEnum.ChooseOption.Equip_Theme_Pentagon] = {sLanguage = "Equipment_Filter_Main_Attr", layout = AllEnum.OptionLayout.Normal, items = AllEnum.Equip_Theme_Pentagon},-- Equip_Theme_Pentagon
    [AllEnum.ChooseOption.Equip_PowerStyle]       = {sLanguage = "Filter_Tag1", layout = AllEnum.OptionLayout.Normal, items = AllEnum.Equip_PowerStyle},-- Equip_PowerStyle
    [AllEnum.ChooseOption.Equip_TacticalStyle]    = {sLanguage = "Filter_Tag2", layout = AllEnum.OptionLayout.Normal, items = AllEnum.Equip_TacticalStyle},-- Equip_TacticalStyle
    [AllEnum.ChooseOption.Equip_AffiliatedForces] = {sLanguage = "Filter_Tag3", layout = AllEnum.OptionLayout.Normal, items = AllEnum.Equip_AffiliatedForces},-- Equip_AffiliatedForces
    [AllEnum.ChooseOption.Equip_Match]        = {sLanguage = "Equipment_Filter_Match_Count", layout = AllEnum.OptionLayout.Normal, items = AllEnum.Equip_Match},-- Equip_Theme
}

AllEnum.OptionType = {
    Char = 1,
    Disc = 2,
    Equipment = 3,
}

AllEnum.RewardType = {
    First = 1,
    Three = 2,
    Extra = 3,
}

AllEnum.FormationEnterType = {
    MainLine = 0,           -- 主线
    FixedRoguelike = 1,     -- 老版肉鸽
    StarTower = 2,          -- 普通星塔
}

AllEnum.RegionBossFormationType = {
    RegionBoss = 1,             -- 区域boss
    TravelerDuel = 2,           -- 旅人对决
    DailyInstance = 3,          -- 日常副本
    InfinityTower = 4,          -- 无尽塔
    EquipmentInstance = 5,      -- 装备副本
    Story = 6,                  -- 主线
    Vampire = 7,                -- 吸血鬼
    ScoreBoss = 8,              -- 积分boss
    SkillInstance = 9,          -- 技能本
    WeeklyCopies = 10,          -- 周本
    JointDrill = 11,            -- 总力战
    ActivityLevels = 12,        -- 中型活动挑战关卡
}

AllEnum.EnergyPanelType = {
    Main = 1,               -- 购买主界面
    BuyConfirm = 2,         -- 体力兑换
    ItemUse = 3,            -- 道具使用
    BatteryUse = 4,         -- 干劲储藏
}

--委托状态类型
AllEnum.DispatchState = {
    CanAccept = 0,             --可以接取
    Accepting = 1,             --已经接取
    Complete = 2,              --完成待领奖励
    Done = 3,                   --已领奖
}

--登录弹窗队列类型
AllEnum.PopUpType = {
    DailyCheckIn = 1,               -- 每日签到
    MonthlyCard = 2,                -- 月卡
    Activity = 3,                   -- 活动推送
    ActivityLogin = 4,              -- 登录活动弹窗
    NewChat = 5,                    -- 新聊天
    FuncUnlock = 6,                 -- 功能解锁
    WorldClass = 7,                 -- 升级
}

AllEnum.GamepadUIType = {
    Xbox = 1,   -- 显示Xbox的图标
    PS = 2,     -- 显示PS的图标
    Keyboard = 3,     -- 显示键盘的图标
    Mouse = 4,     -- 显示键盘的图标
    Other = 5   -- 其他模式不显示图标
}

AllEnum.StarTowerBookPanelType = {
    Main = 1,               -- 入口
    Potential = 2,          -- 潜能
    FateCard = 3,           -- 命运卡
    Event = 4,              -- 事件
    Affinity = 5,           -- NPC好感度
}

AllEnum.FateCardBookStatus = {
    Lock = 1,               -- 未解锁
    UnLock = 2,             -- 已解锁未收集
    Collect = 3,            -- 已收集
}

AllEnum.BookQuestStatus = {
    Complete = 1,
    UnComplete = 0,
    Received = 2,
}

AllEnum.DatingEventStatus = {
    Lock = 1,
    Unlock = 2,
    Received = 3,
}

AllEnum.DatingKrTags = {
    ["1"] = {["==KR1=="] = "는",
             ["==KR2=="] = "가",
             ["==KR3=="] = "를",
             ["==KR4=="] = "와",},
    ["2"] = {["==KR1=="] = "은",
             ["==KR2=="] = "이",
             ["==KR3=="] = "을",
             ["==KR4=="] = "과",},
}

AllEnum.PotentialCardType = {
    StarTower = 1,          -- 星塔内
    CharInfo = 2,           -- 角色信息
    Book = 3,               -- 图鉴
    TowerDefense = 4,       -- 塔防
    Detial = 5,             -- 详细信息
}

AllEnum.PhoneTogType = {
    Chat = 1,               -- 聊天
    Dating = 2,             -- 邀约
    Gift = 3,               -- 赠礼
}

AllEnum.ReceivePropsTitle = {
    Common = 1,                 -- 通用（获得道具）
    Dating = 2,                 -- 邀约（获得回礼）
}

AllEnum.DiscSkillIconSurfix = {
    Small = "_S",
    Corner = "_jb",
}

AllEnum.QuestPanelTab = {
    GuideQuest = 1,
    WorldClass = 2,
    DailyQuest = 3,
    Tutorial=4,
}

AllEnum.StarTowerFastBattleBg = {
    Bg_L = "bg_fastBattle_%s_l",
    Bg_R = "bg_fastBattle_%s_r",
    Flag = "zs_fastBattle_%s",
}

AllEnum.FateCardBundleIcon = {
    L = "_L", 
    S = "_S",
}

AllEnum.WorldClassType = {
    LevelUp = 1,        --升级
    Advance = 2,        --突破
}

-- 表名
AllEnum.ShopCondSource = {
    ResidentGoods = 1,
    ResidentShop = 2,
    MallShop = 3,
    MallPackage = 4,
}
-- 公告类型
AllEnum.AnnType={
    SystemAnn=1,    --系统公告
    ActivityAnn=2,  --活动公告
    Other1=3,       --其他1
    Other2=4,       --其他2
}

-- 星塔局内侧边提示
AllEnum.StarTowerTipsType={
    ItemTip = 1,
    DiscTip = 2,
    FateCardTip = 3,
    NoteTip = 4,
    NPCAffinity = 5,
}

--[[
    UI排序相关设计规划：
    [sortingLayer] 从后往前的顺序是：UI, UI Top,UI Overlay，越靠前的越优先显示（不会被遮挡）。
    [sortingOrder] 在 sortingLayer 相同时，按 order 的数字大小，从小（靠后）到大（靠前）排序。
    Tips: Unity Canvas sortingOrder 的取值范围是 [-32768, 32767] 闭区间。
]]
AllEnum.UI_SORTING_ORDER = {
    ----------【UI Top】----------
    AVG_Bubble = 298, -- 29800 气泡AVG
    AVG_ST = 299, -- 29900 常规AVG
    Guide = 32000, -- 新手引导
    GMMonsterAI = 32760, -- GM工具（其实使用处是在c#里，c#里是数字写死的）
    GMTool = 32760, -- GM工具
    --CBT_Tips = 32760, -- 删档测试提示（当前版本为测试版本，不代表最终游戏品质。）
    Transition = 32761, -- 转场
    ProVideo = 32762, -- 播视频
    MessageBox = 32763, -- 弹框
    BuiltinUICanvas = -32768, -- 内置UI根节点（一个小集合：loading + alert + connecting + block）
    --BuiltIn_Loading = 32764, -- 已弃用此简易的 BuiltIn Loading 所以此值给 Tpis 使用（注意：由于 UI 功能需要 Tips 要比 MessageBox 高）
    Tips = 32764,
    TipsEx = 32765,
    BuiltIn_Alert = 32766, -- 内置弹框
    BuiltIn_Connecting = 32767, -- 链接中
    BuiltIn_Block = 32767, -- 触屏操控的全局禁用
    
    ----------【UI Overlay】----------
    Player_Info = 32764, -- 玩家UID等信息
    LampNotice = 32764, -- 走马灯形式显示服务器维护通知
    MessageBoxOverlay = 32764, -- MessageBox 里的 SideBanner 和 飘字
    BlackEdge = 32765, -- 补黑边
    _FPSCounter = 32766, -- FPS debug
    TouchEffectUI = 32767, -- 屏幕点击特效
}

--手机消息类型
AllEnum.PhoneMsgType = {
    ReceiveMsg = 0,             -- 收消息
    ReplyMsg = 1,               -- 直接回复消息
    ReplyChoiceMgs = 2,         -- 选项回复消息
    ReceiveImgMsg = 3,          -- 收到图片（表情）
    ReplyImgMsg = 4,            -- 回复图片（表情）
    SystemMsg = 5,              -- 系统消息（进出群聊等）
    InputingMsgLeft = 6,        -- 输入中
    InputingMsgRight = 7,       -- 输入中
}

AllEnum.CharAdvancePreview = {
    LevelMax = 1, 
    SkillLevelMax = 2,
    SkinUnlock = 3,
}

AllEnum.DiscBgSurfix = {
    Main = "_M",    -- 主界面看板资源
    L2d = "_L",     -- L2d资源
    Image = "_B",   -- 大图资源
    Card = "_G",    -- 陀螺仪资源
}

AllEnum.BossBloodType = {
    Single = 1,         -- 单血条
    Multiple = 2,       -- 多血条
  
}

AllEnum.JointDrillResultType = {
    Success = 1,            --胜利
    BattleEnd = 2,          --战斗结束
    Retreat = 3,            --撤退
    ChallengeEnd = 4,       --挑战结束
}

AllEnum.ActivityMainType = {
    Activity = 1,          --正常普通活动
    ActivityGroup = 2,     --活动组
}
AllEnum.TutorialLevelLockType = {
    None=1,
    WorldClass = 2,          --世界等级限制
    PreLevel = 3,            --前置关卡限制
}

AllEnum.JointDrillActStatus = {
    WaitStart = 1,              -- 等待开始
    Start = 2,                  -- 进行中
    WaitClose = 3,              -- 等待结算
    Closed = 4,                 -- 已结束
}

AllEnum.DiscReadType = {
    DiscStory = 1, -- 星盘故事
    DiscAvg = 2, -- 星盘AVG
}
AllEnum.BattleHudType = {
    Sector = 1, --扇形布局
    Horizontal = 2, --横板布局
}

AllEnum.ActivityThemeFuncIndex = {
    MiniGame = 1,
    Task = 2,
    Story = 3,
    Shop = 4,
    Level = 5
}
AllEnum.CgSurfix = {
    Main = "_M",    -- 主界面看板资源
    Image = "",   -- 大图资源
}
AllEnum.Cg2DType = {
    Base = 1 ,    -- 大图资源
    L2D  = 2,   -- L2D资源
}

AllEnum.CharSkinSource = {
    [GameEnum.skinSourceType.ACTIVITY] = "Skin_Unlock_Activity",
    [GameEnum.skinSourceType.TIMELIMIT] = "Skin_Unlock_Shop",
    [GameEnum.skinSourceType.ADVANCE] = "Skin_Unlock_Advance",
    [GameEnum.skinSourceType.BATTLEPASS] = "Skin_Unlock_Battlepass",
}

AllEnum.StorySetStatus = {
    Lock = 1 ,          -- 未解锁
    UnLock  = 2,        -- 已解锁可领取
    Received = 3,       -- 已领取
}

AllEnum.LevelMenuResourceList = {
    [1] = GameEnum.OpenFuncType.DailyInstance,
    [2] = GameEnum.OpenFuncType.RegionBoss,
    [3] = GameEnum.OpenFuncType.SkillInstance,
    [4] = GameEnum.OpenFuncType.CharGemInstance,
}

AllEnum.TransitionStatus = {
    IsPlayingInAnim = 1,--播落幕动画中
    InAnimDone = 2,--落幕动画播完
    IsPlayingOutAnim = 3,--播开幕动画中
    OutAnimDone = 4,--开幕动画播完
}

return AllEnum
