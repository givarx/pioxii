-- c600000022.lua
-- Script for a card that is immune to any effects during the Battle Phase.
-- When summoned, you can send a card whose name contains "lorenzo" to the Graveyard,
-- then shuffle all banished cards back into your Deck.

local s,id=GetID()
function s.initial_effect(c)
    -- Immunity during Battle Phase
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.econ)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)

    -- Trigger when this card is Normal Summoned
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
end

-- Condition: only during Battle Phase
function s.econ(e)
	return e:GetHandler():IsFaceup() and Duel.GetCurrentPhase()==PHASE_BATTLE
end

-- Effect filter: immune to effects from opponent
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

-- Filter for cards with "lorenzo" in their name that can be sent to the Graveyard
function s.tgfilter(c)
    return c:IsCode(600000001,600000021,600000022) and c:IsAbleToGrave()
end

-- Target selection: ensure there is at least one valid card from hand or deck
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

-- Operation: send one "lorenzo" card to the Graveyard and shuffle all banished cards into the Deck
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
    local banished=Duel.GetFieldGroup(tp,LOCATION_REMOVED,0)
    if #banished>0 then
        Duel.SendtoDeck(banished,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end