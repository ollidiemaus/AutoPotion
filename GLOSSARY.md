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
The aura that buff food leaves on the player, whatever its strength or source. A weaker or older
one still counts. Forever's Nutritious drinks leave it too.
_Avoid_: Well Fed (only one of its names)

**Relaxed**:
The buff that Retail's buff drinks leave. It is separate from the food buff: having one says
nothing about the other.
_Avoid_: Drink buff, Well Fed

**Nutritious food**:
Forever's buff food: it restores what plain food of its level does, and leaves the food buff after
10 seconds of eating. Its drinks work the same way.
_Avoid_: Well Fed food, stat food

**Conjured food**:
Free food a mage creates. It goes first in the food priority unless buff food is preferred.

### Potion priority

**Potion priority**:
The order in which a macro picks one potion from the bags: the strongest first. All potions share
one cooldown, so a macro holds only one of them. A potion that expires (Fleeting, Perishable) goes
before the plain one of the same strength, and a zone-locked item goes before all others where it
works.
_Avoid_: Potion list, pot order

**Weakest potion first**:
A setting that turns the potion priority around for health potions: the weakest potion in the
bags first, for leveling, when a big heal matters less than saving the good potions. Only the
strength order turns around: within one strength the usual order stays (an expiring potion before
the plain one, a plain mana potion before a rejuvenation potion), and zone-locked items still go
first. Its twin, Weakest mana potion first, does the same for mana potions. Healthstones and mana
gems keep their order: the best one first.
_Avoid_: Reverse order, leveling mode, lowest potion first

### Mana potions

**Mana gem**:
An item a mage conjures that restores mana at once, like Mana Ruby or Retail's Mana Gem. All mana
gems share one cooldown, apart from the mana potions' one, so AutoManaPotion uses the best one
first and the mana potion on the next press.
_Avoid_: Mana stone, gem (also means socket gems)

### Bandages

**Bandage**:
A bandage item: a channeled first-aid heal that leaves the Recently Bandaged debuff.
_Avoid_: Using it for spells that heal like one

**Bandage spell**:
A free, channeled self-heal that taking damage cancels, so it plays the part of a bandage and the
AutoBandage macro uses it alongside bandages. Today only Rapid Regeneration, the Forever Troll
racial.
_Avoid_: Bandage, heal spell

### Availability

**Zone-locked item**:
A consumable the game only lets the player use in one place, like Windstone on Zephras Isle or a
battleground's draughts. A macro only uses it there, and there it goes first.
_Avoid_: Zone item, area item
