-- Amico delle Guardie
local s,id=GetID()

function s.initial_effect(c)
    -- Annulla una o più Evocazioni Speciali
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_SPSUMMON)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Mostro "Mafioso" scoperto
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x2222)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return tp~=ep
        and Duel.IsExistingMatchingCard(
            s.cfilter,
            tp,
            LOCATION_MZONE,
            0,
            1,
            nil
        )
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return eg
            and #eg>0
            and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
    end

    Duel.SetOperationInfo(
        0,
        CATEGORY_DISABLE_SUMMON,
        eg,
        #eg,
        0,
        0
    )

    Duel.SetOperationInfo(
        0,
        CATEGORY_DESTROY,
        eg,
        #eg,
        0,
        0
    )
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateSummon(eg) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end