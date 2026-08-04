local s,id=GetID()

function s.initial_effect(c)
    -- Attivazione
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(
        CATEGORY_REMOVE
        +CATEGORY_SPECIAL_SUMMON
        +CATEGORY_FUSION_SUMMON
    )
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.fustg)
    e1:SetOperation(s.fusop)
    c:RegisterEffect(e1)
end

-- Materiali dalla mano o dal Terreno
function s.matfilter1(c,e)
    return c:IsAbleToRemove()
        and not c:IsImmuneToEffect(e)
end

-- Materiali dal Cimitero
function s.matfilter2(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsCanBeFusionMaterial()
        and c:IsAbleToRemove()
end

-- Mostri Fusione "0x1111" evocabili
function s.fusfilter(c,e,tp,mg,chkf)
    return c:IsType(TYPE_FUSION)
        and c:IsSetCard(0x1111)
        and c:IsCanBeSpecialSummoned(
            e,
            SUMMON_TYPE_FUSION,
            tp,
            false,
            false
        )
        and c:CheckFusionMaterial(mg,nil,chkf)
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    local chkf=tp

    -- Mano e Terreno
    local mg1=Duel.GetFusionMaterial(tp):Filter(
        s.matfilter1,
        nil,
        e
    )

    -- Cimitero
    local mg2=Duel.GetMatchingGroup(
        s.matfilter2,
        tp,
        LOCATION_GRAVE,
        0,
        nil
    )

    mg1:Merge(mg2)

    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.fusfilter,
            tp,
            LOCATION_EXTRA,
            0,
            1,
            nil,
            e,
            tp,
            mg1,
            chkf
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

    Duel.SetOperationInfo(
        0,
        CATEGORY_REMOVE,
        nil,
        1,
        tp,
        LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE
    )
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local chkf=tp

    -- Materiali dalla mano e dal Terreno
    local mg1=Duel.GetFusionMaterial(tp):Filter(
        s.matfilter1,
        nil,
        e
    )

    -- Materiali dal Cimitero
    local mg2=Duel.GetMatchingGroup(
        s.matfilter2,
        tp,
        LOCATION_GRAVE,
        0,
        nil
    )

    mg1:Merge(mg2)

    -- Mostri Fusione "0x1111" evocabili
    local fg=Duel.GetMatchingGroup(
        s.fusfilter,
        tp,
        LOCATION_EXTRA,
        0,
        nil,
        e,
        tp,
        mg1,
        chkf
    )

    if #fg==0 then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

    local fc=fg:Select(tp,1,1,nil):GetFirst()
    if not fc then
        return
    end

    -- Seleziona i materiali da mano, Terreno e Cimitero
    local mat=Duel.SelectFusionMaterial(
        tp,
        fc,
        mg1,
        nil,
        chkf
    )

    if not mat or #mat==0 then
        return
    end

    fc:SetMaterial(mat)

    -- Bandisce tutti i materiali scelti
    if Duel.Remove(
        mat,
        POS_FACEUP,
        REASON_EFFECT|REASON_MATERIAL|REASON_FUSION
    )==0 then
        return
    end

    Duel.BreakEffect()

    if Duel.SpecialSummon(
        fc,
        SUMMON_TYPE_FUSION,
        tp,
        tp,
        false,
        false,
        POS_FACEUP
    )~=0 then
        fc:CompleteProcedure()
    end
end