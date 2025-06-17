-- Bisceglia
local s, id = GetID()
function s.initial_effect(c)
  -- Once per turno: puoi rivelare questa carta dalla tua mano; annulla 1 attacco.
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetCode(EVENT_ATTACK_ANNOUNCE)
  e1:SetRange(LOCATION_HAND)
  e1:SetCountLimit(1, id)
  e1:SetCondition(s.atkcon)
  e1:SetCost(s.atkcost)
  e1:SetOperation(s.atkop)
  c:RegisterEffect(e1)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetAttacker()~=nil
end

function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return not e:GetHandler():IsPublic() end
  -- Rivela la carta
  Duel.ConfirmCards(1-tp, e:GetHandler())
  Duel.ShuffleHand(tp)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  Duel.NegateAttack()
end