--N° 104: Il prestigiatroie
--Number 104: The Mastermage
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x1111),12,2) -- 0x1111 rappresenta "TSO Obbligatorio"
	c:EnableReviveLimit()
	
	--cannot be target for "TSO Obbligatorio" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tgtarget)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	
	--atk/def up based on "TSO Obbligatorio" cards
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	
	--negate spell/trap (Quick Effect)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.negcon)
	e4:SetCost(s.negcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
	
	--attach opponent's monster as xyz material (Quick Effect)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetHintTiming(TIMING_BATTLE_PHASE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+1)
	e5:SetCondition(s.attachcon)
	e5:SetTarget(s.attachtg)
	e5:SetOperation(s.attachop)
	c:RegisterEffect(e5)
end

--target protection for "TSO Obbligatorio" monsters
function s.tgtarget(e,c)
	return c:IsSetCard(0x1111) --"TSO Obbligatorio"
end

--atk/def calculation
function s.atkval(e,c)
	local g1=Duel.GetMatchingGroupCount(aux.FilterBoolFunctionEx(Card.IsSetCard,0x1111),c:GetControler(),LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroupCount(aux.FilterBoolFunctionEx(Card.IsSetCard,0x1111),c:GetControler(),LOCATION_REMOVED,0,nil)
	return (g1+g2)*500
end

--negate condition
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end

--negate cost
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

--negate target
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end

--negate operation
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end

--attach condition
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return Duel.IsBattlePhase() and not c:IsStatus(STATUS_CHAINING) and bc and bc:IsControler(1-tp) and c:GetOverlayCount()==0
end

--attach target
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsOnField() and bc:IsCanBeEffectTarget(e) and not bc:IsImmuneToEffect(e) end
	Duel.SetTargetCard(bc)
end

--attach operation
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e) then
		if not tc:IsImmuneToEffect(e) then
			Duel.Overlay(c,tc,true)
			--cannot attack until end of next turn
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3206)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_OPPO_TURN,2)
			c:RegisterEffect(e1)
		end
	end
end