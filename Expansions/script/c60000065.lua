--Lorenzo a Mangiasj
-- Mostro "Lorenzo"
local s,id=GetID()
local SET_LORENZO=0x1113

s.listed_series={SET_LORENZO}

function s.initial_effect(c)
	------------------------------------------------------------
	-- Conversione facoltativa del recupero LP in danno
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
	-- guadagna 1000 LP e bandisci un mostro dal Cimitero avversario
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.reccon)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
end

------------------------------------------------------------
-- Effetto che prevede un recupero LP per te
------------------------------------------------------------
function s.replacecon(e,tp,eg,ep,ev,re,r,rp)
	local exists,g,count,player,amount=
		Duel.GetOperationInfo(ev,CATEGORY_RECOVER)

	return exists
		and (player==tp or player==PLAYER_ALL)
		and not Duel.IsChainDisabled(ev)
end

------------------------------------------------------------
-- Scegli se convertire il recupero
------------------------------------------------------------
function s.replaceop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		return
	end

	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)

	-- Trasforma in danno il recupero di questo effetto.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REVERSE_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(re)
	e1:SetValue(s.reverseval)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)

	-- Trasferisce quel danno all'avversario.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REFLECT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetLabelObject(re)
	e2:SetValue(s.reflectval)
	e2:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e2,tp)

	-- Rimuove la conversione dopo la risoluzione
	-- di questo specifico anello della Catena.
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
-- Evocazione Speciale tramite un mostro "Lorenzo"
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
-- Mostro bandibile dal Cimitero
------------------------------------------------------------
function s.rmfilter(c)
	return c:IsType(TYPE_MONSTER)
		and c:IsAbleToRemove()
end

------------------------------------------------------------
-- Informazioni sull'effetto: non sceglie bersagli
------------------------------------------------------------
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(
		0,CATEGORY_RECOVER,nil,0,tp,1000
	)

	local g=Duel.GetMatchingGroup(
		aux.NecroValleyFilter(s.rmfilter),
		tp,0,LOCATION_GRAVE,nil
	)
	if g:GetCount()>0 then
		Duel.SetOperationInfo(
			0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE
		)
	end
end

------------------------------------------------------------
-- Recupero LP e bando
------------------------------------------------------------
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- Può essere convertito in 1000 danni dal primo effetto.
	Duel.Recover(tp,1000,REASON_EFFECT)

	-- Il bando viene applicato anche se il recupero
	-- è stato convertito in danno.
	Duel.BreakEffect()

	local g=Duel.GetMatchingGroup(
		aux.NecroValleyFilter(s.rmfilter),
		tp,0,LOCATION_GRAVE,nil
	)
	if g:GetCount()==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,1,1,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end