# AutoPotion - Copilot Instructions

## Project Overview

**AutoPotion** is a World of Warcraft addon that intelligently maintains healing macros for players. The addon automatically updates macros based on available healing spells, Healthstones, potions, and bandages in the player's bags.

**Key Features:**

- Automatic macro generation and updates (`AutoPotion` and `AutoBandage`)
- Smart priority system for healing options (spells → Healthstones → potions → bandages)
- Multi-version WoW support (Retail, Classic Era, TBC, WotLK, Cataclysm, MoP)
- Localization in 10 languages
- Smart battleground-specific healing draughts and bandages
- Performance optimized with event debouncing

## Architecture & Design

### Core Concept

The addon maintains two macros by scanning the player's character state (spells known, items in bags, equipped gear) and rebuilding macro strings when relevant changes occur (login, combat exit, talent change, bag changes, equipment change).

### Module Structure

```
Core/
  ├── Constants.lua      # Game constants (Map IDs, version detection)
  ├── Spell.lua          # Individual spell wrapper
  ├── Spells.lua         # Collection of player's known spells
  ├── Item.lua           # Individual item wrapper
  ├── Potions.lua        # Potion item collection and prioritization
  ├── Bandages.lua       # Bandage item collection and prioritization
  ├── Player.lua         # Player state (spells, items, class info)
  └── DB.lua             # SavedVariables database handling

FrameXML/
  └── InterfaceOptionsFrame.lua  # Settings UI

Libs/
  └── AceLocale-3.0/     # Localization library

Locales/
  └── *.lua              # Language-specific translations

code.lua                  # Main addon logic and macro building
Bindings.lua             # Macro binding definitions
```

### Version Detection

The addon supports multiple WoW versions:

- `WOW_PROJECT_ID == WOW_PROJECT_MAINLINE` — Retail
- `WOW_PROJECT_ID == WOW_PROJECT_CLASSIC` — Classic Era (1.15.x)
- `WOW_PROJECT_ID == 5` — TBC Anniversary/BCC (2.5.x)
- `WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC` — WotLK Classic (3.4.x)
- `WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC` — Cataclysm Classic (4.4.x)
- `WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC` — Mists Classic (5.5.x)

Use these constants to branch version-specific logic.

## Key Modules

### Spell (`Core/Spell.lua`)

Represents a single spell with tracking for ID, name, and cooldown.

**Constructor:**

```lua
local spell = ham.Spell.new(spellId)
```

**Methods:**

- `spell:getId()` — Returns spell ID
- `spell:getName()` — Returns localized spell name
- `spell:getCd()` — Returns cooldown duration in seconds
- `spell:isKnown()` — Returns true if player knows the spell

### Spells (`Core/Spells.lua`)

Manages collection of spell objects for a player. Handles class-specific spells (Renewal, Exhilaration, Desperate Prayer, Gift of the Naaru, etc.).

### Item (`Core/Item.lua`)

Represents items (potions, bandages, tinkers) with tracking for item ID, name, quality, and availability.

**Constructor:**

```lua
local item = ham.Item.new(itemId)
```

### Potions (`Core/Potions.lua`)

Scans bags for healing potions and maintains a prioritized list. Supports:

- Retail potions (Algari, Invigorating, Dreamwalker's, Withering, Cosmic, Spiritual, etc.)
- Legacy potions from previous expansions
- Special items (Heartseeking Health Injector on Retail)
- Cavedweller's Delight (toggleable)

### Bandages (`Core/Bandages.lua`)

Similar to Potions but for bandages. Includes special handling for:

- Classic battleground-specific bandages
- Ashran tonics (Retail)
- Version-appropriate bandages

### Player (`Core/Player.lua`)

Singleton that tracks player state:

- Known spells
- Items in bags
- Class, race, talents
- Current location and combat status

### Database (`Core/DB.lua`)

Handles `SavedVariables` (HAMDB) for persistent settings:

- `cdReset` — Include CD reset in macro
- `stopCast` — Include `/stopcasting` in macro
- `raidStone` — Lower Healthstone priority
- `witheringPotion` / `witheringDreamsPotion` — Version-specific toggles
- `cavedwellerDelight` — Toggle special item
- `heartseekingInjector` — Toggle engineering tinker (Retail)

## Macro Building Logic

### Trigger Events

Macros are rebuilt when:

1. Player logs in
2. `/reload` or UI restore
3. Leaving combat (updates postponed during combat)
4. Talent changes
5. Equipment changes
6. Pet summoned (certain classes)
7. Bags update (debounced, 3 second cooldown)

### Macro Structure

The generated macro uses:

- `/castsequence` — Primary macro cycling through options
- `/cast` or `/use` commands
- `[@player]` target modifier where appropriate
- Conditional `reset=` clause with optional CD component

**Example:**

```
/castsequence [@player] reset=combat Self-Heal, Healthstone, Eternal Healing Potion, #showtooltip Eternal Healing Potion
```

### Priority Order (Default)

1. Class/Racial self-heal spells
2. Healthstone (optional lower priority via `raidStone` flag)
3. Engineering tinker (Heartseeking Health Injector, Retail only)
4. Strongest healing potion in bags
5. Cavedweller's Delight (optional)
6. Fallback bandage

## Development Guidelines

### Code Style

- Use lowercase variable names: `myVar`, `playerSpells`
- Use lowercase function names: `isKnown()`, `getId()`
- Use consistent indentation (spaces, not tabs)
- Use `local` by default; declare globals with `ham.` prefix
- Comment complex logic, especially version-specific branches

### Working with SavedVariables

Always use `ham.options` table instead of direct `HAMDB` access for in-memory caching:

```lua
if ham.options.cdReset then
  -- Include CD reset in macro
end
```

### Adding New Spells

Edit `Core/Spells.lua` to add class-specific spells. Include version checks if needed:

```lua
if isRetail then
  table.insert(self.items, ham.Spell.new(SPELL_ID_RETAIL))
else
  table.insert(self.items, ham.Spell.new(SPELL_ID_CLASSIC))
end
```

### Adding New Items/Potions

Edit `Core/Potions.lua` or `Core/Bandages.lua`. Follow the pattern:

1. Define item ID constant
2. Create item object: `ham.Item.new(itemId)`
3. Add to appropriate collection based on version and rarity

### Event Handling

Use WoW event system in `code.lua`. Key events:

- `PLAYER_LOGIN` — Initial setup
- `BAG_UPDATE` — Debounced item changes
- `PLAYER_EQUIPMENT_CHANGED` — Equipment swaps
- `UNIT_SPELLCAST_SUCCEEDED` — Pet summons (some classes)
- `PLAYER_TALENT_UPDATE` — Talent changes
- `COMBAT_LOG_EVENT_UNFILTERED` — Combat tracking

### Debouncing

Bag updates are debounced to prevent excessive macro rebuilds:

```lua
local bagUpdates = false
local debounceTime = 3  -- seconds
```

### Testing Across Versions

Always test changes against multiple WoW versions using version constants:

```lua
local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
```

## Localization

### Supported Languages

- English (US) — `enUS.lua`
- German — `deDE.lua`
- Spanish (ES/MX) — `esES.lua`, `esMX.lua`
- French — `frFR.lua`
- Italian — `itIT.lua`
- Korean — `koKR.lua`
- Portuguese (Brazil) — `ptBR.lua`
- Russian — `ruRU.lua`
- Chinese (Simplified/Traditional) — `zhCN.lua`, `zhTW.lua`

### Adding Localized Strings

1. Add string to `Locales/enUS.lua`
2. Add translations to other language files in `Locales/`
3. Access via AceLocale:

```lua
local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local text = L["AutoPotion"]
```

## Common Patterns

### Version-Specific API Calls

```lua
if isRetail then
  local cooldown = C_Spell.GetSpellCooldown(spellId).duration
  local name = C_Spell.GetSpellName(spellId)
else
  local cooldown = GetSpellBaseCooldown(spellId)
  local name = GetSpellInfo(spellId)
end
```

### Item Availability Check

```lua
local item = ham.Item.new(itemId)
if item:isAvailable() then
  -- Item is in bags
end
```

### Spell Known Check

```lua
local spell = ham.Spell.new(spellId)
if spell:isKnown() then
  -- Player knows the spell
end
```

### Macro Registration

Macros must be created by the user first, then the addon updates them:

1. Player creates macro named `AutoPotion` or `AutoBandage`
2. Addon finds and updates the macro via `EditMacro()`
3. Never create macros in code; only update existing ones

## Debugging

### Debug Mode

Enable debug output (in `code.lua`):

```lua
ham.debug = true
```

### Logging Macro Changes

When modifying macro-building logic, log the generated macro strings:

```lua
print("Spells macro: " .. spellsMacroString)
print("Items macro: " .. itemsMacroString)
print("Final macro: " .. macroStr)
```

## Performance Considerations

- **Debouncing**: Bag changes are debounced to 3 seconds to avoid rapid updates
- **Combat Postponement**: Macro updates during combat are queued for post-combat
- **Lazy Initialization**: Options loaded on-demand via `setmetatable`
- **Selective Scanning**: Only rescan necessary bags/spells when specific events fire

## Testing Checklist

Before changes are ready:

- [ ] Tested on all supported WoW versions (Retail, Classic, TBC, WotLK, Cata, MoP)
- [ ] Macros generate correctly with various character setups
- [ ] Battleground-specific items appear in BGs
- [ ] All localization keys exist across all language files
- [ ] No secure execution violations (macro updates only occur out of combat)
- [ ] Debouncing works; rapid bag changes don't spam macro updates
- [ ] Settings persist and load correctly from `HAMDB`

## File Responsibilities Quick Reference

| File                                 | Responsibility                                   |
| ------------------------------------ | ------------------------------------------------ |
| `code.lua`                           | Main event loop, macro generation, orchestration |
| `Bindings.lua`                       | Macro keybinding setup                           |
| `Core/Spell.lua`                     | Single spell wrapper                             |
| `Core/Spells.lua`                    | Player's known spells collection                 |
| `Core/Item.lua`                      | Single item wrapper                              |
| `Core/Potions.lua`                   | Healing potion scanning and prioritization       |
| `Core/Bandages.lua`                  | Bandage scanning and prioritization              |
| `Core/Player.lua`                    | Player state aggregation                         |
| `Core/DB.lua`                        | Saved variables handling                         |
| `Core/Constants.lua`                 | Game constants and version checks                |
| `FrameXML/InterfaceOptionsFrame.lua` | Settings UI                                      |
| `Locales/*.lua`                      | Language-specific text                           |
