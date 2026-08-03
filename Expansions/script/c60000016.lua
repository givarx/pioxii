-- amico delle guardie
--Quando è presente un mostro "Mafioso" o chad sul terreno,e il tuo avversario evoca specialmente due o piu mostri sul terreno: Annulla le evocaziioni e manda quelle carte al cimitero.
local s,id=GetID()
function s.initial_effect(c)
    --Controtrappola: Annulla l'evocazione speciale di 2+ mostri e manda al cimitero
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_names={27204312}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(1-tp,id)>=2
end
function s.cfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x2222) or c:IsSetCard(0x3333))
end


function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,eg,#eg,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateSummon(eg)
    Duel.SendtoGrave(eg,REASON_EFFECT)
end