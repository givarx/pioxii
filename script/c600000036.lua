-- c600000036.lua
-- Effetto carta magia:
-- "Aggiungi un 'Davide', 'Mr. Davide Scopece' oppure 'Scopece Sulekko' dal Deck alla tua mano"

function c600000036.initial_effect(c)
    -- Attivazione dell'effetto
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,600000036 + EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(c600000036.target)
    e1:SetOperation(c600000036.activate)
    c:RegisterEffect(e1)
end

-- Funzione filtro per individuare le carte desiderate
function c600000036.filter(c)
    -- Utilizza gli ID delle carte: 
    -- 600000037 => "Davide"
    -- 600000038 => "Mr. Davide Scopece"
    -- 600000039 => "Scopece Sulekko"
    return (c:IsCode(600000000) or c:IsCode(600000012) or c:IsCode(600000013)) and c:IsAbleToHand()
end

function c600000036.target(e, tp, eg, ep, ev, re, r, chk)
    if chk == 0 then 
        return Duel.IsExistingMatchingCard(c600000036.filter, tp, LOCATION_DECK, 0, 1, nil) 
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function c600000036.activate(e, tp, eg, ep, ev, re, r)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, c600000036.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if g:GetCount() > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end