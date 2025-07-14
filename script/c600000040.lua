-- c600000040.lua
local s,id=GetID()
function s.initial_effect(c)
    -- Fusion summoning procedure: material 1 with code 600000002 and 1 Warrior monster
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,600000002,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR))
end

return s
