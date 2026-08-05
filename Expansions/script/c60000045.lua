-- Mostro Effetto
-- falco il bandito
local s,id=GetID()

function s.initial_effect(c)
	------------------------------------------------------------
	-- SCOPRI: pesca 1 carta
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Una volta per turno:
	-- metti questa carta coperta in Posizione di Difesa
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)

	------------------------------------------------------------
	-- Se questa carta viene scartata
	------------------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.exctg)
	e3:SetOperation(s.excop)
	c:RegisterEffect(e3)

	------------------------------------------------------------
	-- Se questa carta viene bandita
	------------------------------------------------------------
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	e4:SetCondition(s.bancon)
	c:RegisterEffect(e4)
end

------------------------------------------------------------
-- Effetto SCOPRI
------------------------------------------------------------

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
	end

	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(
		0,
		CATEGORY_DRAW,
		nil,
		0,
		tp,
		1
	)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(
		0,
		CHAININFO_TARGET_PLAYER,
		CHAININFO_TARGET_PARAM
	)

	Duel.Draw(p,d,REASON_EFFECT)
end

------------------------------------------------------------
-- Rimette questa carta coperta
------------------------------------------------------------

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsCanTurnSet()
	end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if c:IsRelateToEffect(e)
		and c:IsFaceup()
		and c:IsCanTurnSet() then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end

------------------------------------------------------------
-- Condizione: è stata scartata
------------------------------------------------------------

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DISCARD)
end
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(EVENT_REMOVE)
end

------------------------------------------------------------
-- Controllo delle prime 3 carte
------------------------------------------------------------

function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then
			return false
		end

		local g=Duel.GetDecktopGroup(tp,3)

		return g:FilterCount(
			Card.IsAbleToHand,
			nil
		)>0
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_TOHAND,
		nil,
		1,
		tp,
		LOCATION_DECK
	)
end

function s.excop(e,tp,eg,ep,ev,re,r,rp)
	-- Rivela le prime 3 carte
	Duel.ConfirmDecktop(tp,3)

	local g=Duel.GetDecktopGroup(tp,3)
	if g:GetCount()<3 then
		return
	end

	-- Può essere scelta solo una carta aggiungibile alla mano
	local hg=g:Filter(Card.IsAbleToHand,nil)
	if hg:GetCount()==0 then
		-- Se nessuna può essere aggiunta, mettile tutte in fondo
		Duel.SendtoDeck(
			g,
			nil,
			SEQ_DECKBOTTOM,
			REASON_EFFECT
		)
		return
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

	local sg=hg:Select(tp,1,1,nil)
	local tc=sg:GetFirst()

	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		g:RemoveCard(tc)
	end

	-- Le carte restanti vengono messe in fondo al Deck
	if g:GetCount()>0 then
		Duel.SendtoDeck(
			g,
			nil,
			SEQ_DECKBOTTOM,
			REASON_EFFECT
		)
	end
end