-- c600000032.lua
-- Carta Magia Rapida: "Doppio Impatto"
-- Scegli come bersaglio un mostro sul terreno. Raddoppia il suo ATK
-- fino alla fine del turno. Se entro la fine del turno quel mostro non ha
-- distrutto un mostro, distruggilo.

function c600000032.initial_effect(c)
    -- Activate effect
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E)
    e1:SetTarget(c600000032.target)
    e1:SetOperation(c600000032.activate)
    c:RegisterEffect(e1)
end

function c600000032.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then 
        return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup()
    end
    if chk == 0 then 
        return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_ATKCHANGE, g, 1, 0, 0)
end

function c600000032.activate(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local current_atk = tc:GetAttack()
        -- Double the attack until end of turn.
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(current_atk * 2)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(e1)
        
        -- Register a flag if this monster destroys an opponent's monster in battle.
        local eflag = Effect.CreateEffect(e:GetHandler())
        eflag:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
        eflag:SetCode(EVENT_BATTLE_DESTROYING)
        eflag:SetOperation(c600000032.addflag)
        eflag:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(eflag)
        
        -- At end of turn, check if the monster destroyed a monster.
        local e2 = Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_PHASE + PHASE_END)
        e2:SetCountLimit(1)
        e2:SetLabelObject(tc)
        e2:SetCondition(c600000032.descon)
        e2:SetOperation(c600000032.desop)
        Duel.RegisterEffect(e2, tp)
    end
end

function c600000032.addflag(e, tp, eg, ep, ev, re, r, rp)
    e:GetHandler():RegisterFlagEffect(600000032, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
end

function c600000032.descon(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    return tc and tc:IsOnField() and tc:IsFaceup() and tc:GetFlagEffect(600000032) == 0
end

function c600000032.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    if tc and tc:IsOnField() and tc:IsFaceup() then
        Duel.Destroy(tc, REASON_EFFECT)
    end
end