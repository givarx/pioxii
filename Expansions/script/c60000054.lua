--Leone in Arsura
-- Leone in Arsura
local s,id=GetID()

local SET_LEONE=0x1118
local SET_ALTREX=0x1114
local SET_SQUALO=0x1116
local SET_FALCONE=0x1112

function s.initial_effect(c)

	------------------------------------------------------------
	-- Quando viene Evocata:
	-- aggiungi dal Deck 1 carta Leone/Altrex/Squalo/Falcone
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Anche Evocazione Speciale
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	-- Anche Evocazione per Scoperta
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)

	------------------------------------------------------------
	-- Quando viene mandata al Cimitero:
	-- puoi recuperare Leone/Altrex/Squalo/Falcone dal Cimitero
	------------------------------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+100)
	e4:SetTarget(s.gytg)
	e4:SetOperation(s.gyop)
	c:RegisterEffect(e4)
end

s.listed_series={
	SET_LEONE,
	SET_ALTREX,
	SET_SQUALO,
	SET_FALCONE
}

------------------------------------------------------------
-- Controlla i 4 archetipi
------------------------------------------------------------

function s.archetypefilter(c)
	return c:IsSetCard(SET_LEONE)
		or c:IsSetCard(SET_ALTREX)
		or c:IsSetCard(SET_SQUALO)
		or c:IsSetCard(SET_FALCONE)
end

------------------------------------------------------------
-- EFFETTO 1
-- Cerca dal Deck
------------------------------------------------------------

function s.thfilter(c)
	return s.archetypefilter(c)
		and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.thfilter,
			tp,
			LOCATION_DECK,
			0,
			1,
			nil
		)
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_TOHAND,
		nil,
		1,
		tp,
		LOCATION_DECK
	)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_ATOHAND
	)

	local g=Duel.SelectMatchingCard(
		tp,
		s.thfilter,
		tp,
		LOCATION_DECK,
		0,
		1,
		1,
		nil
	)

	if g:GetCount()>0 then
		Duel.SendtoHand(
			g,
			nil,
			REASON_EFFECT
		)

		Duel.ConfirmCards(
			1-tp,
			g
		)
	end
end

------------------------------------------------------------
-- EFFETTO 2
-- Recupera dal Cimitero
------------------------------------------------------------

function s.gyfilter(c)
	return s.archetypefilter(c)
		and c:IsAbleToHand()
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp)
			and chkc:IsLocation(LOCATION_GRAVE)
			and s.gyfilter(chkc)
	end

	if chk==0 then
		return Duel.IsExistingTarget(
			s.gyfilter,
			tp,
			LOCATION_GRAVE,
			0,
			1,
			e:GetHandler()
		)
	end

	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_ATOHAND
	)

	local g=Duel.SelectTarget(
		tp,
		s.gyfilter,
		tp,
		LOCATION_GRAVE,
		0,
		1,
		1,
		e:GetHandler()
	)

	Duel.SetOperationInfo(
		0,
		CATEGORY_TOHAND,
		g,
		1,
		0,
		0
	)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()

	if tc
		and tc:IsRelateToEffect(e) then

		Duel.SendtoHand(
			tc,
			nil,
			REASON_EFFECT
		)

		Duel.ConfirmCards(
			1-tp,
			tc
		)
	end
end
