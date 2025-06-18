-- c600000021.lua
-- Effetto di questo mostro:
-- "Una volta per turno, questa carta non può essere distrutta in battaglia.
--  Puoi Sacrificare questa carta ed evocare specialmente dal tuo Deck o mano 
--  "Lorenzo Lv.6" (l'ID seguente a questa carta)."

local s,id=GetID()
-- L'ID di "Lorenzo Lv.6" è considerato uguale a id+1
local LORENZO_ID = id + 1

function s.initial_effect(c)
    -- Effetto 1: Protezione dalla distruzione in battaglia una volta per turno
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    
    e1:SetCountLimit(1)
    e1:SetValue(s.valcon) -- Impedisce la distruzione
    c:RegisterEffect(e1)
    
    -- Effetto 2: Sacrifica questa carta per evocare "Lorenzo Lv.6" da mano o Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
function s.valcon(e,re,r,rp)
	return (r&REASON_BATTLE)~=0 
end
-- Costo: Sacrifica questa carta
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return e:GetHandler():IsReleasable()
    end
    Duel.Release(e:GetHandler(),REASON_COST)
end

-- Filtro per "Lorenzo Lv.6"
function s.spfilter(c,e,tp)
    return c:IsCode(LORENZO_ID) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Obiettivo: controlla se "Lorenzo Lv.6" può essere evocato
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end

-- Operazione: Evoca specialmente "Lorenzo Lv.6"
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end