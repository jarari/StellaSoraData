---- 程序自动生成的枚举文件，请不要手动修改

local GameEnum = {}

GameEnum.monsterEpicType =
{
    NORMAL                                                       =   5 ; --- 普通
    ELITE                                                        =   4 ; --- 精英
    LEADER                                                       =   3 ; --- 小Boss
    LORD                                                         =   2 ; --- Boss
    ALL                                                          =   1 ; --- 全体
    TRAP                                                         =   6 ; --- 陷阱
    BOSSRUSH                                                     =   7 ; --- BossRush
    JOINTDRILLBOSS                                               =   8 ; --- JointDrillBoss
}

GameEnum.actorMovType =
{
    STATIC                                                       =   1 ; --- 静止
    WALK                                                         =   2 ; --- 行走
    FLY                                                          =   3 ; --- 漂浮
}

GameEnum.skillType =
{
    NORMAL                                                       =   1 ; --- 普攻
    OTHER_SKILL                                                  =   2 ; --- 技能
    SKILL                                                        =   3 ; --- 主控技能
    SUPPORT                                                      =   4 ; --- 援护技能
    ULTIMATE                                                     =   5 ; --- 绝招
    DODGE                                                        =   6 ; --- 闪避
    RUSH                                                         =   7 ; --- 疾跑
}

GameEnum.skinType =
{
    BASIC                                                        =   1 ; --- 初始皮肤
    ADVANCE                                                      =   2 ; --- 进阶皮肤
    OTHER                                                        =   3 ; --- 其它皮肤
}

GameEnum.skinExtraTag =
{
    MODEL                                                        =   1 ; --- 模型
    IMAGE                                                        =   2 ; --- 背景图
    MUSIC                                                        =   3 ; --- 音乐
    TWOD                                                         =   4 ; --- 立绘
}

GameEnum.skinSourceType =
{
    ACTIVITY                                                     =   1 ; --- 活动获得
    TIMELIMIT                                                    =   2 ; --- 限时出售
    ACHIEVEMENT                                                  =   3 ; --- 成就获得
    MAINTASK                                                     =   4 ; --- 主线任务
    ROGUELIKE                                                    =   5 ; --- 地宫获得
    ADVANCE                                                      =   6 ; --- 升阶获得
    BATTLEPASS                                                   =   7 ; --- 创业基金
}

GameEnum.handbookType =
{
    SKIN                                                         =   1 ; --- 角色皮肤
    OUTFIT                                                       =   2 ; --- 星盘大图
    PLOT                                                         =   3 ; --- 剧情大图
    CG                                                           =   4 ; --- 好感度CG
}

GameEnum.roguelikeLevelStyle =
{
    CountrySide                                                  =   1 ; --- 麦田
    City_Main_2                                                  =   2 ; --- 城镇白天
    City_Main_1                                                  =   3 ; --- 城镇傍晚
    Boss_miniewa                                                 =   4 ; --- 密涅瓦
    City_Main_3                                                  =   5 ; --- 水道桥
    Boss_Gaoda                                                   =   6 ; --- 水道桥_高达
    Forest                                                       =   7 ; --- 森林
    Forest_New                                                   =   8 ; --- 新森林
    Boss_Yezhuwang                                               =   9 ; --- 野猪王
    Boss_Banshenshu                                              =  10 ; --- 半身树
    Company_Main_5_1                                             =  11 ; --- 温室
    Boss_Fengniao                                                =  12 ; --- 蜂鸟
    Company_Main_6_1                                             =  13 ; --- 花房
    Boss_Fengcao                                                 =  14 ; --- 风草
    Boss_Haitu                                                   =  15 ; --- 海兔
    City_Main_1_2                                                =  16 ; --- 城市突围
    Forest_Main_2_5                                              =  17 ; --- 污染森林
    Roguelike_non                                                = 101 ; --- 无属性塔
    Roguelike_miniboss                                           = 102 ; --- miniboss
    Roguelike_shilaimu                                           = 103 ; --- 史莱姆
    Roguelike_tiaowuji                                           = 104 ; --- 跳舞机
    Roguelike_shasha                                             = 105 ; --- 鲨鱼
    Roguelike_daguanzi                                           = 106 ; --- 大罐子
    Roguelike_chuzi                                              = 107 ; --- 厨子
    Roguelike_talou                                              = 108 ; --- 塔楼
    Roguelike_fengshanji                                         = 109 ; --- 风扇姬
    Roguelike_duobitaideng                                       = 110 ; --- 多臂台灯
    Roguelike_jinduanlirong                                      = 111 ; --- 禁断丽容
    Roguelike_CommonBoss                                         = 112 ; --- 通用
    Roguelike_Fangminiboss                                       = 113 ; --- 方miniboss
    Roguelike_Commonminiboss_BOSS                                = 114 ; --- 圆boss通用
    DailyInstance_01                                             = 115 ; --- 射击卡带
    DailyInstance_02                                             = 116 ; --- 节奏卡带
    DailyInstance_03                                             = 117 ; --- 格斗卡带
    TravelBoss_Maoyan                                            = 201 ; --- 猫眼
    TravelBoss_Huayuan                                           = 202 ; --- 花原
    TravelBoss_Huochui                                           = 203 ; --- 火锤
    TravelBoss_WuYu                                              = 204 ; --- 雾语
    JointDrill_01_JYMY                                           = 251 ; --- 剧院魅影
    VampireSurvivor_01                                           = 301 ; --- 吸血鬼1号
    VampireSurvivor_02                                           = 302 ; --- 吸血鬼2号
    VampireSurvivor_03                                           = 303 ; --- 吸血鬼3号
    VampireSurvivor_04                                           = 304 ; --- 吸血鬼4号
    StoryActivity_1                                              = 401 ; --- 泳装活动
    StoryActivity_2                                              = 406 ; --- 冬香活动
    StoryActivity_3                                              = 411 ; --- 夏花活动
    StoryActivity_4                                              = 416 ; --- 圣诞活动
    Training                                                     = 901 ; --- 训练关
}

GameEnum.roguelikeFloorFunction =
{
    THROUGH                                                      =   1 ; --- 跑图
    MAPEVENT                                                     =   2 ; --- 事件
    BOSSFIGHT                                                    =   3 ; --- Boss战
}

GameEnum.effectiveGoals =
{
    NONE                                                         =   0 ; --- 无
    ONESELF                                                      =   1 ; --- 自己
    ENEMY                                                        =   2 ; --- 敌人
    FULL_TEAM                                                    =   3 ; --- 小队全员
    TEAMMATE                                                     =   4 ; --- 队友
    FULL_ENEMY                                                   =   5 ; --- 全部敌人
    MAINCONTROL_PLAYER                                           =   6 ; --- 主控角色
    ASSISTANT_PLAYER                                             =   7 ; --- 援护角色
    TEAM_SUMMONED                                                =   8 ; --- 己方仆从
    FULL_TEAM_AND_SUMMONED                                       =   9 ; --- 小队全员及仆从
    ONESELF_AND_SUMMONED                                         =  10 ; --- 自己及仆从
}

GameEnum.screen =
{
    NONE                                                         =   0 ; --- 无
    NOTHING                                                      =   1 ; --- 无筛选
    LOCKED                                                       =   2 ; --- 被锁定的
}

GameEnum.timeSuperposition =
{
    DONOTSTACK                                                   =   1 ; --- 不叠加
    RESET                                                        =   2 ; --- 重置
    SUPERPOSITION                                                =   3 ; --- 叠加
}

GameEnum.packMark =
{
    Material                                                     =   1 ; --- 素材
    Consumables                                                  =   4 ; --- 消耗品
    Equipment                                                    =   5 ; --- 装备
    BasicItem                                                    =   6 ; --- 基础物品
}

GameEnum.timing =
{
    INDEPENDENT                                                  =   1 ; --- 独立计算
    SEQUENCE                                                     =   2 ; --- 先来后到
}

GameEnum.logicType =
{
    AND                                                          =   1 ; --- 与
    OR                                                           =   2 ; --- 或
}

GameEnum.distance =
{
    CLOSERANGE                                                   =   1 ; --- 近战
    REMOTE                                                       =   2 ; --- 远程
}

GameEnum.damageSource =
{
    PLAYER                                                       =   1 ; --- 玩家
    MONSTER                                                      =   2 ; --- 怪物
    TRAP                                                         =   3 ; --- 陷阱
    PERK                                                         =   4 ; --- 信条
    FATECARD                                                     =   5 ; --- 命运卡
}

GameEnum.damageType =
{
    NORMAL                                                       =   1 ; --- 普攻
    SKILL                                                        =   2 ; --- 技能
    ULTIMATE                                                     =   3 ; --- 绝招
    OTHER                                                        =   4 ; --- 其他
    MARK                                                         =   5 ; --- 印记
    PROJECTILE                                                   =   6 ; --- 衍生物
    SUMMON                                                       =   7 ; --- 仆从
}

GameEnum.damageEffect =
{
    PHYSICS                                                      =   1 ; --- 物理
    MAGIC                                                        =   2 ; --- 法术
    REAL                                                         =   4 ; --- 真实
    NO_DAMAGE                                                    =   5 ; --- 无伤害
    NO_DAMAGE_APPLY_FEATHER_NO_ANI                               =   6 ; --- 无伤害应用攻击特性无受击动画
    NO_DAMAGE_APPLY_FEATHER                                      =   7 ; --- 无伤害应用攻击特性有受击动画
    NONE                                                         =   8 ; --- 无
}

GameEnum.skillSlotType =
{
    NONE                                                         =   0 ; --- 无
    A                                                            =   1 ; --- 闪避
    B                                                            =   2 ; --- 技能1
    C                                                            =   3 ; --- 技能2
    D                                                            =   4 ; --- 绝招
    NORMAL                                                       =   5 ; --- 普攻
}

GameEnum.otherSources =
{
    ONESELF                                                      =   1 ; --- 自身
    ENEMY                                                        =   2 ; --- 敌人
}

GameEnum.diffculty =
{
    Diffculty_1                                                  =   1 ; --- 难度1
    Diffculty_2                                                  =   2 ; --- 难度2
    Diffculty_3                                                  =   3 ; --- 难度3
    Diffculty_4                                                  =   4 ; --- 难度4
    Diffculty_5                                                  =   5 ; --- 难度5
    Diffculty_6                                                  =   6 ; --- 难度6
    Diffculty_7                                                  =   7 ; --- 难度7
    Diffculty_8                                                  =   8 ; --- 难度8
    Diffculty_9                                                  =   9 ; --- 难度9
    Diffculty_10                                                 =  10 ; --- 难度10
}

GameEnum.monsterBloodType =
{
    NONE                                                         =   0 ; --- 不显示
    SIMPLE                                                       =   1 ; --- 简易
    ADVANCE                                                      =   2 ; --- 高级
    BOSS                                                         =   3 ; --- Boss
    PLAYERSUMMON                                                 =   4 ; --- 友方召唤物
    SIMPLE2                                                      =   5 ; --- 简易常驻
    MINIBOSS                                                     =   6 ; --- 小Boss
    BOSSRUSH                                                     =   7 ; --- BossRush
    JOINTDRILLBOSS                                               =   8 ; --- JointDrillBoss
}

GameEnum.travelerDuelBossType =
{
    NORMAL                                                       =   1 ; --- 普通
    CHALLENGE                                                    =   2 ; --- 挑战
}

GameEnum.worldLevelType =
{
    Mainline                                                     =   1 ; --- 主线
    Branchline                                                   =   3 ; --- 支线
    RegionBoss                                                   =   4 ; --- 地区boss
    Prologue                                                     =   6 ; --- 序章
    PrologueBattleLevel                                          =   7 ; --- 序章战斗
    TravelerDuel                                                 =   8 ; --- 旅人决斗
    DailyInstance                                                =   9 ; --- 日常副本
    InfinityTower                                                =  10 ; --- 无尽塔
    All                                                          =  11 ; --- 通用
    EquipmentInstance                                            =  12 ; --- 装备副本
    StarTower                                                    =  13 ; --- 星塔
    VampireInstance                                              =  14 ; --- 吸血鬼
    ScoreBoss                                                    =  15 ; --- Boss积分挑战
    SkillInstance                                                =  16 ; --- 技能素材本
    WeeklyCopies                                                 =  17 ; --- 周本
    Dynamic                                                      =  18 ; --- 动态关卡
    AutoBalance                                                  =  19 ; --- 自动战斗平衡测试
    ActivityLevels                                               =  20 ; --- 中型活动挑战
    BrickBreaker                                                 =  21 ; --- 打砖块
    TowerDefense                                                 =  22 ; --- 塔防玩法
    Tutorial                                                     =  23 ; --- 教学关
}

GameEnum.dynamicLevelType =
{
    JointDrill                                                   =   1 ; --- 总力战
    TowerDefense                                                 =   2 ; --- 塔防
    Trial                                                        =   3 ; --- 试玩关
    Tutorial                                                     =   4 ; --- 教学关
}

GameEnum.mainLineType =
{
    Mainline                                                     =   1 ; --- 主线
    Branchline                                                   =   2 ; --- 支线
}

GameEnum.hurtFlashTintType =
{
    NONE                                                         =   0 ; --- 无
    EDGE                                                         =   1 ; --- 边缘
    WHOLE                                                        =   2 ; --- 全身
}

GameEnum.referencetarget =
{
    Self                                                         =   1 ; --- 释放者
    Target                                                       =   2 ; --- 受益者
}

GameEnum.referenceattrib =
{
    Hp                                                           =   1 ; --- 最大生命
    Atk                                                          =   2 ; --- 总攻击力
    BaseAtk                                                      =   3 ; --- 基础攻击力
    BaseHp                                                       =   4 ; --- 基础最大生命
    DEF                                                          =   5 ; --- 最大防御力
    BaseDEF                                                      =   6 ; --- 基础防御力
    CRITRATE                                                     =   7 ; --- 暴击
    CRITPOWER_P                                                  =   8 ; --- 暴击伤害
    PENETRATE                                                    =   9 ; --- 防御穿透
    WEE                                                          =  10 ; --- 水系伤害
    FEE                                                          =  11 ; --- 火系伤害
    SEE                                                          =  12 ; --- 地系伤害
    AEE                                                          =  13 ; --- 风系伤害
    LEE                                                          =  14 ; --- 光系伤害
    DEE                                                          =  15 ; --- 暗系伤害
    WEP                                                          =  16 ; --- 水系穿透
    FEP                                                          =  17 ; --- 火系穿透
    SEP                                                          =  18 ; --- 地系穿透
    AEP                                                          =  19 ; --- 风系穿透
    LEP                                                          =  20 ; --- 光系穿透
    DEP                                                          =  21 ; --- 暗系穿透
}

GameEnum.subMapName =
{
    ThunderBluff                                                 =   1 ; --- 雷霆崖
    Orgrimmar                                                    =   2 ; --- 奥格瑞玛
    Barrens                                                      =   3 ; --- 贫瘠之地
    EasternPlaguelands                                           =   4 ; --- 东瘟疫之地
}

GameEnum.monsterAIBranchActiveConditionType =
{
    NONE                                                         =   0 ; --- 无
    HP_PER_MORE_OR_EQUAL                                         =   1 ; --- 血量百分比大于等于
    HP_PER_LESS                                                  =   2 ; --- 血量百分比小于
    TARGET_DISTANCE_GREATER_OR_EQU                               =   3 ; --- 目标距离大于等于
    TARGET_DISTANCE_LESS                                         =   4 ; --- 目标距离小于
    POSITION_DISTANCE_GREATER_OR_EQU                             =   5 ; --- 坐标距离大于等于
    POSITION_DISTANCE_LESS                                       =   6 ; --- 坐标距离小于
    TARGET_MONSTER_BASIC_STATE                                   =   7 ; --- 特定怪物基础状态
    TARGET_MONSTER_BUFFID                                        =   8 ; --- 指定buffId
    TARGET_MONSTER_BUFFGROUPID                                   =   9 ; --- 指定buffGroupId
    TARGET_MONSTER_CASTSKILLTIME                                 =  10 ; --- 指定BranchID释放次数
    TARGET_MONSTER_GROUP_CASTSKILLTIME                           =  11 ; --- 指定Branch组ID释放次数
    TARGET_TOUGHNESS_STATE                                       =  12 ; --- 目标韧性状态
    TARGET_TOUGHNESS_STATECHANGE                                 =  13 ; --- 目标韧性状态变化
}

GameEnum.jumpType =
{
    Mainline                                                     =   1 ; --- 关卡
    Rogue                                                        =   2 ; --- 遗迹
    RogueGroup                                                   =   3 ; --- 遗迹组
    RoguePanel                                                   =   4 ; --- 遗迹主界面
    RegionBoss                                                   =   5 ; --- 区域BOSS
    RegionBossGroup                                              =   6 ; --- 区域BOSS组
    RegionBossPanel                                              =   7 ; --- 区域BOSS主界面
    Text                                                         =   8 ; --- 文本
    Map                                                          =   9 ; --- 世界地图
    Shop                                                         =  10 ; --- 商店
    Mall                                                         =  11 ; --- 商城
    Gacha                                                        =  12 ; --- 抽卡
    DailyInstanceLevel                                           =  13 ; --- 每日副本
    TravelerDuelLevel                                            =  14 ; --- 旅人对决
    Depot                                                        =  15 ; --- 背包
    CharacterList                                                =  16 ; --- 角色列表
    Crafting                                                     =  17 ; --- 材料合成
    StarTower                                                    =  18 ; --- 星塔
    StarTowerGroup                                               =  19 ; --- 星塔组
    StarTowerPanel                                               =  20 ; --- 星塔主界面
    Disc                                                         =  21 ; --- 星盘列表
    EquipmentPanel                                               =  22 ; --- 纹章本主界面
    EquipmentGroup                                               =  23 ; --- 纹章本组
    MainlineStory                                                =  24 ; --- 主线故事
    InfinityTower                                                =  25 ; --- 无尽塔主界面
    InfinityTowerGroup                                           =  26 ; --- 无尽塔种类
    Agent                                                        =  27 ; --- 委托
    Phone                                                        =  28 ; --- 手机
    Vampire                                                      =  29 ; --- 吸血鬼
    StarTowerRank                                                =  30 ; --- 排行榜星塔
    ComCYO                                                       =  31 ; --- 自选包
    SkillInstancePanel                                           =  32 ; --- 技能本主界面
    SkillInstanceGroup                                           =  33 ; --- 技能本组
    Quest                                                        =  34 ; --- 王权
    ScoreBoss                                                    =  35 ; --- 积分boss
    WeeklyCopies                                                 =  36 ; --- 周本
    StorySet                                                     =  37 ; --- 故事集
    StarTowerGrowth                                              =  38 ; --- 星塔养成
    SwimActivityTask                                             =  39 ; --- 泳装挖格子对应任务
}

GameEnum.characterSearchTargetType =
{
    MELEE                                                        =   1 ; --- 近战
    RANGED                                                       =   2 ; --- 远程
}

GameEnum.characterSearchTargetTypeTowerDefense =
{
    NORMAL                                                       =   1 ; --- 常规
}

GameEnum.gachaStorageType =
{
    CharacterUpCardPool                                          =   1 ; --- 角色UP卡池
    CharacterCardPool                                            =   2 ; --- 角色常驻卡池
    DiscUpCardPool                                               =   3 ; --- 秘纹UP卡池
    DiscCardPool                                                 =   4 ; --- 秘纹常驻卡池
    BeginnerCardPool                                             =   5 ; --- 新手卡池
}

GameEnum.guidetype =
{
    ForcedClick                                                  =   1 ; --- 强制点击型
    Introductory                                                 =   2 ; --- 介绍型
    PopPicture                                                   =   3 ; --- 弹出图片型
    PlayAvg                                                      =   4 ; --- 通用对话
}

GameEnum.dailyType =
{
    ExpDungeon                                                   =   1 ; --- 经验本
    MoneyDungeon                                                 =   2 ; --- 金币本
    PresentsExpDungeon                                           =   3 ; --- 神器经验本
    OutfitExpDungeon                                             =   4 ; --- 星盘经验本
    Common                                                       =   5 ; --- 通用素材关
}

GameEnum.DailyRewardType =
{
    CharExp                                                      =   1 ; --- 角色经验
    Money                                                        =   2 ; --- 金币
    EquipmentExp                                                 =   3 ; --- 纹章经验
    DiscExp                                                      =   4 ; --- 星盘经验
}

GameEnum.guideDetectionType =
{
    InitiativeCheck                                              =   1 ; --- 主动检测
    PassiveCheck                                                 =   2 ; --- 被动检测
}

GameEnum.guideprepose =
{
    PreGuide                                                     =   1 ; --- 完成指引
    WorldClass                                                   =   2 ; --- 世界等级
    FinishDungeon                                                =   3 ; --- 完成关卡
    UnlockFunction                                               =   4 ; --- 系统解锁
    HoldItem                                                     =   5 ; --- 持有道具
    FinishStarTowerQuest                                         =   6 ; --- 完成星塔任务
    UnFinishCharacterPlot                                        =   7 ; --- 未观看角色指定剧情
}

GameEnum.guidepost =
{
    UnDoneGuide                                                  =   1 ; --- 未完成指引
}

GameEnum.guidetrigger =
{
    PreGuide                                                     =   1 ; --- 完成指引
    WorldClass                                                   =   2 ; --- 世界等级
    OpenInterface                                                =   3 ; --- 打开界面
    FinishLastStep                                               =   4 ; --- 完成上一步
    FinishDungeon                                                =   5 ; --- 完成关卡
    UnlockFunction                                               =   6 ; --- 系统解锁
}

GameEnum.endtype =
{
    ForceGuide                                                   =   1 ; --- 强制引导
    UnforceGuide                                                 =   2 ; --- 非强制引导
}

GameEnum.fixedRoguelikeFunc0 =
{
    Battle                                                       =   1 ; --- 战斗
    Boss                                                         =   2 ; --- Boss战
}

GameEnum.fixedRoguelikeFunc1 =
{
    CommonChallenge                                              =  31 ; --- 普通挑战
    LiveChallenge                                                =  32 ; --- 生存挑战
    MiniBossChallenge                                            =  33 ; --- MiniBoss挑战
    Monster                                                      = 101 ; --- 无主的财富_怪物型
    Treasure                                                     = 102 ; --- 无主的财富_宝箱型
}

GameEnum.fixedRoguelikeGameplayType =
{
    UnReplenish                                                  =   1 ; --- 无补充
    Replenish                                                    =   2 ; --- 连续补充
    Remote                                                       =   3 ; --- 全远程
    Surround                                                     =   4 ; --- 包围
    One2One                                                      =   5 ; --- 单挑
    Thorough                                                     =   6 ; --- 深入
    Chaos                                                        =   7 ; --- 混乱
}

GameEnum.infinityTowerGameplayType =
{
    Normal                                                       =   1 ; --- 常规
    Surround                                                     =   2 ; --- 包围
    One2One                                                      =   3 ; --- 单挑
    Chaos                                                        =   4 ; --- 混乱
    Elite                                                        =   5 ; --- 精英战
    RemoteSur                                                    =   6 ; --- 全远程包围
    Melee                                                        =   7 ; --- 全近战
    Special                                                      =   8 ; --- 特殊怪
    RemoteSBS                                                    =   9 ; --- 全远程并排
}

GameEnum.vampireWaveType =
{
    Normal                                                       =   1 ; --- 常规
    gather                                                       =   2 ; --- 集群
    Loose                                                        =   3 ; --- 分散
}

GameEnum.fixedRoguelikePortDir =
{
    Left                                                         =   1 ; --- 左
    Right                                                        =   2 ; --- 右
}

GameEnum.levelState =
{
    Failed                                                       =   1 ; --- 失败
    Success                                                      =   2 ; --- 完成
    Teleporter                                                   =   3 ; --- 下一个房间
}

GameEnum.specificCombatType =
{
    Timelimited                                                  =   1 ; --- 限时挑战
    RobberGoblin                                                 =   2 ; --- 盗宝哥布林
    EscapeInjury                                                 =   3 ; --- 免受伤害
    ContinuousKilling                                            =   4 ; --- 连续击杀
    KillMonster                                                  =   5 ; --- 击杀指定怪物
    DisturbMonster                                               =   6 ; --- 召唤干扰怪物
}

GameEnum.combatActivePointType =
{
    LevelStart                                                   =   1 ; --- 关卡开始时
    FirstWaveRefresh                                             =   2 ; --- 首个波次刷新时
    FirstWaveClear                                               =   3 ; --- 首个波次完成时
    EveryWaveRefresh                                             =   4 ; --- 每个波次刷新时
    EveryWaveClear                                               =   5 ; --- 每个波次完成时
    FinalWaveRefresh                                             =   6 ; --- 最后波次刷新时
    FinalWaveClear                                               =   7 ; --- 最后波次完成时
}

GameEnum.combatActiveType =
{
    Automatic                                                    =   1 ; --- 自动
    Interactive                                                  =   2 ; --- 交互
}

GameEnum.npcType =
{
    Talent                                                       =   1 ; --- 天赋
    RewardRoom                                                   =   2 ; --- 福利房
    shop                                                         =   3 ; --- 商店
    Gamble                                                       =   4 ; --- 资源轮换
    Upgrade                                                      =   5 ; --- 强化
    Quest                                                        =   6 ; --- 任务
    Resque                                                       =   7 ; --- 恢复
    PrologueReward                                               =   8 ; --- 信条选择（序章专用）
    Narrate                                                      =   9 ; --- 叙事
}

GameEnum.npcNewType =
{
    Shop                                                         =   1 ; --- 商店
    Upgrade                                                      =   2 ; --- 强化
    Resque                                                       =   3 ; --- 恢复
    Narrate                                                      =   4 ; --- 叙事
    Event                                                        =   5 ; --- 事件
    Danger                                                       =   6 ; --- 危险房
    Horror                                                       =   7 ; --- 高危房
}

GameEnum.areaEffectType =
{
    TriggerAreaObj                                               =   1 ; --- 通用区域效果
    TriggerWindWall                                              =   2 ; --- 风墙
    DiffuseArea                                                  =   3 ; --- 扩散型区域效果
    PullArea                                                     =   4 ; --- 持续牵引型区域效果
    HitArea                                                      =   5 ; --- 单次攻击区域效果
    TriggerArea                                                  =   6 ; --- 触发型区域效果
}

GameEnum.characterGrade =
{
    SSR                                                          =   1 ; --- SSR
    SR                                                           =   2 ; --- SR
    R                                                            =   3 ; --- R
}

GameEnum.characterJobClass =
{
    Vanguard                                                     =   1 ; --- 先锋
    Balance                                                      =   2 ; --- 均衡
    Support                                                      =   3 ; --- 支援
}

GameEnum.characterAttackType =
{
    MELEE                                                        =   1 ; --- 近战
    RANGED                                                       =   2 ; --- 远程
}

GameEnum.shopRefreshTimeType =
{
    DAY                                                          =   1 ; --- 日
    WEEK                                                         =   2 ; --- 周
    MONTH                                                        =   3 ; --- 月
}

GameEnum.itemType =
{
    Res                                                          =   1 ; --- 资源
    Item                                                         =   2 ; --- 道具
    Char                                                         =   3 ; --- 角色
    Energy                                                       =   4 ; --- 体力
    WorldRankExp                                                 =   5 ; --- 世界等级经验
    RogueItem                                                    =   6 ; --- 遗迹道具
    Disc                                                         =   7 ; --- 星盘
    Equipment                                                    =   9 ; --- 装备
    CharacterSkin                                                =  10 ; --- 角色皮肤
    MonthlyCard                                                  =  11 ; --- 月卡
    Title                                                        =  12 ; --- 头衔
    Honor                                                        =  13 ; --- 称号
    HeadItem                                                     =  14 ; --- 头像
}

GameEnum.expireType =
{
    ExpireMin                                                    =   1 ; --- 固定时间
    ExpireDay                                                    =   2 ; --- 指定天数
    ExpireWeek                                                   =   3 ; --- 指定周数
}

GameEnum.useMode =
{
    UseModeManual                                                =   1 ; --- 手动使用
    UseModeAuto                                                  =   2 ; --- 自动使用
    UseModeNot                                                   =   3 ; --- 不可使用
}

GameEnum.useAction =
{
    Drop                                                         =   1 ; --- 掉落
    Item                                                         =   2 ; --- 获得物品
    Pick                                                         =   3 ; --- 自选
    No                                                           =   4 ; --- 不可使用
}

GameEnum.questType =
{
    Mainline                                                     =   0 ; --- 主线
    New                                                          =   1 ; --- 新手
    Daily                                                        =   2 ; --- 日常
    Weekly                                                       =   3 ; --- 周常
    Monthly                                                      =   4 ; --- 月常
    Talent                                                       =   5 ; --- 天赋
    Achieve                                                      =   6 ; --- 成就
}

GameEnum.fateCardActiveAction =
{
    RoomExit                                                     =   0 ; --- 房间退出
    BattleEnd                                                    =   1 ; --- 战斗结束
}

GameEnum.achievementCond =
{
    AchievementSpecific                                          =   1 ; --- [历史]达成成就X
    AchievementTotal                                             =   2 ; --- [历史]达成X个成就
    BattleTotal                                                  =   3 ; --- 战斗X次
    CharacterAcquire                                             =   5 ; --- 拥有角色X
    CharacterAcquireQuantityRarityAndAdvancement                 =   6 ; --- 拥有X个品阶Y稀有度Z的角色
    CharacterAdvanceTotal                                        =   7 ; --- 角色进阶X次
    CharacterSkillUpTotal                                        =   8 ; --- 角色技能提升X次
    CharacterSkillWithSpecificUpTotal                            =   9 ; --- 角色X升级技能Y次
    CharacterSpecific                                            =  10 ; --- [历史]拥有角色X
    CharacterUpLevel                                             =  11 ; --- [历史]角色升级到X级
    CharacterUpTotal                                             =  12 ; --- 角色升级X次
    CharacterWithSpecificAdvance                                 =  13 ; --- [历史]角色X突破到Y阶
    CharacterWithSpecificAffinity                                =  14 ; --- [历史]角色X达到Y好感度
    CharacterWithSpecificUpLevel                                 =  15 ; --- [历史]角色X升到Y级
    CharactersWithSpecificLevelAndQuantity                       =  16 ; --- [历史]拥有X数量Y等级的角色
    CharactersWithSpecificNumberLevelAndAttributes               =  17 ; --- [历史]拥有X数量Y等级Z属性的角色
    CharactersWithSpecificPlot                                   =  18 ; --- [历史]角色X剧情
    CharactersWithSpecificQuantityAdvancementCountAndAttribute   =  19 ; --- [历史]拥有X数量Y进阶次数Z属性的角色
    CharactersWithSpecificQuantityAndRarity                      =  20 ; --- [历史]拥有X数量Y稀有度的角色
    CharactersWithSpecificQuantityRarityAndAdvancement           =  21 ; --- [历史]拥有X数量Y进阶次数Z稀有度的角色
    CharactersWithSpecificQuantityRarityAndLevel                 =  22 ; --- [历史]拥有X数量Y等级Z稀有度的角色
    ChatTotal                                                    =  23 ; --- [历史]聊天X次
    DailyInstanceClearSpecificDifficultyAndTotal                 =  24 ; --- 通关X次难度Y的Z日常副本
    DailyInstanceClearSpecificTypeAndTotal                       =  25 ; --- 通关X次Y类型日常副本
    DailyInstanceClearTotal                                      =  26 ; --- 通关日常副本X次
    DateSpecific                                                 =  27 ; --- [历史]特定日期
    DiscAcquire                                                  =  28 ; --- 拥有星盘X
    DiscAcquireSpecificQuantityAndRarity                         =  29 ; --- 拥有X个稀有度Y的星盘
    DiscAcquireQuantityLevelAndRarity                            =  30 ; --- 拥有X个等级Y稀有度Z的星盘
    DiscAcquireQuantityPhaseAndRarity                            =  31 ; --- 拥有X个品阶Y稀有度Z的星盘
    DiscAcquireQuantityStarAndRarity                             =  32 ; --- 拥有X个星级Y稀有度Z的星盘
    DiscLimitBreakTotal                                          =  33 ; --- 星盘突破X次
    DiscPromoteTotal                                             =  34 ; --- 星盘升阶X次
    DiscStrengthenTotal                                          =  35 ; --- 星盘强化X次
    DiscWithSpecificQuantityLevelAndRarity                       =  36 ; --- [历史]拥有X个等级Y稀有度Z的星盘
    DiscWithSpecificQuantityPhaseAndRarity                       =  37 ; --- [历史]拥有X个品阶Y稀有度Z的星盘
    DiscWithSpecificQuantityStarAndRarity                        =  38 ; --- [历史]拥有X个星级Y稀有度Z的星盘
    GachaCharacterNotSSRTotal                                    =  40 ; --- 抽卡X次没有获得SSR角色
    GachaCharacterTenModeSSRTotal                                =  41 ; --- 单次十连获得X个SSR角色
    GachaCharacterTotal                                          =  42 ; --- 抽取X次角色
    GachaTenModeAcquireQuantityAndRarityItems                    =  43 ; --- 单次十连获得X个Y稀有度的物品
    GachaTotal                                                   =  44 ; --- 抽卡X次
    GiftGiveTotal                                                =  45 ; --- 赠礼X次
    InfinityTowerClearSpecificFloor                              =  46 ; --- [历史]通关X层Y类型的无尽塔
    InfinityTowerClearTotal                                      =  47 ; --- 通关无尽塔X次
    ItemsAdd                                                     =  48 ; --- 新增X道具Y个
    ItemsDeplete                                                 =  49 ; --- 消耗X道具Y个
    ItemsProductTotal                                            =  50 ; --- 合成X次
    LoginTotal                                                   =  51 ; --- 登录X次
    QuestTravelerDuelChallengeTotal                              =  52 ; --- 完成巅峰揭幕赛季X次
    QuestTourGuideSpecific                                       =  53 ; --- [历史]达成手册任务X
    QuestTravelerDuelSpecific                                    =  54 ; --- [历史]完成巅峰揭幕常驻任务X
    QuestWithSpecificType                                        =  55 ; --- 达成X次Y类型任务
    RegionBossClearSpecificFullStarWithBossIdAndDifficulty       =  56 ; --- [历史]三星通关X种Y难度的区域
    RegionBossClearSpecificLevelWithDifficultyAndTotal           =  57 ; --- 通关X次难度Y的Z地区
    RegionBossClearSpecificTotal                                 =  58 ; --- 通关X次Y地区
    RegionBossClearTotal                                         =  59 ; --- 通关地区X次
    SkillsWithSpecificQuantityAndLevel                           =  60 ; --- [历史]拥有X个等级Y的技能
    SkinAcquire                                                  =  61 ; --- 拥有角色皮肤X
    StageClearSpecificStars                                      =  62 ; --- [历史]通关X类型Y关卡获得Z星数
    StoryClear                                                   =  63 ; --- [历史]通关旅行故事X
    TravelerDuelChallengeSpecificBoosLevelWithDifficultyAndTotal =  64 ; --- 通关X次词条难度Y的Z巅峰揭幕赛季
    TravelerDuelClearBossTotal                                   =  65 ; --- 通关巅峰揭幕常驻X次
    TravelerDuelClearSpecificBossIdAndDifficulty                 =  66 ; --- [历史]通关X种Y关卡难度的巅峰揭幕常驻
    TravelerDuelChallengeClearSpecificBossLevelAndAffix          =  67 ; --- 通关X巅峰揭幕赛季指定Y词条
    TravelerDuelClearSpecificBossLevelWithDifficultyAndTotal     =  68 ; --- 通关X次关卡难度Y的Z巅峰揭幕常驻
    TravelerDuelClearSpecificBossTotal                           =  69 ; --- 通关X次Y巅峰揭幕常驻
    TravelerDuelChallengeRankUploadTotal                         =  70 ; --- 上传X次巅峰揭幕赛季模式分数
    WorldClassSpecific                                           =  71 ; --- [历史]达到X世界等级
    RegionBossClearSpecificTypeWithTotal                         =  72 ; --- 通关X次Y类型的区域
    CharactersWithSpecificDatingCount                            =  73 ; --- [历史]完成X次Y角色的邀约
    CharactersDatingTotal                                        =  74 ; --- 完成X次角色邀约
    VampireSurvivorScoreTotal                                    =  75 ; --- 吸血鬼赛季累计达到X分
    VampireSurvivorSpecificLevelWithSpecificScore                =  76 ; --- 指定吸血鬼关卡达到指定分数
    VampireSurvivorPassedSpecificLevel                           =  77 ; --- 通关指定吸血鬼关卡X
    CharacterParticipateTowerNumber                              =  78 ; --- 角色X参与Y次星塔
    CharacterAllSkillReachSpecificLevel                          =  79 ; --- 角色X所有技能均达到Y级
    TravelerDuelPlayTotal                                        =  80 ; --- 体验巅峰揭幕常驻X次
    VampireClearTotal                                            =  81 ; --- 通关吸血鬼X次
    VampireWithSpecificClearTotal                                =  82 ; --- [历史]通关吸血鬼X次
    AgentFinishTotal                                             =  83 ; --- 完成委托X次
    AgentWithSpecificFinishTotal                                 =  84 ; --- [历史]完成委托X次
    ActivityMiningEnterLayer                                     =  86 ; --- 在挖格子活动X中抵达Y层
    ActivityMiningDestroyGrid                                    =  87 ; --- 在挖格子活动X中破坏Y个Z类型的格子
    BossRushTotalStars                                           =  88 ; --- 当期BOSSRUSH累计星数达到X
    InfinityTowerClearSpecificDifficultyAndTotal                 =  89 ; --- [历史]通关X个Y层的无尽塔
    SkillInstanceClearTotal                                      =  90 ; --- 通关技能副本X次
    VampireSurvivorSpecificPassedLevel                           =  91 ; --- [历史]通关指定吸血鬼关卡X
    WeekBoosClearSpecificDifficultyAndTotal                      =  92 ; --- [历史]通关X个Y难度的周常副本
    NpcAffinityWithSpecificLevel                                 =  93 ; --- NpcX达到Y好感度
    CharacterPassedWithSpecificTowerAndCount                     =  94 ; --- [历史]角色X通关Y次星塔
    JointDrillScoreTotal                                         =  95 ; --- 总力战赛季累计达到X分
    CharGemInstanceClearTotal                                    = 104 ; --- 通关纹章副本X次
    DailyShopReceiveShopTotal                                    = 105 ; --- 领取商店奖励X次
    AgentApplyTotal                                              = 106 ; --- 申请委托X次
    DiscSpecific                                                 = 114 ; --- [历史]拥有星盘X
    ClientReport                                                 = 200 ; --- 客户端事件(Client)
    TowerBattleTimes                                             = 501 ; --- 星塔战斗胜利X次Y类型房间
    TowerBossChallengeSpecificHighRewardWithTotal                = 502 ; --- 星塔BOSS挑战最高奖励X次
    TowerBuildSpecificCharacter                                  = 503 ; --- 星塔Build特定角色X
    TowerBuildSpecificScoreWithTotal                             = 504 ; --- 星塔角色达到X次Y评分
    TowerClearSpecificCharacterTypeWithTotal                     = 505 ; --- 通关X次全部角色类型Y的星塔
    TowerClearSpecificGroupIdAndDifficulty                       = 506 ; --- 通过任意X种Y难度的星塔
    TowerClearSpecificLevelWithDifficultyAndTotal                = 507 ; --- 通关X次难度Y的Z星塔组
    TowerClearTotal                                              = 508 ; --- 星塔通关X次
    TowerEnterRoom                                               = 509 ; --- [历史]进入X次Y类型星塔房间
    TowerEventTimes                                              = 511 ; --- 星塔房触发X次事件
    TowerFateTimes                                               = 512 ; --- 星塔房获得X次命运卡
    TowerItemsGet                                                = 513 ; --- 星塔获得X道具Y个
    TowerSpecificDifficultyShopBuyTimes                          = 514 ; --- [历史]星塔X难度商店购买X次
    TowerGrowthSpecificNote                                      = 515 ; --- 完成星塔养成特定节点X解锁
    TowerClearSpecificLevelWithDifficultyAndTotalHistory         = 516 ; --- [历史]通关X次难度Y的Z星塔组
    TowerBookWithSpecificEvent                                   = 517 ; --- [历史]星塔事典累计收集事件图鉴数量
    TowerBookWithSpecificFateCard                                = 518 ; --- [历史]星塔事典累计收集卡片图鉴数量
    TowerBookWithSpecificPotential                               = 520 ; --- [历史]星塔事典累计收集潜能图鉴数量
    TowerBuildSpecificDifficultyAndScoreWithTotal                = 521 ; --- 星塔获得X次难度Y以上评分Z的构筑
    TowerSpecificDifficultyStrengthenMachineTotal                = 522 ; --- [历史]星塔X难度使用强化器X次
    TowerSpecificDifficultyKillBossTotal                         = 524 ; --- [历史]星塔X难度击杀boss总数X
    TowerBookSpecificCharWithPotentialTotal                      = 525 ; --- [历史]星塔事典累计收集角色X的潜能达到Y个
    TowerBuildSpecificCharSpecificScoreWithTotal                 = 526 ; --- 星塔角色X获得Y次Z评分构筑
    TowerGrowthWithSpecificNote                                  = 527 ; --- [历史]完成星塔养成特定节点X解锁
    TowerSpecificFateCardReRollTotal                             = 528 ; --- [历史]星塔命运卡重随X次
    TowerSpecificPotentialReRollTotal                            = 529 ; --- [历史]星塔潜能重随X次
    TowerSpecificShopReRollTotal                                 = 530 ; --- [历史]星塔商店重随X次
    TowerSpecificNoteActivateTotal                               = 531 ; --- [历史]星塔音符激活X次
    TowerSpecificNoteLevelTotal                                  = 532 ; --- [历史]星塔累计获得X级音符等级
    TowerSpecificPotentialBonusTotal                             = 533 ; --- [历史]星塔新潜能加成X次
    TowerSpecificPotentialLuckyTotal                             = 534 ; --- [历史]星塔潜能幸运强化X次
    TowerSpecificShopBuyDiscountTotal                            = 535 ; --- [历史]星塔X难度商店折扣物品购买Y次
    TowerSpecificSecondarySkillActivateTotal                     = 536 ; --- [历史]星塔X难度协奏技能激活Y次
    TowerSpecificGetExtraNoteLvTotal                             = 537 ; --- [历史]星塔X难度音符额外等级效果触发Y次
    TowerSweepTimes                                              = 539 ; --- 星塔扫荡X次
    TowerSweepTotal                                              = 540 ; --- [历史]星塔扫荡X次
}

GameEnum.activityAcceptCond =
{
    WorldClassSpecific                                           =  71 ; --- [历史]达到X世界等级
}

GameEnum.chatCond =
{
    CharacterAcquire                                             =   5 ; --- 拥有角色X
    CharacterSpecific                                            =  10 ; --- [历史]拥有角色X
    CharacterUpLevel                                             =  11 ; --- [历史]角色升级到X级
    CharacterWithSpecificAdvance                                 =  13 ; --- [历史]角色X突破到Y阶
    CharacterWithSpecificAffinity                                =  14 ; --- [历史]角色X达到Y好感度
    ChatTotal                                                    =  23 ; --- [历史]聊天X次
    DateSpecific                                                 =  27 ; --- [历史]特定日期
    DiscAcquire                                                  =  28 ; --- 拥有星盘X
    GiftGiveTotal                                                =  45 ; --- 赠礼X次
    LoginTotal                                                   =  51 ; --- 登录X次
    StageClearSpecificStars                                      =  62 ; --- [历史]通关X类型Y关卡获得Z星数
    WorldClassSpecific                                           =  71 ; --- [历史]达到X世界等级
    BossRushTotalStars                                           =  88 ; --- 当期BOSSRUSH累计星数达到X
    DiscSpecific                                                 = 114 ; --- [历史]拥有星盘X
}

GameEnum.handBookCond =
{
    CharacterAcquire                                             =   5 ; --- 拥有角色X
    CharacterSpecific                                            =  10 ; --- [历史]拥有角色X
    CharacterWithSpecificAdvance                                 =  13 ; --- [历史]角色X突破到Y阶
    ItemsAdd                                                     =  48 ; --- 新增X道具Y个
    SkinAcquire                                                  =  61 ; --- 拥有角色皮肤X
    StoryClear                                                   =  63 ; --- [历史]通关旅行故事X
}

GameEnum.jointDrillCond =
{
    JointDrillScoreTotal                                         =  95 ; --- 总力战赛季累计达到X分
}

GameEnum.questAcceptCond =
{
    QuestTourGuideSpecific                                       =  53 ; --- [历史]达成手册任务X
    WorldClassSpecific                                           =  71 ; --- [历史]达到X世界等级
    CharactersWithSpecificDatingCount                            =  73 ; --- [历史]完成X次Y角色的邀约
    NpcAffinityWithSpecificLevel                                 =  93 ; --- NpcX达到Y好感度
    CharacterPassedWithSpecificTowerAndCount                     =  94 ; --- [历史]角色X通关Y次星塔
    TowerSpecificDifficultyShopBuyTimes                          = 514 ; --- [历史]星塔X难度商店购买X次
    TowerGrowthSpecificNote                                      = 515 ; --- 完成星塔养成特定节点X解锁
    TowerBookWithSpecificEvent                                   = 517 ; --- [历史]星塔事典累计收集事件图鉴数量
    TowerBookWithSpecificFateCard                                = 518 ; --- [历史]星塔事典累计收集卡片图鉴数量
    TowerBookWithSpecificPotential                               = 520 ; --- [历史]星塔事典累计收集潜能图鉴数量
    TowerSpecificDifficultyStrengthenMachineTotal                = 522 ; --- [历史]星塔X难度使用强化器X次
    TowerSpecificDifficultyKillBossTotal                         = 524 ; --- [历史]星塔X难度击杀boss总数X
    TowerBookSpecificCharWithPotentialTotal                      = 525 ; --- [历史]星塔事典累计收集角色X的潜能达到Y个
    TowerGrowthWithSpecificNote                                  = 527 ; --- [历史]完成星塔养成特定节点X解锁
    TowerSpecificFateCardReRollTotal                             = 528 ; --- [历史]星塔命运卡重随X次
    TowerSpecificPotentialReRollTotal                            = 529 ; --- [历史]星塔潜能重随X次
    TowerSpecificShopReRollTotal                                 = 530 ; --- [历史]星塔商店重随X次
    TowerSpecificNoteActivateTotal                               = 531 ; --- [历史]星塔音符激活X次
    TowerSpecificNoteLevelTotal                                  = 532 ; --- [历史]星塔累计获得X级音符等级
    TowerSpecificPotentialBonusTotal                             = 533 ; --- [历史]星塔新潜能加成X次
    TowerSpecificPotentialLuckyTotal                             = 534 ; --- [历史]星塔潜能幸运强化X次
    TowerSpecificShopBuyDiscountTotal                            = 535 ; --- [历史]星塔X难度商店折扣物品购买Y次
    TowerSpecificSecondarySkillActivateTotal                     = 536 ; --- [历史]星塔X难度协奏技能激活Y次
    TowerSpecificGetExtraNoteLvTotal                             = 537 ; --- [历史]星塔X难度音符额外等级效果触发Y次
}

GameEnum.questCompleteCond =
{
    BattleTotal                                                  =   3 ; --- 战斗X次
    BattlesTotalWithPartner                                      =   4 ; --- 战斗X次Y成员
    CharacterAcquireQuantityRarityAndAdvancement                 =   6 ; --- 拥有X个品阶Y稀有度Z的角色
    CharacterAdvanceTotal                                        =   7 ; --- 角色进阶X次
    CharacterSkillUpTotal                                        =   8 ; --- 角色技能提升X次
    CharacterSkillWithSpecificUpTotal                            =   9 ; --- 角色X升级技能Y次
    CharacterUpTotal                                             =  12 ; --- 角色升级X次
    CharacterWithSpecificAdvance                                 =  13 ; --- [历史]角色X突破到Y阶
    CharacterWithSpecificUpLevel                                 =  15 ; --- [历史]角色X升到Y级
    CharactersWithSpecificNumberLevelAndAttributes               =  17 ; --- [历史]拥有X数量Y等级Z属性的角色
    CharactersWithSpecificQuantityAdvancementCountAndAttribute   =  19 ; --- [历史]拥有X数量Y进阶次数Z属性的角色
    CharactersWithSpecificQuantityRarityAndLevel                 =  22 ; --- [历史]拥有X数量Y等级Z稀有度的角色
    ChatTotal                                                    =  23 ; --- [历史]聊天X次
    DailyInstanceClearSpecificDifficultyAndTotal                 =  24 ; --- 通关X次难度Y的Z日常副本
    DailyInstanceClearSpecificTypeAndTotal                       =  25 ; --- 通关X次Y类型日常副本
    DailyInstanceClearTotal                                      =  26 ; --- 通关日常副本X次
    DiscAcquireQuantityLevelAndRarity                            =  30 ; --- 拥有X个等级Y稀有度Z的星盘
    DiscAcquireQuantityPhaseAndRarity                            =  31 ; --- 拥有X个品阶Y稀有度Z的星盘
    DiscAcquireQuantityStarAndRarity                             =  32 ; --- 拥有X个星级Y稀有度Z的星盘
    DiscLimitBreakTotal                                          =  33 ; --- 星盘突破X次
    DiscPromoteTotal                                             =  34 ; --- 星盘升阶X次
    DiscStrengthenTotal                                          =  35 ; --- 星盘强化X次
    DiscWithSpecificQuantityLevelAndRarity                       =  36 ; --- [历史]拥有X个等级Y稀有度Z的星盘
    DiscWithSpecificQuantityPhaseAndRarity                       =  37 ; --- [历史]拥有X个品阶Y稀有度Z的星盘
    DiscWithSpecificQuantityStarAndRarity                        =  38 ; --- [历史]拥有X个星级Y稀有度Z的星盘
    EnergyDeplete                                                =  39 ; --- 体力消耗X点
    GachaTotal                                                   =  44 ; --- 抽卡X次
    GiftGiveTotal                                                =  45 ; --- 赠礼X次
    InfinityTowerClearSpecificFloor                              =  46 ; --- [历史]通关X层Y类型的无尽塔
    InfinityTowerClearTotal                                      =  47 ; --- 通关无尽塔X次
    ItemsAdd                                                     =  48 ; --- 新增X道具Y个
    ItemsDeplete                                                 =  49 ; --- 消耗X道具Y个
    ItemsProductTotal                                            =  50 ; --- 合成X次
    LoginTotal                                                   =  51 ; --- 登录X次
    QuestTravelerDuelChallengeTotal                              =  52 ; --- 完成巅峰揭幕赛季X次
    QuestTourGuideSpecific                                       =  53 ; --- [历史]达成手册任务X
    QuestTravelerDuelSpecific                                    =  54 ; --- [历史]完成巅峰揭幕常驻任务X
    QuestWithSpecificType                                        =  55 ; --- 达成X次Y类型任务
    RegionBossClearSpecificFullStarWithBossIdAndDifficulty       =  56 ; --- [历史]三星通关X种Y难度的区域
    RegionBossClearSpecificLevelWithDifficultyAndTotal           =  57 ; --- 通关X次难度Y的Z地区
    RegionBossClearSpecificTotal                                 =  58 ; --- 通关X次Y地区
    RegionBossClearTotal                                         =  59 ; --- 通关地区X次
    SkillsWithSpecificQuantityAndLevel                           =  60 ; --- [历史]拥有X个等级Y的技能
    StageClearSpecificStars                                      =  62 ; --- [历史]通关X类型Y关卡获得Z星数
    StoryClear                                                   =  63 ; --- [历史]通关旅行故事X
    TravelerDuelChallengeSpecificBoosLevelWithDifficultyAndTotal =  64 ; --- 通关X次词条难度Y的Z巅峰揭幕赛季
    TravelerDuelClearBossTotal                                   =  65 ; --- 通关巅峰揭幕常驻X次
    TravelerDuelClearSpecificBossIdAndDifficulty                 =  66 ; --- [历史]通关X种Y关卡难度的巅峰揭幕常驻
    TravelerDuelChallengeClearSpecificBossLevelAndAffix          =  67 ; --- 通关X巅峰揭幕赛季指定Y词条
    TravelerDuelClearSpecificBossLevelWithDifficultyAndTotal     =  68 ; --- 通关X次关卡难度Y的Z巅峰揭幕常驻
    TravelerDuelClearSpecificBossTotal                           =  69 ; --- 通关X次Y巅峰揭幕常驻
    TravelerDuelChallengeRankUploadTotal                         =  70 ; --- 上传X次巅峰揭幕赛季模式分数
    WorldClassSpecific                                           =  71 ; --- [历史]达到X世界等级
    RegionBossClearSpecificTypeWithTotal                         =  72 ; --- 通关X次Y类型的区域
    CharactersWithSpecificDatingCount                            =  73 ; --- [历史]完成X次Y角色的邀约
    CharactersDatingTotal                                        =  74 ; --- 完成X次角色邀约
    VampireSurvivorPassedSpecificLevel                           =  77 ; --- 通关指定吸血鬼关卡X
    CharacterParticipateTowerNumber                              =  78 ; --- 角色X参与Y次星塔
    CharacterAllSkillReachSpecificLevel                          =  79 ; --- 角色X所有技能均达到Y级
    TravelerDuelPlayTotal                                        =  80 ; --- 体验巅峰揭幕常驻X次
    VampireClearTotal                                            =  81 ; --- 通关吸血鬼X次
    VampireWithSpecificClearTotal                                =  82 ; --- [历史]通关吸血鬼X次
    AgentFinishTotal                                             =  83 ; --- 完成委托X次
    AgentWithSpecificFinishTotal                                 =  84 ; --- [历史]完成委托X次
    ActivityMiningEnterLayer                                     =  86 ; --- 在挖格子活动X中抵达Y层
    ActivityMiningDestroyGrid                                    =  87 ; --- 在挖格子活动X中破坏Y个Z类型的格子
    BossRushTotalStars                                           =  88 ; --- 当期BOSSRUSH累计星数达到X
    InfinityTowerClearSpecificDifficultyAndTotal                 =  89 ; --- [历史]通关X个Y层的无尽塔
    SkillInstanceClearTotal                                      =  90 ; --- 通关技能副本X次
    VampireSurvivorSpecificPassedLevel                           =  91 ; --- [历史]通关指定吸血鬼关卡X
    WeekBoosClearSpecificDifficultyAndTotal                      =  92 ; --- [历史]通关X个Y难度的周常副本
    NpcAffinityWithSpecificLevel                                 =  93 ; --- NpcX达到Y好感度
    CharacterPassedWithSpecificTowerAndCount                     =  94 ; --- [历史]角色X通关Y次星塔
    ActivityCookieLevelAccPackage                                =  96 ; --- 在曲奇工坊活动X中的Y关卡中累计打包Z盒
    ActivityCookieLevelScore                                     =  97 ; --- 在曲奇工坊活动X中的关卡Y达到Z分
    ActivityCookieTypeAccPackage                                 =  98 ; --- 在曲奇工坊活动X中的Y模块中累计完成Z盒
    ActivityCookieTypeAccPackCookie                              =  99 ; --- 在曲奇工坊活动X中的Y模块中累计包装Z个饼干
    ActivityCookieTypeAccRhythm                                  = 100 ; --- 在曲奇工坊活动X中的Y模块中累计收集Z类型评价N次
    ActivityCookieTypeChallenge                                  = 101 ; --- 在曲奇工坊活动X中的Y模块中累计挑战Z次
    CharGemInstanceClearTotal                                    = 104 ; --- 通关纹章副本X次
    DailyShopReceiveShopTotal                                    = 105 ; --- 领取商店奖励X次
    AgentApplyTotal                                              = 106 ; --- 申请委托X次
    ActivityScore                                                = 107 ; --- 在活动X中累计达到Y分
    ActivityTypeAvgReadWithSpecificIdAndLevelId                  = 108 ; --- 活动类型AVG阅读X活动剧情第Y关
    ActivityTypeLevelPassedWithSpecificIdAndLevelId              = 109 ; --- 活动类型关卡通关X活动战斗关卡Y关
    ActivityTypeLevel3StarPassedWithSpecificIdAndLevelId         = 110 ; --- 活动类型关卡3星通关X活动战斗关卡Y关
    ActivityTypeLevelStarWithSpecificIdAndLevelTypeTotal         = 111 ; --- 活动类型关卡收集X活动战斗关卡Y类型关卡Z星
    ActivityTypeLevelPassedWithSpecificIdAndLevelIdAndSpecificPositionAndCharElem = 112 ; --- 活动类型关卡通关X活动战斗关卡Y关时A位置出场Z属性角色
    ActivityTypeLevelPassedSpecificIdTotal                       = 113 ; --- 活动类型关卡挑战X活动战斗关卡Y次
    ClientReport                                                 = 200 ; --- 客户端事件(Client)
    TowerBuildSpecificScoreWithTotal                             = 504 ; --- 星塔角色达到X次Y评分
    TowerClearSpecificLevelWithDifficultyAndTotal                = 507 ; --- 通关X次难度Y的Z星塔组
    TowerEnterTotal                                              = 510 ; --- 进入星塔X次
    TowerSpecificDifficultyShopBuyTimes                          = 514 ; --- [历史]星塔X难度商店购买X次
    TowerGrowthSpecificNote                                      = 515 ; --- 完成星塔养成特定节点X解锁
    TowerClearSpecificLevelWithDifficultyAndTotalHistory         = 516 ; --- [历史]通关X次难度Y的Z星塔组
    TowerBookWithSpecificEvent                                   = 517 ; --- [历史]星塔事典累计收集事件图鉴数量
    TowerBookWithSpecificFateCard                                = 518 ; --- [历史]星塔事典累计收集卡片图鉴数量
    TowerBookWithSpecificPotential                               = 520 ; --- [历史]星塔事典累计收集潜能图鉴数量
    TowerBuildSpecificDifficultyAndScoreWithTotal                = 521 ; --- 星塔获得X次难度Y以上评分Z的构筑
    TowerSpecificDifficultyStrengthenMachineTotal                = 522 ; --- [历史]星塔X难度使用强化器X次
    TowerSpecificDifficultyKillBossTotal                         = 524 ; --- [历史]星塔X难度击杀boss总数X
    TowerBookSpecificCharWithPotentialTotal                      = 525 ; --- [历史]星塔事典累计收集角色X的潜能达到Y个
    TowerBuildSpecificCharSpecificScoreWithTotal                 = 526 ; --- 星塔角色X获得Y次Z评分构筑
    TowerGrowthWithSpecificNote                                  = 527 ; --- [历史]完成星塔养成特定节点X解锁
    TowerSpecificFateCardReRollTotal                             = 528 ; --- [历史]星塔命运卡重随X次
    TowerSpecificPotentialReRollTotal                            = 529 ; --- [历史]星塔潜能重随X次
    TowerSpecificShopReRollTotal                                 = 530 ; --- [历史]星塔商店重随X次
    TowerSpecificNoteActivateTotal                               = 531 ; --- [历史]星塔音符激活X次
    TowerSpecificNoteLevelTotal                                  = 532 ; --- [历史]星塔累计获得X级音符等级
    TowerSpecificPotentialBonusTotal                             = 533 ; --- [历史]星塔新潜能加成X次
    TowerSpecificPotentialLuckyTotal                             = 534 ; --- [历史]星塔潜能幸运强化X次
    TowerSpecificShopBuyDiscountTotal                            = 535 ; --- [历史]星塔X难度商店折扣物品购买Y次
    TowerSpecificSecondarySkillActivateTotal                     = 536 ; --- [历史]星塔X难度协奏技能激活Y次
    TowerSpecificGetExtraNoteLvTotal                             = 537 ; --- [历史]星塔X难度音符额外等级效果触发Y次
    TowerEnterFloor                                              = 538 ; --- 进入星塔X层
    TowerSweepTimes                                              = 539 ; --- 星塔扫荡X次
    TowerSweepTotal                                              = 540 ; --- [历史]星塔扫荡X次
}

GameEnum.shopCond =
{
    StageClearSpecificStars                                      =  62 ; --- [历史]通关X类型Y关卡获得Z星数
    WorldClassSpecific                                           =  71 ; --- [历史]达到X世界等级
    ShopPreGoodsSellOut                                          =  85 ; --- 商店X前置商品Y售罄
}

GameEnum.towerCond =
{
    ClientReport                                                 = 200 ; --- 客户端事件(Client)
    TowerBattleTimes                                             = 501 ; --- 星塔战斗胜利X次Y类型房间
    TowerBossChallengeSpecificHighRewardWithTotal                = 502 ; --- 星塔BOSS挑战最高奖励X次
    TowerBuildSpecificCharacter                                  = 503 ; --- 星塔Build特定角色X
    TowerBuildSpecificScoreWithTotal                             = 504 ; --- 星塔角色达到X次Y评分
    TowerClearSpecificCharacterTypeWithTotal                     = 505 ; --- 通关X次全部角色类型Y的星塔
    TowerClearSpecificGroupIdAndDifficulty                       = 506 ; --- 通过任意X种Y难度的星塔
    TowerClearSpecificLevelWithDifficultyAndTotal                = 507 ; --- 通关X次难度Y的Z星塔组
    TowerClearTotal                                              = 508 ; --- 星塔通关X次
    TowerEnterRoom                                               = 509 ; --- [历史]进入X次Y类型星塔房间
    TowerEnterTotal                                              = 510 ; --- 进入星塔X次
    TowerEventTimes                                              = 511 ; --- 星塔房触发X次事件
    TowerFateTimes                                               = 512 ; --- 星塔房获得X次命运卡
    TowerItemsGet                                                = 513 ; --- 星塔获得X道具Y个
    TowerSpecificDifficultyShopBuyTimes                          = 514 ; --- [历史]星塔X难度商店购买X次
    TowerGrowthSpecificNote                                      = 515 ; --- 完成星塔养成特定节点X解锁
    TowerClearSpecificLevelWithDifficultyAndTotalHistory         = 516 ; --- [历史]通关X次难度Y的Z星塔组
    TowerBookWithSpecificEvent                                   = 517 ; --- [历史]星塔事典累计收集事件图鉴数量
    TowerBookWithSpecificFateCard                                = 518 ; --- [历史]星塔事典累计收集卡片图鉴数量
    TowerBookWithSpecificPotential                               = 520 ; --- [历史]星塔事典累计收集潜能图鉴数量
    TowerBuildSpecificDifficultyAndScoreWithTotal                = 521 ; --- 星塔获得X次难度Y以上评分Z的构筑
    TowerSpecificDifficultyStrengthenMachineTotal                = 522 ; --- [历史]星塔X难度使用强化器X次
    TowerSpecificDifficultyKillBossTotal                         = 524 ; --- [历史]星塔X难度击杀boss总数X
    TowerBookSpecificCharWithPotentialTotal                      = 525 ; --- [历史]星塔事典累计收集角色X的潜能达到Y个
    TowerBuildSpecificCharSpecificScoreWithTotal                 = 526 ; --- 星塔角色X获得Y次Z评分构筑
    TowerGrowthWithSpecificNote                                  = 527 ; --- [历史]完成星塔养成特定节点X解锁
    TowerSpecificFateCardReRollTotal                             = 528 ; --- [历史]星塔命运卡重随X次
    TowerSpecificPotentialReRollTotal                            = 529 ; --- [历史]星塔潜能重随X次
    TowerSpecificShopReRollTotal                                 = 530 ; --- [历史]星塔商店重随X次
    TowerSpecificNoteActivateTotal                               = 531 ; --- [历史]星塔音符激活X次
    TowerSpecificNoteLevelTotal                                  = 532 ; --- [历史]星塔累计获得X级音符等级
    TowerSpecificPotentialBonusTotal                             = 533 ; --- [历史]星塔新潜能加成X次
    TowerSpecificPotentialLuckyTotal                             = 534 ; --- [历史]星塔潜能幸运强化X次
    TowerSpecificShopBuyDiscountTotal                            = 535 ; --- [历史]星塔X难度商店折扣物品购买Y次
    TowerSpecificSecondarySkillActivateTotal                     = 536 ; --- [历史]星塔X难度协奏技能激活Y次
    TowerSpecificGetExtraNoteLvTotal                             = 537 ; --- [历史]星塔X难度音符额外等级效果触发Y次
    TowerEnterFloor                                              = 538 ; --- 进入星塔X层
    TowerSweepTimes                                              = 539 ; --- 星塔扫荡X次
    TowerSweepTotal                                              = 540 ; --- [历史]星塔扫荡X次
}

GameEnum.towerDefenseCond =
{
    TowerDefenseClear                                            = 102 ; --- [历史]通关塔防关卡X
    TowerDefenseClearSpecificStar                                = 103 ; --- [历史]塔防关卡X星级达到Y
}

GameEnum.vampireSurvivorCond =
{
    VampireSurvivorScoreTotal                                    =  75 ; --- 吸血鬼赛季累计达到X分
    VampireSurvivorSpecificLevelWithSpecificScore                =  76 ; --- 指定吸血鬼关卡达到指定分数
    VampireSurvivorPassedSpecificLevel                           =  77 ; --- 通关指定吸血鬼关卡X
    VampireSurvivorSpecificPassedLevel                           =  91 ; --- [历史]通关指定吸血鬼关卡X
}

GameEnum.honorType =
{
    Normal                                                       =   1 ; --- 普通
    Character                                                    =   2 ; --- 默契
    Group                                                        =   3 ; --- 组
}

GameEnum.headType =
{
    HeroineAvatar                                                =   1 ; --- 主角头像女
    HeroAvatar                                                   =   2 ; --- 主角头像男
    CharacterAvatar                                              =   3 ; --- 角色头像
    PropAvatar                                                   =   4 ; --- 道具头像
}

GameEnum.towerBookFateCardFinishType =
{
    FateCardCount                                                =   1 ; --- 命运卡图鉴数量
    FateCardCollect                                              =   2 ; --- 收集特定命运卡
    FateCardUnlock                                               =   3 ; --- 解锁特定命运卡
}

GameEnum.towerBookPotentialCond =
{
    TowerBookCharPotentialQuantity                               = 401 ; --- 星塔图鉴X角色解锁Y个潜能图鉴
}

GameEnum.towerGrowthEffect =
{
    ClientEffect                                                 =   0 ; --- 客户端效果
    ReRollPotential                                              =   1 ; --- 潜能重随
    ReRollFateCard                                               =   2 ; --- 卡片重随
    UnlockHighRiskRoom                                           =   3 ; --- 命运之间解锁
    UnlockTowerSweep                                             =   4 ; --- 星塔扫荡解锁
    ReRollShopGoods                                              =   5 ; --- 商店重随
    GetNewPotentialLvUp                                          =   6 ; --- 获得新潜能等级加成
    UnlockStrengthenMachine                                      =   7 ; --- 强化机解锁
    LuckyStrengthenMachine                                       =   8 ; --- 强化机幸运强化
    StrengthenMachineFirstFree                                   =   9 ; --- 强化机首次免费
    StrengthenMachineDiscount                                    =  10 ; --- 强化机打折
    EnterTowerGetCoins                                           =  11 ; --- 初始额外星塔币
    DropExtraGetCoins                                            =  12 ; --- 额外掉落星塔币
    ShopGoodsIncrease                                            =  13 ; --- 商店货物增加
    ShopDiscountGoodsIncrease                                    =  14 ; --- 商店打折货物增加
    TowerExtraReward                                             =  15 ; --- 星塔额外产出
    EnterTowerGetFateCard                                        =  16 ; --- 初始额外卡片
    FateCardDropPropUp                                           =  17 ; --- 卡片掉落概率提高
    DropExtraGetFateCard                                         =  18 ; --- 额外获得同系卡片
    GetFateCardWeightUp                                          =  19 ; --- 获得卡片权重提升
    TowerTicketProductionUp                                      =  20 ; --- 星塔产生票根提升
    TowerTicketLimitUp                                           =  21 ; --- 票根周获取上限提升
    HighRiskRoomExtraDrop                                        =  22 ; --- 命运之间额外掉落
    AddResurrectionCount                                         =  23 ; --- 增加复活次数
    UnlockFateCard                                               =  24 ; --- 解锁命运卡
    BOSSExtraGetRunes                                            =  25 ; --- BOSS房额外掉落音符
    DiscExtraSubSlot                                             =  26 ; --- 额外SUB星盘槽位
    DropExtraGetRunes                                            =  27 ; --- 星塔额外获得的音符数
    EnterTowerGetRunes                                           =  28 ; --- 进入星塔获得音符
    GetExtraRuneLevel                                            =  29 ; --- 获得额外音符等级
    PotentialMaxLvUp                                             =  30 ; --- 潜能等级提升
    RandomExtraEvent                                             =  31 ; --- 随机额外事件
}

GameEnum.vampireTalentEffect =
{
    ClientEffect                                                 =   0 ; --- 客户端效果
    FateCardSelectUp                                             =   1 ; --- 命运卡选项提升
    BattleGetFateCard                                            =   2 ; --- 战斗获取命运卡
    ReRollFateCard                                               =   3 ; --- 命运卡重随
    UnlockspecialFateCard                                        =   4 ; --- 解锁特殊命运卡
    BattleRdmEventUp                                             =   5 ; --- 战斗随机事件概率提升
    VampireExpUp                                                 =   6 ; --- 经验提升
    ActiveDrop                                                   =   7 ; --- 激活掉落物
    DropItemPropUp                                               =   8 ; --- 提升掉落物概率
}

GameEnum.towerGrowthNodeType =
{
    Normal                                                       =   1 ; --- 普通
    Core                                                         =   2 ; --- 核心
}

GameEnum.towerEventResType =
{
    Common                                                       =   0 ; --- 通用资源
    FateCard                                                     =   1 ; --- 命运卡
    SubNoteSkill                                                 =   2 ; --- 属性音符技能
    Potential                                                    =   3 ; --- 潜能
}

GameEnum.eventTypes =
{
    eUnKnown                                                     =   1 ; --- 未定义
    eWildCard                                                    =   2 ; --- 通配符
    eLogin                                                       =   3 ; --- 登录
    eQuest                                                       =   4 ; --- 完成任务
    eDailyLogin                                                  =   5 ; --- 每日首次登录
    eBattle                                                      =   6 ; --- 战斗相关事件
    eBattleStar                                                  =   7 ; --- 战斗星级相关事件
    eDailyInstance                                               =   8 ; --- 日常副本通关事件
    eWorldClassUpgrade                                           =   9 ; --- 世界等级升级事件
    eItemsDeplete                                                =  10 ; --- 道具消耗
    eItemsAdd                                                    =  11 ; --- 道具补充
    eGacha                                                       =  12 ; --- 抽卡事件
    eCharacterExpUp                                              =  13 ; --- 角色经验变化
    eRegionBoss                                                  =  14 ; --- 地区boss关卡
    eEnergyConsume                                               =  15 ; --- 体力消耗
    eDiscAdd                                                     =  16 ; --- 星盘获得事件
    eDiscStrengthen                                              =  17 ; --- 星盘强化事件
    eDiscPromote                                                 =  18 ; --- 星盘升阶事件
    eDiscLimitBreak                                              =  19 ; --- 星盘突破事件
    eCharacterAdvance                                            =  20 ; --- 角色进阶事件
    eCharacterSkillUpgrade                                       =  21 ; --- 角色技能升级事件
    eCharacterAdd                                                =  22 ; --- 获取新角色事件
    eCharacterUpgrade                                            =  23 ; --- 角色升级事件
    eCharacterSkinAdd                                            =  24 ; --- 角色皮肤变更事件
    eCharacterAffinity                                           =  25 ; --- 角色好感度事件
    ePlot                                                        =  26 ; --- 角色完成剧情事件
    eAchievement                                                 =  27 ; --- 达成成就
    eTravelerDuel                                                =  28 ; --- 旅人对决关卡
    eTravelerDuelLevelUp                                         =  29 ; --- 旅人对决等级升级
    eEnterInstance                                               =  30 ; --- 进入副本
    eOverflow                                                    =  31 ; --- 溢出事件
    eClient                                                      = 200 ; --- 客户端事件(CLIENT)
    eTowerResurrection                                           = 201 ; --- 客户端事件[星塔复活]
}

GameEnum.elementType =
{
    INHERIT                                                      =   0 ; --- 继承属性
    WE                                                           =   1 ; --- 水
    FE                                                           =   2 ; --- 火
    SE                                                           =   3 ; --- 地
    AE                                                           =   4 ; --- 风
    LE                                                           =   5 ; --- 光
    DE                                                           =   6 ; --- 暗
    NONE                                                         =   7 ; --- 无
}

GameEnum.itemRarity =
{
    SSR                                                          =   1 ; --- 史诗（彩）
    SR                                                           =   2 ; --- 精英（橙）
    R                                                            =   3 ; --- 稀有（蓝）
    M                                                            =   4 ; --- 优秀（绿）
    N                                                            =   5 ; --- 普通（白）
}

GameEnum.monsterAIBranchFollowEventType =
{
    NONE                                                         =   0 ; --- 无
    DEACTIVE_CERTAIN_ID_AI                                       =   1 ; --- 沉睡指定id的AI
    ACTIVE_CERTAIN_ID_AI                                         =   2 ; --- 激活指定id的AI
    DEACTIVE_CERTAIN_GROUPID_AI                                  =   3 ; --- 沉睡指定组id的AI
    ACTIVE_CERTAIN_GROUPID_AI                                    =   4 ; --- 激活指定组id的AI
    EXECUTE_CERTAIN_ID_AI                                        =   5 ; --- 执行指定id的AI
    CLOSE_CERTAIN_ID_AI                                          =   6 ; --- 关闭指定id的AI
    OPEN_CERTAIN_ID_AI                                           =   7 ; --- 开启指定id的AI
    CLOSE_CERTAIN_GROUPID_AI                                     =   8 ; --- 关闭指定组id的AI
    OPEN_CERTAIN_GROUPID_AI                                      =   9 ; --- 开启指定组id的AI
    FORCE_EXECUTE_CERTAIN_ID_AI                                  =  10 ; --- 无视限制条件执行指定BranchID
    CERTAIN_ID_AI_BEGIN_CD                                       =  11 ; --- 指定id的AI进入CD
    CERTAIN_ID_AI_CLEAR_CASTSKILLTIME                            =  12 ; --- 指定BranchID释放次数清零
    CERTAIN_ID_GROUP_CLEAR_CASTSKILLTIME                         =  13 ; --- 指定BranchID组释放次数清零
}

GameEnum.effectAttributeType =
{
    NONE                                                         =   0 ; --- 无
    ATK                                                          =   1 ; --- 攻击力
    DEF                                                          =   2 ; --- 防御力
    MAXHP                                                        =   3 ; --- 生命上限
    HITRATE                                                      =   4 ; --- 命中
    EVD                                                          =   5 ; --- 回避
    CRITRATE                                                     =   6 ; --- 暴击
    CRITRESIST                                                   =   7 ; --- 暴击抵抗
    CRITPOWER_P                                                  =   8 ; --- 暴击伤害
    PENETRATE                                                    =   9 ; --- 防御穿透
    DEF_IGNORE                                                   =  10 ; --- 无视防御
    WER                                                          =  11 ; --- 水系抗性
    FER                                                          =  12 ; --- 火系抗性
    SER                                                          =  13 ; --- 地系抗性
    AER                                                          =  14 ; --- 风系抗性
    LER                                                          =  15 ; --- 光系抗性
    DER                                                          =  16 ; --- 暗系抗性
    WEE                                                          =  17 ; --- 水系伤害
    FEE                                                          =  18 ; --- 火系伤害
    SEE                                                          =  19 ; --- 地系伤害
    AEE                                                          =  20 ; --- 风系伤害
    LEE                                                          =  21 ; --- 光系伤害
    DEE                                                          =  22 ; --- 暗系伤害
    WEP                                                          =  23 ; --- 水系穿透
    FEP                                                          =  24 ; --- 火系穿透
    SEP                                                          =  25 ; --- 地系穿透
    AEP                                                          =  26 ; --- 风系穿透
    LEP                                                          =  27 ; --- 光系穿透
    DEP                                                          =  28 ; --- 暗系穿透
    WEI                                                          =  29 ; --- 无视水系伤害
    FEI                                                          =  30 ; --- 无视火系伤害
    SEI                                                          =  31 ; --- 无视地系伤害
    AEI                                                          =  32 ; --- 无视风系伤害
    LEI                                                          =  33 ; --- 无视光系伤害
    DEI                                                          =  34 ; --- 无视暗系伤害
    WEERCD                                                       =  35 ; --- 受到水系伤害
    FEERCD                                                       =  36 ; --- 受到火系伤害
    SEERCD                                                       =  37 ; --- 受到地系伤害
    AEERCD                                                       =  38 ; --- 受到风系伤害
    LEERCD                                                       =  39 ; --- 受到光系伤害
    DEERCD                                                       =  40 ; --- 受到暗系伤害
    WEIGHT                                                       =  41 ; --- 重量
    TOUGHNESS_MAX                                                =  42 ; --- 最大韧性
    TOUGHNESS_DAMAGE_ADJUST                                      =  43 ; --- 破韧效率
    SHIELD_MAX                                                   =  44 ; --- 护盾上限
    MOVESPEED                                                    =  46 ; --- 移动速度
    ATKSPD_P                                                     =  47 ; --- 攻击速度
    INTENSITY                                                    =  48 ; --- 强度
    GENDMG                                                       =  49 ; --- 造成伤害
    DMGPLUS                                                      =  50 ; --- 伤害值
    FINALDMG                                                     =  51 ; --- 最终伤害
    FINALDMGPLUS                                                 =  52 ; --- 最终伤害值
    GENDMGRCD                                                    =  53 ; --- 受到所有伤害
    DMGPLUSRCD                                                   =  54 ; --- 受到伤害
    SUPPRESS                                                     =  55 ; --- 弱点压制
    NORMALDMG                                                    =  56 ; --- 普攻伤害
    SKILLDMG                                                     =  57 ; --- 技能伤害
    ULTRADMG                                                     =  58 ; --- 绝招伤害
    OTHERDMG                                                     =  59 ; --- 其他伤害
    RCDNORMALDMG                                                 =  60 ; --- 受到普攻伤害
    RCDSKILLDMG                                                  =  61 ; --- 受到技能伤害
    RCDULTRADMG                                                  =  62 ; --- 受到绝招伤害
    RCDOTHERDMG                                                  =  63 ; --- 受到其他伤害
    MARKDMG                                                      =  64 ; --- 印记伤害
    RCDMARKDMG                                                   =  65 ; --- 受到印记伤害
    SUMMONDMG                                                    =  66 ; --- 仆从伤害
    RCDSUMMONDMG                                                 =  67 ; --- 受到仆从伤害
    PROJECTILEDMG                                                =  68 ; --- 衍生物伤害
    RCDPROJECTILEDMG                                             =  69 ; --- 受到衍生物伤害
    NORMALCRITRATE                                               =  70 ; --- 普攻暴击
    SKILLCRITRATE                                                =  71 ; --- 技能暴击
    ULTRACRITRATE                                                =  72 ; --- 绝招暴击
    MARKCRITRATE                                                 =  73 ; --- 印记暴击
    SUMMONCRITRATE                                               =  74 ; --- 仆从暴击
    PROJECTILECRITRATE                                           =  75 ; --- 衍生物暴击
    OTHERCRITRATE                                                =  76 ; --- 其他暴击
    NORMALCRITPOWER                                              =  77 ; --- 普攻暴击伤害
    SKILLCRITPOWER                                               =  78 ; --- 技能暴击伤害
    ULTRACRITPOWER                                               =  79 ; --- 绝招暴击伤害
    MARKCRITPOWER                                                =  80 ; --- 印记暴击伤害
    SUMMONCRITPOWER                                              =  81 ; --- 仆从暴击伤害
    PROJECTILECRITPOWER                                          =  82 ; --- 衍生物暴击伤害
    OTHERCRITPOWER                                               =  83 ; --- 其他暴击伤害
    ENERGY_MAX                                                   =  84 ; --- 能量上限
    SKILL_INTENSITY                                              =  85 ; --- 技能强度
    TOUGHNESS_BROKEN_DMG                                         =  86 ; --- 破韧专属易伤
    ADD_SHIELD_STRENGTHEN                                        =  87 ; --- 护盾强效
    BE_ADD_SHIELD_STRENGTHEN                                     =  88 ; --- 受护盾效率
    MAX                                                          =  89 ; --- 最大效果数量
}

GameEnum.trigger =
{
    NONE                                                         =   0 ; --- 无
    NOTHING                                                      =   1 ; --- 无条件
    HITTING                                                      =   2 ; --- 击中时
    BEHIT                                                        =   3 ; --- 被击中时
    KILLENEMY                                                    =   4 ; --- 击杀敌人时
    CRIT                                                         =   5 ; --- 造成暴击时
    CASTSKILL                                                    =   6 ; --- 释放技能时
    GETBUFF                                                      =   7 ; --- 获得特定buff时
    REMOVEBUFF                                                   =   8 ; --- 特定buff消失时
    ENTERBATTLE                                                  =   9 ; --- 入场时
    LEAVEBATTLE                                                  =  10 ; --- 离场时
    BECRIT                                                       =  11 ; --- 被暴击时
    BEGIN_RELOAD                                                 =  12 ; --- 开始换弹时
    FINISH_RELOAD                                                =  13 ; --- 换弹完成时
    EFFECT_EXECUTE                                               =  18 ; --- 效果执行时
    CERTAIN_TIME_INTERVAL                                        =  19 ; --- 指定间隔触发
    CASTSKILLEND                                                 =  20 ; --- 技能释放完成时触发
    HP_CHANGE                                                    =  21 ; --- 血量变化时
    ON_IMMUNE_DEAD                                               =  22 ; --- 免疫死亡时触发
    DAMAGE_CAUSE_DEAD                                            =  23 ; --- 伤害会导致死亡时触发
    PERFECT_DODGE                                                =  24 ; --- 极限闪避时
    BATTLE_WIN                                                   =  25 ; --- 战斗胜利时
    SWICH_PLAYER                                                 =  26 ; --- 手动切换上场
    TO_BREAK_ALLSHIELD                                           =  27 ; --- 击破所有护盾时
    BE_BREAK_ALLSHIELD                                           =  28 ; --- 所有护盾被击破时
    BE_BREAK_CERTAINSHIELD                                       =  29 ; --- 指定护盾被击破时
    BE_FINISH_CERTAINSHIELD                                      =  30 ; --- 指定护盾正常消失时
    BREAK_TOUGHNESS                                              =  31 ; --- 破韧时
    TRIGGER_MARK                                                 =  32 ; --- 触发印记时
    ULTIMATE_ENERGY_CHANGE                                       =  33 ; --- 大招能量变化时
    ATTACKING                                                    =  34 ; --- 攻击时
    BEATTACK                                                     =  35 ; --- 被攻击时
    SUMMONED_DIED                                                =  36 ; --- 仆从死亡时
    SUMMON                                                       =  37 ; --- 召唤仆从时
    ADD_SHIELD                                                   =  38 ; --- 施加护盾时
    GET_SHIELD                                                   =  39 ; --- 获得护盾时
    IN_BATTLE_STATE                                              =  40 ; --- 进入战斗状态时
    ANY_ACTOR_TRIGGER_MARK                                       =  41 ; --- 己方触发印记时
}

GameEnum.takeEffect =
{
    NONE                                                         =   0 ; --- 无
    DEFAULT                                                      =   1 ; --- 默认
    HEALTHUP                                                     =   2 ; --- 生命高于
    HEALTHDOWN                                                   =   3 ; --- 生命低于
    CARRYBUFFID                                                  =   4 ; --- 携带IDBuff
    CARRYBUFFGROUP                                               =   5 ; --- 携带组Buff
    CARRYBUFFIDENTIFYING                                         =   6 ; --- 携带标识Buff
    SKILLSLOTTYPE                                                =   7 ; --- 指定技能槽位
    HITELEMENTTYPE                                               =   8 ; --- 指定伤害元素类型
    DISTANCETYPE                                                 =   9 ; --- 指定攻击类型
    ACTORELEMENTTYPE                                             =  10 ; --- 指定角色元素类型
    CERTAINBUFFID                                                =  11 ; --- 指定BUFFID
    CERTAINBUFFGROUPID                                           =  12 ; --- 指定BUFF组ID
    CERTAINBUFFTAG                                               =  13 ; --- 指定BUFF标识
    CERTAINSHIELDID                                              =  14 ; --- 指定护盾ID
    NEARBY_ACTOR_LARGE_OR_EQUAL                                  =  15 ; --- 附近人数多于
    NEARBY_ACTOR_LESS_OR_EQUAL                                   =  16 ; --- 附近人数少于
    CERTAIN_SKILL_ID                                             =  17 ; --- 指定技能ID
    HAVE_SHIELD                                                  =  18 ; --- 有护盾
    NO_SHIELD                                                    =  19 ; --- 无护盾
    LEAVE_STAGE                                                  =  20 ; --- 不在场上
    HIT_TARGET_MOREOREQUAL_THAN                                  =  21 ; --- 同时命中敌人多于
    HIT_TARGET_LESSOREQUAL_THAN                                  =  22 ; --- 同时命中敌人少于
     BUFF_NUM                                                    =  23 ; --- BUFF叠加层数
     PROBOBILITY_UP                                              =  24 ; --- 概率高于 
    CERTAIN_LEVEL_TYPE                                           =  25 ; --- 指定关卡类型
    CERTAIN_EFFECT_ID                                            =  26 ; --- 指定效果ID
    CERTAIN_EFFECT_TAG                                           =  27 ; --- 指定效果TAG
    CERTAIN_MONSTER_EPICTYPE                                     =  28 ; --- 指定怪物阶层
    TIME_INTERVAL                                                =  29 ; --- 间隔时间
    CHARACTER_JOBCLASS                                           =  30 ; --- 指定职业
    ROGUELIKE_LEVELSTYLE                                         =  31 ; --- 指定关卡主题
    CERTAIN_MONSTER_TAG                                          =  32 ; --- 指定怪物标签
    TARGET_CONTAIN_TAG                                           =  33 ; --- 目标包含指定标签
    DAMAGE_CONTAIN_TAG                                           =  34 ; --- 伤害包含指定标签
    DISTANCE_LESSOREQUAL_THAN                                    =  35 ; --- 与目标距离小于
    DISTANCE_MOREOREQUAL_THAN                                    =  36 ; --- 与目标距离大于
    CERTAIN_FACTION_TYPE                                         =  37 ; --- 指定阵营类型
    IN_FORWARDAREA                                               =  38 ; --- 目标处于自己前方扇形范围内
    CERTAIN_HITDAMAGEID                                          =  39 ; --- 指定伤害ID
    HAVE_FRIENDLY_SUMMONS                                        =  40 ; --- 场上有友方召唤物
    SELF_BE_MIANCONTROL                                          =  41 ; --- 自己为主控角色
    SELF_BE_ASSISTANT                                            =  42 ; --- 自己为支援角色
    CERTAIN_TYPE_ASSISTANT_IN_BATTLE                             =  43 ; --- 指定元素类型的支援角色驻场
    CERTAIN_MARK_ELMENT_TYPE                                     =  44 ; --- 指定印记元素类型
    ULTIMATE_ENERGY_MOREOREQUAL_THAN                             =  45 ; --- 大招能量百分比大于等于
    SELF_HP_PERCENT_MOREOREQUAL_THAN                             =  46 ; --- 自己血量百分比高于目标
    ULTIMATE_ENERGY_LESSOREQUAL_THAN                             =  47 ; --- 大招能量百分比小于等于
    IS_TOUGHNESS_BROKEN                                          =  48 ; --- 是否处于破韧状态
    DAMAGE_NOT_NORMAL                                            =  49 ; --- 非普攻伤害
    WEAKELEMENTTYPE                                              =  50 ; --- 指定目标弱点元素类型
    CERTAIN_MARK_TYPE                                            =  51 ; --- 指定印记类型
}

GameEnum.effectType =
{
    STATE_CAHNGE                                                 =   1 ; --- 状态属性修改
    CURRENTCD                                                    =   2 ; --- 技能冷却当前时间
    CD                                                           =   3 ; --- 技能冷却最大值
    ADDBUFF                                                      =   6 ; --- 添加Buff
    ADD_SKILL_LV                                                 =   7 ; --- 提升技能等级
    SET_SKILL_LV                                                 =   8 ; --- 提升技能等级至
    IMM_BUFF                                                     =   9 ; --- 免疫Buff
    ADDSKILLAMOUNT                                               =  10 ; --- 增加技能使用层数
    RESUMSKILLAMOUNT                                             =  11 ; --- 恢复技能最大使用层数
    ATTR_FIX                                                     =  12 ; --- 属性修改
    REMOVE_BUFF                                                  =  13 ; --- 移除BUFF
    EFFECT_CD_FIX                                                =  14 ; --- 效果当前冷却
    EFFECT_MAX_CD_FIX                                            =  15 ; --- 效果最大冷却
    AMEND_NO_COST                                                =  16 ; --- 攻击不消耗子弹
    DAMAGE_IMM_ACC                                               =  17 ; --- 免疫次数伤害
    EFFECT_MUL                                                   =  18 ; --- 同时触发效果
    EFFECT_HP_RECOVRY                                            =  19 ; --- 回复生命值
    KILL_IMMEDIATELY                                             =  21 ; --- 即死
    ADD_BUFF_DURATION_EXISTING                                   =  22 ; --- 延长已有Buff持续时长
    HIT_ELEMENT_TYPE_EXTEND                                      =  23 ; --- 伤害元素类型扩展
    CHANGE_EFFECT_RATE                                           =  24 ; --- 效果起效几率
    ADD_TAG                                                      =  25 ; --- 添加标签
    EFFECT_HP_REVERTTO                                           =  27 ; --- 恢复生命值至
    EFFECT_HP_ABSORB                                             =  28 ; --- 生命吸取
    CHANGE_BUFF_LAMINATEDNUM                                     =  29 ; --- 调整Buff单实例叠加上限
    CHANGE_BUFF_TIME                                             =  30 ; --- 调整Buff持续时间
    EFFECT_REVIVE                                                =  31 ; --- 复活目标
    EFFECT_POSTREVIVE                                            =  32 ; --- 复活效果
    SPECIAL_ATTR_FIX                                             =  34 ; --- 特殊属性修改
    AMMO_FIX                                                     =  35 ; --- 弹夹修正
    MONSTER_ATTR_FIX                                             =  36 ; --- 怪物属性修改
    PLAYER_ATTR_FIX                                              =  37 ; --- 玩家属性修改
    IMMUNE_DEAD                                                  =  38 ; --- 免疫死亡
    ENTER_TRANSPARENT                                            =  39 ; --- 进入遮蔽表现
    UNABLE_RECOVER_ENERGY                                        =  40 ; --- 无法恢复能量
    CLEAR_MONSTER_AI_BRANCH_CD                                   =  41 ; --- 清除怪物分支cd
    ADD_SHIELD                                                   =  42 ; --- 添加护盾
    REDUCE_HP_BY_CURRENTHP                                       =  43 ; --- 根据当前生命扣除血量
    REDUCE_HP_BY_MAXHP                                           =  44 ; --- 根据最大生命扣除血量
    HITTED_ADDITIONAL_ATTR_FIX                                   =  45 ; --- 击中时附加属性修改
    ATTR_ASSIGNMENT                                              =  46 ; --- 属性赋予
    CAST_AREAEFFECT                                              =  47 ; --- 释放区域效果
    PASSIVE_SKILL                                                =  48 ; --- 释放被动技能
    IMM_CERTAIN_HITDAMAGEID                                      =  49 ; --- 免疫指定伤害id的伤害
    STATE_AMOUNT                                                 =  50 ; --- 特殊状态属性生效次数
    DROP_ITEM_PICKUP_RANGE_FIX                                   =  51 ; --- 掉落物拾取半径修正
}

GameEnum.stateAttributeType =
{
    NONE                                                         =   0 ; --- 无
    CHAOS                                                        =   1 ; --- 混乱
    CHAOS_WEAKENED                                               =   2 ; --- 次级混乱
    SUA                                                          =   3 ; --- 霸体
    FROZEN                                                       =   4 ; --- 冰冻
    FROZEN_WEAKENED                                              =   5 ; --- 次级冰冻
    STUN                                                         =   6 ; --- 眩晕
    STUN_WEAKENED                                                =   7 ; --- 次级眩晕
    DAMAGE_IMM                                                   =   8 ; --- 伤害免疫
    BONDAGE                                                      =   9 ; --- 束缚
    BONDAGE_WEAKENED                                             =  10 ; --- 次级束缚
    SEARCHED_IMMUNITY                                            =  11 ; --- 无法选定
    HIDE_MODEL                                                   =  12 ; --- 隐藏模型
    CLOSE_MOVE_BLOCK                                             =  13 ; --- 关闭阻挡
    SNEAK                                                        =  14 ; --- 潜行
    INVINCIBLE                                                   =  15 ; --- 无敌
    IMMUNE_KILL                                                  =  16 ; --- 免疫即死
    CURE_IMM                                                     =  17 ; --- 禁疗
    BLINDNESS                                                    =  18 ; --- 致盲
    BLINDNESS_WEAKENED                                           =  19 ; --- 次级致盲
    SLEEP                                                        =  20 ; --- 沉睡
    SLEEP_WEAKENED                                               =  21 ; --- 次级沉睡
    CHARM                                                        =  22 ; --- 魅惑
    CHARM_WEAKENED                                               =  23 ; --- 次级魅惑
    TERROR                                                       =  24 ; --- 恐惧
    TERROR_WEAKENED                                              =  25 ; --- 次级恐惧
    TAUNT                                                        =  26 ; --- 嘲讽
    TAUNT_WEAKENED                                               =  27 ; --- 次级嘲讽
    SILENCE                                                      =  28 ; --- 沉默
    SILENCE_WEAKENED                                             =  29 ; --- 次级沉默
    REDUCE_FOV                                                   =  30 ; --- 视野遮蔽
    IMMUNE_CONTROL                                               =  31 ; --- 免疫控制
    HIDE_OUT                                                     =  32 ; --- 隐匿
    BATTLE_OUT                                                   =  33 ; --- 未参战
    DYINGSUA                                                     =  34 ; --- 濒死霸体
    DODGE_CROSS_OBSTACLE                                         =  35 ; --- 闪避穿越障碍物
    PENETRATE                                                    =  36 ; --- 穿透
    FORBIDDEN_RUSH                                               =  37 ; --- 禁止疾跑
    UNPARALLELED                                                 =  38 ; --- 无双
    INDEFENSE                                                    =  39 ; --- 塔防
    MAX                                                          =  40 ; --- 最大数量
}

GameEnum.playerAttributeType =
{
    ADD_ENERGY                                                   =   0 ; --- 支援能量获取效率
    FRONT_ADD_ENERGY                                             =   1 ; --- 主控能量获取效率
    ADSORPTION_CHANGE                                            =   2 ; --- 吸血鬼掉落物吸附距离修正
    MAX                                                          =   3 ; --- 最大效果数量
}

GameEnum.monsterAttributeType =
{
    MONSTER_AIBRANCH_CD                                          =   0 ; --- 怪物AI分支CD
    MAX                                                          =   1 ; --- 最大效果数量
}

GameEnum.parameterType =
{
    BASE_VALUE                                                   =   1 ; --- 基础值
    PERCENTAGE                                                   =   2 ; --- 百分比
    ABSOLUTE_VALUE                                               =   3 ; --- 绝对值
}

GameEnum.specifyType =
{
    SPECIFIC_SLOT                                                =   1 ; --- 特定槽位
    SPECIFIC_ID                                                  =   2 ; --- 特定ID
    SPECIFIC_TAG                                                 =   3 ; --- 特定Tag
    SPECIFIC_GROUP                                               =   4 ; --- 特定组
    ALL                                                          =   5 ; --- 全部
    BEDAMEGE_REDUCE                                              =   6 ; --- 受击时减少1层
    SHIELDVALUE_ZERO                                             =   7 ; --- 当前护盾值为0减少1层
}

GameEnum.itemStype =
{
    Res                                                          =   1 ; --- 资源
    Item                                                         =   2 ; --- 道具
    Char                                                         =   3 ; --- 角色
    Energy                                                       =   4 ; --- 体力
    WorldRankExp                                                 =   5 ; --- 世界等级经验
    CharShard                                                    =   6 ; --- 角色碎片
    Disc                                                         =   8 ; --- 星盘
    TalentStrengthen                                             =   9 ; --- 天赋强化素材
    DiscStrengthen                                               =  12 ; --- 星盘强化素材
    DiscPromote                                                  =  13 ; --- 星盘升阶素材
    TreasureBox                                                  =  17 ; --- 补给箱
    GearTreasureBox                                              =  18 ; --- 装备补给箱
    SubNoteSkill                                                 =  19 ; --- 属性音符技能
    SkillStrengthen                                              =  24 ; --- 角色技能升级素材
    CharacterLimitBreak                                          =  25 ; --- 角色升阶素材
    MonthlyCard                                                  =  30 ; --- 月卡
    EnergyItem                                                   =  31 ; --- 体力道具
    ComCYO                                                       =  32 ; --- 批量使用自选包
    OutfitCYO                                                    =  33 ; --- 星盘自选包
    RandomPackage                                                =  34 ; --- 随机掉落包
    Equipment                                                    =  35 ; --- 纹章素材
    FateCard                                                     =  37 ; --- 命运卡
    EquipmentExp                                                 =  38 ; --- 装备经验道具
    DiscLimitBreak                                               =  40 ; --- 星盘突破素材
    Potential                                                    =  41 ; --- 潜能
    SpecificPotential                                            =  42 ; --- 特殊潜能
    Honor                                                        =  43 ; --- 称号
    CharacterYO                                                  =  44 ; --- 角色自选包
    PlayHead                                                     =  45 ; --- 头像
    CharacterSkin                                                =  46 ; --- 角色皮肤
}

GameEnum.targetType =
{
    AllActor                                                     =   1 ; --- 场上全体对象
    Player                                                       =   2 ; --- 玩家场上角色
    PlayerGroup                                                  =   3 ; --- 玩家全队角色
    AllMonster                                                   =   4 ; --- 所有敌方怪物
    AllTrap                                                      =   5 ; --- 所有陷阱
}

GameEnum.MonsterPosition =
{
    Melee                                                        =   1 ; --- 近战
    Remote                                                       =   2 ; --- 远程
}

GameEnum.chapterType =
{
    Mainline                                                     =   1 ; --- 主线
    Branchline                                                   =   2 ; --- 支线
    Activity                                                     =   3 ; --- 活动
}

GameEnum.levelType =
{
    Mainline                                                     =   1 ; --- 主线
    FixedRoguelike                                               =   2 ; --- 肉鸽
    RegionBoss                                                   =   3 ; --- 区域领主
    TravelerDuel                                                 =   4 ; --- 旅人对决
    StarTower                                                    =   5 ; --- 星塔
    All                                                          =   6 ; --- 全部
    ActivityLevels                                               =   7 ; --- 剧情活动
    WeeklyCopies                                                 =   8 ; --- 周本BOSS
    VampireInstance                                              =   9 ; --- 吸血鬼
    InfinityTower                                                =  10 ; --- 无尽塔
    ScoreBoss                                                    =  11 ; --- bossrush
    JointDrill                                                   =  12 ; --- 总力战
    SkillInstance                                                =  13 ; --- 卡带副本
    DailyInstance                                                =  14 ; --- 日常副本
    EquipmentInstance                                            =  15 ; --- 装备副本
}

GameEnum.levelEliteType =
{
    Common                                                       =   1 ; --- 通用
    Normal                                                       =   2 ; --- 仅普通本
    Elite                                                        =   3 ; --- 仅精英本
}

GameEnum.RegionType =
{
    NormalRegion                                                 =   1 ; --- 常规模式
    HardCoreRegion                                               =   2 ; --- 真格模式
}

GameEnum.factionRelationship =
{
    Friendly                                                     =   1 ; --- 友善
    Neutrality                                                   =   2 ; --- 中立
    UnFriendly                                                   =   3 ; --- 敌对
}

GameEnum.monsterSubType =
{
    Monster                                                      =   1 ; --- 普通怪物
    Trap                                                         =   2 ; --- 陷阱
}

GameEnum.dropMode =
{
    Sequential                                                   =   1 ; --- 依次掉落
    RoundTable                                                   =   2 ; --- 圆桌
}

GameEnum.weightMode =
{
    Return                                                       =   1 ; --- 放回
    Leave                                                        =   2 ; --- 不放回
}

GameEnum.achievementType =
{
    Others                                                       =   1 ; --- 探索世界
    StarTower                                                    =   2 ; --- 摘星征途
    Battle                                                       =   3 ; --- 战果累累
    Growing                                                      =   4 ; --- 百炼成金
    SocialMedia                                                  =   5 ; --- 社交网络
    Overview                                                     =   6 ; --- 总览（暂未使用）
}

GameEnum.questCompleteCondClient =
{
    KillMonsterWithoutHitBySkill                                 =   1 ; --- 不被指定技能击中击杀指定怪物(Client)
    KillMonsterWithoutKillSpecifiedMonster                       =   2 ; --- 不击杀指定怪物时击杀指定怪物(Client)
    InteractL2D                                                  =   3 ; --- 与看板角色交互(Client)
    KillMonsterWithOneAttack                                     =   4 ; --- 一次攻击击杀X个怪物,限定Y角色完成(Client)
    CritCount                                                    =   6 ; --- X角色暴击(Client)
    CastSkillTypeCount                                           =   5 ; --- 累计释放某个类型技能X次(Client)
    CastSkillCount                                               =   7 ; --- 释放Id为X的技能(Client)
    ExtremDodgeCount                                             =   8 ; --- X角色触发极限闪避(Client)
    KillMonsterClass                                             =   9 ; --- 消灭X级别的怪物,限定Y角色(Client)
    TriggerTagElement                                            =  10 ; --- 触发X系印记(Client)
    OneHitDamage                                                 =  11 ; --- 单次对敌伤害达到X点(Client)
    ClearLevelWithHPBelow                                        =  12 ; --- 以血量低于x%状态通关(Client)
    KillMonsterWithTag                                           =  13 ; --- 累计击杀带有TAG[X]的怪物,限定Y角色(Client)
    KillMonsterWithSkin                                          =  14 ; --- 累计击杀X只MonsterSkin[Y]
    GaoDa_001                                                    = 1305101 ; --- 高达-破坏高达双手并击杀高达
    GaoDa_002                                                    = 1305102 ; --- 高达-被高达的光束炮击中
    GaoDa_003                                                    = 1305103 ; --- 高达-无伤击杀高达
    JiaMianYeZhu_001                                             = 1000501 ; --- 野猪-中断万猪冲锋技能
    JiaMianYeZhu_002                                             = 1000502 ; --- 野猪-不被小猪攻击到
    JiaMianYeZhu_003                                             = 1000503 ; --- 野猪-单次万猪冲锋技能内被小野猪命中X次以上
    JiaMianYeZhu_004                                             = 1000504 ; --- 野猪-无伤击杀野猪王
    BanShenShu_001                                               = 1050101 ; --- 半身树-消灭半身树召唤的花苞X次
    BanShenShu_002                                               = 1050102 ; --- 半身树-不消灭花苞击杀半身树
    BanShenShu_003                                               = 1050103 ; --- 半身树-半身树死亡时场上有活着的土拨鼠
    BanShenShu_004                                               = 1050104 ; --- 半身树-无伤击杀半身树
    ShiLaiMuWang_001                                             = 5008101 ; --- 史莱姆王-阻止小史莱姆合体成史莱姆王
    ShiLaiMuWang_002                                             = 5008102 ; --- 史莱姆王-被史莱姆王击飞
    ShiLaiMuWang_003                                             = 5008103 ; --- 史莱姆王-在小史莱姆合体后，不被连环波浪命中
    ShiLaiMuWang_004                                             = 5008104 ; --- 史莱姆王-10S内击杀全部分裂出的中史莱姆和小史莱姆
    ShiLaiMuWang_005                                             = 5008105 ; --- 史莱姆王-中断史莱姆的滑行技能
    HuoTaLou_001                                                 = 5051101 ; --- 火塔楼-无伤击杀火塔楼
    HuoTaLou_002                                                 = 5051102 ; --- 火塔楼-通过极限闪避躲过火塔楼的砸地板
    ShaSha_001                                                   = 5050101 ; --- 鲨鲨-不被暗影毒池影响的情况下击败鲨鲨
    ShaSha_002                                                   = 5050102 ; --- 鲨鲨-打断一次BOSS狂暴
    ShaSha_003                                                   = 5050103 ; --- 鲨鲨-被地面水域减速累计X秒
    TiaoWuJi_001                                                 = 5052101 ; --- 跳舞机-无伤击败跳舞机
    TiaoWuJi_002                                                 = 5052102 ; --- 跳舞机-遇到俄罗斯方块
    TiaoWuJi_003                                                 = 5052103 ; --- 跳舞机-一场战斗中触发极限闪避到达X次
    TiaoWuJi_004                                                 = 5052104 ; --- 跳舞机-10S内被跳舞机命中X次
    DaGuanZi_001                                                 = 5053101 ; --- 大罐子-在小罐子的形态下死亡
    DaGuanZi_002                                                 = 5053102 ; --- 大罐子-小罐子形态下，没有释放任意技能
    ChuShi_001                                                   = 5054101 ; --- 厨师-一场战斗中，场上刀叉数量到X
    ChuShi_002                                                   = 5054102 ; --- 厨师-厨师没能收回任何一把刀叉
    ChuShi_003                                                   = 5054103 ; --- 厨师-破坏场上刀叉X个
    SanJianKe_001                                                = 5016101 ; --- 三剑客-跳过2阶段
    SanJianKe_002                                                = 5016102 ; --- 三剑客-3个变速刺客在间隔XX秒内被先后击杀
    FanRonShiTi_001                                              = 1001201 ; --- 繁荣实体-不被冲锋命中情况下击败BOSS
    FanRonShiTi_002                                              = 1001202 ; --- 繁荣实体-一场战斗中，被冲锋命中N次
    FanRonShiTi_003                                              = 1001203 ; --- 繁荣实体-中断繁荣实体的大招释放
    FanRonShiTi_004                                              = 1001204 ; --- 小高达-无伤击败BOSS
    XiaoGaoDa_001                                                = 1306101 ; --- 小高达-无伤击败小高达
    XiaoGaoDa_002                                                = 1306102 ; --- 小高达-被小高达的三连冲锋全部命中
    XiaoGaoDa_003                                                = 1306103 ; --- 小高达-在小高达释放天降正义期间击杀BOSS
    DaYinYing_001                                                = 5010101 ; --- 大阴影-击杀大阴影时，场上没有其他小怪存活
    DaYinYing_002                                                = 5010102 ; --- 大阴影-无伤击败大阴影
    MaoYanLvRenBoss_001                                          = 7002101 ; --- 通过旅人对决猫眼XX难度(系统难度）
    MaoYanLvRenBoss_002                                          = 7002102 ; --- 自选词条达到XX分通过旅人对决猫眼
    MaoYanLvRenBoss_003                                          = 7002103 ; --- 单局战斗内被猫眼击中XX次并成功击杀猫眼
    MiNieWaZhuxian_001                                           = 1304101 ; --- 单场战斗内，保持与密涅瓦距离小于4M超过X秒钟
    FengNiao_001                                                 = 1551001 ; --- 蜂鸟-在蜂鸟放大招期间前往大招区域的中心
    FengNiao_002                                                 = 1551002 ; --- 蜂鸟-单场战斗中成功极限闪避蜂鸟的360度激光X次
    FengNiao_003                                                 = 1551003 ; --- 蜂鸟-没有受到来自小蜂鸟与蜂鸟花的伤害
    FengCao_001                                                  = 1651001 ; --- 风草-最高难度下全场未被任何龙卷风命中
    FengCao_002                                                  = 1651002 ; --- 风草-Boss处于大招期间被破韧
    FengCao_003                                                  = 1651003 ; --- 风草-击败Boss时受到的伤害次数小于X
    FengCao_004                                                  = 1651004 ; --- 风草-击败Boss时没有受到任何伤害
    HuoChuiLvRenBoss_001                                         = 7003101 ; --- 自选词条最高分通过 旅人对决 - 火垂
    HuoChuiLvRenBoss_002                                         = 7003102 ; --- 在挑战模式下单场战斗使火垂破韧 x 次
    HuoChuiLvRenBoss_003                                         = 7003103 ; --- 在挑战模式下火垂热力阶段期间不受到伤害
    HuaYuanLvRenBoss_001                                         = 7002201 ; --- 自选词条最高分通过 旅人对决 - 花原
    HuaYuanLvRenBoss_002                                         = 7002202 ; --- 在雾中没有受到来自花原的伤害
    HuaYuanLvRenBoss_003                                         = 7002203 ; --- 挑战模式下通过 旅人对决 - 花原
    XingXing_001                                                 = 5001101 ; --- 猩猩-中断X次猩猩的爬行
    XingXing_002                                                 = 5001102 ; --- 猩猩-在没有受到来自下落攻击伤害的条件下，击败1次猩猩
    CanCha_001                                                   = 5055101 ; --- 累计消灭任意召唤物X个
    CanCha_002                                                   = 5055102 ; --- 餐叉猪-不击杀小餐具情况下击杀BOSS
    CanCha_003                                                   = 5055103 ; --- 餐叉猪-在X分钟内，击败餐叉猪
    CharCommon_01                                                = 10001 ; --- 不使用支援技和支援绝招完成肉鸽塔
    CharCommon_02                                                = 10002 ; --- 累计释放绝招X次
    CharCommon_03                                                = 10003 ; --- 累计释放支援技和支援绝招X次
    CharCommon_04                                                = 10004 ; --- 一个技能或绝招杀死X个以上敌人
    CharCommon_05                                                = 10005 ; --- 不使用闪避完成一次BOSS战
    CharCommon_06                                                = 10006 ; --- 不使用技能，必杀及支援技，支援绝招完成肉鸽塔
    CharCommon_07                                                = 10007 ; --- 指定角色在主控位完成X次战斗
    CharCommon_08                                                = 10008 ; --- 触发火系印记XX次
    CharCommon_09                                                = 10009 ; --- 触发水系印记XX次
    CharCommon_10                                                = 10010 ; --- 触发风系印记XX次
    CharCommon_11                                                = 10011 ; --- 触发暗系印记XX次
    CharCommon_12                                                = 10012 ; --- 触发光系印记XX次
    CharCommon_13                                                = 10013 ; --- 使用3名近战角色完成一次build
    CharCommon_14                                                = 10014 ; --- 使用3名远程角色完成一次build
    CharCommon_15                                                = 10015 ; --- 使用3名半C完成一次build
    CharCommon_16                                                = 10016 ; --- 使用3名辅助角色完成一次build
    CharCommon_17                                                = 10017 ; --- 使用3名C完成一次build
    CharCommon_18                                                = 10018 ; --- 第一次触发属性压制（红字伤害）
    CharCommon_19                                                = 10019 ; --- 连续触发X次暴击伤害
    CharCommon_20                                                = 10020 ; --- 无伤通过星塔
    CharCommon_21                                                = 10021 ; --- 通过星塔时剩余血量低于10%
    CharCommon_22                                                = 10022 ; --- 触发极限闪避XX次
    CharCommon_23                                                = 10023 ; --- 使用初始3名角色通关X难度的星塔
    CharCommon_24                                                = 10024 ; --- 使用3名火系角色完成build X次
    CharCommon_25                                                = 10025 ; --- 使用3名水系角色完成build X次
    CharCommon_26                                                = 10026 ; --- 使用3名光系角色完成build X次
    CharCommon_27                                                = 10027 ; --- 使用3名风系角色完成build X次
    CharCommon_28                                                = 10028 ; --- 使用3名暗系角色完成build X次
    CharCommon_29                                                = 10029 ; --- 指定难度，限定时间
    CharCommon_30                                                = 10030 ; --- 秒杀怪物累计XX次
    CharCommon_31                                                = 10031 ; --- 在build中获得指定角色所有潜能
    CharCommon_32                                                = 10032 ; --- 连续X次攻击不暴击
    Amber_01                                                     = 10301 ; --- 单技能击杀N只怪物
    Amber_02                                                     = 10302 ; --- X秒内连续重置技能冷却
    Amber_03                                                     = 10303 ; --- 普攻同时命中X个及以上目标
    Amber_04                                                     = 10304 ; --- 作为援护角色时眩晕目标X次
    Amber_05                                                     = 10305 ; --- 使用大招消灭任意首领
    Amber_06                                                     = 10306 ; --- 使用大招命中且未消灭小怪
    Amber_07                                                     = 10307 ; --- 连续普攻N次不换弹
    Kasimira_01                                                  = 10801 ; --- 连续进行10次强化普攻
    Kasimira_02                                                  = 10802 ; --- 一个支援技能连续命中同一敌人X次
    Kasimira_03                                                  = 10803 ; --- 连续装弹N次
    Kasimira_04                                                  = 10804 ; --- 连续N次不消耗弹药
    Kasimira_05                                                  = 10805 ; --- 10秒内连续轰炸20次（触发2次潜能29）
    Kasimira_06                                                  = 10806 ; --- 单次绝招对同一个目标命中N次
    Kasimira_07                                                  = 10807 ; --- 连续眩晕目标X秒
    CatsEye_01                                                   = 11401 ; --- 10秒内连续使用5次技能
    CatsEye_02                                                   = 11402 ; --- 单个支援技杀死3名敌人
    Ann_01                                                       = 12301 ; --- 单次风墙挡住X次子弹
    Ann_02                                                       = 12302 ; --- 丰臀和所有友方角色同时在场作战累计X秒
    Ann_03                                                       = 12303 ; --- 风墙被敌方子弹累计击破X次
    Ann_04                                                       = 12304 ; --- 通过风墙累计击飞X次目标
    Ann_05                                                       = 12305 ; --- 绝招累计摧毁X个飞行道具
    Ann_06                                                       = 12306 ; --- 驾驶火狼累计奔跑100米
    Ann_07                                                       = 12307 ; --- 风暴同时击飞3个及以上敌人，累计N次
    Sandy_01                                                     = 11201 ; --- 单次绝招累计触发N次风系印记
    Sandy_02                                                     = 11202 ; --- 35秒内连续释放两次绝招
    Sandy_03                                                     = 11203 ; --- 单次援护技造成10次及以上伤害
    Sandy_04                                                     = 11204 ; --- （风刃）累计击杀X个远处目标（>N米）
    Hanahara_01                                                  = 11901 ; --- 花瓣飞镖（X秒内）全部命中目标
    Hanahara_02                                                  = 11902 ; --- 单次绝招期间，花原所有分身累计造成X次伤害
    Hanahara_03                                                  = 11903 ; --- 单次技能期间，向日葵飞镖累计飞行X米
    Hanahara_04                                                  = 11904 ; --- 单次技能期间，连续两次投掷向日葵飞镖的距离大于X米
    Hanahara_05                                                  = 11905 ; --- 单次技能期间，花瓣飞镖累计造成X次伤害
    Iris_01                                                      = 11101 ; --- 第一次触发摔跤
    Iris_02                                                      = 11102 ; --- 书包累计抡死X名敌人
    Iris_03                                                      = 11103 ; --- 5秒内对同一个目标造成N次伤害
    Iris_04                                                      = 11104 ; --- 3秒内冻住5个敌人
    Iris_05                                                      = 11105 ; --- 支援技范围内始终有3个及以上敌人
    Iris_06                                                      = 11106 ; --- 暴风雪内存在友方角色累计100秒
    Iris_07                                                      = 11107 ; --- 主控技急冻箭头一次命中N个敌人
    Freesia_01                                                   = 12501 ; --- 持续狂化30秒
    Freesia_02                                                   = 12502 ; --- 单次狂化状态下消灭20个敌人
    Freesia_03                                                   = 12503 ; --- 累计触发碎冰N次
    Freesia_04                                                   = 12504 ; --- 2秒内对同一个目标造成N次伤害
    Freesia_05                                                   = 12505 ; --- 支援角色驻场时间累计10分钟
    Freesia_06                                                   = 12506 ; --- 旋风斩期间累计移动X米
    Freesia_07                                                   = 12507 ; --- 单次旋风斩期间造成X次伤害
    Freesia_08                                                   = 12508 ; --- 累计生成X朵冰花
    Donut_01                                                     = 13001 ; --- 累计消灭离自己距离超过X米的敌人Y个
    Donut_02                                                     = 13002 ; --- 累计触发碎冰N次
    Donut_03                                                     = 13003 ; --- 宠物消灭敌人XX个
    Donut_04                                                     = 13004 ; --- 一次射击命中N个不同的目标
    Donut_05                                                     = 13005 ; --- 战斗中连续60秒没有进行移动（战斗开始计时，战斗结束）
    Donut_06                                                     = 13006 ; --- 绝招箭雨持续超过1X秒
    Teresa_01                                                    = 12701 ; --- 涟漪或波浪累计杀死敌人X个
    Teresa_02                                                    = 12702 ; --- 任意友方角色连续在水域中超过X秒（测极限
    Teresa_03                                                    = 12703 ; --- 特丽莎2秒内连续获得5次护盾
    Teresa_04                                                    = 12704 ; --- 特丽莎生成的护盾连续存在30秒
    Teresa_05                                                    = 12705 ; --- 特丽莎生成的护盾在1秒内破损
    Teresa_06                                                    = 12706 ; --- 咖喱棒同时经过5个及以上的敌人和2个友方角色
    LinJing_01                                                   = 11701 ; --- 一次雷圈对X名敌人产生影响
    LinJing_02                                                   = 11702 ; --- 使用麒麟杀死BOSS
    LinJing_03                                                   = 11703 ; --- 主控技能雷击对同一个目标连续暴击X次
    LinJing_04                                                   = 11704 ; --- 璟麟的单次释放主控技能消灭X个及以上目标(极限测试
    LinJing_05                                                   = 11705 ; --- 璟麟5秒内连续眩晕同一个目标3次
    LinJing_06                                                   = 11706 ; --- 场上璟麟支援技召唤的雷圈数量大于等于3个
    LinJing_07                                                   = 11707 ; --- 璟麟在2秒内消灭任意2个相互距离30米及以上的敌人
    Tilia_01                                                     = 10701 ; --- 在单次技能期间承受XX点伤害
    Tilia_02                                                     = 10702 ; --- 飞盾累计眩晕不同的目标X个
    Tilia_03                                                     = 10703 ; --- 利用疾跑消灭X个敌人
    Tilia_04                                                     = 10704 ; --- 利用主控技能免疫伤害累计X次
    Tilia_05                                                     = 10705 ; --- 飞盾累计弹射1000次
    Tilia_06                                                     = 10706 ; --- 缇莉娅为主控施加的护盾，未被打破累计Y次
    Minerva_01                                                   = 13201 ; --- 单次技能使敌人持续击飞5秒
    Minerva_02                                                   = 13202 ; --- 单次使用大招只杀死一名非BOSS敌人
    Minerva_03                                                   = 13203 ; --- 普攻最后一段消灭敌人累计X个
    Minerva_04                                                   = 13204 ; --- 支援技累计给X个敌人挂满4层星星
    Minerva_05                                                   = 13205 ; --- 支援技（在挥洒星星时）直接消灭5个及以上敌人，累计X次
    Minerva_06                                                   = 13206 ; --- 绝招大乱斗时自己或者主控角色也加入到混战中，累计参战100秒
    Firefly_01                                                   = 11501 ; --- 使用火垂大招击杀高达BOSS（改投放）
    Firefly_02                                                   = 11502 ; --- 10秒内对单个敌人造成100HIT
    Firefly_03                                                   = 11503 ; --- 处于主控时强化普攻期间不使用闪避（1轮）
    Firefly_04                                                   = 11504 ; --- 一次技能变形期间触发了N次印记
    Firefly_05                                                   = 11505 ; --- 闪避期间累计消灭N个敌人（火垂本体）
    Firefly_06                                                   = 11506 ; --- 火垂累计发射了1000发浮游刃
    Firefly_07                                                   = 11507 ; --- 绝招单次射击命中N个敌人，累计N次
    Firenze_01                                                   = 11001 ; --- 使用主控技暗影三连斩累计穿过N个敌人
    Firenze_02                                                   = 11002 ; --- 主控情况下，累计发动联动攻击N次「普攻5+技能+潜能」
    Firenze_03                                                   = 11003 ; --- 翡冷翠累计召唤N个暗影分身「主控+支援」
    Firenze_04                                                   = 11004 ; --- 暗影分身通过暴击累计击杀N个的敌人「主控+支援」
    Firenze_05                                                   = 11005 ; --- 单次绝招寂灭收割法阵生成时内部有超过10个敌人（生成的瞬间判断）
    Firenze_06                                                   = 11006 ; --- 单次绝招寂灭收割累计造成50Hit，累计触发N次
    Mistique_01                                                  = 13501 ; --- 雾雨的自爆幽灵累计被击杀X次
    Mistique_02                                                  = 13502 ; --- 大头幽灵击杀眩晕的敌人X次
    Mistique_03                                                  = 13503 ; --- 主控角色累计在幽灵之门中战斗X秒
    Mistique_04                                                  = 13504 ; --- （单个）自爆幽灵一次爆炸击杀6个敌人
    Mistique_05                                                  = 13505 ; --- 绝招午夜幽灵所有攻击全部都命中敌人，累计X次
    Mistique_06                                                  = 13506 ; --- 支援技幽灵之门累计生成X个自爆幽灵
    Coronis_01                                                   = 11801 ; --- 暗影交错单次攻击命中9个以上敌人，累计X次
    Coronis_02                                                   = 11802 ; --- 单轮暗影交错技能触发20次以上暗印记
    Coronis_03                                                   = 11803 ; --- 骨牢禁锢成功击破X个敌人的韧性
    Coronis_04                                                   = 11804 ; --- 骨牢禁锢成功拉扯敌人累计X次
    Coronis_05                                                   = 11805 ; --- 通过「暗影飞镰」累计击杀敌人X次
    Coronis_06                                                   = 11806 ; --- 绝招「寂灭收割」最终横斩累计击杀X名敌人
    Hibiscus_01                                                  = 12601 ; --- 火蝴蝶连续存在20秒
    Hibiscus_02                                                  = 12602 ; --- 一次惊吓魔盒同时恐惧X个小怪
    Hibiscus_03                                                  = 12603 ; --- 返回的魔术帽命中X个目标，累计X次
    Hibiscus_04                                                  = 12604 ; --- 累计生成X顶魔术帽
    Hibiscus_05                                                  = 12605 ; --- 1秒内连续分裂出6只火蝶（包括潜能22分裂和死亡分裂）
    Hibiscus_06                                                  = 12606 ; --- 凤凰蛋累计眩晕X个敌人
    Hibiscus_07                                                  = 12607 ; --- 同时存在5只灰蝶时，主控角色连续N次伤害不暴击
    ShiMiao_01                                                   = 11301 ; --- N秒内旋转X圈（技能第1段）；执行Y次
    ShiMiao_02                                                   = 11302 ; --- N秒内施放技能第2段9次
    ShiMiao_03                                                   = 11303 ; --- 伤害提升Buff叠满50层（潜能25）；执行Y次
    ShiMiao_04                                                   = 11304 ; --- 累计发射最大号水剑500次
    ShiMiao_05                                                   = 11305 ; --- 单次存续期间触发X次寒冷效果；执行Y次
    ShiMiao_06                                                   = 11306 ; --- 单次绝招横扫期间，共命中X个目标；执行Y次
    ShiMiao_07                                                   = 11307 ; --- 用绝招累计击杀500个「冰冻」状态目标
    Cosette_01                                                   = 14201 ; --- 累计10秒内对敌人施加30次暗系印记
}

GameEnum.areaEffectOverLimitType =
{
    Replace                                                      =   1 ; --- 替换
    NotGenerate                                                  =   2 ; --- 不生成
}

GameEnum.CharVoiceType =
{
    GachaFirstGet                                                =   1 ; --- 抽卡首次获得
    GachaGetAgain                                                =   2 ; --- 抽卡重复获得
    MainUITouch                                                  =   3 ; --- 主界面L2D交互
    MainUICGTouch                                                =   4 ; --- 主界面CGL2D交互
}

GameEnum.currencyType =
{
    Cash                                                         =   1 ; --- 现金
    Item                                                         =   2 ; --- 道具
    Free                                                         =   3 ; --- 免费
}

GameEnum.mallPackageRefreshType =
{
    None                                                         =   0 ; --- 不刷新
    Day                                                          =   1 ; --- 日
    Week                                                         =   2 ; --- 周
    Month                                                        =   3 ; --- 月
}

GameEnum.TitleType =
{
    Prefix                                                       =   1 ; --- 前缀
    Suffix                                                       =   2 ; --- 后缀
}

GameEnum.VoResType =
{
    MainCharacter                                                =   1 ; --- 主控角色
    SupportCharacter                                             =   2 ; --- 助战角色
    RandomCharacter                                              =   3 ; --- 队内随机角色
    SpecificCharacter                                            =   4 ; --- 特定角色
}

GameEnum.AttackHintType =
{
    Null                                                         =   0 ; --- 无
    Always                                                       =   1 ; --- 常驻型
    SkillOn                                                      =   2 ; --- 技能激活型
}

GameEnum.AssistOnStageType =
{
    Attack                                                       =   1 ; --- 进攻登场
    Defend                                                       =   2 ; --- 防御登场
}

GameEnum.AssistOnStageOrientation =
{
    None                                                         =   0 ; --- 无
    Same                                                         =   1 ; --- 主控同向
    LookAt                                                       =   2 ; --- 朝向主控
    BackOn                                                       =   3 ; --- 背对主控
}

GameEnum.errorShowType =
{
    Window                                                       =   1 ; --- 默认弹窗
    Tips                                                         =   2 ; --- 飘字
    Relogin                                                      =   3 ; --- 返回登录
}

GameEnum.activityType =
{
    None                                                         =   0 ; --- 无
    PeriodicQuest                                                =   1 ; --- 周期任务组
    LoginReward                                                  =   2 ; --- 登录奖励
    Mining                                                       =   3 ; --- 挖格子
    Cookie                                                       =   4 ; --- 曲奇工坊
    TowerDefense                                                 =   5 ; --- 塔防
    Trial                                                        =   6 ; --- 试玩
    JointDrill                                                   =   7 ; --- 总力战
    CG                                                           =   8 ; --- CG
    Levels                                                       =   9 ; --- 关卡
    Avg                                                          =  10 ; --- Avg
    Task                                                         =  11 ; --- 活动任务
    Shop                                                         =  12 ; --- 商店
    Advertise                                                    =  13 ; --- 广告页
}

GameEnum.activityOpenType =
{
    None                                                         =   0 ; --- 无
    Original                                                     =   1 ; --- 初始开放
    Date                                                         =   2 ; --- 日期开放
    Trigger                                                      =   3 ; --- 触发条件开放
}

GameEnum.activityEndType =
{
    None                                                         =   0 ; --- 无
    NoLimit                                                      =   1 ; --- 不结束
    Date                                                         =   2 ; --- 指定日期关闭
    TimeLimit                                                    =   3 ; --- 开启一段时间后关闭
}

GameEnum.activityPreLimit =
{
    None                                                         =   0 ; --- 无
    WorldClass                                                   =   1 ; --- 世界等级
    questLimit                                                   =   2 ; --- 主线进度
}

GameEnum.specialAttributeType =
{
    NONE                                                         =   0 ; --- 无
    HP                                                           =   1 ; --- 当前生命值
    TOUGHNESS_V                                                  =   2 ; --- 当前韧性值
    SHIELD_V                                                     =   3 ; --- 当前护盾值
    ENERGY                                                       =   4 ; --- 大招能量
    MAX                                                          =   5 ; --- 最大效果数量
}

GameEnum.addressBookType =
{
    None                                                         =   0 ; --- 无
    Character                                                    =   1 ; --- 抽卡角色
    NPC                                                          =   2 ; --- npc
    GroupChat                                                    =   3 ; --- 群聊
    OfficialAccount                                              =   4 ; --- 公众号
}

GameEnum.chatTriggerType =
{
    None                                                         =   0 ; --- 无
    Immediately                                                  =   1 ; --- 立刻触发
    Time                                                         =   2 ; --- 计时放出
}

GameEnum.chatTriggerCond =
{
    None                                                         =   0 ; --- 无
    CharacterAcquire                                             =   1 ; --- 首次获得某角色
    ClearSpecifiedMainlineLevel                                  =   2 ; --- 首次通关剧情关卡
    CharacterFavorabilityLevel                                   =   3 ; --- 特定角色好感度达到特定等级
    CharacterLevel                                               =   4 ; --- 特定角色等级达到特定等级
    CharacterStarLevel                                           =   5 ; --- 特等角色等级达到特定突破等级
    WorldClass                                                   =   6 ; --- 世界等级达到X级
    OutfitAcquire                                                =   7 ; --- 首次获得到特定星盘
    LevelStar                                                    =   8 ; --- 特定关卡达到3星
    Date                                                         =   9 ; --- 特定日期
}

GameEnum.battlePassQuestType =
{
    DAY                                                          =   1 ; --- 日
    WEEK                                                         =   2 ; --- 周
}

GameEnum.ArchType =
{
    None                                                         =   0 ; --- 无
    BaseType                                                     =   1 ; --- 基础
    NormalType                                                   =   2 ; --- 常规
    SpecialType                                                  =   3 ; --- 特殊
}

GameEnum.ArchVoiceType =
{
    None                                                         =   0 ; --- 无
    DailyVoice                                                   =   1 ; --- 日常
    BattlceVoice                                                 =   2 ; --- 战斗
}

GameEnum.AmmoType =
{
    Main                                                         =   0 ; --- 主弹夹
    Special1                                                     =   1 ; --- 附加弹夹1
    Special2                                                     =   2 ; --- 附加弹夹2
    Max                                                          =   3 ; --- 最大数量
}

GameEnum.ammoParameterType =
{
    MAX_BASE_VALUE                                               =   1 ; --- 最大容量基础修正
    MAX_PERCENTAGE                                               =   2 ; --- 最大容量百分比修正
    MAX_ABSOLUTE_VALUE                                           =   3 ; --- 最大容量绝对值修正
    SET_MAX_PERCENTAGE_VALUE                                     =   4 ; --- 最大容量百分比设置
    SET_MAX_ABSOLUTE_VALUE                                       =   5 ; --- 最大容量绝对值设置
    PERCENTAGE                                                   =   6 ; --- 当前容量百分比修正
    ABSOLUTE_VALUE                                               =   7 ; --- 当前容量绝对值修正
    SET_PERCENTAGE_VALUE                                         =   8 ; --- 当前容量百分比设置
    SET_ABSOLUTE_VALUE                                           =   9 ; --- 当前容量绝对值设置
}

GameEnum.talentType =
{
    KeyNode                                                      =   1 ; --- 关键节点
    OrdinaryNode                                                 =   2 ; --- 普通节点
}

GameEnum.talentSubType =
{
    Fate1                                                        =   1 ; --- 跃升天赋一
    Fate2                                                        =   2 ; --- 跃升天赋二
    Fate3                                                        =   3 ; --- 跃升天赋三
    Fate4                                                        =   4 ; --- 跃升天赋四
    Fate5                                                        =   5 ; --- 跃升天赋五
}

GameEnum.levelTypeData =
{
    None                                                         =   0 ; --- 无
    Exclusive                                                    =   1 ; --- 潜能等级
    Actor                                                        =   2 ; --- 角色等级
    SkillSlot                                                    =   3 ; --- 技能槽位
    BreakCount                                                   =   4 ; --- 突破次数
    Note                                                         =   5 ; --- 属性音符等级
    DiscSkill                                                    =   6 ; --- 星盘技能等级
    BuildLevel                                                   =   7 ; --- 构筑等级
}

GameEnum.blockPriorityType =
{
    None                                                         =   0 ; --- 无
    Priority1                                                    =   1 ; --- 一档
    Priority2                                                    =   2 ; --- 二档
    Priority3                                                    =   3 ; --- 三档
    Priority4                                                    =   4 ; --- 四档
}

GameEnum.equipmentType =
{
    Square                                                       =   1 ; --- 盾形
    Circle                                                       =   2 ; --- 菱形
    Pentagon                                                     =   3 ; --- 方形
}

GameEnum.equipmentAttrGroupType =
{
    Normal                                                       =   1 ; --- 基础
    Guaranteed                                                   =   2 ; --- 保底
}

GameEnum.characterTagType =
{
    PowerStyle                                                   =   1 ; --- 力量风格
    TacticalStyle                                                =   2 ; --- 战术风格
    AffiliatedForces                                             =   3 ; --- 所属势力
}

GameEnum.noteGetComplete =
{
    PassRoomType                                                 =   1 ; --- 累计通关特定类型房间
}

GameEnum.starTowerStage =
{
    FirstStage                                                   =   1 ; --- 第一阶段
    SecondStage                                                  =   2 ; --- 第二阶段
    ThirdStage                                                   =   3 ; --- 第三阶段
}

GameEnum.dropItemType =
{
    Coin                                                         =   1 ; --- 星塔币
    Exp                                                          =   2 ; --- 经验
    FateCard                                                     =   3 ; --- 命运卡
    Note                                                         =   4 ; --- 音符
}

GameEnum.dropEntityType =
{
    VampireExp                                                   =   1 ; --- 吸血鬼经验
    VampireBox                                                   =   2 ; --- 吸血鬼宝箱
    VampireClear                                                 =   3 ; --- 吸血鬼清屏
    VampireGet                                                   =   4 ; --- 吸血鬼拾取
    HP                                                           =   5 ; --- 回血
    MP                                                           =   6 ; --- 回能
    ATK                                                          =   7 ; --- 攻击力
}

GameEnum.BrickDropType =
{
    BrickFire                                                    =   1 ; --- 火焰道具
    BrickEnergy                                                  =   2 ; --- 充能道具
    BrickExpCoin                                                 =   3 ; --- 积分金币
    BrickHp                                                      =   4 ; --- 回血道具
    BrickPaddle                                                  =   5 ; --- 弹射版
    BrickBoom                                                    =   6 ; --- 炸弹
}

GameEnum.starTowerRoomType =
{
    BattleRoom                                                   =   0 ; --- 普通战斗
    EliteBattleRoom                                              =   1 ; --- 精英战斗
    BossRoom                                                     =   2 ; --- 普通Boss
    FinalBossRoom                                                =   3 ; --- 最终Boss
    DangerRoom                                                   =   4 ; --- 危险房间
    HorrorRoom                                                   =   5 ; --- 高危房间
    ShopRoom                                                     =   6 ; --- 商店房
    EventRoom                                                    =   7 ; --- 事件房
    UnifyBattleRoom                                              =  15 ; --- 战斗房间
}

GameEnum.starTowerBattleType =
{
    Battle                                                       =   1 ; --- 战斗房间
    Danger                                                       =   2 ; --- 危险房间
    Horror                                                       =   3 ; --- 高危房间
}

GameEnum.fateCardServerEffect =
{
    RecoveryHP                                                   =   5 ; --- 回血
    ChangeResourceOutput                                         =   6 ; --- 资源产出百分比修正
    ChangePotentialOutput                                        =   7 ; --- 潜能产出权重修正
}

GameEnum.fateCardMethodMode =
{
    ClientFateCard                                               =   1 ; --- 客户端
    ServerFateCard                                               =   2 ; --- 服务器
    LuaFateCard                                                  =   3 ; --- 放出物脚本
    FloorBuffFateCard                                            =   4 ; --- 房间buff
}

GameEnum.fateCardTheme =
{
    NoType                                                       =   0 ; --- 非特定
    FireRing                                                     =   1 ; --- 环火
    FireWave                                                     =   2 ; --- 裂火
    Meteor                                                       =   3 ; --- 陨火
    LightningBall                                                =   4 ; --- 光击阵
    ChainLightning                                               =   5 ; --- 闪电链
    FireBall                                                     =   6 ; --- 火球
    LightningBolt                                                =   7 ; --- 闪电
    WindBlade                                                    =   8 ; --- 风刃
    Blizzard                                                     =   9 ; --- 冰雹
    WhirlWind                                                    =  10 ; --- 旋风
    WindEagle                                                    =  11 ; --- 镰鼬
    WindArea                                                     =  12 ; --- 风领域
    LightingGhost                                                =  13 ; --- 电鬼
    Shark                                                        =  14 ; --- 鲨鱼
    CloudBottle                                                  =  15 ; --- 云朵瓶
    FreezeArea                                                   =  16 ; --- 水领域
    EarthSpike                                                   =  17 ; --- 岩突
    EarthSpear                                                   =  18 ; --- 岩矛
    EarthQuake                                                   =  19 ; --- 地震
    EarthFissure                                                 =  20 ; --- 地裂
    NightPierce                                                  =  21 ; --- 暗刺
    ShadowSphere                                                 =  22 ; --- 暗球
    DarkBurst                                                    =  23 ; --- 暗爆
    VoidVortex                                                   =  24 ; --- 黑洞
}

GameEnum.fateCardThemeRank =
{
    Base                                                         =   1 ; --- 基础
    ProA                                                         =   2 ; --- 强化类型A
    ProB                                                         =   3 ; --- 强化类型B
    Super                                                        =   4 ; --- 超级强化
}

GameEnum.fateCardThemeTriggerType =
{
    NormalAttack                                                 =   1 ; --- 普攻
    Dodge                                                        =   2 ; --- 闪避
    CastSkill                                                    =   3 ; --- 技能
    AssistSkill                                                  =   4 ; --- 支援技能
    ExSkill                                                      =   5 ; --- 大招
    Behit                                                        =   6 ; --- 受击
}

GameEnum.rglTheme =
{
    NoType                                                       =   0 ; --- 非特定
    FireRing                                                     =   1 ; --- 环火
    FireWave                                                     =   2 ; --- 裂火
    Meteor                                                       =   3 ; --- 陨火
    LightningBall                                                =   4 ; --- 光球
    ChainLightning                                               =   5 ; --- 光链
    FireBall                                                     =   6 ; --- 火球
    LightningBolt                                                =   7 ; --- 闪电
    WindBlade                                                    =   8 ; --- 风刃
    Blizzard                                                     =   9 ; --- 冰雹
    WhirlWind                                                    =  10 ; --- 旋风
    WindEagle                                                    =  11 ; --- 风鹰
    WindArea                                                     =  12 ; --- 风领域
    LightingGhost                                                =  13 ; --- 电鬼
    Shark                                                        =  14 ; --- 鲨鱼
    CloudBottle                                                  =  15 ; --- 云朵瓶
    FreezeArea                                                   =  16 ; --- 水领域
}

GameEnum.perkType =
{
    Theme                                                        =   1 ; --- 主题信条
    Exclusive                                                    =   2 ; --- 专属信条
    Recover                                                      =   3 ; --- 回复信条
    Strengthen                                                   =   4 ; --- 强化信条
    SpecificExclusive                                            =   5 ; --- 特殊专属信条
}

GameEnum.charperkType =
{
    Branch                                                       =   1 ; --- 分支
    Basics                                                       =   2 ; --- 基础
}

GameEnum.perkSlot =
{
    Null                                                         =   0 ; --- 无
    NormalAttack                                                 =   1 ; --- 普通攻击
    Dodge                                                        =   2 ; --- 闪避
    CastSkill                                                    =   3 ; --- 释放技能
    Behit                                                        =   4 ; --- 受击
}

GameEnum.MainOrSupport =
{
    NONE                                                         =   0 ; --- 无
    MAINCONTROL                                                  =   1 ; --- 主控
    SUPPORT                                                      =   2 ; --- 支援
}

GameEnum.potentialDropType =
{
    PotentialOf1                                                 =   1 ; --- 1号位潜能
    PotentialOf2                                                 =   2 ; --- 2号位潜能
    PotentialOf3                                                 =   3 ; --- 3号位潜能
}

GameEnum.charPotentialType =
{
    Special                                                      =   1 ; --- 特殊潜能
    Basics                                                       =   2 ; --- 基础潜能
}

GameEnum.starTowerEventType =
{
    Treasure                                                     =   1 ; --- 无主的财富
    Strengthen                                                   =   2 ; --- 强化房
    Exchange                                                     =   3 ; --- 资源轮换房
    Basics                                                       =   4 ; --- 基础事件
}

GameEnum.starTowerOptionsEffect =
{
    GetStarCoin                                                  =   1 ; --- 获取星币
    GetPotential                                                 =   3 ; --- 获取潜能
    GetFateCard                                                  =   4 ; --- 获取命运卡
    ExpendStarCoin                                               =   5 ; --- 消耗星币
    LossStarCoin                                                 =   6 ; --- 损失星币
    ExpendPotential                                              =   9 ; --- 消耗潜能
    LossPotential                                                =  10 ; --- 损失潜能
    LossFateCard                                                 =  11 ; --- 损失命运卡
    ActivateFateCard                                             =  12 ; --- 激活命运卡
    StrengthenPotential                                          =  13 ; --- 强化潜能
    RecoveryHP                                                   =  14 ; --- 恢复生命
    RecycleFateCard                                              =  15 ; --- 回收命运卡
    NoIssue                                                      =  16 ; --- 无效果
    GetRandomSubNodeSkill                                        =  17 ; --- 获得随机音符属性技能
    GetSpecificSubNodeSkill                                      =  18 ; --- 获得指定音符属性技能
    LossRandomSubNodeSkill                                       =  19 ; --- 移除随机音符属性技能
}

GameEnum.force =
{
    Force1                                                       =   1 ; --- 空白旅团
    Force2                                                       =   2 ; --- 自由旅人
    Force4                                                       =   4 ; --- 帝国卫队
    Force5                                                       =   5 ; --- 白猫剧团
    Force6                                                       =   6 ; --- 灰风俱乐部
    Force7                                                       =   7 ; --- 万送屋
    Force8                                                       =   8 ; --- 谷风家政
    Force9                                                       =   9 ; --- 绯瞳传讯
    Force10                                                      =  10 ; --- 恩赐意志
    Force11                                                      =  11 ; --- 联合种业
    Force12                                                      =  12 ; --- 花令旅团
    Force13                                                      =  13 ; --- 地理协会
    Force14                                                      =  14 ; --- 凤凰炒蛋
    Force15                                                      =  15 ; --- 白泽公署
    Force16                                                      =  16 ; --- 云笈文化
    Force17                                                      =  17 ; --- 柔光会社
}

GameEnum.bubbleDirection =
{
    Left                                                         =   1 ; --- 左
    Right                                                        =   2 ; --- 右
}

GameEnum.attributeType =
{
    BaseAttrType                                                 =   1 ; --- 基础属性类型
    PlayerAttrType                                               =   2 ; --- 玩家属性类型
}

GameEnum.attributeSizeType =
{
    High                                                         =   1 ; --- 高
    Mid                                                          =   2 ; --- 中
    Low                                                          =   3 ; --- 低
    None                                                         =   4 ; --- 无
}

GameEnum.potentialCornerType =
{
    Diamond                                                      =   1 ; --- 菱形
    Triangle                                                     =   2 ; --- 三角
    Round                                                        =   3 ; --- 方块
}

GameEnum.BranchType =
{
    Master                                                       =   1 ; --- 主控等级
    Assist                                                       =   2 ; --- 援护等级
    Common                                                       =   3 ; --- 潜能等级
}

GameEnum.giftTag =
{
    Lighter                                                      =   1 ; --- 火机
    Camera                                                       =   2 ; --- 相机
    Skincare                                                     =   3 ; --- 美容
    Cooldown                                                     =   4 ; --- 降温
    Idol                                                         =   5 ; --- 偶像
    Lamp                                                         =   6 ; --- 台灯
    Dessert                                                      =   7 ; --- 甜品
    Teacup                                                       =   8 ; --- 茶具
    Festival                                                     =   9 ; --- 节日
}

GameEnum.bulletType =
{
    Null                                                         =   0 ; --- 无
    Pistol                                                       =   1 ; --- 手枪子弹
    Rifle                                                        =   2 ; --- 步枪子弹
    Shotgun                                                      =   3 ; --- 霰弹枪子弹
    FireShotgun                                                  =   4 ; --- 火系霰弹枪子弹
    EnergyGun                                                    =   5 ; --- 能量子弹
}

GameEnum.ValueFormat =
{
    Int                                                          =   1 ; --- 整数
    ODP                                                          =   2 ; --- 一位小数
    TDP                                                          =   3 ; --- 两位小数
}

GameEnum.InfinityTowerMsgType =
{
    Daily                                                        =   1 ; --- 每日
    Breakout                                                     =   2 ; --- 突发
    News                                                         =   3 ; --- 快讯
}

GameEnum.InfinityTowerMsgConditions =
{
    SpecialLv                                                    =   1 ; --- 通过特定无尽塔关卡
}

GameEnum.AgentType =
{
    Emergency                                                    =   1 ; --- 紧急委托
    Construction                                                 =   2 ; --- 社区帮手
    Security                                                     =   3 ; --- 生态调查
    Monster                                                      =   4 ; --- 魔物清剿
    Excavate                                                     =   5 ; --- 矿产勘探
}

GameEnum.AgentRefreshType =
{
    Normal                                                       =   1 ; --- 常驻
    Daily                                                        =   2 ; --- 每日
    NonRefresh                                                   =   3 ; --- 不刷新
}

GameEnum.AgentMemberType =
{
    CharType                                                     =   1 ; --- 旅人
    BuildType                                                    =   2 ; --- 构筑
}

GameEnum.OpenFuncType =
{
    Char                                                         =   1 ; --- 角色
    Gacha                                                        =   2 ; --- 招募
    Mail                                                         =   3 ; --- 邮件
    StarTower                                                    =   4 ; --- 星塔探索
    DailyInstance                                                =   5 ; --- 悬赏行动
    RegionBoss                                                   =   6 ; --- 强敌讨伐
    TravelerDuel                                                 =   7 ; --- 巅峰揭幕
    SignIn                                                       =   8 ; --- 签到
    InfinityTower                                                =   9 ; --- 心危擂台
    SkillInstance                                                =  10 ; --- 卡带回收
    StarTowerRank                                                =  11 ; --- 星塔排行榜
    Agent                                                        =  12 ; --- 委托派遣
    RegionBossChallenge                                          =  13 ; --- 强敌讨伐挑战模式
    TravelerDuelChallenge                                        =  14 ; --- 巅峰揭幕挑战模式
    VampireSurvivor                                              =  15 ; --- 灾变防线
    Quest                                                        =  16 ; --- 任务
    Phone                                                        =  17 ; --- 手机
    Activity                                                     =  18 ; --- 活动
    Crafting                                                     =  19 ; --- 材料合成
    ScoreBoss                                                    =  20 ; --- 积分boss
    WeeklyCopies                                                 =  21 ; --- 周本
    DailyQuest                                                   =  22 ; --- 每日任务
    DailyReward                                                  =  23 ; --- 每日赠礼
    CharGemInstance                                              =  24 ; --- 角色宝石副本
    CharDating                                                   =  25 ; --- 角色邀约
    JointDrill                                                   =  26 ; --- 总力战
    TutorialLevel                                                =  27 ; --- 教学关
    BattlePass                                                   =  28 ; --- 战令
}

GameEnum.DestructibleObjectType =
{
    Common                                                       =   1 ; --- 通用
    WaterAndDarkTower                                            =   2 ; --- 水暗星塔
    FireAndEarthTower                                            =   3 ; --- 火地星塔
    WindAndLightTower                                            =   4 ; --- 风光星塔
    NoneTower                                                    =   5 ; --- 无属性星塔
}

GameEnum.DatingEventType =
{
    Start                                                        =   1 ; --- 人物开始约会事件
    End                                                          =   2 ; --- 人物结束约会事件
    Landmark                                                     =   3 ; --- 地点事件
    Regular                                                      =   4 ; --- 人物常规事件
    LimitedLandmark                                              =   5 ; --- 限定地点的角色事件
    BranchA                                                      =   6 ; --- 分支A
    BranchB                                                      =   7 ; --- 分支B
    BeforeBranch                                                 =   8 ; --- 分支前地点事件
    AfterBranch                                                  =   9 ; --- 分支后地点事件
}

GameEnum.InfinityTowerLevelType =
{
    Normal                                                       =   1 ; --- 普通
    Boss                                                         =   2 ; --- 首领
    Challenge                                                    =   3 ; --- 挑战
}

GameEnum.InfinityTowerCond =
{
    LevelClearWithSpecificId                                     =   1 ; --- 通关无尽塔关卡X
    InfinityTowerWithSpecificLevelTotal                          =   2 ; --- 累计通关总层数达到X
    AnyTowerWithSpecificTotalLevel                               =   3 ; --- 任意X座擂台通关总层数达到Y
    BountyLevelSpecific                                          =   4 ; --- 擂台等级达到X
    MasterCharactersWithSpecificElementType                      =   5 ; --- 主控角色属性为X
    ElementTypeWithSpecificQuantityNoLessThanQuantity            =   6 ; --- 角色属性为X的数量不小于Y
    ElementTypeWithSpecificQuantityNoMoreThanQuantity            =   7 ; --- 角色属性为X的数量不大于Y
}

GameEnum.HonorTitleBgType =
{
    Ellipse                                                      =   1 ; --- 椭圆背板
    Parallelogram                                                =   2 ; --- 四边形背板
}

GameEnum.honorTabType =
{
    Achieve                                                      =   1 ; --- 成就
    Character                                                    =   2 ; --- 默契
    Activity                                                     =   3 ; --- 活动
}

GameEnum.TowerQuestType =
{
    Core                                                         =   1 ; --- 核心任务
    Normal                                                       =   2 ; --- 普通任务
}

GameEnum.poolType =
{
    Elite                                                        =   1 ; --- 精英
    Boss                                                         =   2 ; --- 首领
}

GameEnum.starTowerNodeColor =
{
    Blue                                                         =   1 ; --- 蓝
    Yellow                                                       =   2 ; --- 黄
    Orange                                                       =   3 ; --- 橙
    Red                                                          =   4 ; --- 红
    Green                                                        =   5 ; --- 绿
}

GameEnum.vampireSurvivorType =
{
    Normal                                                       =   1 ; --- 普通
    Hard                                                         =   2 ; --- 困难
    Turn                                                         =   3 ; --- 轮换
}

GameEnum.vampireSurvivorMode =
{
    Single                                                       =   1 ; --- 单关
    Double                                                       =   2 ; --- 双关
}

GameEnum.miningGridType =
{
    Destroyed                                                    =   0 ; --- 已摧毁
    Fragile                                                      =   1 ; --- 脆弱
    Normal                                                       =   2 ; --- 普通
    Hard                                                         =   3 ; --- 坚硬
    SuperHard                                                    =   4 ; --- 超坚硬
    Max                                                          =   5 ; --- 格子类型最大值
}

GameEnum.miningRewardType =
{
    RewardTypeA                                                  =   1 ; --- 宝藏类型A
    RewardTypeB                                                  =   2 ; --- 宝藏类型B
    RewardTypeC                                                  =   3 ; --- 宝藏类型C
    RewardTypeD                                                  =   4 ; --- 宝藏类型D
}

GameEnum.miningRewardDir =
{
    Up                                                           =   1 ; --- 上
    LeftUp                                                       =   2 ; --- 左上
    LeftDown                                                     =   3 ; --- 左下
    Down                                                         =   4 ; --- 下
    RightDown                                                    =   5 ; --- 右下
    RightUp                                                      =   6 ; --- 右上
}

GameEnum.BuffEffectType =
{
    OnceDoT                                                      =   1 ; --- 总体型持续伤害
    NormalDoT                                                    =   2 ; --- 单次型持续伤害
}

GameEnum.miningRewardRarity =
{
    miningSSR                                                    =   1 ; --- 传奇道具
    miningSR                                                     =   2 ; --- 稀有道具
}

GameEnum.miningQuestCond =
{
    test                                                         =   1 ; --- 占位
}

GameEnum.miningSupportEffect =
{
    Dig                                                          =   1 ; --- 普通挖掘
    NeighborDestroyed                                            =   2 ; --- 相邻格子被破坏
    AreaDamageOnDig                                              =   3 ; --- 敲击时对随机相邻格子造成范围伤害
    ConsumePreserver                                             =   4 ; --- 概率不消耗道具
    ConverterOnEnterLayer                                        =   5 ; --- 进入当前层时转换格子
    ConverterOnReceiveTreasure                                   =   6 ; --- 找到宝藏时转换格子
    ConverterOnGridDestroyed                                     =   7 ; --- 开启空格子时转换格子
    CriticalDamage                                               =   8 ; --- 概率伤害翻倍
    TreasureMarkerOnGridDestroyed                                =   9 ; --- 开启空格子后标记宝藏格子
    Max                                                          =  10 ; --- 最大值标记
}

GameEnum.scoreBossBehavior =
{
    TriggerEarthTag                                              =   1 ; --- 触发地系印记
    TriggerFireTag                                               =   2 ; --- 触发火系印记
    TriggerWaterTag                                              =   3 ; --- 触发水系印记
    TriggerWindTag                                               =   4 ; --- 触发风系印记
    TriggerLightTag                                              =   5 ; --- 触发光系印记
    TriggerDarkTag                                               =   6 ; --- 触发暗系印记
    TriggerToughnessBreakdown                                    =   7 ; --- Boss进入破韧状态
    TriggerContinuousAttackFiveSeconds                           =   8 ; --- 连续对Boss攻击5秒
    TriggerSupportSkillHitBoss                                   =   9 ; --- 支援技命中Boss
    TriggerUltimateSkillHitBoss                                  =  10 ; --- 大招命中Boss
    TriggerFengCaoCyclonesMissPlayer                             =  11 ; --- 不被风草龙卷风命中
    TriggerFengCaoSummonLiveTenSeconds                           =  12 ; --- 风草召唤怪物存活时间不超过10秒
    TriggerChuShiKillKnife                                       =  13 ; --- 击破厨师的刀
    TriggerChuShiCallBackKnife                                   =  14 ; --- 厨师收回刀
    TriggerShaShaFissureMissPlayer                               =  15 ; --- 不被鲨鲨地面裂隙命中
    TriggerJinDuanLiRongCyclonesMissPlayer                       =  16 ; --- 不被禁断丽容龙卷风命中
    TriggerJinDuanLiRongCombsMissPlayer                          =  17 ; --- 不被禁断丽容梳子命中
}

GameEnum.scoreBossType =
{
    WildCard                                                     =   1 ; --- 通用
}

GameEnum.JointDrillBattleLvsToggle =
{
    HpLessThan                                                   =   1 ; --- 血量低于
}

GameEnum.JointDrillFloorType =
{
    Monster                                                      =   1 ; --- 小怪关卡
    Boss                                                         =   2 ; --- Boss关卡
}

GameEnum.mangaLoadingCondition =
{
    None                                                         =   1 ; --- 无条件
    Time                                                         =   2 ; --- 时间
}

GameEnum.potentialBuild =
{
    PotentialBuild1                                              =   1 ; --- 流派1
    PotentialBuild2                                              =   2 ; --- 流派2
    PotentialBuildCommon                                         =   3 ; --- 通用
}

GameEnum.bannerType =
{
    Activity                                                     =   1 ; --- 活动
    OpenFunc                                                     =   2 ; --- 功能
    Gacha                                                        =   3 ; --- 抽卡
    Community                                                    =   4 ; --- 社区
    Mall                                                         =   5 ; --- 商城
    MallSkin                                                     =   6 ; --- 商城皮肤
    Payment                                                      =   7 ; --- 支付中心
}

GameEnum.FrozenTimeHighlightUnit =
{
    Self                                                         =   1 ; --- 自己
    SelfAndTarget                                                =   2 ; --- 自己和目标
}

GameEnum.TowerDefGuideType =
{
    Character                                                    =   1 ; --- 角色
    Item                                                         =   2 ; --- 道具
}

GameEnum.TowerDefQuestType =
{
    ClearLevel                                                   =   1 ; --- 通关塔防关卡X
    LevelScore                                                   =   2 ; --- 塔防关卡X评分达到Y
}

GameEnum.CookiePackModel =
{
    CookiePackNormalModel                                        =   1 ; --- 常规模式
    CookiePackPathsModel                                         =   2 ; --- 流线模式
    CookiePackRhythmlModel                                       =   3 ; --- 节奏模式
    CookiePackComplexModel                                       =   4 ; --- 复合模式
}

GameEnum.CookiePackType =
{
    Daily                                                        =   1 ; --- 日常
    Complex                                                      =   2 ; --- 梦魇
}

GameEnum.CookieType =
{
    Round                                                        =   1 ; --- 圆
    Square                                                       =   2 ; --- 方
    Star                                                         =   3 ; --- 五角星
}

GameEnum.CookieRhythmlResult =
{
    Excellent                                                    =   1 ; --- 极致完美
    Perfect                                                      =   2 ; --- 完美
    Good                                                         =   3 ; --- 极好
    Miss                                                         =   4 ; --- 失误
}

GameEnum.LevelQuestTargetType =
{
    Null                                                         =   0 ; --- 空任务
    KillMonster                                                  =   1 ; --- 击杀指定Id怪物
    CastDodgeSkill                                               =   2 ; --- 进行闪避
    HoldRushState                                                =   3 ; --- 保持疾跑状态
    CastAssitSkill                                               =   4 ; --- 释放援护技能
    CastAssitUltraSkill                                          =   5 ; --- 释放援护绝招
    BreakMonsterToughness                                        =   6 ; --- 完成破韧
    ReceiveTriggerOpId                                           =   7 ; --- 收到指定交互行为Id
    CastSkill                                                    =   8 ; --- 释放指定Id技能
    UseCombo                                                     =   9 ; --- 执行指定标签Combo
    KillMonsterByDamageTag                                       =  10 ; --- 指定标签伤害击杀怪物
    DamagedByDamageTag                                           =  11 ; --- 指定标签伤害造成伤害
    RecoverEnergy                                                =  12 ; --- 指定Id角色绝招能量回满
    KillAllMonster                                               =  13 ; --- 清理场上所有怪物
    CastSkillEnd                                                 =  14 ; --- 指定Id技能释放完毕
    DamagedByDamageIdGroup                                       =  15 ; --- 指定数组内伤害Id造成伤害
}

GameEnum.TutorialLevelProcessType =
{
    Test                                                         =   0 ; --- 测试流程
    BasicOperation                                               =   1 ; --- 基础操作练习
    MoveOperation                                                =   2 ; --- 移动操作练习
    SupportOperation                                             =   3 ; --- 援护角色复习
    MarkMechanism                                                =   4 ; --- 战斗机制教学-印记
    ElementMechanism                                             =   5 ; --- 战斗机制教学-元素属性强弱
    StarTowerCardMechanism                                       =   6 ; --- 星塔基础机制-选卡
    StarTowerNoteMechanism                                       =   7 ; --- 星塔基础机制-音符
    MonsterToughnessMechanism                                    =   8 ; --- 怪物机制教学-韧性
}

GameEnum.wordLinkType =
{
    Word                                                         =   1 ; --- 关键字
    Potential                                                    =   2 ; --- 潜能
}

GameEnum.potentialIType =
{
    Potential5                                                   =   5 ; --- 5号潜能提升
    Potential6                                                   =   6 ; --- 6号潜能提升
    Potential7                                                   =   7 ; --- 7号潜能提升
    Potential8                                                   =   8 ; --- 8号潜能提升
    Potential9                                                   =   9 ; --- 9号潜能提升
    Potential10                                                  =  10 ; --- 10号潜能提升
    Potential11                                                  =  11 ; --- 11号潜能提升
    Potential12                                                  =  12 ; --- 12号潜能提升
    Potential13                                                  =  13 ; --- 13号潜能提升
    Potential25                                                  =  25 ; --- 25号潜能提升
    Potential26                                                  =  26 ; --- 26号潜能提升
    Potential27                                                  =  27 ; --- 27号潜能提升
    Potential28                                                  =  28 ; --- 28号潜能提升
    Potential29                                                  =  29 ; --- 29号潜能提升
    Potential30                                                  =  30 ; --- 30号潜能提升
    Potential31                                                  =  31 ; --- 31号潜能提升
    Potential32                                                  =  32 ; --- 32号潜能提升
    Potential33                                                  =  33 ; --- 33号潜能提升
    Potential41                                                  =  41 ; --- 41号潜能提升
    Potential42                                                  =  42 ; --- 42号潜能提升
    Potential43                                                  =  43 ; --- 43号潜能提升
}

GameEnum.CharGemSlotPosition =
{
    Slot1                                                        =   0 ; --- 第一槽
    Slot2                                                        =   1 ; --- 第二槽
    Slot3                                                        =   2 ; --- 第三槽
    SlotBound                                                    =   3 ; --- 槽边界
}

GameEnum.CharGemType =
{
    GemType_1                                                    =   1 ; --- 恩赐意志
    GemType_2                                                    =   2 ; --- 地理协会
    GemType_3                                                    =   3 ; --- 帝国卫队
}

GameEnum.CharGemAttrGroupType =
{
    UniqueAttrGroup                                              =   1 ; --- 独有库
    CommonAttrGroup                                              =   2 ; --- 权重库
}

GameEnum.CharGemAttrTag =
{
    ATTR                                                         =   1 ; --- 属性
    SILL                                                         =   2 ; --- 技能等级
    Potential_F                                                  =   3 ; --- 前台潜能
    Potential_B                                                  =   4 ; --- 后台潜能
    Potential_G                                                  =   5 ; --- 通用潜能
}

GameEnum.GemASkillLevelType =
{
    NormalAtk                                                    =   1 ; --- 普通攻击等级提升
    Skill                                                        =   2 ; --- 技能等级提升
    AssistSkillI                                                 =   3 ; --- 支援技能等级提升
    Ultimate                                                     =   4 ; --- 必杀等级提升
}

GameEnum.CharGemEffectType =
{
    ATTR_FIX                                                     =  12 ; --- 属性修改
    PLAYER_ATTR_FIX                                              =  37 ; --- 玩家属性修改
    SkillLevel                                                   =   7 ; --- 技能等级提升
    Potential                                                    =  99 ; --- 潜能等级提升
}

GameEnum.TrialSectType =
{
    MainSect1                                                    =   1 ; --- 主控流派1
    MainSect2                                                    =   2 ; --- 主控流派2
    SupSect1                                                     =   3 ; --- 支援流派1
    SupSect2                                                     =   4 ; --- 支援流派2
}

GameEnum.activityGroupType =
{
    None                                                         =   0 ; --- 无
    Middle                                                       =   1 ; --- 中型
    Huge                                                         =   2 ; --- 大型
}

GameEnum.activityThemeType =
{
    None                                                         =   0 ; --- 无
    Swim                                                         =   1 ; --- 泳装主题
}

GameEnum.ActivityLevelType =
{
    Explore                                                      =   1 ; --- 普通
    Adventure                                                    =   2 ; --- 挑战
    AVG                                                          =   3 ; --- 剧情
}

GameEnum.TutorialType =
{
    Character                                                    =   1 ; --- 旅人机制
    Battle                                                       =   2 ; --- 战斗机制
    StarTower                                                    =   3 ; --- 星塔机制
}

GameEnum.ActivityTaskTabType =
{
    Tab1                                                         =   1 ; --- 日常任务
    Tab2                                                         =   2 ; --- 挑战任务
    Tab3                                                         =   3 ; --- 冒险任务
    Tab4                                                         =   4 ; --- 玩法任务
    Tab5                                                         =   5 ; --- 活跃任务
}

GameEnum.ActivityUseType =
{
    None                                                         =   1 ; --- 无
    Middle                                                       =   2 ; --- 中型活动
}

GameEnum.PopUpType =
{
    Activity                                                     =   1 ; --- 单活动
    ActivityGroup                                                =   2 ; --- 活动组
    OwnPopUP                                                     =   3 ; --- 独立公告
}

GameEnum.PopRefreshType =
{
    WholeFirst                                                   =   1 ; --- 期间首次登录
    DailyFirst                                                   =   2 ; --- 期间每日登录
}

GameEnum.PopJumpType =
{
    None                                                         =   1 ; --- 无跳转
    ActivityJump                                                 =   2 ; --- 活动跳转
    NormalJump                                                   =   3 ; --- 常规跳转
}

GameEnum.PopUpSeqType =
{
    None                                                         =   0 ; --- 无
    WorldClass                                                   =   1 ; --- 世界等级
    FuncUnlock                                                   =   2 ; --- 功能解锁
    DailyCheckIn                                                 =   3 ; --- 每日签到
    MonthlyCard                                                  =   4 ; --- 月卡
    ActivityFaceAnnounce                                         =   5 ; --- 打脸公告
    ActivityLogin                                                =   6 ; --- 活动登录
    NewChat                                                      =   7 ; --- 聊天
    MessageBox                                                   =   8 ; --- 通用弹窗
}

GameEnum.MallItemType =
{
    Package                                                      =   1 ; --- 礼包
    Skin                                                         =   2 ; --- 皮肤
}

GameEnum.GetLinesType =
{
    GachaNew                                                     =   1 ; --- 初次获得
    Gacha                                                        =   2 ; --- 重复获得
    UnLockLook                                                   =   3 ; --- 觉醒
    UnLockCG                                                     =   4 ; --- CG
    Skin                                                         =   5 ; --- 皮肤
}

GameEnum.storySetOpenCond =
{
    WorldClassSpecific                                           =  71 ; --- [历史]达到X世界等级
}

GameEnum.ElementMarkType =
{
    Fire                                                         =   1 ; --- 全部火系印记
    Water                                                        =   2 ; --- 全部水系印记
    Light                                                        =   3 ; --- 全部光系印记
    Dark                                                         =   4 ; --- 全部暗系印记
    Earth                                                        =   5 ; --- 全部地系印记
    Wind                                                         =   6 ; --- 全部风系印记
    FireMark1                                                    =  11 ; --- 火系印记1
    FireMark2                                                    =  12 ; --- 火系印记2
    FireMark3                                                    =  13 ; --- 火系印记3
    FireMark4                                                    =  14 ; --- 火系印记4
    FireMark5                                                    =  15 ; --- 火系印记5
    WaterMark1                                                   =  21 ; --- 水系印记1
    WaterMark2                                                   =  22 ; --- 水系印记2
    WaterMark3                                                   =  23 ; --- 水系印记3
    WaterMark4                                                   =  24 ; --- 水系印记4
    WaterMark5                                                   =  25 ; --- 水系印记5
    LightMark1                                                   =  31 ; --- 光系印记1
    LightMark2                                                   =  32 ; --- 光系印记2
    LightMark3                                                   =  33 ; --- 光系印记3
    LightMark4                                                   =  34 ; --- 光系印记4
    LightMark5                                                   =  35 ; --- 光系印记5
    DarkMark1                                                    =  41 ; --- 暗系印记1
    DarkMark2                                                    =  42 ; --- 暗系印记2
    DarkMark3                                                    =  43 ; --- 暗系印记3
    DarkMark4                                                    =  44 ; --- 暗系印记4
    DarkMark5                                                    =  45 ; --- 暗系印记5
    EarthMark1                                                   =  51 ; --- 地系印记1
    EarthMark2                                                   =  52 ; --- 地系印记2
    EarthMark3                                                   =  53 ; --- 地系印记3
    EarthMark4                                                   =  54 ; --- 地系印记4
    EarthMark5                                                   =  55 ; --- 地系印记5
    WindMark1                                                    =  61 ; --- 风系印记1
    WindMark2                                                    =  62 ; --- 风系印记2
    WindMark3                                                    =  63 ; --- 风系印记3
    WindMark4                                                    =  64 ; --- 风系印记4
    WindMark5                                                    =  65 ; --- 风系印记5
}

GameEnum.AdventureActorElementTriggerType =
{
    None                                                         =   0 ; --- 无
    FireElementTriggerType1                                      =  11 ; --- 超燃
    FireElementTriggerType2                                      =  12 ; --- 灼炎
    WaterElementTriggerType1                                     =  21 ; --- 寒冷
    WaterElementTriggerType2                                     =  22 ; --- 水系2暂无
    LightElementTriggerType1                                     =  31 ; --- 落雷
    LightElementTriggerType2                                     =  32 ; --- 光系2暂无
    DarkElementTriggerType1                                      =  41 ; --- 暗灼
    DarkElementTriggerType2                                      =  42 ; --- 暗锁
    EarthElementTriggerType                                      =  51 ; --- 岩锥
    EarthElementTriggerType2                                     =  52 ; --- 地系2暂无
    WindElementTriggerType1                                      =  61 ; --- 气旋
    WindElementTriggerType2                                      =  62 ; --- 绽放
}
return GameEnum
