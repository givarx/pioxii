--Buongiorno Carabinieri
local s,id=GetID()

local SET_FALCONE=0x1112
local SET_TSO=0x1111

s.listed_series={SET_FALCONE,SET_TSO}

function s.initial_effect(c)
	------------------------------------------------------------
	-- Considerata una carta "Falcone"
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetValue(SET_FALCONE)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Considerata una carta "TSO Obbligatorio"
	------------------------------------------------------------
	local e2=e1:Clone()
	e2:SetValue(SET_TSO)
	c:RegisterEffect(e2)

	------------------------------------------------------------
	-- Attivazione
	------------------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end

------------------------------------------------------------
-- Magie/Trappole sul Terreno
------------------------------------------------------------
function s.targetfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end

------------------------------------------------------------
-- Solo il giocatore che ha attivato questa carta
-- può aggiungere effetti alla Catena
------------------------------------------------------------
function s.chainlimit(e,rp,tp)
	return tp==rp
end

------------------------------------------------------------
-- Selezione del bersaglio
------------------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField()
			and chkc~=e:GetHandler()
			and s.targetfilter(chkc)
	end

	if chk==0 then
		return Duel.IsExistingTarget(
			s.targetfilter,
			tp,
			LOCATION_ONFIELD,
			LOCATION_ONFIELD,
			1,
			e:GetHandler()
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(
		tp,
		s.targetfilter,
		tp,
		LOCATION_ONFIELD,
		LOCATION_ONFIELD,
		1,1,
		e:GetHandler()
	)

	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)

	-- L'avversario non può rispondere,
	-- nemmeno dopo un ulteriore effetto concatenato da te.
	Duel.SetChainLimitTillChainEnd(s.chainlimit)
end

------------------------------------------------------------
-- Carta che l'avversario può scartare
------------------------------------------------------------
function s.discardfilter(c)
	return c:IsDiscardable()
end

------------------------------------------------------------
-- Risoluzione
------------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opponent=1-tp

	-- L'avversario può scartare 1 carta
	-- per impedire l'applicazione dell'effetto.
	if Duel.IsExistingMatchingCard(
		s.discardfilter,
		opponent,
		LOCATION_HAND,
		0,
		1,nil
	) and Duel.SelectYesNo(opponent,aux.Stringid(id,1)) then

		local ct=Duel.DiscardHand(
			opponent,
			s.discardfilter,
			1,1,
			REASON_COST+REASON_DISCARD
		)

		if ct>0 then
			return
		end
	end

	-- Se non scarta, distrugge la carta bersaglio.
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end