#!/usr/bin/env bash
# Static sanity checks for AutoPotion. Run from anywhere; exits non-zero on hard errors.
#   1. Lua syntax of every addon .lua file (luac -p)
#   2. Every ham.<name> used in a priority list (Core/<Category>/<Flavor>.lua) is defined
#   3. Variables defined twice, and item IDs used more than once (review: often intentional)
set -uo pipefail
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)" || exit 1

status=0

echo "== Lua syntax"
if command -v luac >/dev/null; then
  while IFS= read -r f; do
    luac -p "$f" || status=1
  done < <(git ls-files '*.lua' | grep -v '^Libs/')
  [ $status -eq 0 ] && echo "ok"
else
  echo "luac not found, skipped (brew install lua)"
fi

echo "== List entries without a definition"
defined=$(grep -rhoE '^ham\.[A-Za-z0-9_]+ = ham\.(Item|Spell)\.new' Core/*.lua | sed 's/ = .*//' | sort -u)
used=$(grep -rhoE '^[[:space:]]+ham\.[A-Za-z0-9_]+,?[[:space:]]*(--.*)?$' Core/*/*.lua \
  | sed -E 's/--.*//; s/[[:space:],]//g' | sort -u)
missing=$(comm -13 <(echo "$defined") <(echo "$used"))
if [ -n "$missing" ]; then
  echo "$missing" | while read -r name; do
    grep -rnE "^[[:space:]]+${name//./\\.},?" Core/*/*.lua | sed "s/^/MISSING $name  /"
  done
  status=1
else
  echo "ok"
fi

echo "== Variables defined more than once (review)"
grep -rhoE '^ham\.[A-Za-z0-9_]+ = ham\.(Item|Spell)\.new' Core/*.lua | sed 's/ = .*//' | sort | uniq -d \
  | while read -r name; do grep -rnE "^${name//./\\.} = " Core/*.lua; done

echo "== Item IDs used more than once (review: e.g. health+mana potions live in both files)"
grep -rhoE 'Item\.new\([0-9]+' Core/*.lua | sort | uniq -d | sed 's/Item\.new(//' \
  | while read -r id; do grep -rnE "Item\.new\($id," Core/*.lua; done

exit $status
