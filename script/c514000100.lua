--Evil Hero Black Mist
--Scripted by OkumuraPlays
local s,id=GetID()
function s.initial_effect(c)
      c:AddSetcodesRule(id,true,0x6008)
      --spsummon proc 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
      --draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
s.listed_series={0x6008}
s.listed_names={79979666}
function s.filter(c)
    return c:IsFacedown() or not c:IsSetCard(0x6008)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and not    Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.fusionfilter(c)
 return c:IsFaceup() and c:IsSetCard(0x6008) and c:IsType(TYPE_FUSION)
end
function s.filter2(c)
    return not c:IsStatus(STATUS_LEAVE_CONFIRMED)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return (Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_MZONE,0,1,nil)) or 
    (not Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_ONFIELD,0,1,e:GetHandler()))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end