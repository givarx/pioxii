--Attentato Al Leone
local s,id=GetID()

local SET_LEONE=0x1118

function s.initial_effect(c)
	------------------------------------------------------------
	-- Attivazione:
	-- se hai almeno 4 carte "Leone" nel Cimitero,
	-- rimischia tutti i mostri del tuo Cimitero nel Deck;
	-- poi rimischia carte avversarie pari alla metà
	-- dei mostri rimischiati
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Puoi attivare questa Trappola dalla mano
	-- se non controlli nessuna carta
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)

	------------------------------------------------------------
	-- Se è nel Cimitero e l'avversario attiva
	-- una carta o un effetto:
	-- bandisci questa carta; annulla l'attivazione
	-- e rimischia quella carta nel Deck
	------------------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	e3:SetCountLimit(1,id+100)
	c:RegisterEffect(e3)
end

s.listed_series={SET_LEONE}

------------------------------------------------------------
-- Almeno 4 carte "Leone" nel proprio Cimitero
------------------------------------------------------------

function s.leonefilter(c)
	return c:IsSetCard(SET_LEONE)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(
		s.leonefilter,
		tp,
		LOCATION_GRAVE,
		0,
		4,
		nil
	)
end

------------------------------------------------------------
-- Attivazione dalla mano:
-- non controlli nessuna carta
------------------------------------------------------------

function s.handcon(e)
	local tp=e:GetHandlerPlayer()

	return Duel.GetFieldGroupCount(
		tp,
		LOCATION_ONFIELD,
		0
	)==0
end

------------------------------------------------------------
-- Mostri nel proprio Cimitero rimischiabili
------------------------------------------------------------

function s.monsterfilter(c)
	return c:IsType(TYPE_MONSTER)
		and c:IsAbleToDeck()
end

------------------------------------------------------------
-- Carte avversarie rimischiabili
------------------------------------------------------------

function s.deckfilter(c)
	return c:IsAbleToDeck()
end

------------------------------------------------------------
-- Target primo effetto
------------------------------------------------------------

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.monsterfilter,
			tp,
			LOCATION_GRAVE,
			0,
			1,
			nil
		)
	end

	local g=Duel.GetMatchingGroup(
		s.monsterfilter,
		tp,
		LOCATION_GRAVE,
		0,
		nil
	)

	Duel.SetOperationInfo(
		0,
		CATEGORY_TODECK,
		g,
		g:GetCount(),
		tp,
		LOCATION_GRAVE
	)
end

------------------------------------------------------------
-- Risoluzione primo effetto
------------------------------------------------------------

function s.activate(e,tp,eg,ep,ev,re,r,rp)

	--------------------------------------------------------
	-- Prende TUTTI i mostri attualmente nel tuo Cimitero
	--------------------------------------------------------
	local g=Duel.GetMatchingGroup(
		s.monsterfilter,
		tp,
		LOCATION_GRAVE,
		0,
		nil
	)

	local ct=g:GetCount()

	if ct==0 then
		return
	end

	--------------------------------------------------------
	-- Rimischia tutti i mostri nel Deck
	--------------------------------------------------------
	local returned=Duel.SendtoDeck(
		g,
		nil,
		SEQ_DECKSHUFFLE,
		REASON_EFFECT
	)

	if returned==0 then
		return
	end

	--------------------------------------------------------
	-- Numero di carte da rimischiare:
	-- mostri effettivamente rimischiati / 2
	-- arrotondato per difetto
	--------------------------------------------------------
	local num=math.floor(returned/2)

	if num<=0 then
		return
	end

	--------------------------------------------------------
	-- Carte controllate dall'avversario
	--------------------------------------------------------
	local og=Duel.GetMatchingGroup(
		s.deckfilter,
		tp,
		0,
		LOCATION_ONFIELD,
		nil
	)

	if og:GetCount()==0 then
		return
	end

	-- Se l'avversario controlla meno carte,
	-- rimischia tutte quelle disponibili
	if num>og:GetCount() then
		num=og:GetCount()
	end

	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_TODECK
	)

	local sg=og:Select(
		tp,
		num,
		num,
		nil
	)

	Duel.SendtoDeck(
		sg,
		nil,
		SEQ_DECKSHUFFLE,
		REASON_EFFECT
	)
end

------------------------------------------------------------
-- EFFETTO DAL CIMITERO
------------------------------------------------------------

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
		and Duel.IsChainNegatable(ev)
end

------------------------------------------------------------
-- Costo: bandisci questa carta dal Cimitero
------------------------------------------------------------

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsAbleToRemoveAsCost()
	end

	Duel.Remove(
		c,
		POS_FACEUP,
		REASON_COST
	)
end

------------------------------------------------------------
-- Target negazione
------------------------------------------------------------

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
end

------------------------------------------------------------
-- Annulla l'attivazione e rimischia la carta
------------------------------------------------------------

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()

	if not Duel.NegateActivation(ev) then
		return
	end

	if rc
		and rc:IsRelateToEffect(re)
		and rc:IsAbleToDeck() then

		Duel.SendtoDeck(
			rc,
			nil,
			SEQ_DECKSHUFFLE,
			REASON_EFFECT
		)
	end
end