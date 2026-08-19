-- Il Leone sulla Rupe
local s,id=GetID()

local SET_LEONE=0x1118
local SET_TSO=0x1111 -- SetCode di "TSO Obbligatorio"

function s.initial_effect(c)
	------------------------------------------------------------
	-- Xyz: 2 mostri di Livello 8
	------------------------------------------------------------
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()

	------------------------------------------------------------
	-- Questa carta è considerata "TSO Obbligatorio"
	------------------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(SET_TSO)
	c:RegisterEffect(e0)

	------------------------------------------------------------
	-- Effetto Rapido 1:
	-- quando viene attivato l'effetto di un mostro,
	-- stacca 1 materiale; annulla quell'effetto
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Effetto Rapido 2:
	-- rimischia 2 "Leone" dal Cimitero;
	-- rimischia tutte le Magie/Trappole dell'avversario
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.tdcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)

	------------------------------------------------------------
	-- Quando viene mandata dal Terreno al Cimitero:
	-- Evoca Specialmente 2 "Leone" dal Cimitero
	------------------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_LEONE,SET_TSO}

------------------------------------------------------------
-- EFFETTO 1
-- Negazione effetto mostro
------------------------------------------------------------

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
		and Duel.IsChainNegatable(ev)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:CheckRemoveOverlayCard(
			tp,
			1,
			REASON_COST
		)
	end

	c:RemoveOverlayCard(
		tp,
		1,
		1,
		REASON_COST
	)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_DISABLE,
		eg,
		1,
		0,
		0
	)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

------------------------------------------------------------
-- EFFETTO 2
-- Rimischia 2 "Leone" dal Cimitero come costo
------------------------------------------------------------

function s.tdcostfilter(c)
	return c:IsSetCard(SET_LEONE)
		and c:IsAbleToDeck()
end

function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.tdcostfilter,
			tp,
			LOCATION_GRAVE,
			0,
			2,
			nil
		)
	end

	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_TODECK
	)

	local g=Duel.SelectMatchingCard(
		tp,
		s.tdcostfilter,
		tp,
		LOCATION_GRAVE,
		0,
		2,
		2,
		nil
	)

	Duel.SendtoDeck(
		g,
		nil,
		SEQ_DECKSHUFFLE,
		REASON_COST
	)
end

------------------------------------------------------------
-- Magie/Trappole controllate dall'avversario
------------------------------------------------------------

function s.tdfilter(c)
	return (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
		and c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.tdfilter,
			tp,
			0,
			LOCATION_SZONE+LOCATION_FZONE,
			1,
			nil
		)
	end

	local g=Duel.GetMatchingGroup(
		s.tdfilter,
		tp,
		0,
		LOCATION_SZONE+LOCATION_FZONE,
		nil
	)

	Duel.SetOperationInfo(
		0,
		CATEGORY_TODECK,
		g,
		g:GetCount(),
		0,
		0
	)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(
		s.tdfilter,
		tp,
		0,
		LOCATION_SZONE+LOCATION_FZONE,
		nil
	)

	if g:GetCount()>0 then
		Duel.SendtoDeck(
			g,
			nil,
			SEQ_DECKSHUFFLE,
			REASON_EFFECT
		)
	end
end


------------------------------------------------------------
-- Quando questa carta viene mandata dal Terreno al Cimitero:
-- scegli fino a 2 mostri "Leone" nel Cimitero,
-- eccetto "Il Leone sulla Rupe"; Evocali Specialmente.
------------------------------------------------------------

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

------------------------------------------------------------
-- Mostri "Leone" evocabili dal Cimitero
-- eccetto "Il Leone sulla Rupe"
------------------------------------------------------------

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_LEONE)
		and not c:IsCode(id)
		and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(
			e,
			0,
			tp,
			false,
			false
		)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp)
			and chkc:IsLocation(LOCATION_GRAVE)
			and s.spfilter(chkc,e,tp)
	end

	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(
				s.spfilter,
				tp,
				LOCATION_GRAVE,
				0,
				1,
				nil,
				e,
				tp
			)
	end

	--------------------------------------------------------
	-- Possiamo scegliere 1 oppure 2 a seconda
	-- delle Zone Mostri disponibili
	--------------------------------------------------------
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)

	if ft>2 then
		ft=2
	end

	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_SPSUMMON
	)

	local g=Duel.SelectTarget(
		tp,
		s.spfilter,
		tp,
		LOCATION_GRAVE,
		0,
		1,
		ft,
		nil,
		e,
		tp
	)

	Duel.SetOperationInfo(
		0,
		CATEGORY_SPECIAL_SUMMON,
		g,
		g:GetCount(),
		tp,
		LOCATION_GRAVE
	)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)

	if ft<=0 then
		return
	end

	--------------------------------------------------------
	-- Recupera i bersagli ancora validi
	--------------------------------------------------------
	local g=Duel.GetChainInfo(
		0,
		CHAININFO_TARGET_CARDS
	)

	local sg=Group.CreateGroup()

	local tc=g:GetFirst()

	while tc do
		if tc:IsRelateToEffect(e)
			and tc:IsLocation(LOCATION_GRAVE)
			and s.spfilter(tc,e,tp) then

			sg:AddCard(tc)
		end

		tc=g:GetNext()
	end

	--------------------------------------------------------
	-- Se al momento della risoluzione abbiamo meno
	-- Zone Mostri, limita il numero di mostri evocati
	--------------------------------------------------------
	if sg:GetCount()>ft then
		Duel.Hint(
			HINT_SELECTMSG,
			tp,
			HINTMSG_SPSUMMON
		)

		sg=sg:Select(
			tp,
			ft,
			ft,
			nil
		)
	end

	if sg:GetCount()==0 then
		return
	end

	--------------------------------------------------------
	-- Evocazione Speciale
	--------------------------------------------------------
	if Duel.SpecialSummon(
		sg,
		0,
		tp,
		tp,
		false,
		false,
		POS_FACEUP
	)>0 then

		----------------------------------------------------
		-- I mostri effettivamente evocati
		-- non possono essere usati come Materiali Xyz
		----------------------------------------------------
		local tc=sg:GetFirst()

		while tc do
			if tc:IsLocation(LOCATION_MZONE)
				and tc:IsControler(tp) then

				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+0x1fe0000)
				tc:RegisterEffect(e1)
			end

			tc=sg:GetNext()
		end
	end
end