#!/usr/bin/env bash
# Runs AutoPotion's headless test suite: the addon loaded into a fake WoW client (tests/fake) on
# Retail, Classic Era and Forever. Exits non-zero when a test fails. Run from anywhere; pass test
# files (tests/login_test.lua) to run only those.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

# The game runs Lua 5.1; LuaJIT is a 5.1 interpreter, the default lua (5.4/5.5) isn't.
if ! command -v luajit >/dev/null; then
  echo "LuaJIT not found. The tests need Lua 5.1 like the game: brew install luajit" >&2
  exit 1
fi

exec luajit tests/run.lua "$@"
