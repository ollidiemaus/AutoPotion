# Buff food records its buff kinds; the addon doesn't read them from tooltips

The player picks which buff kinds of buff food they want eaten (Attack Power, Fishing, ...). Each
buff food and drink item records its kinds in its definition, filled in once from the client
data's Well Fed aura and checked by `wago_check.py` like IDs, names and restore amounts (ADR 0001).
A flavor whose buff differs for an item (Forever reworked old fish into Nutritious food) gets a
table of its own under that flavor, as restore amounts do.

Reading the buff from the item's tooltip at runtime would need no data, but tooltip text depends
on the game's language (21 locales) and isn't always loaded when the macro is built, so the same
item could change kind or drop out between two rebuilds. The cost is a kind to fill in for every
buff food item, roughly 430 today, and for every new one.
