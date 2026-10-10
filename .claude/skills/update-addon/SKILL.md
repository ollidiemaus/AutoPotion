---
name: update-addon
description: Update AutoPotion for a new WoW patch or season - bump the ## Interface lines in AutoPotion.toc, check the patch's API changes against the APIs the addon calls, add new consumables (healing/mana potions, healthstones, food, drink, bandages) and update the README. Does not tag or release.
disable-model-invocation: true
argument-hint: "[patch or flavor, e.g. 12.1.5 or 'mists']"
---

# Update AutoPotion for a new patch

Requested scope: $ARGUMENTS
(Empty means: check every flavor in the TOC for a newer patch.)

Work through the phases in order. Finish each one with a short table of what changed
(or "nothing to do") before moving on, so the user can follow along and stop you early.
Never guess a number, ID or API name - every value you write must come from a source you
actually read in this session. If no source confirms it, ask the user instead.

Game data (builds, item and spell IDs, ranks, amounts, tooltips) and Blizzard's UI source
come from the `wow-data` skill's script, not from Wowhead/wago.tools pages in the browser
and not from memory. Its output is a few lines; a browsed page is tens of thousands of tokens.
Keep the browser for what the script can't answer (patch notes, "new items" guides, comments).

```bash
W=~/.claude/skills/wow-data/scripts/wow.py   # python3 $W <command> -h for options
```

## 0. Setup

- Start from an up-to-date `main` with a clean tree, then create a branch `update/<patch>`.
- Read `AutoPotion.toc` to get the current interface versions; they tell you which
  patches the addon was last updated for.

## 1. Interface versions (`AutoPotion.toc`)

TOC line → game flavor:

| TOC line | Flavor | Client version → interface number |
|---|---|---|
| `## Interface` | Retail (Mainline) | 12.1.5 → `120105` |
| `## Interface-Classic` | Classic Era | 1.15.9 → `11509` |
| `## Interface-BCC` | TBC Anniversary | 2.5.6 → `20506` |
| `## Interface-WOTLKC` | Wrath Classic | 3.4.5 → `30405` |
| `## Interface-Cata` | Cata Classic | 4.4.2 → `40402` |
| `## Interface-Mists` | Mists Classic | 5.5.4 → `50504` |
| `## Interface-Forever` | WoW Forever | 1.60.1 → `16001` |

Formula: `major*10000 + minor*100 + patch`.

- Sources: `python3 $W builds` (newest client build per flavor, including PTR) and
  https://warcraft.wiki.gg/wiki/TOC_format (current interface versions per flavor).
  Confirm each number with both; https://warcraft.wiki.gg/wiki/Public_client_builds
  breaks a tie.
- A line can list several versions, comma-separated (`120100, 120105`). For retail, list the
  live version and the upcoming PTR/patch version. Drop a version only once its patch is
  completely gone from live. Keep the list in ascending order.
- Change only the flavors that actually got a new patch.
- Leave `## Version: @project-version@` as it is; the packager fills it in from the git tag.

## 2. API changes

For every flavor that got a new patch, read the API change notes for each patch between
the old and new interface version, e.g. https://warcraft.wiki.gg/wiki/Patch_12.1.5/API_changes
(Classic flavors use their own patch numbers). Then check them against what the addon
actually uses. Run this to list the current API surface:

```bash
grep -rhoE '\bC_[A-Za-z]+\.[A-Za-z]+' --include='*.lua' code.lua Core FrameXML Bindings.lua | sort | uniq -c | sort -rn
```

To check whether an API the addon calls still exists, or what its signature is now, grep
that flavor's Blizzard UI source instead of opening the wiki page for every function
(`-f retail|ptr|classic|tbc|mists|forever`; Wrath and Cata have no branch):

```bash
python3 $W ui -f ptr grep 'Name = "GetItemCount"' Interface/AddOns/Blizzard_APIDocumentationGenerated
python3 $W ui -f ptr grep 'GetMacroInfo\('         # old globals aren't in the generated docs: find callers
python3 $W ui -f mists grep 'InterfaceOptionsCheckButtonTemplate' --files
```

`C_*` namespaces are documented in `Blizzard_APIDocumentationGenerated`; old globals such as
the macro API are not, so look for Blizzard's own callers instead. A template or function that
only turns up in a `Deprecated*` file is on its way out: report it.

Pay particular attention to the following:
- **Macro API** in `code.lua`: `CreateMacro`, `EditMacro`, `GetMacroInfo`, `InCombatLockdown`
  and the macro syntax itself (`/castsequence`, `/use item:<id>`, `reset=`, `[@player]`).
  The addon is useless without these.
- **Items/spells**: `C_Item.*`, `C_Spell.*`, `IsSpellKnown`, `IsPlayerSpell`,
  `GetSpellBaseCooldown`, and the legacy `GetSpellInfo` fallback in `Core/Spell.lua`.
- **Settings UI** in `FrameXML/`: `Settings.Register*`, `Settings.OpenToCategory`, templates
  `InterfaceOptionsCheckButtonTemplate`, `UIPanelButtonTemplate`, `UIPanelScrollFrameTemplate`,
  `InputBoxTemplate`, and `GameTooltip:SetItemByID/SetSpellByID`.
- **Events** registered in `code.lua` (`grep -rn RegisterEvent code.lua`).
- **Flavor detection** in `Core/Constants.lua`: `WOW_PROJECT_*` constants and the
  interface-range check for Forever.
- `C_AddOns.*`, `C_Map.GetBestMapForUnit`, `C_PvP.*`, `C_Timer.After`.

Rules:
- A Retail API change does not apply to the Classic flavors (and vice versa). The code
  already guards per flavor (`ham.isRetail`, `if C_Spell and ...`); keep fixes inside those guards.
- Fix removals and signature changes that break the addon. If an API is only marked
  deprecated, report it and ask the user before changing it.
- While reading the patch notes, also look for changes to the class/racial self-heals in
  `Core/Spells.lua` and `Core/Spells/<Flavor>.lua` (spells removed, made passive or added).
  Report them, but ask before changing the spell lists. See the comment at the top of
  `Core/Spells/Retail.lua` for how removed spells were handled before.

## 3. New consumables

How the code is laid out:
- Item objects are defined in `Core/Potions.lua` (healing potions + healthstones),
  `Core/ManaPotions.lua`, `Core/Food.lua`, `Core/Drink.lua` and `Core/Bandages.lua`
  as `ham.<name> = ham.Item.new(<itemID>, "<English name>")`, grouped under an expansion
  comment (`--Midnight`, `--The War Within`, ...). New items go under the matching header,
  highest rank/quality first.
- The priority lists live in `Core/<Category>/<Flavor>.lua` (e.g. `ham.getPotsForRetail()` in
  `Core/Potions/Retail.lua`). They are ordered best first; the macro uses the first entry
  found in the bags. Each comment starts a section, and each section is sorted by amount
  restored unless its comment says "order doesn't matter" (Well Fed food).
- The food and drink lists of TBC, Wrath, Cata and Mists end with a fallback for lower-level
  characters: a copy of the older flavors' lists, one `-- <Flavor>: <section>` block per
  section. When you change an older flavor's list, change these copies too.
- Potions that restore health *and* mana are defined twice, once in `Potions.lua` and once
  in `ManaPotions.lua` with `{ rejuvenation = true }`, and are on the health list in
  `ham.getDelightPotsForRetail()`.

What to look for: new healing potions (all ranks/qualities), fleeting variants, mana
potions, health+mana potions, healthstone variants, food/drink (including conjured food)
and bandages for the new patch or season.

- Find candidates with the script, against the flavor's client (`-f ptr` before the patch is live):
  ```bash
  python3 $W item 'healing potion' -f ptr -n 40
  python3 $W db2 ItemSparse -f ptr -w ExpansionID=11 -w 'Display_lang~potion|healthstone' -c ID,Display_lang,ItemLevel
  python3 $W item 241304 241305 -f retail          # name, crafting rank R1-R3, on-use spell
  python3 $W spell <spellID> -f retail --effects   # what it restores
  python3 $W wowhead item 241304                   # tooltip; also for items wago lacks
  ```
  Use Wowhead's "new items" lists or patch notes in the browser only to learn *which* items
  are new, then confirm each one with `item`. Confirm the item ID **and** the rank/quality → ID
  mapping from the `item` output (its R1-R3 column). IDs are not always ascending by rank
  (e.g. Silvermoon R2 = 241304, R1 = 241305).
- Order them the way the existing list does: stronger before weaker; a fleeting variant
  sits next to its normal version of the same rank (see the Invigorating/Algari entries).
  `python3 .claude/skills/update-addon/wago_check.py --dump --flavor <flavor>` prints the
  amount every list entry restores in that flavor's client, so you can see where a new item goes.
- Never add potions that are channeled, have harmful side effects or only work in one zone. The
  existing side-effect potions (Withering) only run behind a settings toggle. If a new item
  would need a new option, that is a feature: describe it and ask before adding settings
  or locale strings (`Locales/enUS.lua` is the default locale; the other locales fall back to it).
- Add it to every flavor list where the item exists, not just Retail.

## 4. README

There is no CHANGELOG file and no `.pkgmeta`. The BigWigs packager builds the
CurseForge/Wago changelog from the **commit messages** since the last tag, so:
- Write commit subjects for players to read, e.g. `Add Midnight Season 2 healing potions`,
  `Update interface versions for 12.1.5`. Make one commit per phase that changed something.
- Update `README.md` where it lists things you changed: the potion families named under
  "What the addon does", the mana potion examples, and the supported versions in that
  section and in the FAQ.

## 5. Verify

Run the static checks (Lua syntax, list entries without a definition, duplicate IDs):

```bash
.claude/skills/update-addon/check.sh
```

It must exit 0. The two "review" sections list duplicates that already exist and are
intentional (health+mana potions, `5512` Healthstone). Only look into entries your change added.

Then check every item against the game client data on wago.tools:

```bash
python3 .claude/skills/update-addon/wago_check.py
```

It reads the interface versions from `AutoPotion.toc`, downloads the item and spell tables
of the newest client build for each of them (about 600 MB on the first run, cached in the
wow-data cache `~/.cache/wow-data/db2`, so `wow.py` and this check share downloads;
`AUTOPOTION_WAGO_CACHE` overrides it, `--no-order` skips the large spell tables) and must exit 0:
- `ERROR`: the item ID does not exist in that flavor, is "UNUSED ITEM" there, points to an
  item with another name (a wrong ID), is not a consumable, or its R1/R2/R3 suffix does not
  match its crafting quality. Fix the ID or remove the entry from that flavor's list.
- `ORDER`: an entry restores more than one listed above it in the same section, or a lower
  quality of an item is listed above a higher one. Move it.
- `NOTE`: wago only has part of the item (its export lacks encrypted and hotfix-only rows).
  Confirm the item with `python3 $W wowhead item <id> -f <flavor>`; these don't fail the check.

Amounts that scale with the player's level can't be compared, so for Retail potions and
bandages (and a few Mists/Cata items) only the quality order is checked. Keep the rest of
their order by hand: newest expansion first. A new zone-, underwater- or battleground-only
item also passes the check, so read its tooltip (`python3 $W wowhead item <id>`) before adding it.

You cannot run the game. Finish with an in-game test checklist for the user, listing each
changed flavor: `/reload` without Lua errors, the `AutoPotion`/`AutoManaPotion` macro text
picks up the new item, and `/ap` shows it on the right settings page.

## 6. Wrap up

- Show a summary table: interface versions old → new, API fixes, items added (name, ID,
  source), README changes and anything left open for the user.
- Commit on the branch. Ask the user before pushing or opening a PR.
- Do **not** create or push a git tag: a tag push publishes a release to CurseForge and
  Wago, and the user does that themselves.
