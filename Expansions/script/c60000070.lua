--il Padrone
--Il Padrone
local s,id=GetID()

function s.initial_effect(c)
	--Evocazione Synchro
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()

	--Ci può essere solo 1 "Il Padrone" sul tuo Terreno
	c:SetUniqueOnField(1,0,id)

	--Annulla Trappola Normale
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	--Annulla Evocazione Speciale
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

--========================================
-- EFFETTO 1
-- Trappola Normale
--========================================

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
		and re:IsActiveType(TYPE_TRAP)
		and re:GetHandler():IsType(TYPE_NORMAL)
		and Duel.IsChainNegatable(ev)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsFaceup() and c:GetAttack()>0
	end

	local atk=c:GetAttack()

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(math.floor(atk/2))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local rc=re:GetHandler()

		if rc:IsRelateToEffect(re) then
			Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
		end
	end
end

--========================================
-- EFFETTO 2
-- Annulla Evocazione Speciale
--========================================

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
		and ep~=tp
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsReleasable()
	end

	Duel.Release(c,REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(
		0,
		CATEGORY_DISABLE_SUMMON,
		eg,
		eg:GetCount(),
		0,
		0
	)

	Duel.SetOperationInfo(
		0,
		CATEGORY_REMOVE,
		eg,
		eg:GetCount(),
		0,
		0
	)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateSummon(eg) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end