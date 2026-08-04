-- Card 600000038
local s,id=GetID()

function s.initial_effect(c)
    -- Evocazione Speciale dalla mano
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Aggiunge 600000018 quando viene Evocata Normalmente
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,id+100)
    e2:SetTarget(s.thtg1)
    e2:SetOperation(s.thop1)
    c:RegisterEffect(e2)

    -- Aggiunge 600000033 quando viene Evocata Specialmente
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,id+100)
    e3:SetTarget(s.thtg2)
    e3:SetOperation(s.thop2)
    c:RegisterEffect(e3)
end

s.listed_names={60000018,60000033}

------------------------------------------------------------
-- Evocazione Speciale dalla mano
------------------------------------------------------------

-- Carta 600000018 scoperta in una Zona Terreno
function s.fieldfilter(c)
    return c:IsFaceup() and c:IsCode(60000018)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(
        s.fieldfilter,
        tp,
        LOCATION_FZONE,
        LOCATION_FZONE,
        1,
        nil
    )
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()

    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(
                e,
                0,
                tp,
                false,
                false
            )
    end

    Duel.SetOperationInfo(
        0,
        CATEGORY_SPECIAL_SUMMON,
        c,
        1,
        0,
        0
    )
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    if not c:IsRelateToEffect(e) then
        return
    end

    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
        return
    end

    Duel.SpecialSummon(
        c,
        0,
        tp,
        tp,
        false,
        false,
        POS_FACEUP
    )
end

------------------------------------------------------------
-- Ricerca dopo Evocazione Normale
------------------------------------------------------------

function s.thfilter1(c)
    return c:IsCode(60000018)
        and c:IsAbleToHand()
end

function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.thfilter1,
            tp,
            LOCATION_DECK,
            0,
            1,
            nil
        )
    end

    Duel.SetOperationInfo(
        0,
        CATEGORY_TOHAND,
        nil,
        1,
        tp,
        LOCATION_DECK
    )
end

function s.thop1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

    local g=Duel.SelectMatchingCard(
        tp,
        s.thfilter1,
        tp,
        LOCATION_DECK,
        0,
        1,
        1,
        nil
    )

    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

------------------------------------------------------------
-- Ricerca dopo Evocazione Speciale
------------------------------------------------------------

function s.thfilter2(c)
    return c:IsCode(60000033)
        and c:IsAbleToHand()
end

function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.thfilter2,
            tp,
            LOCATION_DECK,
            0,
            1,
            nil
        )
    end

    Duel.SetOperationInfo(
        0,
        CATEGORY_TOHAND,
        nil,
        1,
        tp,
        LOCATION_DECK
    )
end

function s.thop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

    local g=Duel.SelectMatchingCard(
        tp,
        s.thfilter2,
        tp,
        LOCATION_DECK,
        0,
        1,
        1,
        nil
    )

    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end