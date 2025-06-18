-- burger king (Magia Terreno)
local s,id = GetID()
function s.initial_effect(c)
    -- Attiva normalmente (Field Spell)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    
    -- Una volta per turno: scegli 1 tra 2 effetti
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    
    -- Guadagna LP alla fine di ogni tuo turno in base alle carte "12E0" nel Cimitero e tra quelle bandite
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
        return Duel.GetTurnPlayer()==tp
    end)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetOperation(s.lpop)
    c:RegisterEffect(e2)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

-- Effetto 1: Scarta 1 carta dalla mano per aggiungere una Magia/Trappola dal Deck
function s.filter1(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.filter2(c)
    return c:IsAbleToGraveAsCost()
end

-- Effetto 2: Banish 1 carta dal Cimitero come costo per aggiungere 1 carta dal Cimitero alla mano
function s.filter3(c)
    return c:IsAbleToRemoveAsCost()
end
function s.filter4(c)
    return c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local option1 = Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND,0,1,nil)
        and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil)
    local option2 = Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.filter4,tp,LOCATION_GRAVE,0,1,nil)
    if chk==0 then return option1 or option2 end
    local op=0
    if option1 and option2 then
        op = Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif option1 then
        op = 0
    else
        op = 1
    end
    e:SetLabel(op)
    if op==0 then
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    else
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
    end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local op = e:GetLabel()
    if op==0 then
        -- Scarta 1 carta dalla mano come costo, poi aggiungi 1 Magia/Trappola dal Deck
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g = Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND,0,1,1,nil)
        if #g>0 and Duel.SendtoGrave(g,REASON_COST)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg = Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
            if #sg>0 then
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
                Duel.ShuffleDeck(tp)
            end
        end
    else
        -- Banish 1 carta dal Cimitero come costo, poi aggiungi 1 carta dal Cimitero alla mano
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local rg = Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_GRAVE,0,1,1,nil)
        if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_COST)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local hg = Duel.SelectMatchingCard(tp,s.filter4,tp,LOCATION_GRAVE,0,1,1,nil)
            if #hg>0 then
                Duel.SendtoHand(hg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,hg)
            end
        end
    end
end

-- Recupera LP alla fine del turno in base al numero di carte "12E0" nel Cimitero e tra quelle bandite (300 LP ciascuna)
function s.tsofilter(c)
    return c:IsSetCard(0x1111) and (c:IsType(TYPE_MONSTER) or c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
end

function s.lpop(e,tp,eg,ep,ev,re,r,rp)
    local g1 = Duel.GetMatchingGroup(s.tsofilter,tp,LOCATION_GRAVE,0,nil)
    local g2 = Duel.GetMatchingGroup(s.tsofilter,tp,LOCATION_REMOVED,0,nil)
    local ct = g1:GetCount() + g2:GetCount()
    if ct>0 then
        Duel.Recover(tp, ct*200, REASON_EFFECT)
    end
end