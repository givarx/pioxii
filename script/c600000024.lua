-- This file intentionally left blank.
local SIN = 0x9999 -- contatore sinistro stradale
local s, id=GetID()
function s.initial_effect(c)
    -- synchro summon: tuner + 1 or more non-tuner(s) (level 6)
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()
    --counter settings
    c:EnableCounterPermit(SIN)
	c:SetCounterLimit(SIN,99)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetTarget(s.addct)
	e1:SetOperation(s.addc)
	c:RegisterEffect(e1)
    local e2 = Effect.CreateEffect(c)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetValue(function(e,c)
        return e:GetHandler():GetCounter(SIN)*200
    end)
    c:RegisterEffect(e2)
end
s.counter_place_list={SIN}
function s.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,SIN)
end
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(SIN,1)
	end
end