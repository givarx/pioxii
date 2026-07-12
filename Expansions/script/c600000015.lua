---Una Volta per turno: puoi prendere una carta bandita e riaggiungerla alla mano.
--Se colabbela Samurai leggendario è sul terreno, questa carta non puo essere scelta come bersaglio dagli effetti delle carte.
--Se "colabbella samurai leggendario" (60000008) sta per lasciare il terreno per via di un effetto, puoi invece bandire questa carta ed annullare tale effetto.

function c600000015.initial_effect(c)
    -- Attiva normalmente
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    -- Una volta per turno: puoi prendere una carta bandita e aggiungerla alla mano.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(600000015,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,600000015)
    e1:SetTarget(c600000015.thtg)
    e1:SetOperation(c600000015.thop)
    c:RegisterEffect(e1)
    -- Se "Colabbela Samurai Leggendario" è sul terreno, questa carta non può essere scelta come bersaglio dagli effetti delle carte.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetCondition(c600000015.tgcon)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    
end


function c600000015.thfilter(c)
    return c:IsAbleToHand() and c:IsFaceup() and c:IsLocation(LOCATION_REMOVED)
end
function c600000015.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c600000015.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function c600000015.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c600000015.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function c600000015.tgcon(e)
    local tp = e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(600000008) end, tp, LOCATION_MZONE, 0, 1, nil)
end
function c600000015.replacecon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsAbleToRemove() then return false end
    local g=eg:Filter(function(tc)
        return tc:IsFaceup() and tc:IsCode(600000008) and tc:IsControler(tp) 
           and tc:IsOnField() and tc:IsReason(REASON_EFFECT)
    end, nil)
end

function c600000015.replaceop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsAbleToRemove() and Duel.SelectYesNo(tp,aux.Stringid(600000015,1)) then
        Duel.Remove(c, POS_FACEUP, REASON_EFFECT)
        Duel.NegateEffect(ev)
    end
end