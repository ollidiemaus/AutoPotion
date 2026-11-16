# Food and drink record their restore amounts; the lists don't group by strength

Weakest food first and Weakest drink first rank food and drink by what they restore. Unlike the
potion lists, which carry strength as `{ }` groups that `ham.potionPriority` flattens either way,
each food and drink item records the health and mana it restores (a flat total, or a share of
maximum health or mana, as on Retail), and the setting sorts a copy of the normal priority by that
amount, keeping the normal order on ties and putting items that can't be compared with the rest
last.

Groups didn't fit: the normal order puts dual-restore food ahead of all plain food in its section
and Forever's Restorative Bread right after conjured food, whatever their strength, and that order
stays. Weakest first mixes dual-restore food in among plain food by strength. One grouped list
can't give both orders, while amounts serve both and let `wago_check.py` check them against client
data like IDs and names. The cost is an amount to fill in for every food and drink item.
