## Auto Potion

Smart, always-up-to-date macros for Healthstones, healing potions, class/racial self-heals, mana potions, food, drink and bandages.

Auto Potion was previously known as *Healthstone Auto Macro*. The addon automatically creates and maintains these macros for you:

- **`AutoPotion`** – uses your class/racial healing spells, Healthstones and the best available healing potion (and some special healing items).
- **`AutoManaPotion`** – uses the mana potion in your bags that restores the most mana.
- **`AutoFood`** – eats the best food in your bags: conjured food first, then the food that restores the most health.
- **`AutoDrink`** – drinks the best drink in your bags: conjured water first, then the drink that restores the most mana.
- **`AutoBandage`** – uses your strongest bandage, with special handling in battlegrounds.

You never have to edit these macros yourself – Auto Potion keeps them updated as your bags, talents and gear change. Just put the ones you want on your action bars.

## What the addon does

- **Automatic healing macro**: Keeps a `/castsequence` macro up to date so you can bind a single key for self-heals, Healthstones and healing potions.
- **Smart priority system**:
  - Class/racial healing spells (like Renewal, Exhilaration, Desperate Prayer, Gift of the Naaru, etc.).
  - Optional support for **Heartseeking Health Injector** (engineering tinker) on Retail.
  - Warlock **Healthstones** (including classic variants), with an option to lower their priority if you prefer potions first.
  - The **strongest available healing potion** in your bags, including modern and legacy potions (Silvermoon / Invigorating / Algari / Dreamwalker's / Withering / Cosmic / Spiritual / etc.).
  - Fleeting potions are used before the normal potion of the same quality, since they expire.
  - Optional **Cavedweller's Delight** support as a separate, toggleable step.
- **Sorted for your game version**:
  - Every potion, food, drink and bandage list is ordered strongest first for your game version (checked against the game data of Retail, Classic Era, TBC, Wrath, Cata, Mists and Forever), so the macro always picks the best item you have.
- **Smart battleground support**:
  - Uses the appropriate PvP-only healing draughts and bandages when you are in battlegrounds (e.g. Ashran tonic, Classic draughts and BG bandages).
- **Mana potion macro**:
  - Maintains an `AutoManaPotion` macro (`/use item:<id>`) for the best mana potion in your bags, sorted by the amount of mana restored for your game version (e.g. Lightfused / Algari / Aerated on Retail, Master / Mythical / Runic / Super / Major on the Classic versions).
  - Potions that restore health *and* mana (Rejuvenation potions, Cavedweller's Delight, Refreshing Serum) are included and sorted by their mana, and can be turned off in the settings.
  - Channeled/"defenseless" potions, potions with side effects and zone-locked potions are never used.
- **Food and drink macros**:
  - Maintain an `AutoFood` and an `AutoDrink` macro for the best food and drink in your bags.
  - Conjured food and water come first (free, and they don't take up bag space).
  - Food and drink that also give a "Well Fed" or "Relaxed" buff come next, but only if you turn on **Include Buff Food**.
  - Then food and drink that restore health *and* mana, then plain food and drink, highest tier first.
  - On TBC, Wrath, Cata and Mists, food and drink from the earlier expansions follow as a fallback for characters that are still leveling.
- **Bandage macro**:
  - Maintains an `AutoBandage` macro that uses the best bandage available for your current game version and content.
- **Works across versions**:
  - Retail (Midnight), Classic Era, The Burning Crusade Anniversary, WotLK Classic, Cataclysm Classic, Mists of Pandaria Classic, and WoW Forever (beta).

## How it works

- **Macro maintenance**:
  - On login, `/reload`, leaving combat, changing talents, changing equipment, summoning a pet (for certain classes) or when your bags change, the addon:
    - Scans your character for supported healing spells, Healthstones, potions, food, drink, bandages and special items.
    - Builds an ordered list based on your settings.
    - Rebuilds the `AutoPotion`, `AutoManaPotion`, `AutoFood`, `AutoDrink` and `AutoBandage` macros (and creates any that are missing).
- **Macro content (high level)**:
  - Uses standard macro commands like `/cast`, `/castsequence` and `/use` with `[@player]` where appropriate.
  - Can optionally include `/stopcasting` at the top of the macro if you enable that in the settings.
  - Uses a `reset=` condition that can factor in the shortest cooldown of your selected healing spells if you enable the **CD reset** option.
- **Performance-friendly**:
  - Bag events are debounced so the macro is not rebuilt excessively when your bags change rapidly.
  - Macro updates are postponed while in combat to comply with WoW's secure execution rules.

## Installation & Quick Start

1. **Install the addon**
   - Install via CurseForge/Wago or manually drop the `AutoPotion` folder into your `Interface/AddOns` directory.
2. **Log in or reload once**
   - The addon creates its macros (`AutoPotion`, `AutoManaPotion`, `AutoFood`, `AutoDrink`, `AutoBandage`) under **General Macros** (`/macro`). If all your general macro slots are full, delete one first.
3. **Place them on your bars**
   - Drag the `AutoPotion` macro to your action bar and bind it to a comfortable key.
   - Do the same for any of the other macros you want to use.
4. **Configure (optional)**
   - Open the settings via `/ap` or through the **Interface → AddOns → AutoPotion** options panel. The first page is a short overview of how the addon works; the settings for each macro are on the pages below it.

After this, just press your keybind whenever you need an emergency heal; Auto Potion will handle the rest according to your configuration.

## Configuration

Open the settings via `/ap` or **Interface → AddOns → AutoPotion**. `/ap` opens a short **information page** (how the addon works, its macros and commands); each macro has its own page below it, in this order: **AutoPotion**, **AutoManaPotion**, **AutoFood**, **AutoDrink** and **AutoBandage**. Spells and items are listed with their icon, like in the spellbook. The most important options are:

- **Class/Racial Spells** (Interface → AddOns → AutoPotion → AutoPotion):
  - Choose which supported self-healing spells and racials should be part of the sequence for your class.
- **Include `/stopcasting` in the macro**:
  - Useful for casters; immediately stop your current cast before using a heal.
- **Include shortest cooldown in reset**:
  - Optionally include the shortest cooldown of your selected heals in the castsequence `reset=` condition. **Use carefully** if you are not familiar with castsequence behavior.
- **Low Priority Healthstones**:
  - Let health potions be used before Healthstones (or leave disabled to prefer Healthstones first).
- **Potion of Withering Vitality / Potion of Withering Dreams**:
  - Toggle whether these riskier potions are allowed in the rotation.
- **Cavedweller's Delight**:
  - Enable/disable Cavedweller's Delight (and its fleeting versions) as a separate step.
- **Heartseeking Health Injector (tinker)**:
  - Enable support for the engineering tinker on Retail if you have it equipped.
- **Mana Potions** (Interface → AddOns → AutoPotion → AutoManaPotion):
  - Shows which mana potion will be used first, and lets you turn off potions that restore health and mana (**Include Rejuvenation Potions**).
- **Food and Drink** (Interface → AddOns → AutoPotion → AutoFood / AutoDrink):
  - Shows which food and drink will be used first. **Include Buff Food** also uses food and drink with a "Well Fed" or "Relaxed" buff (off by default, since the buff is situational).
- **Soulburn Healthstone** (Retail, Warlock only):
  - Adds `/cast [combat] Soulburn` above the castsequence so your Healthstone is empowered (more healing and +20% max health) in the same keypress. Only added when you know the Soulburn talent and have a Healthstone in your bags.
  - Soulburn costs a Soul Shard and is cast on every press while it is off cooldown, also when the press uses a potion or spell. Without a Soul Shard the macro simply continues as usual.
- **Bandage Priority**:
  - Dedicated bandage priority display that shows which bandage will be used first (including battleground-specific bandages in Classic).

The UI also shows the **current priority order** for your heals, potions, food, drink and bandages so you can easily verify what the macro will do.

## Terms of Use & Fair Play (Not a Cheat)

Auto Potion is designed to be fully compliant with World of Warcraft's Terms of Use and addon policies:

- **No automation of gameplay**:
  - The addon **never presses buttons for you** and does not trigger abilities automatically.
  - You still need to **manually press your keybind** for the macro to activate any spell or item.
- **Uses only Blizzard-approved functionality**:
  - Relies on the normal macro system (`/cast`, `/castsequence`, `/use`, `[@player]`, etc.).
  - Respects combat lockdown rules and only edits macros when it is safe and allowed by the client.
- **No protected actions outside keypresses**:
  - All healing actions are executed exactly as if you had written the macro yourself – Auto Potion just **keeps the macro text up to date**.

In short: Auto Potion is a **quality-of-life** addon, not an automation or botting tool.

## MegaMacro Compatibility

If you use the **MegaMacro** addon, Auto Potion can update your MegaMacro macros instead of the default WoW macro system.

- **Important setup steps**:
  - Create a **Global** macro in MegaMacro named **`AutoPotion`**.
  - (Optional) Create more **Global** macros for the other macros you want: **`AutoManaPotion`**, **`AutoFood`**, **`AutoDrink`** and **`AutoBandage`**.
  - Type `/reload` in-game.
- **How it behaves**:
  - When MegaMacro is installed and loaded, Auto Potion **will not create or manage standard WoW macros** for these names.
  - Instead, it looks for the matching **global MegaMacro entries** and updates their macro text directly.
- **Troubleshooting**:
  - If you see an AutoPotion error about a missing MegaMacro macro:
    - Verify that you created a **Global** (not character-specific) macro.
    - Ensure the name is **exactly** the one from the error message (e.g. `AutoPotion` or `AutoFood`).
    - `/reload` after creating the macro so Auto Potion can detect and update it.

Once configured, you can use your MegaMacro-managed macros exactly like the standard ones.

## FAQ

- **Q: Do I still need to press a key to heal?**  
  **A:** Yes. The addon only updates the macro text. You must press your keybind for any heal, potion, or bandage to be used.

- **Q: Does this work in all versions of WoW?**  
  **A:** Yes. Auto Potion supports Retail, Classic Era, The Burning Crusade Anniversary, WotLK Classic, Cataclysm Classic, Mists of Pandaria Classic, and WoW Forever (beta), adapting the potion, food, drink and bandage lists to each version.

- **Q: Which item does a macro use?**  
  **A:** The first item from its priority list that you have in your bags. The lists are ordered strongest first for your game version; the settings page of each macro shows the order.

- **Q: Can I change which spells are used?**  
  **A:** Yes. Open the settings (`/ap`) and toggle your preferred class/racial self-healing spells.

- **Q: What if I only want potions and Healthstones, no spells?**  
  **A:** Simply disable all class/racial spells in the settings; the macro will then consist only of items.
