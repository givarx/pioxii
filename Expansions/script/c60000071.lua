--Supporto Lorenzo
--c60000071.lua
local s,id=GetID()

local LORENZO_LV2=60000001 --Verifica questo ID
local SET_LORENZO=0x1113

s.listed_names={LORENZO_LV2}
s.listed_series={SET_LORENZO}

function s.initial_effect(c)
	--------------------------------------------------
	--Nome: Lorenzo LV.2 sul Terreno e nel Cimitero
	--------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_ONFIELD+LOCATION_GRAVE)
	e1:SetValue(LORENZO_LV2)
	c:RegisterEffect(e1)

	--------------------------------------------------
	--Livello 2 nella Zona Mostri e nel Cimitero
	--------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetValue(2)
	c:RegisterEffect(e2)

	--------------------------------------------------
	--Bonus dopo l'Evocazione effettuata usando
	--questa carta come materiale
	--------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e3:SetCondition(s.matcon)
	e3:SetOperation(s.matop)
	c:RegisterEffect(e3)

	--------------------------------------------------
	--Gestione del blocco delle risposte:
	--nessun controllo globale sui materiali
	--------------------------------------------------
	if not s.global_check then
		s.global_check=true
		s.pending={}

		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_BREAK_EFFECT)
		ge:SetOperation(s.clearpending)
		Duel.RegisterEffect(ge,0)

		local ge2=ge:Clone()
		ge2:SetCode(EVENT_CHAIN_SOLVING)
		Duel.RegisterEffect(ge2,0)

		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_CHAIN_END)
		ge3:SetOperation(s.chainendop)
		Duel.RegisterEffect(ge3,0)
	end
end

--------------------------------------------------
--Verifica un'Evocazione che utilizza materiali,
--escludendo una semplice rievocazione
--------------------------------------------------
function s.materialsummon(tc)
	return tc:IsSummonType(SUMMON_TYPE_FUSION)
		or tc:IsSummonType(SUMMON_TYPE_SYNCHRO)
		or tc:IsSummonType(SUMMON_TYPE_XYZ)
		or tc:IsSummonType(SUMMON_TYPE_LINK)
		or tc:IsSummonType(SUMMON_TYPE_RITUAL)
end

--------------------------------------------------
--Questa carta deve essere effettivamente
--il materiale del mostro appena evocato
--------------------------------------------------
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if c:IsLocation(LOCATION_REMOVED)
		and not c:IsFaceup() then
		return false
	end

	if not c:IsReason(REASON_MATERIAL) then
		return false
	end

	local tc=c:GetReasonCard()
	if not tc
		or not eg:IsContains(tc)
		or not tc:IsFaceup()
		or not s.materialsummon(tc) then
		return false
	end

	local mg=tc:GetMaterial()
	if not mg or not mg:IsContains(c) then
		return false
	end

	return Duel.GetFlagEffect(tc:GetControler(),id)==0
end

--------------------------------------------------
--Carta "Lorenzo" da aggiungere alla mano
--------------------------------------------------
function s.thfilter(c)
	return c:IsSetCard(SET_LORENZO)
		and c:IsAbleToHand()
end

function s.search(p)
	if not Duel.IsExistingMatchingCard(
		s.thfilter,p,LOCATION_DECK,0,1,nil
	) then
		return
	end

	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)

	local g=Duel.SelectMatchingCard(
		p,s.thfilter,p,LOCATION_DECK,0,1,1,nil
	)

	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-p,g)
	end
end

--------------------------------------------------
--Scelta dei bonus
--0: rinuncia
--1: ricerca
--2: blocco delle risposte
--3: entrambi
--------------------------------------------------
function s.choosebonus(p,islorenzo,cansearch)
	if not Duel.SelectYesNo(p,aux.Stringid(id,0)) then
		return 0
	end

	if not cansearch then
		return 2
	end

	if islorenzo then
		return Duel.SelectOption(
			p,
			aux.Stringid(id,1),
			aux.Stringid(id,2),
			aux.Stringid(id,3)
		)+1
	end

	return Duel.SelectOption(
		p,
		aux.Stringid(id,1),
		aux.Stringid(id,2)
	)+1
end

--------------------------------------------------
--Applicazione dei bonus e hard once per turn
--------------------------------------------------
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	--Ricontrolla: un'altra copia potrebbe avere
	--già consumato l'utilizzo nello stesso evento.
	if not s.matcon(e,tp,eg,ep,ev,re,r,rp) then
		return
	end

	local tc=e:GetHandler():GetReasonCard()
	local p=tc:GetControler()

	local cansearch=Duel.IsExistingMatchingCard(
		s.thfilter,p,LOCATION_DECK,0,1,nil
	)

	local choice=s.choosebonus(
		p,tc:IsSetCard(SET_LORENZO),cansearch
	)

	if choice==0 then
		return
	end

	--Limite condiviso tra tutte le copie
	Duel.RegisterFlagEffect(
		p,id,RESET_PHASE+PHASE_END,0,1
	)

	if choice==1 or choice==3 then
		s.search(p)
	end

	if choice==2 or choice==3 then
		s.protectsummon(p)
	end
end

--------------------------------------------------
--Blocca le risposte dell'avversario
--------------------------------------------------
function s.applylimit(p)
	Duel.SetChainLimitTillChainEnd(
		function(e,ep,tp)
			return tp==p
		end
	)
end

function s.protectsummon(p)
	local chain=Duel.GetCurrentChain()

	if chain==0 then
		s.applylimit(p)
	elseif chain==1 then
		s.pending[p]=true
	end
end

function s.clearpending(e,tp,eg,ep,ev,re,r,rp)
	s.pending={}
end

function s.chainendop(e,tp,eg,ep,ev,re,r,rp)
	local pending=s.pending
	s.pending={}

	for p=0,1 do
		if pending[p] then
			s.applylimit(p)
		end
	end
end