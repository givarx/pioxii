-- Buongiorno Carabinieri
-- Magia Normale
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
-- Solo tu puoi aggiungere effetti alla Catena
------------------------------------------------------------
function s.chainlimit(e,rp,tp)
	return tp==rp
end

------------------------------------------------------------
-- Bersaglio: 1 carta sul Terreno, eccetto questa carta
------------------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField()
			and chkc~=e:GetHandler()
	end

	if chk==0 then
		return Duel.IsExistingTarget(
			aux.TRUE,
			tp,LOCATION_ONFIELD,LOCATION_ONFIELD,
			1,e:GetHandler()
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(
		tp,aux.TRUE,
		tp,LOCATION_ONFIELD,LOCATION_ONFIELD,
		1,1,e:GetHandler()
	)

	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetChainLimitTillChainEnd(s.chainlimit)
end

------------------------------------------------------------
-- Carta scartabile dello stesso tipo: Mostro/Magia/Trappola
------------------------------------------------------------
function s.discardfilter(c,cardtype)
	return c:IsDiscardable()
		and bit.band(c:GetType(),cardtype)~=0
end

------------------------------------------------------------
-- Risoluzione
------------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc
		or not tc:IsRelateToEffect(e)
		or not tc:IsOnField() then
		return
	end

	-- Considera il tipo del bersaglio alla risoluzione.
	local cardtype=bit.band(
		tc:GetType(),
		TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP
	)
	local opponent=1-tp

	-- L'avversario può scartare una carta dello stesso tipo.
	if Duel.IsExistingMatchingCard(
		s.discardfilter,
		opponent,LOCATION_HAND,0,
		1,nil,cardtype
	) and Duel.SelectYesNo(opponent,aux.Stringid(id,1)) then

		local ct=Duel.DiscardHand(
			opponent,
			s.discardfilter,
			1,1,
			REASON_COST+REASON_DISCARD,
			nil,
			cardtype
		)

		if ct>0 then
			return
		end
	end

	-- Se non scarta, distrugge il bersaglio.
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end