-- Lorenzo LV.4
local s,id=GetID()
local SET_LORENZO=0x1113

s.listed_series={SET_LORENZO}
s.listed_names={id}

function s.initial_effect(c)
	------------------------------------------------------------
	-- Una volta per turno, non viene distrutta in battaglia
	------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)

	------------------------------------------------------------
	-- Offri come Tributo questa carta:
	-- evoca un "Lorenzo", eccetto "Lorenzo LV.4"
	------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	------------------------------------------------------------
	-- Evocazione Speciale dalla mano
	-- Una sola volta per turno tra tutte le copie
	------------------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
end

------------------------------------------------------------
-- Protezione: soltanto dalla distruzione in battaglia
------------------------------------------------------------
function s.indval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end

------------------------------------------------------------
-- Costo: offri come Tributo questa carta
------------------------------------------------------------
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsReleasable()
			and Duel.GetMZoneCount(tp,c)>0
	end
	Duel.Release(c,REASON_COST)
end

------------------------------------------------------------
-- Mostro evocabile dalla mano o dal Deck
------------------------------------------------------------
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_LORENZO)
		and c:IsType(TYPE_MONSTER)
		and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp,e:GetHandler())>0
			and Duel.IsExistingMatchingCard(
				s.spfilter,
				tp,
				LOCATION_HAND+LOCATION_DECK,
				0,
				1,nil,e,tp
			)
	end

	Duel.SetOperationInfo(
		0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,
		LOCATION_HAND+LOCATION_DECK
	)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		return
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(
		tp,
		s.spfilter,
		tp,
		LOCATION_HAND+LOCATION_DECK,
		0,
		1,1,nil,e,tp
	)

	if g:GetCount()>0 then
		Duel.SpecialSummon(
			g,0,tp,tp,false,false,POS_FACEUP
		)
	end
end

------------------------------------------------------------
-- Controlli un altro mostro "Lorenzo" scoperto
------------------------------------------------------------
function s.handfilter(c)
	return c:IsFaceup()
		and c:IsType(TYPE_MONSTER)
		and c:IsSetCard(SET_LORENZO)
end

function s.handcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()

	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(
			s.handfilter,
			tp,
			LOCATION_MZONE,
			0,
			1,nil
		)
end