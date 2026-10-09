-- Lotta greco-romana
-- Trappola Normale
local s,id=GetID()

function s.initial_effect(c)
	-- Attivazione
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

------------------------------------------------------------
-- Bersaglio: 1 mostro scoperto che controlli
------------------------------------------------------------
function s.targetfilter(c)
	return c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp)
			and chkc:IsLocation(LOCATION_MZONE)
			and s.targetfilter(chkc)
	end

	if chk==0 then
		return Duel.IsExistingTarget(
			s.targetfilter,
			tp,LOCATION_MZONE,0,
			1,nil
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(
		tp,s.targetfilter,
		tp,LOCATION_MZONE,0,
		1,1,nil
	)
end

------------------------------------------------------------
-- Mostri avversari in Posizione di Attacco
------------------------------------------------------------
function s.attackfilter(e,c)
	return c:IsAttackPos()
end

------------------------------------------------------------
-- Devono attaccare il mostro scelto
------------------------------------------------------------
function s.attackvalue(e,c)
	return c==e:GetHandler()
end

------------------------------------------------------------
-- Immunità:
-- esclude gli effetti del mostro stesso e di questa Trappola
------------------------------------------------------------
function s.immunevalue(e,te)
	return te:GetOwner()~=e:GetHandler()
		and te:GetOwner()~=e:GetOwner()
end

------------------------------------------------------------
-- Risoluzione
------------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if not tc
		or not tc:IsRelateToEffect(e)
		or not tc:IsLocation(LOCATION_MZONE)
		or not tc:IsFaceup()
		or not tc:IsControler(tp)
		or tc:IsImmuneToEffect(e) then
		return
	end

	local reset=RESET_EVENT+RESETS_STANDARD
		+RESET_PHASE+PHASE_END

	------------------------------------------------------------
	-- I mostri avversari in Attacco devono attaccare
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.attackfilter)
	e1:SetReset(reset)
	tc:RegisterEffect(e1)

	------------------------------------------------------------
	-- Devono attaccare un mostro, se possibile
	------------------------------------------------------------
	local e2=e1:Clone()
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetValue(1)
	tc:RegisterEffect(e2)

	------------------------------------------------------------
	-- Possono attaccare soltanto il mostro scelto
	------------------------------------------------------------
	local e3=e1:Clone()
	e3:SetCode(EFFECT_ONLY_ATTACK_MONSTER)
	e3:SetValue(s.attackvalue)
	tc:RegisterEffect(e3)

	------------------------------------------------------------
	-- Il suo controllore non subisce danni
	-- dalle battaglie che coinvolgono questo mostro
	------------------------------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetValue(1)
	e4:SetReset(reset)
	tc:RegisterEffect(e4)

	------------------------------------------------------------
	-- Il mostro non infligge danni da combattimento
	------------------------------------------------------------
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e5:SetValue(1)
	e5:SetReset(reset)
	tc:RegisterEffect(e5)

	------------------------------------------------------------
	-- Non può essere distrutto in battaglia
	------------------------------------------------------------
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e6:SetValue(1)
	e6:SetReset(reset)
	tc:RegisterEffect(e6)

	------------------------------------------------------------
	-- Immune agli effetti delle altre carte
	------------------------------------------------------------
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetValue(s.immunevalue)
	e7:SetReset(reset)
	tc:RegisterEffect(e7)
end