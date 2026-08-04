-- c600000032.lua
-- Carta Magia Rapida: "Doppio Impatto"
-- Scegli come bersaglio un mostro sul terreno. Raddoppia il suo ATK
-- fino alla fine del turno. Se entro la fine del turno quel mostro non ha
-- distrutto un mostro, distruggilo.

-- Carta 600000032
local s,id=GetID()

function s.initial_effect(c)
    -- Raddoppia l'ATK di 1 mostro
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_MZONE)
            and chkc:IsFaceup()
    end

    if chk==0 then
        return Duel.IsExistingTarget(
            Card.IsFaceup,
            tp,
            LOCATION_MZONE,
            LOCATION_MZONE,
            1,
            nil
        )
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)

    local g=Duel.SelectTarget(
        tp,
        Card.IsFaceup,
        tp,
        LOCATION_MZONE,
        LOCATION_MZONE,
        1,
        1,
        nil
    )

    Duel.SetOperationInfo(
        0,
        CATEGORY_ATKCHANGE,
        g,
        1,
        0,
        0
    )
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()

    if not tc
        or not tc:IsRelateToEffect(e)
        or not tc:IsFaceup() then
        return
    end

    local atk=tc:GetAttack()
    if atk<0 then
        return
    end

    -- Raddoppia l'ATK attuale fino alla End Phase
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetValue(atk*2)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    tc:RegisterEffect(e1)

    -- Registra se il mostro distrugge un mostro in battaglia
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetOperation(s.flagop)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    tc:RegisterEffect(e2)

    -- Alla End Phase, distruggilo se non ha distrutto nulla in battaglia
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PHASE|PHASE_END)
    e3:SetLabelObject(tc)
    e3:SetCondition(s.descon)
    e3:SetOperation(s.desop)
    e3:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e3,tp)
end

function s.flagop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    c:RegisterFlagEffect(
        id,
        RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,
        0,
        1
    )
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()

    return tc
        and tc:IsFaceup()
        and tc:IsLocation(LOCATION_MZONE)
        and tc:GetFlagEffect(id)==0
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()

    if tc
        and tc:IsFaceup()
        and tc:IsLocation(LOCATION_MZONE) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end