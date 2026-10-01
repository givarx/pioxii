--Cortesemente, un Crispy McBacon(TM)
--Magia Normale: impostare il tipo nel database.
--Rinominare il file c<ID_NUMERICO_DELLA_CARTA>.lua.
--Archetipo Lorenzo: 0x1113 (non e' l'ID della Magia).
local s,id=GetID()
local SET_LORENZO=0x1113
s.listed_series={SET_LORENZO}

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	--"Utilizzare" una volta per turno, condiviso tra tutte le copie.
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_LORENZO)
		and c:IsAbleToHand()
end

--Somma i mostri nelle tre zone; non richiede nomi differenti.
--Non conta carte coperte sul Terreno o bandite coperte.
function s.countfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_LORENZO)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.recovercon(tp)
	return Duel.IsExistingMatchingCard(s.countfilter,tp,
		LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if s.recovercon(tp) then
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
	elseif Duel.SetPossibleOperationInfo then
		Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Ricerca senza bersagliare.
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SendtoHand(g,nil,REASON_EFFECT)>0
			and tc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,g)
		end
		--Rimescola il Deck dopo la ricerca.
		Duel.ShuffleDeck(tp)
	end
	--"Inoltre": il recupero non richiede che la ricerca sia riuscita.
	--Ricontrolla la soglia alla risoluzione, non solo all'attivazione.
	if s.recovercon(tp) then
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
end
