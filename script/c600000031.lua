-- Super santos
-- Se un Mostro con "Davide" nel nome é presente sul terreno, scarta
-- dalla tua mano un mostro di tipo Macchina dalla tua mano ed
-- evoca specialmente dalla mano o dal Deck un mostro con "Colelli"
-- nel nome.

local s, id=GetID()
function s.initial_effect(c)
    -- Effetto di attivazione
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_names={600000014} -- Colelli

-- Condizione: Controlla se c'è un "Davide" sul terreno
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.davidefilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.davidefilter(c)
    return c:IsFaceup() and c:IsSetCard(0x4444) -- Archetipo "Davide"
end

-- Costo: Scarta un mostro di tipo Macchina dalla mano
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.machinefilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.machinefilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.machinefilter(c)
    return c:IsType(TYPE_MACHINE) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end

-- Target: Controlla se puoi evocare un "Colelli"
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.colellifilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) 
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.colellifilter(c,e,tp)
    return c:IsCode(600000014,600000018) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) -- "Colelli"
end

-- Operazione: Evoca specialmente un mostro con "Colelli" nel nome
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.colellifilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        -- Se pescato dal deck, mescola il deck
        if g:GetFirst():IsLocation(LOCATION_DECK) then
            Duel.ShuffleDeck(tp)
        end
    end
end