-- Banda di Molestatori
-- 2 Mostri di livello 3 "TSO Obbligatorio"
-- I mostri controllati dal tuo avversario non possono scegliere come bersaglio mostri "TSO Obbligatorio" scoperti, per gli attacchi, eccetto questo. 
-- Puoi staccare 1 Materiale Xyz da questa carta, poi scegliere come bersaglio 1 carta Posizionata controllata dal tuo avversario; distruggi quel bersaglio. 
-- Puoi utilizzare questo effetto di "Banda di Molestatori" una sola volta per turno. 
-- Se questa carta viene mandata al Cimitero: puoi scegliere come bersaglio 1 altra carta "TSO Obbligatorio" nel tuo Cimitero; aggiungi quel bersaglio alla tua mano.

-- Banda di Molestatori
-- 2 mostri di Livello 3 "TSO Obbligatorio"

local s,id=GetID()

function s.initial_effect(c)
    -- Evocazione Xyz
    aux.AddXyzProcedure(
        c,
        aux.FilterBoolFunction(Card.IsSetCard,0x1111),
        3,
        2
    )
    c:EnableReviveLimit()

    -- Gli altri mostri "TSO Obbligatorio" non possono
    -- essere scelti come bersagli degli attacchi
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetValue(s.battg)
    c:RegisterEffect(e1)

    -- Stacca 1 Materiale Xyz; distruggi 1 carta Posizionata
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.descost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- Se viene mandata al Cimitero:
    -- recupera 1 altra carta "TSO Obbligatorio"
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

s.listed_series={0x1111}

------------------------------------------------------------
-- Protezione dagli attacchi
------------------------------------------------------------

function s.battg(e,c)
    return c~=e:GetHandler()
        and c:IsFaceup()
        and c:IsSetCard(0x1111)
end

------------------------------------------------------------
-- Distruzione
------------------------------------------------------------

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return e:GetHandler():CheckRemoveOverlayCard(
            tp,
            1,
            REASON_COST
        )
    end

    e:GetHandler():RemoveOverlayCard(
        tp,
        1,
        1,
        REASON_COST
    )
end

function s.desfilter(c)
    return c:IsFacedown()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsOnField()
            and chkc:IsControler(1-tp)
            and s.desfilter(chkc)
    end

    if chk==0 then
        return Duel.IsExistingTarget(
            s.desfilter,
            tp,
            0,
            LOCATION_ONFIELD,
            1,
            nil
        )
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)

    local g=Duel.SelectTarget(
        tp,
        s.desfilter,
        tp,
        0,
        LOCATION_ONFIELD,
        1,
        1,
        nil
    )

    Duel.SetOperationInfo(
        0,
        CATEGORY_DESTROY,
        g,
        1,
        0,
        0
    )
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()

    if tc
        and tc:IsRelateToEffect(e)
        and tc:IsFacedown() then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

------------------------------------------------------------
-- Recupero dal Cimitero
------------------------------------------------------------

function s.thfilter(c)
    return c:IsSetCard(0x1111)
        and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_GRAVE)
            and chkc:IsControler(tp)
            and chkc~=e:GetHandler()
            and s.thfilter(chkc)
    end

    if chk==0 then
        return Duel.IsExistingTarget(
            s.thfilter,
            tp,
            LOCATION_GRAVE,
            0,
            1,
            e:GetHandler()
        )
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)

    local g=Duel.SelectTarget(
        tp,
        s.thfilter,
        tp,
        LOCATION_GRAVE,
        0,
        1,
        1,
        e:GetHandler()
    )

    Duel.SetOperationInfo(
        0,
        CATEGORY_TOHAND,
        g,
        1,
        0,
        0
    )
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()

    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end