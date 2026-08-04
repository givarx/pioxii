-- N° 104: Il Prestigiatore
-- 2 mostri di Livello 12 "TSO Obbligatorio"

local s,id=GetID()

function s.initial_effect(c)
	-- Evocazione Xyz
	aux.AddXyzProcedure(
		c,
		aux.FilterBoolFunction(Card.IsSetCard,0x1111),
		12,
		2
	)
	c:EnableReviveLimit()

	-- I mostri "TSO Obbligatorio" che controlli
	-- non possono essere scelti come bersaglio dagli effetti avversari
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tgtarget)
	e1:SetValue(s.tgvalue)
	c:RegisterEffect(e1)

	-- Guadagna 500 ATK/DEF per ogni carta "TSO Obbligatorio"
	-- nel tuo Cimitero e tra le tue carte bandite
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)

	-- Stacca 1 materiale; annulla una Magia/Trappola e bandiscila
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.negcon)
	e4:SetCost(s.negcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)

	-- Durante la Battle Phase, se combatte e non ha materiali:
	-- attacca il mostro avversario a questa carta come materiale
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_LEAVE_GRAVE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetHintTiming(TIMING_BATTLE_PHASE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+1)
	e5:SetCondition(s.attachcon)
	e5:SetTarget(s.attachtg)
	e5:SetOperation(s.attachop)
	c:RegisterEffect(e5)
end

s.listed_series={0x1111}

------------------------------------------------------------
-- Protezione dal targeting
------------------------------------------------------------

function s.tgtarget(e,c)
	return c:IsFaceup()
		and c:IsSetCard(0x1111)
end

-- Solo gli effetti dell'avversario non possono bersagliare
function s.tgvalue(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end

------------------------------------------------------------
-- Aumento ATK/DEF
------------------------------------------------------------

function s.statfilter(c)
	return c:IsSetCard(0x1111)
end

function s.atkval(e,c)
	local tp=c:GetControler()

	local grave=Duel.GetMatchingGroupCount(
		s.statfilter,
		tp,
		LOCATION_GRAVE,
		0,
		nil
	)

	local removed=Duel.GetMatchingGroupCount(
		s.statfilter,
		tp,
		LOCATION_REMOVED,
		0,
		nil
	)

	return (grave+removed)*500
end

------------------------------------------------------------
-- Negazione Magia/Trappola
------------------------------------------------------------

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and Duel.IsChainNegatable(ev)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	end

	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_NEGATE,
		eg,
		1,
		0,
		0
	)

	local rc=re:GetHandler()

	if rc
		and rc:IsRelateToEffect(re)
		and rc:IsAbleToRemove() then
		Duel.SetOperationInfo(
			0,
			CATEGORY_REMOVE,
			rc,
			1,
			0,
			0
		)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateActivation(ev) then
		return
	end

	local rc=re:GetHandler()

	if rc
		and rc:IsRelateToEffect(re)
		and rc:IsAbleToRemove() then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end

------------------------------------------------------------
-- Sovrappone il mostro avversario
------------------------------------------------------------

function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()

	return Duel.IsBattlePhase()
		and c:GetOverlayCount()==0
		and bc
		and bc:IsControler(1-tp)
		and bc:IsLocation(LOCATION_MZONE)
end

function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()

	if chkc then
		return chkc==bc
			and chkc:IsControler(1-tp)
			and chkc:IsLocation(LOCATION_MZONE)
	end

	if chk==0 then
		return bc
			and bc:IsOnField()
			and bc:IsCanBeEffectTarget(e)
			and not bc:IsImmuneToEffect(e)
	end

	Duel.SetTargetCard(bc)
end

function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if not c:IsRelateToEffect(e)
		or not c:IsFaceup()
		or not tc
		or not tc:IsRelateToEffect(e)
		or tc:IsImmuneToEffect(e) then
		return
	end

	-- Vecchia sintassi compatibile con MDPro
	Duel.Overlay(c,tc)

	-- Non può attaccare fino alla fine del prossimo turno
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3206)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(
		EFFECT_FLAG_CANNOT_DISABLE
		+EFFECT_FLAG_CLIENT_HINT
	)
	e1:SetReset(
		RESET_EVENT
		+RESETS_STANDARD
		+RESET_PHASE
		+PHASE_END,
		2
	)
	c:RegisterEffect(e1)
end