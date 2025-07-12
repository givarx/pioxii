--Carta che non può essere evocata normalmente/posizionata
--Evocazione Speciale dal cimitero quando 2+ mostri lasciano il terreno
--Annulla evocazione dall'Extra Deck dalla mano
local s,id=GetID()
function s.initial_effect(c)
	--Non può essere evocata normalmente/posizionata
	c:EnableUnsummonable()
	
	--Conta i mostri che lasciano il terreno
	if not s.global_check then
		s.global_check=true
		s.monster_left_count=0
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_LEAVE_FIELD)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.GlobalEffect()
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE+PHASE_END)
		ge2:SetOperation(s.resetop)
		Duel.RegisterEffect(ge2,0)
	end
	
	--Evocazione Speciale dal cimitero quando 2+ mostri lasciano il terreno
	--Alla fine della main phase: puoi evocare questa carta dal tuo cimitero in posizione di difesa
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_PHASE+PHASE_MAIN1)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_PHASE+PHASE_MAIN2)
	c:RegisterEffect(e2)
	
	--Annulla evocazione dall'Extra Deck mentre questa carta è nella tua mano
	--Puoi mandare questa carta al cimitero e annullare l'evocazione, dopo di che, bandisci quella carta
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		-- Check if opponent summons from the Extra Deck
		return ep==1-tp and eg:IsExists(Card.IsLocation,1,nil,LOCATION_EXTRA)
	end)
	e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
		Duel.SendtoGrave(e:GetHandler(),REASON_COST)
	end)
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.NegateSpecialSummon(eg) then
			Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
		end
	end)
	c:RegisterEffect(e3)
end

s.monster_left_count=0

--Conta i mostri che lasciano il terreno
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsMonster,nil)
	if #g>0 then
		s.monster_left_count=s.monster_left_count+#g
	end
end

--Reset del contatore alla fine del turno
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	s.monster_left_count=0
end

--Condizione: 2 o più mostri hanno lasciato il terreno
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return s.monster_left_count>=2
end

--Target per l'evocazione speciale dal cimitero
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

--Evocazione speciale in posizione di difesa, ma bandisci alla fine del turno
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		--Bandisci alla fine del turno
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetOperation(s.banop)
		e1:SetLabelObject(c)
		Duel.RegisterEffect(e1,tp)
	end
end

--Operazione per bandire la carta alla fine del turno
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	if c:IsLocation(LOCATION_MZONE) then
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
	end
end