--Vigilanza del Leone
-- Contro Trappola
local s,id=GetID()

local IL_LEONE=60000049

function s.initial_effect(c)
	-- Attivazione
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(
		CATEGORY_NEGATE
		+CATEGORY_DESTROY
		+CATEGORY_SPECIAL_SUMMON
	)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

------------------------------------------------------------
-- Condizione:
-- l'avversario attiva una carta/effetto che distrugge
-- almeno 1 carta
------------------------------------------------------------

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then
		return false
	end

	if not Duel.IsChainNegatable(ev) then
		return false
	end

	local ex,g,ct,p,loc=
		Duel.GetOperationInfo(
			ev,
			CATEGORY_DESTROY
		)

	return ex and ct>0
end

------------------------------------------------------------
-- "Il Leone" evocabile dal Deck
------------------------------------------------------------

function s.spfilter(c,e,tp)
	return c:IsCode(IL_LEONE)
		and c:IsCanBeSpecialSummoned(
			e,
			0,
			tp,
			false,
			false
		)
end

------------------------------------------------------------
-- Target
------------------------------------------------------------

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end

	-- Negazione
	Duel.SetOperationInfo(
		0,
		CATEGORY_NEGATE,
		eg,
		1,
		0,
		0
	)

	-- Distruzione della carta che ha attivato l'effetto
	local rc=re:GetHandler()

	if rc
		and rc:IsRelateToEffect(re)
		and rc:IsDestructable() then

		Duel.SetOperationInfo(
			0,
			CATEGORY_DESTROY,
			rc,
			1,
			0,
			0
		)
	end

	-- Possibile Evocazione di "Il Leone"
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(
			s.spfilter,
			tp,
			LOCATION_DECK,
			0,
			1,
			nil,
			e,
			tp
		) then

		Duel.SetOperationInfo(
			0,
			CATEGORY_SPECIAL_SUMMON,
			nil,
			1,
			tp,
			LOCATION_DECK
		)
	end
end

------------------------------------------------------------
-- Risoluzione
------------------------------------------------------------

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()

	-- Annulla l'attivazione
	if not Duel.NegateActivation(ev) then
		return
	end

	-- Distrugge la carta
	local destroyed=false

	if rc
		and rc:IsRelateToEffect(re)
		and rc:IsDestructable() then

		if Duel.Destroy(rc,REASON_EFFECT)>0 then
			destroyed=true
		end
	end

	--------------------------------------------------------
	-- "e se lo fai"
	-- Puoi Evocare Specialmente "Il Leone"
	--------------------------------------------------------

	if not destroyed then
		return
	end

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		return
	end

	if not Duel.IsExistingMatchingCard(
		s.spfilter,
		tp,
		LOCATION_DECK,
		0,
		1,
		nil,
		e,
		tp
	) then
		return
	end

	-- L'Evocazione è opzionale
	if not Duel.SelectYesNo(
		tp,
		aux.Stringid(id,1)
	) then
		return
	end

	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_SPSUMMON
	)

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
