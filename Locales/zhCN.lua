local L = LibStub("AceLocale-3.0"):NewLocale("AutoPotion", "zhCN")
if not L then return end

-- InterfaceOptionsFrame
L["Addon Behaviour"] = "插件功能"
L["Auto Potion Settings"] = "Auto Potion 设置"
L["Cavedweller's Delight"] = "洞穴住民的挚爱"
L["Refreshing Serum"] = "复苏血清"
L["Class/Racial Spells"] = "职业/种族技能"
L["Configure the behavior of the addon. IE: if you want to include class spells"] =
"您可以在此设置技能。例如：是否包含职业/种族回血技能"
L["Current Priority"] = "当前优先级"
L["Bandage Priority"] = "绷带优先级"
L["Use Rapid Regeneration (Troll racial) before bandages"] = "使用绷带前使用极速再生（巨魔种族技能-无限）"
L["Food Priority"] = "食物优先级"
L["Drink Priority"] = "饮料优先级"
L["Mana Potion Priority"] = "法力药水优先级"
L["Include Rejuvenation Potions"] = "包含复原药水"
L["Also use potions that restore health and mana (Rejuvenation potions, Cavedweller's Delight, Refreshing Serum, ...). They are sorted by the amount of mana they restore."] =
"同时使用可恢复生命值和法力值的药水（复原药水、洞穴住民的挚爱、复苏血清等），并按恢复的法力值多少排序。"
L["Shows the mana potion that will currently be used, based on what is in your bags."] =
"根据背包内的物品，显示当前将被使用的法力药水。"
L["Include Buff Food"] = "包含增益食物"
L["Include \"Well Fed\"/\"Relaxed\" buff food and drink items (with situational secondary-stat bonuses) in the food and drink priority lists."] =
"将\"进食充分\"/\"悠闲\"增益食物和饮料（含情境性副属性加成）纳入食物和饮料优先级列表。"
L["Only when the buff is missing"] = "仅在缺少增益时"
L["Eat buff food first while you don't have its buff (\"Well Fed\" for food, \"Relaxed\" for drinks), even before conjured food. While you have it, buff food comes last and is only eaten when nothing else is left."] =
"缺少增益时（食物对应\"进食充分\"，饮料对应\"悠闲\"）优先食用增益食物，甚至优先于法师造食；已有该增益时，增益食物排在最后，只有在没有其他选择时才食用。"
L["Go back to your first heal once its cooldown is over"] = "首个治疗技能冷却结束后重新从它开始使用"
L["If you don't press the macro for as long as your first heal's cooldown (talents included), the macro starts over with it. Works when the first heal is a spell or a Healthstone. A later heal with a longer cooldown can still make the macro wait."] =
"若在首个治疗技能的冷却时间（含天赋加成）内没有按宏，宏会重新从该技能开始。首个治疗为法术或治疗石时均有效。后续冷却更长的治疗技能仍可能让宏继续等待。"
L["Heartseeking Health Injector (tinker)"] = "觅心生命注射器（匠械）"
L["Include /stopcasting in the macro"] = "添加停止施法（/stopcasting）到宏内（需重载界面）"
L["Invalid option: "] = "无效选项："
L["Items"] = "物品"
L["Soulburn Healthstone"] = "灵魂燃烧治疗石"
L["Casts Soulburn right before the macro in combat to empower your Healthstone. Costs a Soul Shard every time Soulburn is off cooldown, also on presses that use a potion or spell."] =
"战斗中在宏生效前施放灵魂燃烧以强化治疗石。每次灵魂燃烧冷却结束时都会消耗一枚灵魂碎片，使用药水或技能的按键也不例外。"
L["Low Priority Healthstones"] = "降低治疗石使用优先级"
L["Other / Racial"] = "其他 / 种族"
L["Potion of Withering Dreams"] = "凋零梦境药水"
L["Potion of Withering Vitality"] = "枯萎活力药水"
L["Prioritize health potions over a healthstone."] = "治疗药水优先于治疗石使用。"
L["Reset successful!"] = "重置成功！"
L["Reset to Default"] = "重置为默认"
L["Shows the bandage that will currently be used, based on what is in your bags."] =
"显示当前将使用的绷带（依据背包物品）。"
L["Shows the food that will currently be used, based on what is in your bags."] =
"显示当前将使用的食物（依据背包物品）。"
L["Shows the drink that will currently be used, based on what is in your bags."] =
"显示当前将使用的饮料（依据背包物品）。"
L["Useful for casters."] = "对施法职业有用。"

-- InfoOptionsFrame
L["AutoPotion keeps your macros up to date, so one key always uses the best you have right now: healing spells, potions, food, drink and bandages."] =
"AutoPotion 会持续更新您的宏，一个按键即可使用当前最优选择：治疗法术、药水、食物、饮料和绷带。"
L["Version %s"] = "版本 %s"
L["How it works"] = "使用说明"
L["AutoPotion creates the macros listed below. You find them under General Macros (/macro)."] =
"AutoPotion 会创建下列宏，可在通用宏（/macro）中找到。"
L["Drag the macros you want onto your action bars and bind a key."] =
"将需要的宏拖到动作条上并绑定按键即可。"
L["That's it. The macros update themselves out of combat whenever your bags, talents or gear change. You still press the key yourself - AutoPotion never casts anything for you."] =
"就这样。当背包、天赋或装备发生变化时，宏会在战斗外自动更新。您仍需自己按键——AutoPotion 绝不会替您施放任何技能。"
L["Each macro has its own settings page in the list on the left."] =
"每个宏在左侧列表中都有独立的设置页面。"
L["Macros"] = "宏"
L["Healthstones, healing potions and class/racial self-heals."] =
"治疗石、治疗药水以及职业/种族治疗技能。"
L["The mana potion that restores the most mana."] = "恢复法力值最多的法力药水。"
L["The best food in your bags."] = "背包中最好的食物。"
L["The best drink in your bags."] = "背包中最好的饮料。"
L["Your strongest bandage, including battleground bandages."] =
"您最强的绷带，包括战场绷带。"
L["Commands"] = "命令"
L["Opens these settings."] = "打开此设置界面。"
L["Toggles debug messages in the chat."] = "切换聊天中的调试信息。"
L["More addons by %s"] = "%s 的其他插件"
L["Applies the right Edit Mode layout, UI scale and AddOn set for your screen resolution. Made for switching between PC, laptop and Steam Deck."] =
"根据您的屏幕分辨率应用合适的编辑模式布局、UI 缩放和插件集，专为在 PC、笔记本和 Steam Deck 之间切换而设计。"
L["An automatic journal of your adventures: level ups, dungeon runs, first boss kills, professions and your routes on the world map."] =
"自动记录您的冒险历程：升级、地下城通关、首次击杀首领、专业技能以及您在世界地图上的路线。"
L["Small quality of life features in one addon: a smaller viewport, junk selling and repairs, quests accepted and turned in for you, IDs and vendor prices in tooltips, a square minimap and dungeons on the world map."] =
"将多种小型便利功能集于一身：更小的游戏画面区域、自动出售垃圾和修理、自动接取和交付任务、提示信息中显示 ID 和商人价格、方形小地图以及世界地图上的地下城标记。"
L["Installed"] = "已安装"
L["Click and press %s to copy"] = "点击并按 %s 复制"
L["Ctrl+C"] = "Ctrl+C"

-- DO NOT TRANSLATE
L["AutoPotion"] = "AutoPotion"   -- DO NOT TRANSLATE
L["AutoBandage"] = "AutoBandage" -- DO NOT TRANSLATE
L["AutoFood"] = "AutoFood"       -- DO NOT TRANSLATE
L["AutoDrink"] = "AutoDrink"     -- DO NOT TRANSLATE
L["AutoManaPotion"] = "AutoManaPotion" -- DO NOT TRANSLATE

-- code.lua
L["Couldn't create the %s macro: your general macros are full. Delete one of them and it will be created."] =
"无法创建 %s 宏：您的通用宏已满。删除其中一个后即可创建。"

