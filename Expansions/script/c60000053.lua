--Il Leone Appena Sveglio
-- Mostro
local s,id=GetID()

local SET_LEONE=0x1118

function s.initial_effect(c)
	------------------------------------------------------------
	-- Non può essere Evocato Specialmente dal Deck
	------------------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

	------------------------------------------------------------
	-- Evocazione Speciale dalla Mano
	-- mandando mostri da Mano/Terreno con Livello totale >=8
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Stessa procedura dal Cimitero
	------------------------------------------------------------
	local e2=e1:Clone()
	e2:SetRange(LOCATION_GRAVE)
	c:RegisterEffect(e2)

	------------------------------------------------------------
	-- Quando viene Evocato: distruggi 1 carta sul Terreno
	------------------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)

	------------------------------------------------------------
	-- Se lascia il Terreno:
	-- manda 1 mostro "Leone" dal Deck al Cimitero
	------------------------------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)

	------------------------------------------------------------
	-- Danno perforante
	------------------------------------------------------------
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e5)
end

s.listed_series={SET_LEONE}

------------------------------------------------------------
-- Non può essere Evocato Specialmente dal Deck
------------------------------------------------------------

function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_DECK
end

------------------------------------------------------------
-- Materiali per l'Evocazione
------------------------------------------------------------

function s.spfilter(c)
	return c:IsType(TYPE_MONSTER)
		and c:GetLevel()>0
		and c:IsAbleToGraveAsCost()
end

------------------------------------------------------------
-- Controlla se un gruppo ha Livello totale >= 8
------------------------------------------------------------

function s.levelcheck(g)
	return g:GetSum(Card.GetLevel)>=8
end

------------------------------------------------------------
-- Condizione Evocazione
------------------------------------------------------------

function s.spcon(e,c)
	if c==nil then
		return true
	end

	local tp=c:GetControler()

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		return false
	end

	local g=Duel.GetMatchingGroup(
		s.spfilter,
		tp,
		LOCATION_HAND+LOCATION_MZONE,
		0,
		c
	)

	return g:CheckSubGroup(
		s.levelcheck,
		1,
		g:GetCount()
	)
end

------------------------------------------------------------
-- Operazione:
-- seleziona i mostri e mandali al Cimitero
------------------------------------------------------------

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(
		s.spfilter,
		tp,
		LOCATION_HAND+LOCATION_MZONE,
		0,
		c
	)

	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_TOGRAVE
	)

	local sg=g:SelectSubGroup(
		tp,
		s.levelcheck,
		false,
		1,
		g:GetCount()
	)

	if sg then
		Duel.SendtoGrave(
			sg,
			REASON_COST
		)
	end
end

------------------------------------------------------------
-- Quando viene Evocato: distruggi 1 carta
------------------------------------------------------------

function s.desfilter(c)
	return c:IsOnField()
		and c:IsDestructable()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField()
			and s.desfilter(chkc)
	end

	if chk==0 then
		return Duel.IsExistingTarget(
			s.desfilter,
			tp,
			LOCATION_ONFIELD,
			LOCATION_ONFIELD,
			1,
			nil
		)
	end

	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_DESTROY
	)

	local g=Duel.SelectTarget(
		tp,
		s.desfilter,
		tp,
		LOCATION_ONFIELD,
		LOCATION_ONFIELD,
		1,
		1,
		nil
	)

	Duel.SetOperationInfo(
		0,
		CATEGORY_DESTROY,
		g,
		1,
		0,
		0
	)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()

	if tc
		and tc:IsRelateToEffect(e) then
		Duel.Destroy(
			tc,
			REASON_EFFECT
		)
	end
end

------------------------------------------------------------
-- Se lascia il Terreno:
-- manda 1 "Leone" dal Deck al Cimitero
------------------------------------------------------------

function s.tgfilter(c)
	return c:IsSetCard(SET_LEONE)
		and c:IsType(TYPE_MONSTER)
		and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.tgfilter,
			tp,
			LOCATION_DECK,
			0,
			1,
			nil
		)
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_TOGRAVE,
		nil,
		1,
		tp,
		LOCATION_DECK
	)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_TOGRAVE
	)

	local g=Duel.SelectMatchingCard(
		tp,
		s.tgfilter,
		tp,
		LOCATION_DECK,
		0,
		1,
		1,
		nil
	)

	if g:GetCount()>0 then
		Duel.SendtoGrave(
			g,
			REASON_EFFECT
		)
	end
end