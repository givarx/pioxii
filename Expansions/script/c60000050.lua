--La Rupe
local s,id=GetID()

local SET_LEONE=0x1118

function s.initial_effect(c)
	------------------------------------------------------------
	-- Questa carta è considerata una carta "Leone"
	------------------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(SET_LEONE)
	c:RegisterEffect(e0)

	------------------------------------------------------------
	-- Una volta per turno:
	-- rimischia 1 carta dalla mano nel Deck;
	-- Evoca Specialmente 1 mostro "Leone" dal Deck
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Manda questa carta al Cimitero;
	-- manda 1 mostro "Leone" dal Deck al Cimitero
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCost(s.tgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e3)
end

s.listed_series={SET_LEONE}

------------------------------------------------------------
-- EFFETTO 1
------------------------------------------------------------

function s.handfilter(c)
	return c:IsAbleToDeck()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.handfilter,
			tp,
			LOCATION_HAND,
			0,
			1,
			nil
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)

	local g=Duel.SelectMatchingCard(
		tp,
		s.handfilter,
		tp,
		LOCATION_HAND,
		0,
		1,
		1,
		nil
	)

	Duel.SendtoDeck(
		g,
		nil,
		SEQ_DECKSHUFFLE,
		REASON_COST
	)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_LEONE)
		and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(
			e,
			0,
			tp,
			false,
			false,
			POS_FACEUP_ATTACK
		)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(
				s.spfilter,
				tp,
				LOCATION_DECK,
				0,
				1,
				nil,
				e,
				tp
			)
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_SPECIAL_SUMMON,
		nil,
		1,
		tp,
		LOCATION_DECK
	)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		return
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectMatchingCard(
		tp,
		s.spfilter,
		tp,
		LOCATION_DECK,
		0,
		1,
		1,
		nil,
		e,
		tp
	)

	local tc=g:GetFirst()

	if tc then
		Duel.SpecialSummon(
			tc,
			0,
			tp,
			tp,
			false,
			false,
			POS_FACEUP_ATTACK
		)
	end
end

------------------------------------------------------------
-- EFFETTO 2
------------------------------------------------------------

function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsAbleToGraveAsCost()
	end

	Duel.SendtoGrave(c,REASON_COST)
end

function s.tgfilter(c)
	return c:IsSetCard(SET_LEONE)
		and c:IsType(TYPE_MONSTER)
		and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.tgfilter,
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

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)

	local g=Duel.SelectMatchingCard(
		tp,
		s.tgfilter,
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