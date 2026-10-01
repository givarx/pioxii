--Lotta Greco-Romana
-- Trappola Normale
local s,id=GetID()

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
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
function s.filter(c)
	return c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp)
			and chkc:IsLocation(LOCATION_MZONE)
			and s.filter(chkc)
	end

	if chk==0 then
		return Duel.IsExistingTarget(
			s.filter,tp,LOCATION_MZONE,0,1,nil
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(
		tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil
	)
end

------------------------------------------------------------
-- Si applica ai mostri avversari in Attacco
------------------------------------------------------------
function s.attackfilter(e,c)
	return c:IsAttackPos()
end

------------------------------------------------------------
-- Possono attaccare soltanto il mostro scelto
------------------------------------------------------------
function s.attackvalue(e,c)
	return c==e:GetHandler()
end

------------------------------------------------------------
-- Risoluzione
------------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc
		or not tc:IsRelateToEffect(e)
		or not tc:IsFaceup()
		or not tc:IsControler(tp)
		or tc:IsImmuneToEffect(e) then
		return
	end

	local c=e:GetHandler()
	local reset=RESET_EVENT+RESETS_STANDARD
		+RESET_PHASE+PHASE_END

	-- I mostri avversari in Attacco devono attaccare.
	-- L'effetto rimane legato al mostro scelto.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.attackfilter)
	e1:SetReset(reset)
	tc:RegisterEffect(e1)

	-- Devono attaccare un mostro, se possibile,
	-- anche se possiedono un effetto di attacco diretto.
	local e2=e1:Clone()
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetValue(1)
	tc:RegisterEffect(e2)

	-- Il mostro da attaccare è quello scelto.
	local e3=e1:Clone()
	e3:SetCode(EFFECT_ONLY_ATTACK_MONSTER)
	e3:SetValue(s.attackvalue)
	tc:RegisterEffect(e3)

	-- Il controllore del mostro scelto non subisce
	-- danni da combattimento nelle sue battaglie.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetValue(1)
	e4:SetReset(reset)
	tc:RegisterEffect(e4)

	-- Il mostro scelto non infligge danni da combattimento.
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e5:SetValue(1)
	e5:SetReset(reset)
	tc:RegisterEffect(e5)
end
