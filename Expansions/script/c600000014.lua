--Colelli
local s,id,o=GetID()

function s.initial_effect(c)
    --Se questa carta viene mandata al Cimitero o bandita:
    --aggiungi 1 Magia dal Deck alla mano
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_GRAVE)

    -- Hard once per turn condiviso dai due trigger
    e1:SetCountLimit(1,60000014)

    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e2)
end

function s.thfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.thfilter,tp,LOCATION_DECK,0,1,nil
        )
    end
    Duel.SetOperationInfo(
        0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK
    )
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(
        tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil
    )
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end