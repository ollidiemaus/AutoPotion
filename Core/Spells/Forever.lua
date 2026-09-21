local addonName, ham = ...
if not ham.isForever then return end

-- Troll racial (new in Forever): channeled self-heal restoring ~50% of max health over ~6s,
-- canceled by taking damage, moving or acting. 3 minute cooldown.
ham.rapidRegeneration = ham.Spell.new(1260270)
table.insert(ham.supportedSpells, ham.rapidRegeneration)
