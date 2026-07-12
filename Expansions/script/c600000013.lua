-- scopece sulekko
local s,id=GetID(),flag
function s.initial_effect(c)
	--Normal Summon with 3 Tributes
	aux.AddNormalSummonProcedure(c,true,false,3,3,0,0,s.filter)
	aux.AddNormalSetProcedure(c)
	--Cannot be Special Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.spval)
	c:RegisterEffect(e0)
	--This card's Normal Summon cannot be negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	c:RegisterEffect(e1)
	--Other cards and effects cannot be activated when Normal Summoned
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(function(e) Duel.SetChainLimitTillChainEnd(s.genchainlm(e:GetHandler())) end)
	c:RegisterEffect(e2)
	--Salva i tributi usati per la Normal Summon
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e4)
end
function s.spval(e,se,sp,st)
	return st==SUMMON_TYPE_SPECIAL+SUMMON_WITH_MONSTER_REBORN and Duel.IsPlayerAffectedByEffect(sp,41044418) and e:GetHandler():IsControler(sp)
end
function s.econ(e)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.genchainlm(c)
	return	function(e,rp,tp)
			return e:GetHandler()==c
		end
end
function s.filter(c)
	if(c.GetCardID(c)==600000012) then
		flag = 1 

	end
	return c:IsSetCard(0x1111)
end
-- Salva i tributi usati per la Normal Summon
function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local mat=Duel.GetTributeGroup()
    if mat then
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD_DISABLE,0,1)
        c.material_group=Group.CreateGroup()
        c.material_group:Merge(mat)
    end
end

-- Raddoppia ATK se 600000012 è stato usato come tributo
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local mat=c:GetMaterial()
    if mat and mat:IsExists(function(tc) return tc:IsCode(600000012) end,1,nil) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(c:GetBaseAttack()*2)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end