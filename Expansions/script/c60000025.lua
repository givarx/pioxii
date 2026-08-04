local s,id=GetID()

function s.initial_effect(c)
    -- Evocazione Normale
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetTarget(s.lvtg)
    e1:SetOperation(s.lvop)
    c:RegisterEffect(e1)

    -- Evocazione Speciale
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end

function s.filter(c)
    return c:IsAbleToRemove()
        and c:IsSetCard(
            0x4444,0x1112,0x1113
        )
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.filter,
            tp,
            LOCATION_HAND,
            0,
            1,
            nil
        )
    end

    Duel.SetOperationInfo(
        0,
        CATEGORY_REMOVE,
        nil,
        1,
        tp,
        LOCATION_HAND
    )
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    if not c:IsRelateToEffect(e) or not c:IsFaceup() then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)

    local g=Duel.SelectMatchingCard(
        tp,
        s.filter,
        tp,
        LOCATION_HAND,
        0,
        1,
        1,
        nil
    )

    if #g==0
        or Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==0 then
        return
    end

    local lv=Duel.AnnounceNumber(tp,2,3,4,5,6)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_LEVEL)
    e1:SetValue(lv)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
end