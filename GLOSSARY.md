# AutoPotion

An addon that keeps the player's macros pointed at the best consumable in their bags, one macro
per category (potions and heals, bandages, food, drink, mana potions).

## Language

### Cast sequence

**First entry**:
What a macro's sequence starts with, a spell or an item. A sequence reset always goes back to it.
_Avoid_: First spell, top of the sequence

**Sequence reset**:
The macro's sequence starting over at its first entry: when combat starts or ends, or when the
reset timer runs out.
_Avoid_: Reset (also means Reset to Default), macro reset

**Reset timer**:
The number of seconds without a press of the macro after which a sequence reset happens.
_Avoid_: Reset, cooldown reset, reset condition

**Cooldown talent**:
A talent that takes a fixed number of seconds off the cooldown of one of the addon's spells, like
Angel's Mercy for Desperate Prayer. Talents that shorten a cooldown while it runs are not ones.
_Avoid_: Talent modifier, CD reduction

### Food and drink

**Buff food**:
A food or drink whose main value is the stat buff it leaves after eating, not what it restores.
Covers Retail's "Relaxed" drinks too.
_Avoid_: Stat food, Well Fed food

**Food buff**:
The aura that eating buff food (not drinking) leaves on the player, whatever its strength or
source. A weaker or older one still counts.
_Avoid_: Well Fed (only one of its names)

**Relaxed**:
The buff that Retail's buff drinks leave. It is separate from the food buff: having one says
nothing about the other.
_Avoid_: Drink buff, Well Fed

**Conjured food**:
Free food a mage creates. It goes first in the food priority unless buff food is preferred.

### Bandages

**Bandage**:
A bandage item: a channeled first-aid heal that leaves the Recently Bandaged debuff.
_Avoid_: Using it for spells that heal like one

**Bandage spell**:
A free, channeled self-heal that taking damage cancels, so it plays the part of a bandage and the
AutoBandage macro uses it alongside bandages. Today only Rapid Regeneration, the Forever Troll
racial.
_Avoid_: Bandage, heal spell
