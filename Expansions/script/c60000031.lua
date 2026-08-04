-- Super santos
-- Se un Mostro con "Davide" nel nome é presente sul terreno, scarta
-- dalla tua mano un mostro di tipo Macchina dalla tua mano ed
-- evoca specialmente dalla mano o dal Deck un mostro con "Colelli"
-- nel nome.

local s,id=GetID()

function s.initial_effect(c)
    -- Se uno "Scopece" è presente sul Terreno:
    -- scarta 1 mostro Macchina; Evoca 1 "Colelli" dalla mano o Deck,
    -- poi, se l'Evocazione riesce, pesca 1 carta.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Mostro "Scopece" scoperto
function s.scopecefilter(c)
    return c:IsFaceup()
        and c:IsType(TYPE_MONSTER)
        and c:IsSetCard(0x4444)
end

-- Controlla entrambi i Terreni
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(
        s.scopecefilter,
        tp,
        LOCATION_MZONE,
        LOCATION_MZONE,
        1,
        nil
    )
end

-- Mostro Macchina scartabile
function s.costfilter(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsRace(RACE_MACHINE)
        and c:IsDiscardable()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.costfilter,
            tp,
            LOCATION_HAND,
            0,
            1,
            nil
        )
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)

    local g=Duel.SelectMatchingCard(
        tp,
        s.costfilter,
        tp,
        LOCATION_HAND,
        0,
        1,
        1,
        nil
    )

    Duel.SendtoGrave(
        g,
        REASON_COST+REASON_DISCARD
    )
end

-- Mostro "Colelli" Evocabile Specialmente
function s.spfilter(c,e,tp)
    return c:IsType(TYPE_MONSTER)
        and c:IsSetCard(0x1117)
        and c:IsCanBeSpecialSummoned(
            e,
            0,
            tp,
            false,
            false
        )
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(
                s.spfilter,
                tp,
                LOCATION_HAND+LOCATION_DECK,
                0,
                1,
                nil,
                e,
                tp
            )
    end

    Duel.SetOperationInfo(
        0,
        CATEGORY_SPECIAL_SUMMON,
        nil,
        1,
        tp,
        LOCATION_HAND+LOCATION_DECK
    )

    Duel.SetOperationInfo(
        0,
        CATEGORY_DRAW,
        nil,
        0,
        tp,
        1
    )
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

    local g=Duel.SelectMatchingCard(
        tp,
        s.spfilter,
        tp,
        LOCATION_HAND+LOCATION_DECK,
        0,
        1,
        1,
        nil,
        e,
        tp
    )

    local tc=g:GetFirst()
    if not tc then
        return
    end

    -- "e, se lo fai, pesca 1 carta"
    if Duel.SpecialSummon(
        tc,
        0,
        tp,
        tp,
        false,
        false,
        POS_FACEUP
    )>0 then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end