-- c600000019.lua
-- Script per una carta che accumula e trasferisce segnalini "chemio" (coda 0xaaaa)

function c600000019.initial_effect(c)
    -- Effetto 1: All'inizio della Main Phase, aggiungi 1 segnalino chemio (una volta per turno)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_PHASE + PHASE_MAIN1)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetOperation(c600000019.add_counter)
    c:RegisterEffect(e1)

    -- Effetto 2: Una volta per turno, sposta 1 segnalino chemio da questa carta a un mostro scoperto avversario
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(600000019, 0))
    e2:SetCategory(CATEGORY_COUNTER)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(c600000019.move_target)
    e2:SetOperation(c600000019.move_operation)
    c:RegisterEffect(e2)

    -- Effetto 3: Quando un mostro lascia il terreno, infliggi 500 danni per ogni segnalino chemio che aveva
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(c600000019.damage_operation)
    c:RegisterEffect(e3)
end

-- Effetto 1: Aggiunge un segnalino chemio (0xaaaa) a questa carta
function c600000019.add_counter(e, tp, eg, ep, ev, re, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        c:AddCounter(0xaaaa, 1)
    end
end

-- Filtro per i mostri scoperti che possono ricevere un segnalino chemio
function c600000019.counter_filter(c)
    return c:IsFaceup() and c:IsCanAddCounter(0xaaaa, 1)
end

-- Effetto 2: Seleziona un mostro avversario scoperto che possa ricevere un segnalino chemio
function c600000019.move_target(e, tp, eg, ep, ev, re, rp, chk, chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c600000019.counter_filter(chkc)
    end
    if chk == 0 then
        return e:GetHandler():GetCounter(0xaaaa) > 0 and Duel.IsExistingTarget(c600000019.counter_filter, tp, 0, LOCATION_MZONE, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, c600000019.counter_filter, tp, 0, LOCATION_MZONE, 1, 1, nil)
end

-- Effetto 2: Sposta il segnalino chemio dal proprietario a quello selezionato
function c600000019.move_operation(e, tp, eg, ep, ev, re, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if c and tc and c:GetCounter(0xaaaa) > 0 and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
        c:RemoveCounter(tp, 0xaaaa, 1, REASON_EFFECT)
        tc:AddCounter(0xaaaa, 1)
    end
end

-- Effetto 3: Quando un mostro lascia il terreno, infliggi danno pari a 500 x segnalini chemio che aveva
function c600000019.damage_operation(e, tp, eg, ep, ev, re, rp)
    local tc = eg:GetFirst()
    while tc do
        local ct = tc:GetCounter(0xaaaa)
        if ct and ct > 0 then
            local p = tc:GetPreviousControler()
            Duel.Damage(p, ct * 500, REASON_EFFECT)
        end
        tc = eg:GetNext()
    end
end