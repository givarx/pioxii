--Lorenzo Guerriero Della Notte
local s,id=GetID()

local SET_LORENZO=0x1113
local SET_TSO=0x1111

s.listed_series={SET_LORENZO,SET_TSO}

function s.initial_effect(c)
	------------------------------------------------------------
	-- Considerata "TSO Obbligatorio" sul Terreno e nel Cimitero
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(
		EFFECT_FLAG_SINGLE_RANGE
		+EFFECT_FLAG_CANNOT_DISABLE
	)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetRange(LOCATION_ONFIELD+LOCATION_GRAVE)
	e1:SetValue(SET_TSO)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Durante il calcolo dei danni:
	-- scarta questa carta per potenziare un "Lorenzo"
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.atkcon)
	e2:SetCost(s.atkcost)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)

	------------------------------------------------------------
	-- Distrugge il mostro in Difesa con cui combatte
	------------------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end

------------------------------------------------------------
-- Restituisce il proprio "Lorenzo" e il mostro avversario
------------------------------------------------------------
function s.getbattle(tp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()

	-- Non applicabile agli attacchi diretti
	if not a or not d then
		return nil,nil
	end

	if a:IsControler(tp) then
		return a,d
	end
	return d,a
end

------------------------------------------------------------
-- Condizione del potenziamento
------------------------------------------------------------
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc,bc=s.getbattle(tp)
	return tc and bc
		and tc:IsControler(tp)
		and tc:IsFaceup()
		and tc:IsSetCard(SET_LORENZO)
		and bc:IsFaceup()
		and bc:GetAttack()>0
end

------------------------------------------------------------
-- Costo: scarta questa carta
------------------------------------------------------------
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsDiscardable()
	end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end

------------------------------------------------------------
-- Guadagna l'ATK attuale del mostro avversario
------------------------------------------------------------
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc,bc=s.getbattle(tp)
	if not tc or not bc
		or not tc:IsControler(tp)
		or not tc:IsFaceup()
		or not tc:IsLocation(LOCATION_MZONE)
		or not bc:IsFaceup()
		or not bc:IsLocation(LOCATION_MZONE) then
		return
	end

	local atk=bc:GetAttack()
	if atk<=0 then return end

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(
		RESET_EVENT+RESETS_STANDARD
		+RESET_PHASE+PHASE_END
	)
	tc:RegisterEffect(e1)
end

------------------------------------------------------------
-- Condizione: combatte con un mostro in Difesa
------------------------------------------------------------
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsDefensePos()
end

------------------------------------------------------------
-- Informazioni sulla distruzione: non sceglie come bersaglio
------------------------------------------------------------
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end

------------------------------------------------------------
-- Distruzione del mostro con cui combatte
------------------------------------------------------------
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local bc=c:GetBattleTarget()
	if bc and bc:IsRelateToBattle()
		and bc:IsDefensePos() then
		Duel.Destroy(bc,REASON_EFFECT)
	end
end