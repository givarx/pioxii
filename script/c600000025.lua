-- blank
local s, id=GetID()
function s.initial_effect(c)
    -- Effect: When this card is Normal Summoned, you can banish 1 card from your hand matching the filter
    -- to change this card’s level (choose a level from 2 to 6).
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_LVCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
    end)
    e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        if Duel.GetFlagEffect(tp, id)>0 then return end
        if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil)
            and Duel.SelectYesNo(tp, aux.Stringid(id,1)) then
            Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0, 1)
            local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
            if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
                local lv=Duel.AnnounceLevel(tp,2,6)
                local c=e:GetHandler()
                if c:IsRelateToEffect(e) and c:IsFaceup() then
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_CHANGE_LEVEL)
                    e1:SetValue(lv)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    c:RegisterEffect(e1)
                end
            end
        end
    end)
    c:RegisterEffect(e1)
    -- Modified Effect: When this card is Special Summoned, you can banish 1 card from your hand matching the filter
    -- to change this card’s level (choose a level from 2 to 6).
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_LVCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
    end)
    e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        if Duel.GetFlagEffect(tp, id+100)>0 then return end
        if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil)
            and Duel.SelectYesNo(tp, aux.Stringid(id,3)) then
            Duel.RegisterFlagEffect(tp, id+100, RESET_PHASE+PHASE_END, 0, 1)
            local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
            if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
                local lv=Duel.AnnounceLevel(tp,2,6)
                local c=e:GetHandler()
                if c:IsRelateToEffect(e) and c:IsFaceup() then
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_CHANGE_LEVEL)
                    e1:SetValue(lv)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    c:RegisterEffect(e1)
                end
            end
        end
    end)
    c:RegisterEffect(e2)
end
function s.filter(c)
        -- Define your card filter conditions here.
        return c:IsAbleToRemove() and c:IsCode(600000001,600000021,600000009,600000022,600000007,600000013,600000000)
    end