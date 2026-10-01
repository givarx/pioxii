--Lorenzo Ricchione
-- Lorenzo Ricchione
local s,id=GetID()
local SET_LORENZO=0x1113

s.listed_series={SET_LORENZO}

function s.initial_effect(c)
	c:EnableReviveLimit()

	------------------------------------------------------------
	-- Materiali: 2 mostri "Lorenzo"
	------------------------------------------------------------
	aux.AddFusionProcFunRep(c,s.fusfilter,2,true)

	-- Impedisce Evocazioni dall'Extra Deck tramite altri effetti
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

	------------------------------------------------------------
	-- Procedura di contatto, considerata Evocazione Fusione
	------------------------------------------------------------
	local ep=Effect.CreateEffect(c)
	ep:SetType(EFFECT_TYPE_FIELD)
	ep:SetCode(EFFECT_SPSUMMON_PROC)
	ep:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	ep:SetRange(LOCATION_EXTRA)
	ep:SetValue(SUMMON_TYPE_FUSION)
	ep:SetCondition(s.contactcon)
	ep:SetTarget(s.contacttg)
	ep:SetOperation(s.contactop)
	c:RegisterEffect(ep)

	------------------------------------------------------------
	-- Evocazione Fusione: distruggi 2 carte
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Main Phase 2: torna nell'Extra Deck ed evoca dal Deck
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

------------------------------------------------------------
-- Materiali e limitazione dell'Evocazione
------------------------------------------------------------
function s.fusfilter(c)
	return c:IsFusionSetCard(SET_LORENZO)
		and c:IsType(TYPE_MONSTER)
end

function s.splimit(e,se,sp,st)
	-- Dopo essere stata evocata correttamente,
	-- può essere rianimata dal Cimitero.
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.contactfilter(c,fc)
	return s.fusfilter(c)
		and not c:IsType(TYPE_TOKEN)
		and (c:IsAbleToDeckAsCost() or c:IsAbleToExtraAsCost())
		and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_FUSION)
end

function s.matcheck(g,tp,c)
	-- Verifica lo spazio disponibile dopo aver usato i materiali.
	return Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end

------------------------------------------------------------
-- Verifica della procedura di contatto
------------------------------------------------------------
function s.contactcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(
		s.contactfilter,tp,LOCATION_MZONE,0,nil,c
	)
	return g:CheckSubGroup(s.matcheck,2,2,tp,c)
end

------------------------------------------------------------
-- Selezione dei 2 materiali
------------------------------------------------------------
function s.contacttg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local fc=e:GetHandler()
	local g=Duel.GetMatchingGroup(
		s.contactfilter,tp,LOCATION_MZONE,0,nil,fc
	)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local sg=g:SelectSubGroup(tp,s.matcheck,false,2,2,tp,fc)
	if not sg then return false end

	sg:KeepAlive()
	e:SetLabelObject(sg)
	return true
end

------------------------------------------------------------
-- Rimischia i materiali nel Deck
------------------------------------------------------------
function s.contactop(e,tp,eg,ep,ev,re,r,rp,c)
	local fc=e:GetHandler()
	local g=e:GetLabelObject()
	if not g then return end

	fc:SetMaterial(g)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(
		g,nil,SEQ_DECKSHUFFLE,
		REASON_COST+REASON_MATERIAL+REASON_FUSION
	)

	g:DeleteGroup()
	e:SetLabelObject(nil)
end

------------------------------------------------------------
-- Distruzione obbligatoria, senza bersaglio
------------------------------------------------------------
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			aux.TRUE,tp,
			LOCATION_ONFIELD,LOCATION_ONFIELD,
			1,nil
		)
	end

	Duel.SetOperationInfo(
		0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD
	)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(
		aux.TRUE,tp,
		LOCATION_ONFIELD,LOCATION_ONFIELD,
		nil
	)
	local maxct=math.min(2,g:GetCount())
	if maxct==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=g:Select(tp,1,maxct,nil)
	Duel.Destroy(sg,REASON_EFFECT)
end

------------------------------------------------------------
-- Main Phase 2 del proprio turno
------------------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
		and Duel.GetCurrentPhase()==PHASE_MAIN2
end

------------------------------------------------------------
-- Costo: rimetti questa carta nell'Extra Deck
------------------------------------------------------------
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToExtraAsCost()
			and Duel.GetMZoneCount(tp,c)>0
	end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

------------------------------------------------------------
-- Mostri "Lorenzo" evocabili entro il limite di ATK
------------------------------------------------------------
function s.spfilter(c,e,tp,limit)
	local atk=c:GetTextAttack()
	return c:IsSetCard(SET_LORENZO)
		and c:IsType(TYPE_MONSTER)
		and atk>=0
		and atk<=limit
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp,e:GetHandler())>0
			and Duel.IsExistingMatchingCard(
				s.spfilter,tp,LOCATION_DECK,0,
				1,nil,e,tp,2800
			)
	end
	Duel.SetOperationInfo(
		0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK
	)
end

------------------------------------------------------------
-- Evoca fino a 2 mostri: totale ATK originale <= 2800
------------------------------------------------------------
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end

	local g=Duel.GetMatchingGroup(
		s.spfilter,tp,LOCATION_DECK,0,nil,e,tp,2800
	)
	if g:GetCount()==0 then return end

	-- Rispetta il limite di Drago Spirito Occhi Blu.
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		ft=1
	end

	-- Seleziona il primo mostro.
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	local tc=sg:GetFirst()

	-- Seleziona un eventuale secondo mostro.
	if ft>=2 then
		local remaining=2800-tc:GetTextAttack()
		local g2=g:Filter(s.spfilter,tc,e,tp,remaining)

		if g2:GetCount()>0
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			sg:Merge(g2:Select(tp,1,1,nil))
		end
	end

	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
