local s,id=GetID()
function s.initial_effect(c)
    -- Activate this trap card
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    -- Continuous effect: The player who controls more monsters cannot attack
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(s.atktg)
    c:RegisterEffect(e2)
end

function s.atktg(e,c)
    local tp=c:GetControler()
    local ct1=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
    local ct2=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
    if ct1>ct2 then
        return c:IsControler(tp)
    end
    return false
end