--Lo Squalo
-- Lo Squalo
local s,id=GetID()

local SET_LEONE=0x1118
local SET_FALCONE=0x1112
local SET_SQUALO=0x1116
local SET_TSO=0x1111

function s.initial_effect(c)

	------------------------------------------------------------
	-- Questa carta è considerata "Falcone"
	------------------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(SET_FALCONE)
	c:RegisterEffect(e0)

	------------------------------------------------------------
	-- Questa carta è considerata "TSO Obbligatorio"
	------------------------------------------------------------
	local e0b=e0:Clone()
	e0b:SetValue(SET_TSO)
	c:RegisterEffect(e0b)

	------------------------------------------------------------
	-- Se sul Terreno è presente un mostro "Leone":
	-- puoi Evocare Specialmente questa carta dalla mano.
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Quando lascia il Terreno:
	-- puoi aggiungere dal Deck una carta
	-- "Falcone", "Squalo" o "Leone"
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	------------------------------------------------------------
	-- Quando lascia il Cimitero:
	-- puoi mandare dal Deck al Cimitero
	-- una carta "Falcone", "Squalo" o "Leone"
	------------------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_GRAVE)
	e3:SetCountLimit(1,id+200)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end

s.listed_series={
	SET_LEONE,
	SET_FALCONE,
	SET_SQUALO,
	SET_TSO
}

------------------------------------------------------------
-- EVOCAZIONE SPECIALE
------------------------------------------------------------

function s.leonefilter(c)
	return c:IsFaceup()
		and c:IsType(TYPE_MONSTER)
		and c:IsSetCard(SET_LEONE)
end

function s.spcon(e,c)
	if c==nil then
		return true
	end

	local tp=c:GetControler()

	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(
			s.leonefilter,
			tp,
			LOCATION_MZONE,
			LOCATION_MZONE,
			1,
			nil
		)
end

------------------------------------------------------------
-- Filtro comune:
-- Falcone / Squalo / Leone
------------------------------------------------------------

function s.archfilter(c)
	return c:IsSetCard(SET_FALCONE)
		or c:IsSetCard(SET_SQUALO)
		or c:IsSetCard(SET_LEONE)
end

------------------------------------------------------------
-- EFFETTO 1
-- Quando lascia il Terreno: search
------------------------------------------------------------

function s.thfilter(c)
	return s.archfilter(c)
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
-- Quando lascia il Cimitero: manda dal Deck al GY
------------------------------------------------------------

function s.tgfilter(c)
	return s.archfilter(c)
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
	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_TOGRAVE
	)

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
