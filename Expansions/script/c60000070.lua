-- Il Padrone
local s,id=GetID()

function s.initial_effect(c)
	------------------------------------------------------------
	-- Synchro: 1 Tuner + 1 o più mostri non-Tuner
	------------------------------------------------------------
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()

	-- Puoi controllare solo 1 "Il Padrone"
	c:SetUniqueOnField(1,0,id)

	------------------------------------------------------------
	-- Annulla l'attivazione di una Magia/Trappola
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(
		EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL
	)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Annulla un'Evocazione Speciale avversaria
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+10000)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

------------------------------------------------------------
-- Attivazione di una carta Magia o Trappola dell'avversario
------------------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsChainNegatable(ev)
end

------------------------------------------------------------
-- Costo: dimezza l'ATK attuale
------------------------------------------------------------
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	local decrease=math.ceil(atk/2)

	if chk==0 then
		return c:IsFaceup()
			and atk>0
			and c:IsAbleToDecreaseAttackAsCost(decrease)
	end

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(math.floor(atk/2))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(
		0,CATEGORY_REMOVE,re:GetHandler(),1,0,0
	)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()

	if Duel.NegateActivation(ev)
		and rc:IsRelateToEffect(re) then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end

------------------------------------------------------------
-- Evocazione Speciale fuori dalla risoluzione di una Catena
------------------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
		and ep==1-tp
end

------------------------------------------------------------
-- Costo: offri questa carta come Tributo
------------------------------------------------------------
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
		0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0
	)
	Duel.SetOperationInfo(
		0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0
	)
end

------------------------------------------------------------
-- Annulla l'Evocazione e bandisce i mostri
------------------------------------------------------------
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)

	-- Bandisce soltanto i mostri la cui Evocazione
	-- è stata effettivamente annullata.
	local g=eg:Filter(Card.IsStatus,nil,STATUS_SUMMON_DISABLED)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end