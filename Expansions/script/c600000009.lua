-- c600000009.lua
-- Script per il mostro con effetto: puoi mandare questa carta dalla tua mano al Cimitero; bandisci 1 carta dalla mano del tuo avversario.

local s,id=GetID()
function s.initial_effect(c)
    -- Effetto rapido: manda questa carta dalla mano al Cimitero per bandire 1 carta dalla mano dell'avversario
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil)
    end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    if #g==0 then return end
    Duel.ConfirmCards(tp,g)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sg=g:Select(tp,1,1,nil)
    Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
    Duel.ShuffleHand(1-tp)
end