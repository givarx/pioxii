-- Effetto personalizzato

local s,id=GetID()
function s.initial_effect(c)
    -- Effetto 1: Dal Cimitero, bandisci questa carta per aggiungere 1 mostro dal Deck alla mano
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    -- Effetto 2: Se "Falcone il Mago Ciolone" è sul terreno, Evoca Specialmente questa carta dal Cimitero
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Effetto 1: Costo (bandisci questa carta dal Cimitero)
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) end
    aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- Effetto 1: Target (scegli un mostro dal Deck)
function s.thfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- Effetto 1: Operation (aggiungi alla mano)
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Effetto 2: Condizione (controlla "Falcone il Mago Ciolone" sul terreno)
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.ciolonefilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.ciolonefilter(c)
    return c:IsCode(600000007) -- Sostituisci con l'ID di "Falcone il Mago Ciolone"
end
-- Effetto 2: Target (evoca questa carta)
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- Effetto 2: Operation (evoca questa carta)
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end