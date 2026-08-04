-- c600000040.lua
local s,id=GetID()

function s.initial_effect(c)
    aux.AddFusionProcMix(
        c,
        false,
        true,
        aux.FilterBoolFunction(Card.IsCode,60000002),
        aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR)
    )
    c:EnableReviveLimit()
end