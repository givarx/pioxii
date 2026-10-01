--Lorenzo a Mangiasj
local s,id=GetID()
local SET_LORENZO=0x1113

s.listed_series={SET_LORENZO}

function s.initial_effect(c)
	------------------------------------------------------------
	-- Puoi convertire il recupero LP in danno all'avversario
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.replacecon)
	e1:SetOperation(s.replaceop)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Evocata dall'effetto di un mostro "Lorenzo":
	-- recupera 1000 LP
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.reccon)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
end

------------------------------------------------------------
-- Riconosce un effetto che prevede recupero LP per te
------------------------------------------------------------
function s.replacecon(e,tp,eg,ep,ev,re,r,rp)
	local exists,g,count,player,amount=
		Duel.GetOperationInfo(ev,CATEGORY_RECOVER)

	return exists
		and (player==tp or player==PLAYER_ALL)
		and not Duel.IsChainDisabled(ev)
end

------------------------------------------------------------
-- Scelta facoltativa prima della risoluzione
------------------------------------------------------------
function s.replaceop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		return
	end

	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)

	-- Converte in danno il recupero provocato da questo effetto.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REVERSE_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(re)
	e1:SetValue(s.reverseval)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)

	-- Trasferisce all'avversario soltanto il danno
	-- derivato dal recupero di questo stesso effetto.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REFLECT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetLabelObject(re)
	e2:SetValue(s.reflectval)
	e2:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e2,tp)

	-- Rimuove entrambi gli effetti appena questo anello
	-- della Catena ha terminato di risolversi.
	local cleanup=Effect.CreateEffect(c)
	cleanup:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	cleanup:SetCode(EVENT_CHAIN_SOLVED)
	cleanup:SetReset(RESET_CHAIN)
	cleanup:SetOperation(function(ce,ctp,ceg,cep,cev)
		if cev==ev then
			e1:Reset()
			e2:Reset()
			ce:Reset()
		end
	end)
	Duel.RegisterEffect(cleanup,tp)
end

function s.reverseval(e,re,r,rp)
	return re~=nil and re==e:GetLabelObject()
end

function s.reflectval(e,re,damage,r,rp,rc)
	return re~=nil
		and re==e:GetLabelObject()
		and bit.band(r,REASON_RRECOVER)~=0
end

------------------------------------------------------------
-- Controlla l'effetto che ha effettuato l'Evocazione
------------------------------------------------------------
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetHandler():GetReasonEffect()
	if not se or not se:IsActiveType(TYPE_MONSTER) then
		return false
	end

	local sc=se:GetHandler()
	return sc and sc:IsSetCard(SET_LORENZO)
end

------------------------------------------------------------
-- Recupero di 1000 LP
------------------------------------------------------------
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end

function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,amount=Duel.GetChainInfo(
		0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM
	)
	Duel.Recover(p,amount,REASON_EFFECT)
end