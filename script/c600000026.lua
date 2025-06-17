-- Script per "c600000026.lua"
function c600000026.initial_effect(c)
    -- Attiva: se durante la Battle Phase subisci un attacco diretto e non controlli mostri, annulla l'attacco e 
    -- evoca 3 Segna•mostro "Grezzotto Di Candelaro" (TSO Obbligatorio/Down/Guerriero) in ATK, 
    -- il cui ATK è il danno che avresti ricevuto diviso 3.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(c600000026.condition)
    e1:SetOperation(c600000026.operation)
    c:RegisterEffect(e1)
    
end

function c600000026.condition(e,tp,eg,ep,ev,re,r,rp)
    -- Verifica che l'attaccante appartenga all'avversario, che l'attacco sia diretto e che tu non controlli mostri.
    local a=Duel.GetAttacker()
    if a:IsControler(1-tp) then
        return Duel.GetAttackTarget()==nil and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
    end
    return false
end

function c600000026.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Annulla l'attacco
    local a=Duel.GetAttacker()
    local dam=a:GetAttack()
    Duel.NegateAttack()
    -- Calcola il danno che avresti subito
    local token_atk=math.floor(dam/3)
    -- Verifica la possibilità di evocare token personalizzati
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,600000010,6,0x1111,token_atk,0,1,RACE_WARRIOR,ATTRIBUTE_EARTH) then return end
    -- Evoca fino a 3 token "Grezzotto Di Candelaro" in posizione di attacco
    local ft = math.min(3, Duel.GetLocationCount(tp,LOCATION_MZONE))
    if ft==0 then return end
    for i=1,ft do
        local token=Duel.CreateToken(tp,600000010)
        if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(token_atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            token:RegisterEffect(e1,true)
        end
    end
    Duel.SpecialSummonComplete()
end