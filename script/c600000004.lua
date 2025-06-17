local function alwaysTrue() return true end
-- Scripted for Project Ignis by GitHub Copilot
local s,id=GetID()
function s.initial_effect(c)
    -- Ritual Summon only with "Filtro Applicazione Ai"
    c:EnableReviveLimit()
    Ritual.AddProcGreaterCode(c,600000011,0,0)
    -- Main Phase effect: Banish 1 card from hand, shuffle all Spells/Traps on field into Deck
    -- Main Phase effect: Banish 1 card from hand, shuffle all Spells/Traps on field into Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END) -- Mostra il tasto solo in Main Phase
    e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
        return Duel.IsMainPhase() and e:GetHandler():IsControler(tp)
    end)
    e2:SetCost(s.cost)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
    if #g==0 then return false end
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.spelltrapfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.spelltrapfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if chk==0 then
        return #g>0
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.spelltrapfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
