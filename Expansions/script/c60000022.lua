-- c600000022.lua
-- Script for a card that is immune to any effects during the Battle Phase.
-- When summoned, you can send a card whose name contains "lorenzo" to the Graveyard,
-- then shuffle all banished cards back into your Deck.

local s,id=GetID()

function s.initial_effect(c)
    -- Immunità durante la Battle Phase
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.econ)
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)

    -- Se questa carta viene Evocata Normalmente
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCost(s.tdcost)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)

    -- Se questa carta viene Evocata Specialmente
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Se questa carta viene Evocata per Scoperta
    local e4=e2:Clone()
    e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e4)
end

-- Immunità durante la Battle Phase
function s.econ(e)
    return e:GetHandler():IsFaceup()
        and Duel.GetCurrentPhase()==PHASE_BATTLE
end

-- Immune agli effetti dell'avversario
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- Mostri "Lorenzo" scartabili
function s.costfilter(c)
    return c:IsSetCard(0x1111)
        and c:IsType(TYPE_MONSTER)
        and c:IsDiscardable()
end

-- Scarta 1 mostro "Lorenzo" come costo
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
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
        REASON_COST|REASON_DISCARD
    )
end

-- Devi avere almeno 1 tua carta bandita
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            Card.IsAbleToDeck,
            tp,
            LOCATION_REMOVED,
            0,
            1,
            nil
        )
    end

    local g=Duel.GetMatchingGroup(
        Card.IsAbleToDeck,
        tp,
        LOCATION_REMOVED,
        0,
        nil
    )

    Duel.SetOperationInfo(
        0,
        CATEGORY_TODECK,
        g,
        #g,
        tp,
        LOCATION_REMOVED
    )
end

-- Rimescola nel Deck tutte le tue carte bandite
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(
        Card.IsAbleToDeck,
        tp,
        LOCATION_REMOVED,
        0,
        nil
    )

    if #g>0 then
        Duel.SendtoDeck(
            g,
            nil,
            SEQ_DECKSHUFFLE,
            REASON_EFFECT
        )
    end
end