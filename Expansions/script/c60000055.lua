--Primizie del Settore
local s,id=GetID()

local SET_LEONE=0x1118
local SET_ALTREX=0x1114

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

------------------------------------------------------------
-- Costo: scarta 1 mostro "Altrex" o "Leone"
------------------------------------------------------------

function s.costfilter(c)
	return c:IsType(TYPE_MONSTER)
		and (c:IsSetCard(SET_ALTREX) or c:IsSetCard(SET_LEONE))
		and c:IsDiscardable()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.costfilter,
			tp,
			LOCATION_HAND,
			0,
			1,
			nil
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)

	local g=Duel.SelectMatchingCard(
		tp,
		s.costfilter,
		tp,
		LOCATION_HAND,
		0,
		1,
		1,
		nil
	)

	Duel.SendtoGrave(
		g,
		REASON_COST+REASON_DISCARD
	)
end

------------------------------------------------------------
-- Pesca 2
------------------------------------------------------------

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,2)
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_DRAW,
		nil,
		0,
		tp,
		2
	)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,2,REASON_EFFECT)
end