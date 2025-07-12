local s,id=GetID()
function s.initial_effect(c)
	-- Negate effect and shuffle this card into the Deck
	local e1=Effect.CreateEffect(c)
	   e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(0)
	e1:SetCost(s.cost_func)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1111)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsChainNegatable(ev)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
   Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)  -- Set info for shuffling card into deck
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
   -- Negate the activation
   if Duel.NegateActivation(ev) then
       -- Destroy the triggered card if it's still on the field
       if re:GetHandler():IsRelateToEffect(re) then
           Duel.Destroy(eg,REASON_EFFECT)
       end
       -- Prevent this card from going to the Graveyard
       Duel.CancelToGrave(c)
       -- Shuffle this card into the Deck
       Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
   end
end
function s.cost_func(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- Nessun costo aggiuntivo, la carta verrà rimischiata dopo la risoluzione
end