-- Magia Rapida: scegli 1 tra 2 effetti
local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Mostro 0x1111 tributabile
function s.releasefilter(c)
    return c:IsFaceup()
        and c:IsSetCard(0x1111)
        and c:IsReleasable()
end

-- Mostro 0x1111 da rendere immune
function s.immfilter(c)
    return c:IsFaceup()
        and c:IsSetCard(0x1111)
end

-- Mostro Fusione o Synchro evocabile dall'Extra Deck
function s.exfilter(c,e,tp)
    return (c:IsType(TYPE_FUSION) or c:IsType(TYPE_SYNCHRO))
        and c:IsCanBeSpecialSummoned(
            e,
            0,
            tp,
            false,
            false
        )
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Prima opzione disponibile
    local b1=Duel.CheckLPCost(tp,2000)
        and Duel.IsExistingMatchingCard(
            s.releasefilter,
            tp,
            LOCATION_MZONE,
            0,
            1,
            nil
        )
        and Duel.GetLocationCountFromEx(tp)>0
        and Duel.IsExistingMatchingCard(
            s.exfilter,
            tp,
            LOCATION_EXTRA,
            0,
            1,
            nil,
            e,
            tp
        )

    -- Seconda opzione disponibile
    local b2=Duel.CheckLPCost(tp,1000)
        and Duel.IsExistingMatchingCard(
            s.immfilter,
            tp,
            LOCATION_MZONE,
            0,
            1,
            nil
        )

    if chk==0 then
        return b1 or b2
    end

    local op

    if b1 and b2 then
        op=Duel.SelectOption(
            tp,
            aux.Stringid(id,0),
            aux.Stringid(id,1)
        )
    elseif b1 then
        op=0
    else
        op=1
    end

    e:SetLabel(op)

    if op==0 then
        -- Paga 2000 LP
        Duel.PayLPCost(tp,2000)

        -- Tributa 1 mostro 0x1111
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)

        local g=Duel.SelectMatchingCard(
            tp,
            s.releasefilter,
            tp,
            LOCATION_MZONE,
            0,
            1,
            1,
            nil
        )

        Duel.Release(g,REASON_COST)
    else
        -- Paga 1000 LP
        Duel.PayLPCost(tp,1000)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local op=e:GetLabel()

    if op==0 then
        if chk==0 then
            return Duel.GetLocationCountFromEx(tp)>0
                and Duel.IsExistingMatchingCard(
                    s.exfilter,
                    tp,
                    LOCATION_EXTRA,
                    0,
                    1,
                    nil,
                    e,
                    tp
                )
        end

        Duel.SetOperationInfo(
            0,
            CATEGORY_SPECIAL_SUMMON,
            nil,
            1,
            tp,
            LOCATION_EXTRA
        )
    else
        if chkc then
            return chkc:IsControler(tp)
                and chkc:IsLocation(LOCATION_MZONE)
                and s.immfilter(chkc)
        end

        if chk==0 then
            return Duel.IsExistingTarget(
                s.immfilter,
                tp,
                LOCATION_MZONE,
                0,
                1,
                nil
            )
        end

        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)

        Duel.SelectTarget(
            tp,
            s.immfilter,
            tp,
            LOCATION_MZONE,
            0,
            1,
            1,
            nil
        )
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()

    if op==0 then
        -- Controlla nuovamente che ci sia spazio
        if Duel.GetLocationCountFromEx(tp)<=0 then
            return
        end

        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

        local g=Duel.SelectMatchingCard(
            tp,
            s.exfilter,
            tp,
            LOCATION_EXTRA,
            0,
            1,
            1,
            nil,
            e,
            tp
        )

        local sc=g:GetFirst()
        if not sc then
            return
        end

        if Duel.SpecialSummon(
            sc,
            0,
            tp,
            tp,
            false,
            false,
            POS_FACEUP
        )>0 then
            -- Non può attaccare in questo turno
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_ATTACK)
            
            sc:RegisterEffect(e1)
        end
    else
        local tc=Duel.GetFirstTarget()

        if not tc
            or not tc:IsRelateToEffect(e)
            or not tc:IsFaceup() then
            return
        end

        -- Immune agli effetti delle carte dell'avversario
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetValue(s.efilter)
        e1:SetReset(
            RESET_EVENT
            +RESETS_STANDARD
            +RESET_PHASE
            +PHASE_END
        )
        tc:RegisterEffect(e1)
    end
end

-- Immune agli effetti appartenenti all'avversario
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end