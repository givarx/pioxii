-- Supporto Lorenzo
-- c60000071.lua

local s,id=GetID()

local LORENZO_LV2=60000001 -- Sostituisci con l'ID corretto
local SET_LORENZO=0x1113   -- Sostituisci con il SetCode corretto

function s.initial_effect(c)

    --------------------------------------------------
    -- Nome: Lorenzo Lv2 sul Terreno e nel Cimitero
    --------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(LORENZO_LV2)
    c:RegisterEffect(e1)

    --------------------------------------------------
    -- Livello 2 sul Terreno e nel Cimitero
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CHANGE_LEVEL)
    e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e2:SetValue(2)
    c:RegisterEffect(e2)

    --------------------------------------------------
    -- Se dovrebbe tornare nel Deck, viene bandito
    --------------------------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EFFECT_TO_DECK_REDIRECT)
    e3:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e3)

    --------------------------------------------------
    -- Controllo globale sulle Evocazioni Speciali
    --------------------------------------------------
    if not s.global_check then
        s.global_check=true

        local ge=Effect.CreateEffect(c)
        ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge:SetCode(EVENT_SPSUMMON_SUCCESS)
        ge:SetOperation(s.matop)
        Duel.RegisterEffect(ge,0)
    end
end

--------------------------------------------------
-- Identifica Lorenzo tra i materiali
--------------------------------------------------

function s.matfilter(c)
    return c:GetOriginalCode()==id
end

--------------------------------------------------
-- Filtro carta "Lorenzo" dal Deck
--------------------------------------------------

function s.thfilter(c)
    return c:IsSetCard(SET_LORENZO)
        and c:IsAbleToHand()
end

--------------------------------------------------
-- Ricerca
--------------------------------------------------

function s.search(tp)
    if not Duel.IsExistingMatchingCard(
        s.thfilter,tp,LOCATION_DECK,0,1,nil
    ) then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

    local g=Duel.SelectMatchingCard(
        tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil
    )

    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

--------------------------------------------------
-- Tentativo di limitare le risposte
--------------------------------------------------

function s.chlimit(e,ep,tp)
    return tp==ep
end

--------------------------------------------------
-- Controllo dei mostri evocati dall'Extra Deck
--------------------------------------------------

function s.matop(e,tp,eg,ep,ev,re,r,rp)

    local tc=eg:GetFirst()

    while tc do

        if tc:IsFaceup()
            and tc:IsPreviousLocation(LOCATION_EXTRA) then

            local mg=tc:GetMaterial()

            if mg and mg:IsExists(s.matfilter,1,nil) then

                local p=tc:GetControler()
                local islorenzo=tc:IsSetCard(SET_LORENZO)

                local cansearch=Duel.IsExistingMatchingCard(
                    s.thfilter,p,LOCATION_DECK,0,1,nil
                )

                ------------------------------------------
                -- Mostro "Lorenzo":
                -- entrambi i bonus
                ------------------------------------------
                if islorenzo then

                    if cansearch then
                        s.search(p)
                    end

                    Duel.SetChainLimitTillChainEnd(s.chlimit)

                else

                    --------------------------------------
                    -- Altro mostro:
                    -- scegli uno dei due bonus
                    --------------------------------------
                    if cansearch then

                        local op=Duel.SelectOption(
                            p,
                            aux.Stringid(id,0),
                            aux.Stringid(id,1)
                        )

                        if op==0 then
                            s.search(p)
                        else
                            Duel.SetChainLimitTillChainEnd(
                                s.chlimit
                            )
                        end

                    else

                        Duel.SetChainLimitTillChainEnd(
                            s.chlimit
                        )
                    end
                end
            end
        end

        tc=eg:GetNext()
    end
end