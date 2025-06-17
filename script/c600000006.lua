-- Occhiali di falcone
function c600000006.initial_effect(c)
    -- Può essere equipaggiata a qualsiasi mostro sul terreno
    aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsFaceup))
    -- Aggiungi l'archetipo 0x1111 al mostro equipaggiato
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_ADD_SETCODE)
    e1:SetValue(0x1111)
    c:RegisterEffect(e1)
end