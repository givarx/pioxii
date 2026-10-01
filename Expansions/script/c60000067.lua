--Lorenzo Dating Guru
-- Lorenzo Sorpreso
local s,id=GetID()
local SET_LORENZO=0x1113

s.listed_series={SET_LORENZO}

function s.initial_effect(c)
	-- Evocato dall'effetto di un mostro "Lorenzo"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

------------------------------------------------------------
-- Evocazione Speciale effettuata da un mostro "Lorenzo"
------------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetHandler():GetReasonEffect()
	if not se or not se:IsActiveType(TYPE_MONSTER) then
		return false
	end

	local sc=se:GetHandler()
	return sc and sc:IsSetCard(SET_LORENZO)
end

------------------------------------------------------------
-- Bersaglio: mostro in Attacco, esclusi i Link
------------------------------------------------------------
function s.targetfilter(c)
	return c:IsAttackPos()
		and not c:IsType(TYPE_LINK)
		and c:IsCanChangePosition()
end

------------------------------------------------------------
-- Conteggio dei mostri "Lorenzo"
-- Cimitero + carte bandite scoperte
------------------------------------------------------------
function s.countfilter(c)
	return c:IsSetCard(SET_LORENZO)
		and c:IsType(TYPE_MONSTER)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.destroycondition(tp)
	return Duel.IsExistingMatchingCard(
		s.countfilter,
		tp,
		LOCATION_GRAVE+LOCATION_REMOVED,
		0,
		3,
		nil
	)
end

------------------------------------------------------------
-- Selezione del bersaglio
------------------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
			and s.targetfilter(chkc)
	end

	if chk==0 then
		return Duel.IsExistingTarget(
			s.targetfilter,tp,
			LOCATION_MZONE,LOCATION_MZONE,
			1,nil
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(
		tp,s.targetfilter,tp,
		LOCATION_MZONE,LOCATION_MZONE,
		1,1,nil
	)

	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)

	if s.destroycondition(tp) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end

------------------------------------------------------------
-- Risoluzione
------------------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc
		or not tc:IsRelateToEffect(e)
		or not tc:IsLocation(LOCATION_MZONE)
		or not s.targetfilter(tc)
		or tc:IsImmuneToEffect(e) then
		return
	end

	-- Deve effettivamente passare in Difesa.
	if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)==0 then
		return
	end

	-- Fine del turno attuale + fine del prossimo turno.
	local reset=RESET_EVENT+RESETS_STANDARD
		+RESET_PHASE+PHASE_END

	-- Impedisce il cambio manuale di posizione.
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetReset(reset,2)
	tc:RegisterEffect(e1)

	-- Impedisce anche il cambio di posizione tramite effetti.
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
	tc:RegisterEffect(e2)

	-- Conta i "Lorenzo" alla risoluzione.
	if s.destroycondition(tp) then
		Duel.BreakEffect()
		if tc:IsRelateToEffect(e)
			and tc:IsLocation(LOCATION_MZONE) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end