--Night Style
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_BE_BATTLE_TARGET)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --cannot direct attack
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0,TIMING_ATTACK)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(s.grcondition)
    e2:SetCost(aux.bfgcost)
    e2:SetOperation(s.groperation)
    c:RegisterEffect(e2)
end
s.listed_series={0x196}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.GetAttacker():IsControler(tp)
        and eg:GetFirst():IsControler(tp) and eg:GetFirst():IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,eg:GetFirst():GetAttack())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    if Duel.NegateAttack() and tc:IsRelateToBattle() then
        local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
        Duel.Damage(p,tc:GetAttack(),REASON_EFFECT)
    end
end
function s.grcondition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp and (Duel.IsAbleToEnterBP() or (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE))
end
function s.groperation(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end