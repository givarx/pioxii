--I Commensali
-- I Commensali
-- 2 mostri di Livello 4

local s,id=GetID()

local SET_FALCONE=0x1112
local SET_ALTREX=0x1114

function s.initial_effect(c)
	------------------------------------------------------------
	-- Evocazione Xyz: 2 mostri di Livello 4
	------------------------------------------------------------
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()

	------------------------------------------------------------
	-- Questa carta è considerata "Falcone"
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetValue(SET_FALCONE)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Questa carta è considerata "Altrex"
	------------------------------------------------------------
	local e2=e1:Clone()
	e2:SetValue(SET_ALTREX)
	c:RegisterEffect(e2)

	------------------------------------------------------------
	-- Effetto 1:
	-- stacca 2 materiali e scarta 2 mostri; pesca 3 carte
	------------------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.drawcost)
	e3:SetTarget(s.drawtg)
	e3:SetOperation(s.drawop)
	c:RegisterEffect(e3)

	------------------------------------------------------------
	-- Effetto 2:
	-- stacca 1 materiale; manda 1 mostro
	-- "Falcone" o "Altrex" dal Deck al Cimitero
	------------------------------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.sendcost)
	e4:SetTarget(s.sendtg)
	e4:SetOperation(s.sendop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_FALCONE,SET_ALTREX}

------------------------------------------------------------
-- EFFETTO 1
-- Stacca 2 materiali + scarta 2 mostri
------------------------------------------------------------

function s.discardfilter(c)
	return c:IsType(TYPE_MONSTER)
		and c:IsDiscardable()
end

function s.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:CheckRemoveOverlayCard(tp,2,REASON_COST)
			and Duel.IsExistingMatchingCard(
				s.discardfilter,
				tp,
				LOCATION_HAND,
				0,
				2,
				nil
			)
	end

	-- Stacca 2 Materiali Xyz
	c:RemoveOverlayCard(
		tp,
		2,
		2,
		REASON_COST
	)

	-- Scarta 2 mostri
	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_DISCARD
	)

	local g=Duel.SelectMatchingCard(
		tp,
		s.discardfilter,
		tp,
		LOCATION_HAND,
		0,
		2,
		2,
		nil
	)

	Duel.SendtoGrave(
		g,
		REASON_COST+REASON_DISCARD
	)
end

function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,3)
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_DRAW,
		nil,
		0,
		tp,
		3
	)
end

function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,3,REASON_EFFECT)
end

------------------------------------------------------------
-- EFFETTO 2
-- Stacca 1 materiale
------------------------------------------------------------

function s.sendcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:CheckRemoveOverlayCard(
			tp,
			1,
			REASON_COST
		)
	end

	c:RemoveOverlayCard(
		tp,
		1,
		1,
		REASON_COST
	)
end

------------------------------------------------------------
-- Mostro "Falcone" o "Altrex"
------------------------------------------------------------

function s.sendfilter(c)
	return c:IsType(TYPE_MONSTER)
		and (
			c:IsSetCard(SET_FALCONE)
			or c:IsSetCard(SET_ALTREX)
		)
		and c:IsAbleToGrave()
end

function s.sendtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.sendfilter,
			tp,
			LOCATION_DECK,
			0,
			1,
			nil
		)
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_TOGRAVE,
		nil,
		1,
		tp,
		LOCATION_DECK
	)
end

function s.sendop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_TOGRAVE
	)

	local g=Duel.SelectMatchingCard(
		tp,
		s.sendfilter,
		tp,
		LOCATION_DECK,
		0,
		1,
		1,
		nil
	)

	if g:GetCount()>0 then
		Duel.SendtoGrave(
			g,
			REASON_EFFECT
		)
	end
end
