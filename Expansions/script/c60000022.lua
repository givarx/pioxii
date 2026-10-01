-- c600000022.lua
-- Lorenzo
-- ID: 60000022
local s,id=GetID()
local SET_LORENZO=0x1113

s.listed_series={SET_LORENZO}

function s.initial_effect(c)
	------------------------------------------------------------
	-- Immune agli effetti delle altre carte nella Battle Phase
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.immcon)
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- All'Evocazione: Evoca un mostro "Lorenzo"
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)

	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end

------------------------------------------------------------
-- Immunità durante tutta la Battle Phase
------------------------------------------------------------
function s.immcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_BATTLE_START
		or ph==PHASE_BATTLE_STEP
		or ph==PHASE_DAMAGE
		or ph==PHASE_DAMAGE_CAL
		or ph==PHASE_BATTLE
end

function s.immval(e,te)
	-- Comprende gli effetti di entrambi i giocatori,
	-- ma non quelli di questa stessa carta.
	return te:GetOwner()~=e:GetHandler()
end

------------------------------------------------------------
-- Costo
------------------------------------------------------------
function s.costfilter(c)
	if not c:IsSetCard(SET_LORENZO) then
		return false
	end
	if c:IsLocation(LOCATION_HAND) then
		return c:IsDiscardable()
			and c:IsAbleToGraveAsCost()
	end
	return c:IsLocation(LOCATION_GRAVE)
		and c:IsAbleToRemoveAsCost()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.costfilter,tp,
			LOCATION_HAND+LOCATION_GRAVE,0,
			1,nil
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(
		tp,s.costfilter,tp,
		LOCATION_HAND+LOCATION_GRAVE,0,
		1,1,nil
	)
	local tc=g:GetFirst()

	if tc:IsLocation(LOCATION_HAND) then
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	else
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	end
end

------------------------------------------------------------
-- Mostri evocabili
------------------------------------------------------------
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_LORENZO)
		and c:IsType(TYPE_MONSTER)
		and (not c:IsLocation(LOCATION_REMOVED)
			or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(
			e,0,tp,false,false
		)
end

------------------------------------------------------------
-- Controllo di attivazione: non sceglie come bersaglio
------------------------------------------------------------
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(
				s.spfilter,tp,
				LOCATION_GRAVE+LOCATION_REMOVED,0,
				1,nil,e,tp
			)
	end

	Duel.SetOperationInfo(
		0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,
		LOCATION_GRAVE+LOCATION_REMOVED
	)
end

------------------------------------------------------------
-- Evocazione, ATK 0 ed effetti annullati
------------------------------------------------------------
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		return
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(
		tp,s.spfilter,tp,
		LOCATION_GRAVE+LOCATION_REMOVED,0,
		1,1,nil,e,tp
	)
	local tc=g:GetFirst()
	if not tc then return end

	if Duel.SpecialSummonStep(
		tc,0,tp,tp,false,false,POS_FACEUP
	) then
		local c=e:GetHandler()

		-- Annulla gli effetti prima di completare l'Evocazione.
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)

		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2,true)

		-- ATK finale pari a 0.
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(0)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
	end

	Duel.SpecialSummonComplete()
end