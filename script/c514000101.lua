--Evil Hero Burst Mistress
--Scripted by OkumuraPlays
local s,id=GetID()
function s.initial_effect(c)
      c:AddSetcodesRule(id,true,0x6008)
      --damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
      --Draw and Effect Damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DRAW+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_REMOVE)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
end
s.listed_series={0x6008}
s.listed_names={58932615}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(800)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    if Duel.Draw(p,d,REASON_EFFECT)~=0 then
    Duel.SetTargetPlayer(1-tp)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,100)
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    local d=Duel.GetFieldGroupCount(p,LOCATION_ONFIELD,0)*100
    Duel.Damage(p,d,REASON_EFFECT)
    end
end
