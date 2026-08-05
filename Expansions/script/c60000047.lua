--Colpo Da Maestro
-- Magia Rapida
-- Se controlli un mostro "Falcone":
-- scegli come bersaglio 1 mostro scoperto sul Terreno;
-- annulla i suoi effetti, poi mandalo al Cimitero.

local s,id=GetID()

function s.initial_effect(c)
	-- Attivazione
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

------------------------------------------------------------
-- Controllo di un mostro "Falcone"
------------------------------------------------------------

function s.falconefilter(c)
	return c:IsFaceup()
		and c:IsSetCard(0x1112)
		and c:IsType(TYPE_MONSTER)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(
		s.falconefilter,
		tp,
		LOCATION_MZONE,
		0,
		1,
		nil
	)
end

------------------------------------------------------------
-- Bersaglio
------------------------------------------------------------

function s.targetfilter(c)
	return c:IsFaceup()
		and c:IsType(TYPE_MONSTER)
		and c:IsAbleToGrave()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
			and s.targetfilter(chkc)
	end

	if chk==0 then
		return Duel.IsExistingTarget(
			s.targetfilter,
			tp,
			LOCATION_MZONE,
			LOCATION_MZONE,
			1,
			nil
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)

	local g=Duel.SelectTarget(
		tp,
		s.targetfilter,
		tp,
		LOCATION_MZONE,
		LOCATION_MZONE,
		1,
		1,
		nil
	)

	Duel.SetOperationInfo(
		0,
		CATEGORY_DISABLE,
		g,
		1,
		0,
		0
	)

	Duel.SetOperationInfo(
		0,
		CATEGORY_TOGRAVE,
		g,
		1,
		0,
		0
	)
end

------------------------------------------------------------
-- Risoluzione
------------------------------------------------------------

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()

	if not tc
		or not tc:IsRelateToEffect(e)
		or not tc:IsFaceup() then
		return
	end

	-- Annulla gli effetti del mostro
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)

	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)

	-- Poi mandalo al Cimitero
	Duel.SendtoGrave(tc,REASON_EFFECT)
end