# AutoPotion

An addon that keeps the player's macros pointed at the best consumable in their bags, one macro
per category (potions and heals, bandages, food, drink, mana potions).

## Language

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
