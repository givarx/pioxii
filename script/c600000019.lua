--Chemio Counter Monster
local s,id=GetID()
function s.initial_effect(c)
	--enable counter
	c:EnableCounterPermit(0x4321)
	c:SetCounterLimit(0x4321, 150)
	--add counter during standby phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--move counter to any monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.mvcon)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
	--damage when monster leaves field (removed - using individual effects instead)
	--damage when monster is destroyed with counters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.destroyop)
	c:RegisterEffect(e3)
end

--add counter condition
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
--add counter operation
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() then
		c:AddCounter(0x4321,1)
		Debug.Message("Counter aggiunto automaticamente! Totale: " .. c:GetCounter(0x4321))
	end
end
--move counter condition
function s.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local ct = e:GetHandler():GetCounter(0x4321)
	Debug.Message("Controllo condizione move: counter presenti = " .. ct)
	return ct>0
end
--counter filter
function s.ctfilter(c)
	return c:IsFaceup() and c~=nil
end
--move counter target
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.ctfilter(chkc) end
	if chk==0 then 
		Debug.Message("Controllo target chiamato")
		local exists = Duel.IsExistingTarget(s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
		Debug.Message("Controllo target: esistono bersagli validi = " .. tostring(exists))
		return exists
	end
	Debug.Message("Seleziono target...")
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
--move counter operation
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	Debug.Message("Operazione chiamata!")
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Debug.Message("Condizioni soddisfatte, procedo...")
		-- Check if we have counter 0x4321 and remove it
		local our_counters = c:GetCounter(0x4321)
		Debug.Message("Counter 0x4321 sulla carta origine: " .. our_counters)
		if our_counters > 0 then
			c:RemoveCounter(tp,0x4321,1,REASON_EFFECT)
			Debug.Message("Counter 0x4321 rimosso dalla carta origine")
		else
			Debug.Message("ERRORE: Nessun counter 0x4321 da rimuovere!")
			return
		end
		
		local current_counters = tc:GetCounter(0x4321)
		Debug.Message("Counter attuali su bersaglio: " .. current_counters)
		
		--enable counter support if needed
		if current_counters == 0 then
			tc:EnableCounterPermit(0x4321)
			Debug.Message("Abilitati counter sulla carta bersaglio: " .. tc:GetCode())
		end
		
		--add counter (works for both cases)
		tc:AddCounter(0x4321,1)
		Debug.Message("Counter aggiunto a " .. tc:GetCode() .. "! Totale su bersaglio: " .. tc:GetCounter(0x4321))
	else
		Debug.Message("Condizioni non soddisfatte!")
	end
end
--damage operation when monster is destroyed
function s.destroyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsType(TYPE_MONSTER) then
			local ct=tc:GetCounter(0x4321)
			if ct>0 then
				local p=tc:GetOwner()
				local damage_amount = ct * 500
				Debug.Message("Mostro " .. tc:GetCode() .. " con " .. ct .. " counter distrutto. Danno: " .. damage_amount .. " al proprietario " .. p)
				Duel.Damage(p,damage_amount,REASON_EFFECT)
			end
		end
		tc=eg:GetNext()
	end
end
--manual counter operation
function s.manualct(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() then
		c:AddCounter(0x4321,1)
		Debug.Message("Counter manualmente aggiunto! Totale: " .. c:GetCounter(0x4321))
	end
end