-- c600000034.lua
-- Effetto della carta:
-- "Non può essere evocata normalmente / posizionata.
-- Quando 2 o più mostri lasciano il terreno: puoi evocare questa carta dal tuo cimitero in posizione di difesa,
-- ma alla fine del turno bandisci questa carta."

local s,id=GetID()
function s.initial_effect(c)
	-- Impedisce l'evocazione normale/posizionamento
	c:EnableUnsummonable()

	-- Effetto 1: Dalla mano, annulla evocazione dall'Extra Deck dell'avversario
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)

	-- Effetto 2: Evocazione speciale dal cimitero quando 2 o più mostri lasciano il terreno
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

-- Effetto 1: Funzioni per negare evocazione dall'Extra Deck
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.disfilter,1,nil,1-tp)
end

function s.disfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end

function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.disfilter,nil,1-tp)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.disfilter,nil,1-tp)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

-- Effetto 2: Funzioni per evocazione dal cimitero
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
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
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