-- Evasione Fiscale (Magia Continua)
local s,id = GetID()
function s.initial_effect(c)
    -- Attivazione (Magia Continua)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    
    -- Una volta per turno: Mischia fino a 2 carte dalla mano nel Deck, poi pesca 2 carte
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end

function s.tdfilter(c)
    return c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,nil)
           and Duel.IsPlayerCanDraw(tp,2)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g = Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_HAND,0,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg = g:Select(tp,1,2,nil)
    if #sg > 0 then
        Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()
        Duel.Draw(tp,2,REASON_EFFECT)
    end
end