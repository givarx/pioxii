--Sempre Vigile, Mai Urbano
-- Mostro Fusione "Falcone"
-- "Falco Il Bandito" + 1 mostro LUCE

local s,id=GetID()

local FALCO_IL_BANDITO=60000045
local SET_FALCONE=0x1112

function s.initial_effect(c)
	------------------------------------------------------------
	-- Materiali Fusione:
	-- "Falco Il Bandito" + 1 mostro LUCE
	------------------------------------------------------------
	-- Materiali Fusione
	c:EnableReviveLimit()

	aux.AddFusionProcFun2(
		c,
		aux.FilterBoolFunction(Card.IsFusionCode,FALCO_IL_BANDITO),
		aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_LIGHT),
		true
	)

	-- Può essere Evocata Specialmente solo tramite Fusione
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(
		EFFECT_FLAG_CANNOT_DISABLE
		+EFFECT_FLAG_UNCOPYABLE
	)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)

	------------------------------------------------------------
	-- Questa carta viene considerata una carta "Falcone"
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetValue(SET_FALCONE)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Annulla gli effetti di tutti gli altri mostri sul Terreno
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(
		LOCATION_MZONE,
		LOCATION_MZONE
	)
	e2:SetTarget(s.distarget)
	c:RegisterEffect(e2)

	local e3=e2:Clone()
	e3:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e3)

	------------------------------------------------------------
	-- Effetto Rapido:
	-- bandisci 1 carta "Falcone" dal tuo Cimitero;
	-- 1 mostro che controlli può attaccare direttamente
	------------------------------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(
		0,
		TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START
	)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.dacost)
	e4:SetTarget(s.datg)
	e4:SetOperation(s.daop)
	c:RegisterEffect(e4)
end

s.listed_names={FALCO_IL_BANDITO}
s.listed_series={SET_FALCONE}

------------------------------------------------------------
-- Materiale Fusione: 1 mostro LUCE
------------------------------------------------------------

function s.fusfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsType(TYPE_MONSTER)
end

------------------------------------------------------------
-- Solamente tramite Evocazione Fusione
------------------------------------------------------------

function s.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)
		==SUMMON_TYPE_FUSION
end

------------------------------------------------------------
-- Annullamento degli altri mostri
------------------------------------------------------------

function s.distarget(e,c)
	return c:IsType(TYPE_MONSTER)
		and not c:IsSetCard(SET_FALCONE)
end

------------------------------------------------------------
-- Costo: bandisci 1 carta "Falcone" dal tuo Cimitero
------------------------------------------------------------

function s.costfilter(c)
	return c:IsSetCard(SET_FALCONE)
		and c:IsAbleToRemoveAsCost()
end

function s.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.costfilter,
			tp,
			LOCATION_GRAVE,
			0,
			1,
			nil
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)

	local g=Duel.SelectMatchingCard(
		tp,
		s.costfilter,
		tp,
		LOCATION_GRAVE,
		0,
		1,
		1,
		nil
	)

	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

------------------------------------------------------------
-- Bersaglio: 1 mostro scoperto che controlli
------------------------------------------------------------

function s.datargetfilter(c)
	return c:IsFaceup()
		and c:IsType(TYPE_MONSTER)
end

function s.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp)
			and chkc:IsLocation(LOCATION_MZONE)
			and s.datargetfilter(chkc)
	end

	if chk==0 then
		return Duel.IsExistingTarget(
			s.datargetfilter,
			tp,
			LOCATION_MZONE,
			0,
			1,
			nil
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)

	Duel.SelectTarget(
		tp,
		s.datargetfilter,
		tp,
		LOCATION_MZONE,
		0,
		1,
		1,
		nil
	)
end

------------------------------------------------------------
-- Il bersaglio può attaccare direttamente
------------------------------------------------------------

function s.daop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()

	if not tc
		or not tc:IsRelateToEffect(e)
		or not tc:IsFaceup() then
		return
	end

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(
		RESET_EVENT
		+RESETS_STANDARD
		+RESET_PHASE
		+PHASE_END
	)
	tc:RegisterEffect(e1)
end