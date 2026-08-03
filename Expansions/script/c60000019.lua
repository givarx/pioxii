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
	--damage when monster leaves field (removed - using individual effects instead)
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.damcon)
    e3:SetTarget(s.damtg)
    e3:SetOperation(s.damop)
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
		--Debug.Message("Counter aggiunto automaticamente! Totale: " .. c:GetCounter(0x4321))
	end
end

-- Controlla che la carta distrutta fosse un mostro sul Terreno
function s.damfilter(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsReason(REASON_DESTROY)
end

-- L'effetto si attiva se almeno un mostro è stato distrutto
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.damfilter,1,nil)
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local ct=c:GetCounter(COUNTER_CUSTOM)

    if chk==0 then
        return ct>0
            and eg:IsExists(s.damfilter,1,nil)
    end

    -- Memorizza il numero di segnalini al momento dell'attivazione
    e:SetLabel(ct)

    Duel.SetOperationInfo(
        0,
        CATEGORY_DAMAGE,
        nil,
        0,
        PLAYER_ALL,
        ct*300
    )
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    -- Recupera il numero di segnalini memorizzato all'attivazione
    local ct=e:GetLabel()
    if ct<=0 then return end

    local g=eg:Filter(s.damfilter,nil)
    if #g==0 then return end

    local damage0=0
    local damage1=0

    -- Calcola separatamente il danno per ciascun proprietario
    for tc in aux.Next(g) do
        local owner=tc:GetOwner()

        if owner==0 then
            damage0=damage0+ct*500
        elseif owner==1 then
            damage1=damage1+ct*500
        end
    end

    if damage0>0 then
        Duel.Damage(0,damage0,REASON_EFFECT)
    end

    if damage1>0 then
        Duel.Damage(1,damage1,REASON_EFFECT)
    end
end