--Sitcky Fingers TSO Obbligatorio
--Rinominare questo file c<ID_NUMERICO_DELLA_CARTA>.lua.
--Database: Mostro/Effetto/Synchro; setcode 0x1111.
--Livello, ATK, DEF, Tipo e Attributo vanno definiti nel database.
--Stringa 0: Equipaggia 1 mostro da un Cimitero o bandito
--Stringa 1: Manda l'equipaggiamento al Cimitero per salvare 1 carta
--1 Tuner "TSO Obbligatorio" + 1+ mostri non-Tuner
--Il bonus usa meta' dell'ATK originale stampato ("?" vale 0).
--La sostituzione salva UNA carta sul Terreno, di qualsiasi giocatore.
--Nessun limite per turno: non e' previsto dal testo fornito.

local s,id=GetID()
local SET_TSO=0x1111

function s.initial_effect(c)
	c:EnableReviveLimit()
	--Supporto delle due famiglie di procedure Synchro.
	if aux.AddSynchroProcedure then
		aux.AddSynchroProcedure(c,s.tunerfilter,aux.NonTuner(nil),1)
	elseif Synchro and Synchro.AddProcedure then
		Synchro.AddProcedure(c,s.tunerfilter,1,1,Synchro.NonTuner(nil),1,99)
	else
		error("Procedura Synchro non disponibile nelle librerie del simulatore")
	end

	--Quando viene Evocato Synchro: equipaggia 1 mostro.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)

	--Bonus continuo: termina quando il relativo equipaggiamento lascia.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	--Sostituzione della distruzione per effetto dell'avversario.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.desreptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)

	--Sostituzione del bandimento: verifica la destinazione prevista.
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SEND_REPLACE)
	e4:SetTarget(s.banreptg)
	c:RegisterEffect(e4)
end

function s.tunerfilter(c)
	return c:IsSetCard(SET_TSO)
end

function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.eqfilter(c,tp)
	return c:IsType(TYPE_MONSTER)
		and (c:IsLocation(LOCATION_GRAVE)
			or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
		and not c:IsForbidden()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local loc=LOCATION_GRAVE+LOCATION_REMOVED
	if chkc then return chkc:IsLocation(loc) and s.eqfilter(chkc,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingTarget(s.eqfilter,tp,loc,loc,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,loc,loc,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not c:IsFaceup()
		or not c:IsLocation(LOCATION_MZONE) or not c:IsControler(tp)
		or not tc or not tc:IsRelateToEffect(e)
		or not s.eqfilter(tc,tp) or tc:IsImmuneToEffect(e)
		or c:IsImmuneToEffect(e)
		or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if not Duel.Equip(tp,tc,c,false) then return end

	--Resta equipaggiato esclusivamente a questa istanza del Synchro.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetLabelObject(c)
	e1:SetValue(s.eqlimit)
	tc:RegisterEffect(e1)
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,c:GetFieldID())
end

function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

--Riconosce solo i mostri equipaggiati tramite questo effetto.
function s.ownEquip(c,sc)
	return c:IsFaceup() and c:GetEquipTarget()==sc
		and c:GetFlagEffect(id)>0
		and c:GetFlagEffectLabel(id)==sc:GetFieldID()
end

function s.atkval(e,c)
	local sc=e:GetHandler()
	local g=sc:GetEquipGroup():Filter(s.ownEquip,nil,sc)
	local atk=0
	for tc in aux.Next(g) do
		atk=atk+math.floor(math.max(0,tc:GetTextAttack())/2)
	end
	return atk
end

function s.repfilter(c,tp,banish)
	if not c:IsLocation(LOCATION_ONFIELD)
		or not c:IsReason(REASON_EFFECT) or c:GetReasonPlayer()~=1-tp
		or c:IsReason(REASON_REPLACE) then return false end
	if banish then
		return c:GetDestination()==LOCATION_REMOVED
			and not c:IsReason(REASON_DESTROY)
	end
	return true
end

function s.payfilter(c,sc,eg,e)
	return s.ownEquip(c,sc) and c:IsAbleToGraveAsCost()
		and not c:IsImmuneToEffect(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and not eg:IsContains(c)
end

function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	return s.reptg(e,tp,eg,chk,false)
end

function s.banreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	return s.reptg(e,tp,eg,chk,true)
end

function s.reptg(e,tp,eg,chk,banish)
	local c=e:GetHandler()
	local eqg=c:GetEquipGroup():Filter(s.payfilter,nil,c,eg,e)
	if chk==0 then
		return #eqg>0 and eg:IsExists(s.repfilter,1,nil,tp,banish)
	end
	if #eqg==0 or not eg:IsExists(s.repfilter,1,nil,tp,banish)
		or not Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1)) then return false end

	--Selezione durante la sostituzione: non e' un bersaglio in Catena.
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local sg=eg:Filter(s.repfilter,nil,tp,banish):Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local ec=eqg:Select(tp,1,1,nil):GetFirst()
	e:SetLabelObject(sg:GetFirst())
	e:SetLabel(ec:GetFieldID())
	return true
end

function s.repval(e,c)
	return c==e:GetLabelObject()
end

function s.eqidfilter(c,fid)
	return c:GetFieldID()==fid
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	local ec=g:Filter(s.eqidfilter,nil,e:GetLabel()):GetFirst()
	if ec then
		Duel.SendtoGrave(ec,REASON_EFFECT+REASON_REPLACE)
	end
	e:SetLabelObject(nil)
	e:SetLabel(0)
end
