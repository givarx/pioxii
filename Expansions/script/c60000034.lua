-- c600000034.lua
-- Effetto della carta:
-- "Non può essere evocata normalmente / posizionata.
-- Quando 2 o più mostri lasciano il terreno: puoi evocare questa carta dal tuo cimitero in posizione di difesa,
-- ma alla fine del turno bandisci questa carta."

-- Carta 60000034
local s,id=GetID()

function s.initial_effect(c)
    ------------------------------------------------------------
    -- Non può essere Evocata Normalmente/Posizionata
    ------------------------------------------------------------
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_CANNOT_SUMMON)
    c:RegisterEffect(e0)

    local e0b=e0:Clone()
    e0b:SetCode(EFFECT_CANNOT_MSET)
    c:RegisterEffect(e0b)

    ------------------------------------------------------------
    -- Effetto 1:
    -- dalla mano, nega un'Evocazione Speciale dall'Extra Deck
    -- che non avviene durante la risoluzione di una Catena
    ------------------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_SPSUMMON)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.discon)
    e1:SetCost(s.discost)
    e1:SetTarget(s.distg)
    e1:SetOperation(s.disop)
    c:RegisterEffect(e1)

    ------------------------------------------------------------
    -- Effetto 2:
    -- dalla mano, nega l'attivazione di un effetto avversario
    -- che include un'Evocazione Speciale dall'Extra Deck
    ------------------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.excon)
    e2:SetCost(s.discost)
    e2:SetTarget(s.extg)
    e2:SetOperation(s.exop)
    c:RegisterEffect(e2)

    ------------------------------------------------------------
    -- Effetto 3:
    -- se 2 o più mostri lasciano il Terreno contemporaneamente,
    -- Evoca questa carta dal Cimitero
    ------------------------------------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

------------------------------------------------------------
-- Effetto 1: negazione diretta dell'Evocazione
------------------------------------------------------------

-- Controlla che il mostro stia arrivando dall'Extra Deck
function s.disfilter(c,tp)
    return c:GetSummonPlayer()==1-tp
        and c:IsPreviousLocation(LOCATION_EXTRA)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return eg
        and eg:IsExists(s.disfilter,1,nil,tp)
end

-- Manda questa carta dalla mano al Cimitero come costo
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()

    if chk==0 then
        return c:IsAbleToGraveAsCost()
    end

    Duel.SendtoGrave(c,REASON_COST)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.disfilter,nil,tp)

    if chk==0 then
        return #g>0
    end

    Duel.SetOperationInfo(
        0,
        CATEGORY_DISABLE_SUMMON,
        g,
        #g,
        0,
        0
    )

    Duel.SetOperationInfo(
        0,
        CATEGORY_REMOVE,
        g,
        #g,
        0,
        0
    )
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.disfilter,nil,tp)

    if #g==0 then
        return
    end

    if Duel.NegateSummon(g) then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end

------------------------------------------------------------
-- Effetto 2: nega un effetto che Evoca dall'Extra Deck
------------------------------------------------------------

function s.excon(e,tp,eg,ep,ev,re,r,rp)
    -- Deve essere un effetto dell'avversario
    if rp==tp then
        return false
    end

    -- La Catena deve poter essere negata
    if not Duel.IsChainNegatable(ev) then
        return false
    end

    -- Recupera le informazioni sull'Evocazione Speciale
    local ex,g,ct,p,loc=
        Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)

    if not ex then
        return false
    end

    -- Lo script dell'effetto avversario deve dichiarare
    -- che l'Evocazione avviene dall'Extra Deck
    return loc==LOCATION_EXTRA
        or loc==LOCATION_EXTRA+LOCATION_GRAVE
        or loc==LOCATION_EXTRA+LOCATION_HAND
        or loc==LOCATION_EXTRA+LOCATION_DECK
end

function s.extg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return true
    end

    Duel.SetOperationInfo(
        0,
        CATEGORY_NEGATE,
        eg,
        1,
        0,
        0
    )

    local rc=re:GetHandler()

    if rc
        and rc:IsRelateToEffect(re)
        and rc:IsAbleToRemove() then
        Duel.SetOperationInfo(
            0,
            CATEGORY_REMOVE,
            rc,
            1,
            0,
            0
        )
    end
end

function s.exop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.NegateActivation(ev) then
        return
    end

    local rc=re:GetHandler()

    if rc
        and rc:IsRelateToEffect(re)
        and rc:IsAbleToRemove() then
        Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
    end
end

------------------------------------------------------------
-- Effetto 3: Evocazione dal Cimitero
------------------------------------------------------------

-- Mostro che si trovava nella Zona Mostri
function s.leavefilter(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsPreviousLocation(LOCATION_MZONE)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:FilterCount(s.leavefilter,nil)>=2
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()

    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(
                e,
                0,
                tp,
                false,
                false,
                POS_FACEUP_DEFENSE
            )
    end

    Duel.SetOperationInfo(
        0,
        CATEGORY_SPECIAL_SUMMON,
        c,
        1,
        0,
        0
    )
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    if not c:IsRelateToEffect(e) then
        return
    end

    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
        return
    end

    if Duel.SpecialSummon(
        c,
        0,
        tp,
        tp,
        false,
        false,
        POS_FACEUP_DEFENSE
    )==0 then
        return
    end

    -- Durante la End Phase bandisci questa carta
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,3))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetOperation(s.rmop)
    e1:SetReset(
        RESET_EVENT
        +RESETS_STANDARD
        +RESET_PHASE
        +PHASE_END
    )
    c:RegisterEffect(e1)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    if c:IsFaceup()
        and c:IsLocation(LOCATION_MZONE)
        and c:IsAbleToRemove() then
        Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
    end
end