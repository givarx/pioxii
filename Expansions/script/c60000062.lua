--Magia Rapida "Lorenzo" - YGO Omega / MDPro
--Rinominare c<ID_NUMERICO_DELLA_CARTA>.lua.
--Impostare Magia + Rapida nel database.
--Nessun limite per turno: non e' presente nel testo fornito.
local s,id=GetID()
local SET_LORENZO=0x1113
s.listed_series={SET_LORENZO}

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_LORENZO)
		and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.countfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_LORENZO)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.drawcon(tp,minc)
	return Duel.IsExistingMatchingCard(s.countfilter,tp,
		LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,minc or 3,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			and (not s.drawcon(tp,2) or (Duel.IsPlayerCanDraw(tp,1)
				and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2))
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	if Duel.SetPossibleOperationInfo then
		Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif s.drawcon(tp) then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			--Bando differito nello stile di Teletrasporto di Emergenza.
			--La prima End Phase disponibile comprende quella in corso.
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(id,
				RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.rmcon)
			e1:SetOperation(s.rmop)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
		--Rimescola dopo aver cercato nel Deck, prima della pesca.
		if tc then Duel.ShuffleDeck(tp) end
	end

	--"Inoltre": pesca indipendente dalla riuscita dell'Evocazione.
	--Il mostro appena Evocato conta per raggiungere la soglia di 3.
	if s.drawcon(tp) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc and tc:IsLocation(LOCATION_MZONE)
		and tc:GetFlagEffect(id)>0
		and tc:GetFlagEffectLabel(id)==e:GetLabel()
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
end
