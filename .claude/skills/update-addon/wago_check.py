#!/usr/bin/env python3
"""Check AutoPotion's item data against the game client data on wago.tools.

For every flavor in AutoPotion.toc it downloads the DB2 tables of the newest client
build of each listed interface version (cached between runs) and reports:

  ERROR    an item in a priority list does not exist in that flavor's client, or is
           called "UNUSED ITEM" there
  ERROR    an item's name matches no client at all (the ID points to some other item)
  ERROR    an item in a priority list is not a consumable
  ERROR    an R1/R2/R3 (or trailing 1/2) suffix does not match the item's crafting quality
  ORDER    an entry restores more than an entry listed above it in the same list section,
           or a lower crafting quality is listed above a higher one of the same item
           (Fleeting variants count as the same item)
  NOTE     the item is only partly in wago's data for that flavor (encrypted or hotfix item);
           confirm it on Wowhead

A list section is the run of entries below one comment block. Sections whose comment
says "order doesn't matter" are not order-checked. Amounts come from the item's spell
data. Flat amounts and percentages are compared separately; amounts that scale with the
player's level (all Retail potions and bandages, old food in Mists) can't be compared,
so those entries are skipped.

usage: wago_check.py [--flavor NAME ...] [--no-order] [--dump] [--verbose] [--cache DIR]
  --flavor   only check these flavors (retail classic tbc wrath cata mists forever)
  --no-order skip the ordering check (needs only the small item tables)
  --dump     print the amount of every list entry, to place a new item correctly
  --verbose  also list names that differ only because the item was renamed in a client
  --cache    download directory (default: $AUTOPOTION_WAGO_CACHE or <tmp>/autopotion-wago)

Exits 1 when it prints an ERROR or ORDER line.
"""
import argparse
import csv
import json
import os
import re
import sys
import tempfile
import time
import urllib.error
import urllib.request
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

csv.field_size_limit(sys.maxsize)

ROOT = Path(__file__).resolve().parents[3]
WAGO = "https://wago.tools"

# TOC line -> (flavor, file name used in Core/<Category>/<File>.lua)
TOC_FLAVORS = {
    "Interface": ("retail", "Retail"),
    "Interface-Classic": ("classic", "Classic"),
    "Interface-BCC": ("tbc", "TBC"),
    "Interface-WOTLKC": ("wrath", "Wrath"),
    "Interface-Cata": ("cata", "Cata"),
    "Interface-Mists": ("mists", "Mists"),
    "Interface-Forever": ("forever", "Forever"),
}
CATEGORIES = ["Potions", "ManaPotions", "Bandages", "Food", "Drink"]
MANA_CATEGORIES = {"ManaPotions", "Drink"}
ITEM_TABLES = ["ItemSparse", "Item", "ItemEffect", "ItemXItemEffect", "CraftingQuality"]
SPELL_TABLES = ["SpellEffect", "SpellMisc", "SpellDuration"]
UNORDERED = r"order (?:\w+ )*doesn't matter"  # also "order among them doesn't matter"
# Restoring auras (eating, drinking, bandages, potion HoTs) last this long at most; longer
# ones are buffs like "restores 6 health every 5 sec for 10 min", not the restore itself.
MAX_RESTORE_MS = 120000

DEF_RE = re.compile(r'^ham\.(\w+)\s*=\s*ham\.Item\.new\((\d+),\s*"((?:[^"\\]|\\.)*)"')
ENTRY_RE = re.compile(r'ham\.(\w+),?\s*(--.*)?')
FUNC_RE = re.compile(r'function\s+(ham\.\w+)')


# ---- addon side ---------------------------------------------------------------------

def read_toc():
    versions = {}
    for line in (ROOT / "AutoPotion.toc").read_text(encoding="utf-8").splitlines():
        m = re.match(r'##\s*(Interface(?:-\w+)?)\s*:\s*(.+)', line)
        if m and m.group(1) in TOC_FLAVORS:
            nums = [int(x) for x in re.findall(r'\d+', m.group(2))]
            versions[TOC_FLAVORS[m.group(1)][0]] = [f"{n // 10000}.{n // 100 % 100}.{n % 100}" for n in nums]
    return versions


def read_definitions():
    defs = {}
    for path in sorted((ROOT / "Core").glob("*.lua")):
        for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            m = DEF_RE.match(line)
            if m:
                defs[m.group(1)] = dict(var=m.group(1), id=int(m.group(2)), name=m.group(3).replace('\\"', '"'),
                                        where=f"{path.relative_to(ROOT)}:{n}")
    return defs


def read_sections(path, defs):
    """Split a priority list file into sections: [(function, heading, [(line, var)])]."""
    sections, entries, heading, func, comment = [], [], "", "", []

    def close():
        nonlocal entries
        if entries:
            sections.append((func, heading, entries))
            entries = []

    for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        s = line.strip()
        m = FUNC_RE.search(s)
        if m:
            close()
            func, heading, comment = m.group(1), "", []
            continue
        if s.startswith("--") and not s.startswith("---@"):
            close()
            comment.append(s.lstrip("- "))
            heading = " ".join(comment)
            continue
        comment = []
        m = ENTRY_RE.fullmatch(s)
        if m and m.group(1) in defs:
            entries.append((n, m.group(1)))
        elif s:
            close()
    close()
    return sections


def read_lists(defs, files):
    """{flavor: {category: [sections]}}"""
    lists = defaultdict(dict)
    for flavor, fname in files.items():
        for cat in CATEGORIES:
            path = ROOT / "Core" / cat / f"{fname}.lua"
            if path.exists():
                lists[flavor][cat] = read_sections(path, defs)
    return lists


# ---- wago side ----------------------------------------------------------------------

def fetch(url, dest):
    dest.parent.mkdir(parents=True, exist_ok=True)
    tmp = dest.with_suffix(".part")
    for attempt in range(3):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "AutoPotion wago_check"})
            with urllib.request.urlopen(req, timeout=600) as r, open(tmp, "wb") as f:
                while chunk := r.read(1 << 20):
                    f.write(chunk)
            tmp.replace(dest)
            return
        except urllib.error.HTTPError as e:
            if e.code in (400, 404):  # the table doesn't exist in this client (e.g. CraftingQuality in Classic)
                dest.write_bytes(b"")
                return
            if attempt == 2:
                raise SystemExit(f"download failed: {url}: {e}")
            time.sleep(2)
        except OSError as e:
            if attempt == 2:
                raise SystemExit(f"download failed: {url}: {e}")
            time.sleep(2)


def resolve_builds(cache, versions):
    """Newest client build for every TOC version: {flavor: [build, ...]}."""
    builds_file = cache / "builds.json"
    if not builds_file.exists() or time.time() - builds_file.stat().st_mtime > 6 * 3600:
        fetch(f"{WAGO}/api/builds", builds_file)
    known = [b for product in json.loads(builds_file.read_text()).values() for b in product]
    result = {}
    for flavor, vers in versions.items():
        result[flavor] = []
        for v in vers:
            matches = [b for b in known if b["version"].startswith(v + ".")]
            if not matches:
                print(f"NOTE     [{flavor}] no client build {v} on wago.tools yet, skipped")
                continue
            newest = max(matches, key=lambda b: int(b["version"].rsplit(".", 1)[1]))["version"]
            if newest not in result[flavor]:
                result[flavor].append(newest)
    return result


def download_tables(cache, builds, tables):
    jobs = [(b, t) for bs in builds.values() for b in bs for t in tables
            if not (cache / b / f"{t}.csv").exists()]
    if jobs:
        print(f"downloading {len(jobs)} tables from wago.tools (cached in {cache}) ...", file=sys.stderr)
    with ThreadPoolExecutor(6) as pool:
        list(pool.map(lambda j: fetch(f"{WAGO}/db2/{j[1]}/csv?build={j[0]}", cache / j[0] / f"{j[1]}.csv"), jobs))


def rows(cache, build, table):
    path = cache / build / f"{table}.csv"
    if not path.exists() or path.stat().st_size == 0:
        return
    with open(path, encoding="utf-8", newline="") as f:
        yield from csv.DictReader(f)


def num(x):
    try:
        return float(x)
    except (TypeError, ValueError):
        return 0.0


class Client:
    """The data of one client build, limited to the items the addon defines."""

    def __init__(self, cache, build, item_ids, with_spells):
        self.build = build
        self.sparse = {int(r["ID"]): r for r in rows(cache, build, "ItemSparse") if int(r["ID"]) in item_ids}
        self.item = {int(r["ID"]): r for r in rows(cache, build, "Item") if int(r["ID"]) in item_ids}
        self.quality_tier = {r["ID"]: int(r["QualityTier"]) for r in rows(cache, build, "CraftingQuality")}
        self.item_spells = defaultdict(list)
        effects = list(rows(cache, build, "ItemEffect"))
        if effects and "ParentItemID" in effects[0]:
            links = ((int(e["ParentItemID"]), e) for e in effects)
        else:  # newer clients link items to effects through ItemXItemEffect
            by_id = {e["ID"]: e for e in effects}
            links = ((int(r["ItemID"]), by_id.get(r["ItemEffectID"])) for r in rows(cache, build, "ItemXItemEffect"))
        for item_id, e in links:
            if e and item_id in item_ids and e["TriggerType"] == "0":  # 0 = on use
                self.item_spells[item_id].append(int(e["SpellID"]))
        if with_spells:
            self._load_spells(cache)

    def _load_spells(self, cache):
        # spell effects, following triggered spells two levels deep
        self.effects = defaultdict(list)
        wanted = {s for spells in self.item_spells.values() for s in spells}
        loaded = set()
        for _ in range(3):
            todo = wanted - loaded
            if not todo:
                break
            for r in rows(cache, self.build, "SpellEffect"):
                sid = int(r["SpellID"])
                if sid in todo and r.get("DifficultyID", "0") == "0":
                    self.effects[sid].append(r)
            loaded |= todo
            wanted |= {int(num(r["EffectTriggerSpell"])) for s in todo for r in self.effects[s]
                       if r["Effect"] in ("64", "140") and num(r["EffectTriggerSpell"]) > 0}
        durations = {r["ID"]: num(r["Duration"]) for r in rows(cache, self.build, "SpellDuration")}
        self.duration = {int(r["SpellID"]): durations.get(r["DurationIndex"], 0)
                         for r in rows(cache, self.build, "SpellMisc")
                         if int(r["SpellID"]) in loaded and r.get("DifficultyID", "0") == "0"}

    def name(self, item_id):
        r = self.sparse.get(item_id)
        return r["Display_lang"] if r else None

    def amounts(self, item_id):
        """Health/mana restored: {'hp', 'hp%', 'mp', 'mp%'} (flat amounts and percentages), plus
        'scaled' when an amount depends on the player's level and can't be compared."""
        total = defaultdict(float)
        for spell in self.item_spells.get(item_id, []):
            self._spell_amounts(spell, total, 0)
        return total

    def _spell_amounts(self, spell, total, depth):
        effects = self.effects.get(spell, [])
        auras = {e["EffectAura"] for e in effects if e["Effect"] == "6"}
        dur = self.duration.get(spell, 0)
        short = 0 < dur <= MAX_RESTORE_MS
        # Cata and later carry the per-5-sec amount on a PERIODIC_DUMMY aura next to the
        # MOD_REGEN/MOD_POWER_REGEN aura; then the regen aura's own value is not the amount.
        dummy_aura = None
        if any(e["Effect"] == "6" and e["EffectAura"] == "226"
               and (num(e.get("EffectBasePoints")) or num(e.get("EffectBasePointsF"))) > 0 for e in effects):
            dummy_aura = "85" if "85" in auras else "84" if "84" in auras else None
        for e in effects:
            eff, aura = e["Effect"], e["EffectAura"]
            mana = num(e.get("EffectMiscValue_0")) == 0  # power type 0 = mana
            base = num(e.get("EffectBasePoints")) or num(e.get("EffectBasePointsF"))
            die = num(e.get("EffectDieSides"))
            val = base + ((die + 1) / 2 if die > 1 else die)  # classic clients roll base + 1..die
            period = num(e["EffectAuraPeriod"])
            ticks = dur / period if period > 0 and dur > 0 else 0
            key, amount = None, 0
            if eff == "10":                        # HEAL
                key, amount = "hp", val
            elif eff == "136":                     # HEAL_PCT
                key, amount = "hp%", val
            elif eff == "30" and mana:             # ENERGIZE
                key, amount = "mp", val
            elif eff == "137" and mana:            # ENERGIZE_PCT
                key, amount = "mp%", val
            elif eff == "6" and short:
                if aura == "8":                    # PERIODIC_HEAL
                    key, amount = "hp", val * ticks
                elif aura == "20":                 # OBS_MOD_HEALTH (percent per tick)
                    key, amount = "hp%", val * ticks
                elif aura == "21" and mana:        # OBS_MOD_POWER (percent per tick)
                    key, amount = "mp%", val * ticks
                elif aura == "24" and mana:        # PERIODIC_ENERGIZE
                    key, amount = "mp", val * ticks
                elif aura == "84" and dummy_aura != "84":  # MOD_REGEN: health per 5 sec while eating
                    key, amount = "hp", val * dur / 5000
                elif aura == "85" and mana and dummy_aura != "85":  # MOD_POWER_REGEN: mana per 5 sec
                    key, amount = "mp", val * dur / 5000
                elif aura == "226" and val > 0 and dummy_aura:  # PERIODIC_DUMMY with the amount
                    key, amount = "mp" if dummy_aura == "85" else "hp", val * dur / 5000
            if key:
                # a base of 0/1 with a scaling coefficient is a placeholder: the game computes the
                # amount from the player's level instead (Retail potions, old food in Mists)
                if base <= 1 and num(e.get("Coefficient")) > 0:
                    total["scaled"] += 1
                else:
                    total[key] += amount
            if eff in ("64", "140") and depth < 2 and num(e["EffectTriggerSpell"]) > 0:
                self._spell_amounts(int(num(e["EffectTriggerSpell"])), total, depth + 1)


# ---- checks -------------------------------------------------------------------------

def norm(s):
    return (s or "").replace("’", "'").replace("“", '"').replace("”", '"').strip().lower()


def base_name(name):
    """A Fleeting potion does what the normal one of the same quality does; it just expires."""
    return re.sub(r"^fleeting ", "", norm(name))


def rank_of(var):
    m = re.search(r'R?(\d)$', var)
    return int(m.group(1)) if m else None


def sort_value(cat, amounts):
    """(kind, value) used to compare two entries; kind None means not comparable."""
    flat, pct = ("mp", "mp%") if cat in MANA_CATEGORIES else ("hp", "hp%")
    if amounts["scaled"]:
        return None, 0
    if amounts[flat] > 1:
        return "flat", round(amounts[flat], 1)
    if amounts[pct] > 0:
        return "pct", round(amounts[pct], 1)
    return None, 0


def misplaced(values):
    """Indices outside the longest non-increasing subsequence: the fewest entries to move."""
    n = len(values)
    best, prev = [1] * n, [-1] * n
    for i in range(n):
        for j in range(i):
            if values[j] >= values[i] and best[j] + 1 > best[i]:
                best[i], prev[i] = best[j] + 1, j
    keep = set()
    i = max(range(n), key=lambda k: best[k]) if n else -1
    while i != -1:
        keep.add(i)
        i = prev[i]
    return [i for i in range(n) if i not in keep]


def unit(cat, kind):
    what = "mana" if cat in MANA_CATEGORIES else "health"
    return f"% {what}" if kind == "pct" else f" {what}"


def check_order(flavor, cat, fname, sections, defs, client, dump, out):
    path = f"Core/{cat}/{fname}.lua"
    for func, heading, entries in sections:
        info = []
        for line, var in entries:
            d = defs[var]
            amounts = client.amounts(d["id"])
            kind, value = sort_value(cat, amounts)
            cq = (client.item.get(d["id"]) or {}).get("CraftingQualityID") or "0"
            info.append(dict(line=line, var=var, id=d["id"], kind=kind, value=value, amounts=amounts,
                             name=base_name(client.name(d["id"]) or d["name"]), tier=client.quality_tier.get(cq, 0)))
        if dump:
            print(f"\n[{flavor}] {path} {func}: {heading or '(no comment)'}")
            for e in info:
                a = e["amounts"]
                shown = "  ".join(f"{k}={a[k]:g}" for k in ("hp", "hp%", "mp", "mp%", "scaled") if a[k])
                print(f"  {path}:{e['line']:<4} {e['var']:<40} {e['id']:<7} {shown or '-'}")
        if re.search(UNORDERED, heading, re.I):
            continue
        for kind in ("flat", "pct"):
            group = [e for e in info if e["kind"] == kind]
            for i in misplaced([e["value"] for e in group]):
                e = group[i]
                lower = next((p for p in reversed(group[:i]) if p["value"] < e["value"]), None)
                if lower:
                    why = f"listed below {lower['var']} ({lower['value']:g}{unit(cat, kind)})"
                else:
                    higher = next((p for p in group[i + 1:] if p["value"] > e["value"]), e)
                    why = f"listed above {higher['var']} ({higher['value']:g}{unit(cat, kind)})"
                out.append(f"ORDER    [{flavor}] {path}:{e['line']} {e['var']} ({e['id']}) restores "
                           f"{e['value']:g}{unit(cat, kind)} but is {why}")
        for i, e in enumerate(info):
            for later in info[i + 1:]:
                if e["tier"] and later["tier"] > e["tier"] and later["name"] == e["name"]:
                    out.append(f"ORDER    [{flavor}] {path}:{e['line']} {e['var']} (quality {e['tier']}) is listed "
                               f"above {later['var']} (quality {later['tier']}) of the same item")


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--flavor", nargs="*")
    ap.add_argument("--no-order", action="store_true")
    ap.add_argument("--dump", action="store_true")
    ap.add_argument("--verbose", action="store_true")
    ap.add_argument("--cache", type=Path, default=Path(os.environ.get("AUTOPOTION_WAGO_CACHE")
                                                      or Path(tempfile.gettempdir()) / "autopotion-wago"))
    args = ap.parse_args()

    toc = read_toc()
    versions = toc
    if args.flavor:
        unknown = set(args.flavor) - set(versions)
        if unknown:
            raise SystemExit(f"unknown flavor: {', '.join(sorted(unknown))} (have: {', '.join(versions)})")
        versions = {f: v for f, v in versions.items() if f in args.flavor}
    files = {fl: fname for fl, fname in TOC_FLAVORS.values() if fl in versions}
    defs = read_definitions()
    lists = read_lists(defs, files)
    item_ids = {d["id"] for d in defs.values()}

    builds = resolve_builds(args.cache, versions)
    download_tables(args.cache, builds, ITEM_TABLES + ([] if args.no_order else SPELL_TABLES))
    clients = {fl: [Client(args.cache, b, item_ids, with_spells=not args.no_order and b == bs[-1]) for b in bs]
               for fl, bs in builds.items()}
    for fl, cs in clients.items():
        print(f"{fl:<8} {', '.join(c.build for c in cs) or '-'}", file=sys.stderr)

    out = []
    # names: an ID whose name matches no client points to another item. Items get renamed
    # between clients, so this is only conclusive when every client is loaded.
    partial = set(versions) != set(toc)
    listed = {var for cats in lists.values() for sections in cats.values() for _, _, entries in sections
              for _, var in entries}
    for d in defs.values():
        if partial and d["var"] not in listed:
            continue
        names = {c.name(d["id"]) for cs in clients.values() for c in cs} - {None}
        if names and not any(norm(n) == norm(d["name"]) for n in names):
            level = "NOTE    " if partial else "ERROR   "
            out.append(f"{level} {d['where']} {d['var']} ({d['id']}) is \"{d['name']}\" in the addon but "
                       f"{' / '.join(sorted(names))} in the game" + (" (run without --flavor to confirm)"
                                                                       if partial else ""))
    for fl, cats in lists.items():
        cs = clients.get(fl) or []
        if not cs:
            continue
        seen = set()
        for cat, sections in cats.items():
            for func, heading, entries in sections:
                for line, var in entries:
                    d = defs[var]
                    where = f"Core/{cat}/{files[fl]}.lua:{line}"
                    if (var, cat) in seen:
                        continue
                    seen.add((var, cat))
                    sparse = next((c.sparse[d["id"]] for c in cs if d["id"] in c.sparse), None)
                    item = next((c.item[d["id"]] for c in cs if d["id"] in c.item), None)
                    if not sparse:
                        # wago's exports lack rows that are encrypted or only delivered by hotfix,
                        # so an Item row or an on-use effect still means the item exists
                        if item or any(d["id"] in c.item_spells for c in cs):
                            out.append(f"NOTE     [{fl}] {where} {var} ({d['id']}) is only partly in wago's data "
                                       f"(encrypted or hotfix item?), check it on Wowhead")
                        else:
                            out.append(f"ERROR    [{fl}] {where} {var} ({d['id']}) \"{d['name']}\" does not "
                                       f"exist in this client")
                        continue
                    if sparse["Display_lang"].upper().startswith("UNUSED"):
                        out.append(f"ERROR    [{fl}] {where} {var} ({d['id']}) is \"{sparse['Display_lang']}\" "
                                   f"in this client")
                        continue
                    if args.verbose and norm(sparse["Display_lang"]) != norm(d["name"]):
                        out.append(f"NOTE     [{fl}] {where} {var} ({d['id']}) is called "
                                   f"\"{sparse['Display_lang']}\" in this client")
                    if item and item["ClassID"] != "0":
                        out.append(f"ERROR    [{fl}] {where} {var} ({d['id']}) is not a consumable "
                                   f"(item class {item['ClassID']}/{item['SubclassID']})")
                    cq = (item or {}).get("CraftingQualityID") or "0"
                    tier = next((c.quality_tier[cq] for c in cs if cq in c.quality_tier), 0)
                    rank = rank_of(var)
                    if tier and rank and rank != tier:
                        out.append(f"ERROR    [{fl}] {where} {var} ({d['id']}) has crafting quality {tier}, "
                                   f"not {rank}")
        if not args.no_order:
            for cat, sections in cats.items():
                check_order(fl, cat, files[fl], sections, defs, cs[-1], args.dump, out)

    for line in out:
        print(line)
    failed = sum(1 for line in out if line.startswith(("ERROR", "ORDER")))
    print(f"{failed} problem(s) found" if failed else "ok", file=sys.stderr)
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
