-- c600000030.lua
local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()

	--------------------------------------------------
	-- Materiali Fusione:
	-- 60000001 + 60000021 + 60000022
	--------------------------------------------------
	aux.AddFusionProcMix(
		c,
		true,
		true,
		60000001,
		60000021,
		60000022
	)

	--------------------------------------------------
	-- Contact Fusion
	-- Bandisci i materiali da Mano, Terreno o Cimitero
	--------------------------------------------------
	aux.AddContactFusionProcedure(
		c,
		s.contactfilter,
		LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,
		0,
		s.contactop
	)

	--------------------------------------------------
	-- Quando viene Evocata Specialmente:
	-- fai tornare tutti i mostri dell'avversario in mano
	--------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end

--------------------------------------------------
-- Materiali validi per la Contact Fusion
--------------------------------------------------

function s.contactfilter(c)
	return c:IsType(TYPE_MONSTER)
		and (
			c:IsFusionCode(60000001)
			or c:IsFusionCode(60000021)
			or c:IsFusionCode(60000022)
		)
		and c:IsAbleToRemoveAsCost()
end

--------------------------------------------------
-- Bandisci i materiali come costo della Contact Fusion
--------------------------------------------------

function s.contactop(g,tp)
	Duel.Remove(
		g,
		POS_FACEUP,
		REASON_COST+REASON_MATERIAL+REASON_FUSION
	)
end

--------------------------------------------------
-- Bersaglio dell'effetto di rimbalzo
--------------------------------------------------

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			Card.IsAbleToHand,
			tp,
			0,
			LOCATION_MZONE,
			1,
			nil
		)
	end

	local g=Duel.GetMatchingGroup(
		Card.IsAbleToHand,
		tp,
		0,
		LOCATION_MZONE,
		nil
	)

	Duel.SetOperationInfo(
		0,
		CATEGORY_TOHAND,
		g,
		g:GetCount(),
		0,
		0
	)
end

--------------------------------------------------
-- Rimanda tutti i mostri dell'avversario in mano
--------------------------------------------------

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(
		Card.IsAbleToHand,
		tp,
		0,
		LOCATION_MZONE,
		nil
	)

	if g:GetCount()>0 then
		Duel.SendtoHand(
			g,
			nil,
			REASON_EFFECT
		)
	end
end