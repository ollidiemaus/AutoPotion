#!/usr/bin/env bash
# Writes each flavor's valid events (every LiteralName in its Blizzard_APIDocumentationGenerated)
# to tests/fake/events/<flavor>.txt, from the UI source the wow-data skill checks out. Run it when
# a patch adds or removes events (the update-addon skill runs it with each patch update).
set -euo pipefail
cd "$(dirname "$0")"
wow=~/.claude/skills/wow-data/scripts/wow.py
for flavor in retail classic forever; do
  source=$(python3 "$wow" ui -f "$flavor" | tail -1)
  docs="$(cut -f1 <<<"$source")/Interface/AddOns/Blizzard_APIDocumentationGenerated"
  {
    echo "# $(cut -f2- <<<"$source" | tr '\t' ' ')"
    grep -rhoE 'LiteralName = "[A-Z0-9_]+"' "$docs" | cut -d'"' -f2 | LC_ALL=C sort -u
  } >"$flavor.txt"
done
