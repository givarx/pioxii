--Effetto per Magia/Trappola - YGO Omega / MDPro
--Rinominare c<ID_NUMERICO_DELLA_CARTA>.lua prima dell'uso.
--Rimischia nel Deck 1 mostro "Leone" che controlli;
--distruggi 2 carte sul Terreno.
--Il tipo della Magia/Trappola va impostato nel database.
--Non sceglie bersagli e non ha un limite per turno.
local s,id=GetID()
local SET_LEONE=0x1118
s.listed_series={SET_LEONE}

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--Non conta il mostro pagato come costo, ne' gli equipaggiamenti
--che perderebbero il loro bersaglio quando il mostro lascia il Terreno.
function s.remainingfilter(c,mc)
	return c~=mc and c:GetEquipTarget()~=mc and c:IsDestructable()
end

function s.costfilter(c,e,tp)
	if not c:IsType(TYPE_MONSTER) or not c:IsSetCard(SET_LEONE)
		or not c:IsAbleToDeckAsCost() then return false end
	local ct=Duel.GetMatchingGroupCount(s.remainingfilter,tp,
		LOCATION_ONFIELD,LOCATION_ONFIELD,nil,c)
	--Una Magia attivata dalla mano viene collocata sul Terreno.
	--Poiche' l'effetto non bersaglia, puo' distruggere anche se stessa.
	if e:GetHandler():IsLocation(LOCATION_HAND) then ct=ct+1 end
	return ct>=2
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.costfilter,tp,
			LOCATION_MZONE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,
		LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

--SetTarget gestisce anche le verifiche di attivazione:
--non implica che l'effetto scelga bersagli.
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.costfilter,tp,
			LOCATION_MZONE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,PLAYER_ALL,LOCATION_ONFIELD)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsDestructable,tp,
		LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g==0 then return end
	--Se la Catena ha lasciato una sola carta disponibile, distrugge quella.
	local ct=math.min(2,#g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=g:Select(tp,ct,ct,nil)
	Duel.Destroy(sg,REASON_EFFECT)
end
