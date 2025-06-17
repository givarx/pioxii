--Scripted by GitHub Copilot
local s,id=GetID()
function s.initial_effect(c)
    --Ritual Summon
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.ritual_filter(c,e,tp)
    return (c:IsSetCard(0x2222) or c:IsSetCard(0x3333)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end

function s.mat_filter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x1111) and c:IsControler(tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.ritual_filter,tp,LOCATION_HAND,0,1,nil,e,tp)
            and Duel.IsExistingMatchingCard(s.mat_filter,tp,LOCATION_MZONE,0,1,nil,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.ritual_filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    local rc=g:GetFirst()
    if not rc then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local mat=Duel.SelectMatchingCard(tp,s.mat_filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
    if #mat==0 then return end
    rc:SetMaterial(mat)
    Duel.Release(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
    rc:CompleteProcedure()
end