--Cortesemente, La bibita Senza Ghiaccio
-- Magia Normale "Lorenzo"
local s,id=GetID()
local SET_LORENZO=0x1113

s.listed_series={SET_LORENZO}

function s.initial_effect(c)
	------------------------------------------------------------
	-- Questa carta è considerata una carta "Lorenzo"
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetValue(SET_LORENZO)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Pesca, poi recupera 2 carte dal Cimitero
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end

------------------------------------------------------------
-- Conteggio: mostri "Lorenzo" sul tuo Terreno,
-- nel tuo Cimitero e tra le tue carte bandite scoperte
------------------------------------------------------------
function s.countfilter(c)
	return c:IsSetCard(SET_LORENZO)
		and c:IsType(TYPE_MONSTER)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.drawcondition(tp)
	return Duel.IsExistingMatchingCard(
		s.countfilter,
		tp,
		LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,
		0,
		3,
		nil
	)
end

------------------------------------------------------------
-- Carte "Lorenzo" recuperabili: mostri, Magie e Trappole
------------------------------------------------------------
function s.thfilter(c)
	return c:IsSetCard(SET_LORENZO)
		and c:IsAbleToHand()
end

------------------------------------------------------------
-- Controllo di attivazione
-- Non sceglie bersagli
------------------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			aux.NecroValleyFilter(s.thfilter),
			tp,LOCATION_GRAVE,0,2,nil
		)
			and (not s.drawcondition(tp)
				or Duel.IsPlayerCanDraw(tp,1))
	end

	Duel.SetOperationInfo(
		0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE
	)

	if s.drawcondition(tp) then
		Duel.SetOperationInfo(
			0,CATEGORY_DRAW,nil,0,tp,1
		)
	end
end

------------------------------------------------------------
-- Risoluzione
------------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- La condizione della pescata si verifica alla risoluzione,
	-- prima di recuperare le carte dal Cimitero.
	if s.drawcondition(tp) then
		if Duel.Draw(tp,1,REASON_EFFECT)>0 then
			Duel.BreakEffect()
		end
	end

	-- Il recupero si applica anche se non hai pescato.
	local g=Duel.GetMatchingGroup(
		aux.NecroValleyFilter(s.thfilter),
		tp,LOCATION_GRAVE,0,nil
	)

	-- Se rimane una sola carta recuperabile, recupera quella.
	local ct=math.min(2,g:GetCount())
	if ct==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,ct,ct,nil)

	Duel.SendtoHand(sg,nil,REASON_EFFECT)

	-- Mostra soltanto le carte effettivamente aggiunte alla mano.
	local hg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if hg:GetCount()>0 then
		Duel.ConfirmCards(1-tp,hg)
	end
end
