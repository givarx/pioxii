-- c600000030.lua
-- Fusion monster that requires materials: 600000001, 600000021, and 600000022
local s,id=GetID()
function s.initial_effect(c)
    -- Fusion Summon procedure
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,600000001, 600000021,600000022)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true)
    -- Effect: quando questa carta viene Evocata Specialmente, ritorna alla mano tutti i mostri dell'avversario
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetTarget(s.target)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
    end

    function s.thop(e,tp,eg,ep,ev,re,r,rp)
        local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
        end
    end