-- Magia Rapida: Effetto con scelta tra due opzioni
local s,id=GetID()
function s.initial_effect(c)
    -- Attiva
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.tsofilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x1111) and c:IsReleasable()
end
function s.nonnormalfilter(c)
    return c:IsFaceup() and not c:IsType(TYPE_NORMAL)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.tsofilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.CheckLPCost(tp,2000)
        and Duel.IsExistingMatchingCard(s.tsofilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.extra_filter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    local b2=Duel.CheckLPCost(tp,1000)
        and Duel.IsExistingMatchingCard(s.nonnormalfilter,tp,LOCATION_MZONE,0,1,nil)
    if chk==0 then return b1 or b2 end
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif b1 then
        op=0
    else
        op=1
    end
    e:SetLabel(op)
    if op==0 then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    else
        Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,LOCATION_MZONE)
    end
end

function s.extra_filter(c,e,tp)
    return (c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_XYZ) or c:IsType(TYPE_FUSION))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==0 then
        -- Opzione 1: Paga 2000 LP, tributa un TSO obbligatorio, Special Summon 1 Synchro/Xyz/Fusione dall'Extra Deck
        if not Duel.CheckLPCost(tp,2000) then return end
        Duel.PayLPCost(tp,2000)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        local g=Duel.SelectMatchingCard(tp,s.tsofilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
        if #g==0 then return end
        if Duel.Release(g,REASON_COST)==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.extra_filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
        if #sg>0 then
            local sc=sg:GetFirst()
            if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_ATTACK)>0 then
                -- Non può attaccare per il resto del turno
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_CANNOT_ATTACK)
                e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                sc:RegisterEffect(e1)
            end
        end
    else
        -- Opzione 2: Paga 1000 LP, +500 ATK e protezione targeting a un mostro non Normale
        if not Duel.CheckLPCost(tp,1000) then return end
        Duel.PayLPCost(tp,1000)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g=Duel.SelectMatchingCard(tp,s.nonnormalfilter,tp,LOCATION_MZONE,0,1,1,nil)
        if #g>0 then
            local tc=g:GetFirst()
            -- Guadagna 500 ATK
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(500)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            -- Non può essere scelto come bersaglio dagli effetti delle carte fino alla fine del turno
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
            e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e2:SetRange(LOCATION_MZONE)
            e2:SetValue(aux.tgoval)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2)
        end
    end
end