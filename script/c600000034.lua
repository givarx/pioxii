-- c600000034.lua
-- Effetto della carta:
-- "Non può essere evocata normalmente / posizionata.
-- Quando 2 o più mostri lasciano il terreno: puoi evocare questa carta dal tuo cimitero in posizione di difesa,
-- ma alla fine del turno bandisci questa carta."

local s,id=GetID()
function s.initial_effect(c)
	-- Impedisce l'evocazione normale/posizionamento
	c:EnableUnsummonable()

	-- Effetto: Evocazione speciale dal cimitero quando 2 o più mostri lasciano il terreno
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- Controlla se almeno 2 mostri che erano in una zona mostri hanno lasciato il campo
	local ct=eg:FilterCount(s.cfilter,nil)
	return ct>=2 
end

function s.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_DEFENSE)~=0 then
		-- Al termine del turno, bandisci questa carta
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(c)
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			local tc=e:GetLabelObject()
			if tc and tc:IsLocation(LOCATION_MZONE) then
				Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
			end
		end)
		Duel.RegisterEffect(e1,tp)
	end
end