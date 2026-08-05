--Polimerizzalcone
-- Magia Rapida
-- Evoca tramite Fusione 1 Mostro Fusione "Falcone",
-- bandendo dal Deck i materiali indicati su di esso.
-- Dopo aver attivato questa carta, non puoi Evocare Specialmente
-- mostri, eccetto mostri "Falcone", per il resto del turno.

local s,id=GetID()

local SET_FALCONE=0x1112

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

------------------------------------------------------------
-- Materiali utilizzabili dal Deck
------------------------------------------------------------

function s.matfilter(c)
	return c:IsType(TYPE_MONSTER)
		and c:IsAbleToRemove()
		and c:IsCanBeFusionMaterial()
end

------------------------------------------------------------
-- Mostro Fusione "Falcone"
------------------------------------------------------------

function s.fusfilter(c,e,tp,mg)
	return c:IsType(TYPE_FUSION)
		and c:IsSetCard(SET_FALCONE)
		and c:IsCanBeSpecialSummoned(
			e,
			SUMMON_TYPE_FUSION,
			tp,
			false,
			false
		)
		and c:CheckFusionMaterial(mg,nil)
end

------------------------------------------------------------
-- Controllo attivazione
------------------------------------------------------------

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(
		s.matfilter,
		tp,
		LOCATION_DECK,
		0,
		nil
	)

	if chk==0 then
		return Duel.GetLocationCountFromEx(tp)>0
			and Duel.IsExistingMatchingCard(
				s.fusfilter,
				tp,
				LOCATION_EXTRA,
				0,
				1,
				nil,
				e,
				tp,
				mg
			)
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_SPECIAL_SUMMON,
		nil,
		1,
		tp,
		LOCATION_EXTRA
	)

	Duel.SetOperationInfo(
		0,
		CATEGORY_REMOVE,
		nil,
		1,
		tp,
		LOCATION_DECK
	)
end

------------------------------------------------------------
-- Risoluzione
------------------------------------------------------------

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)<=0 then
		return
	end

	local mg=Duel.GetMatchingGroup(
		s.matfilter,
		tp,
		LOCATION_DECK,
		0,
		nil
	)

	if mg:GetCount()==0 then
		return
	end

	-- Seleziona il Mostro Fusione
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local fg=Duel.SelectMatchingCard(
		tp,
		s.fusfilter,
		tp,
		LOCATION_EXTRA,
		0,
		1,
		1,
		nil,
		e,
		tp,
		mg
	)

	local fc=fg:GetFirst()
	if not fc then
		return
	end

	-- Seleziona i materiali dal Deck
	local mat=Duel.SelectFusionMaterial(
		tp,
		fc,
		mg,
		nil
	)

	if not mat or mat:GetCount()==0 then
		return
	end

	fc:SetMaterial(mat)

	-- Bandisce i materiali
	local ct=Duel.Remove(
		mat,
		POS_FACEUP,
		REASON_EFFECT+REASON_MATERIAL+REASON_FUSION
	)

	if ct~=mat:GetCount() then
		return
	end

	-- Evocazione Fusione
	if Duel.SpecialSummon(
		fc,
		SUMMON_TYPE_FUSION,
		tp,
		tp,
		false,
		false,
		POS_FACEUP
	)>0 then
		fc:CompleteProcedure()

		-- Dopo questa Evocazione, non puoi Evocare Specialmente
		-- altri mostri per il resto del turno
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(
			EFFECT_FLAG_PLAYER_TARGET
			+EFFECT_FLAG_OATH
		)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end