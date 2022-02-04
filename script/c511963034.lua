--Night Shadow
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetRange(LOCATION_HAND)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Damage
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(aux.bfgcost)
    e2:SetCondition(s.condition)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
    aux.GlobalCheck(s,function()
        local ge2=Effect.CreateEffect(c)
        ge2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge2:SetCode(EVENT_BATTLE_DAMAGE)
        ge2:SetOperation(s.gop)
        Duel.RegisterEffect(ge2,0)
    end)
end
s.listed_series={0x196}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local ec=eg:GetFirst()
    return ep==tp and ec:GetLevel()==4
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
        c:CompleteProcedure()
    end
end
function s.gop(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE and Duel.GetTurnPlayer()==tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFlagEffect(tp,id)~=0 or Duel.GetFlagEffect(1-tp,id)~=0 end
    local dep=nil
    if Duel.GetFlagEffect(tp,id)~=0 and Duel.GetFlagEffect(1-tp,id)~=0 then
        dep=PLAYER_ALL
    elseif Duel.GetFlagEffect(tp,id)~=0 then
        dep=tp
    else
        dep=1-tp
    end
    Duel.SetTargetPlayer(dep)
    Duel.SetTargetParam(1000)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,dep,1000)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    if p~=PLAYER_ALL then
        Duel.Damage(p,d,REASON_EFFECT)
    else
        Duel.Damage(1-tp,d,REASON_EFFECT,true)
        Duel.Damage(tp,d,REASON_EFFECT,true)
        Duel.RDComplete()
    end
end



