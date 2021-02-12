--Into the Void
local s,id=GetID()
function s.initial_effect(c)
	--pos
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34646691,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetTargetRange(0,LOCATION_ONFIELD)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
		local e5=e2:Clone()
	e5:SetCode(EVENT_MSET)
	c:RegisterEffect(e5)
	local e6=e2:Clone()
	e6:SetCode(EVENT_SSET)
	c:RegisterEffect(e6)
	
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
end
function s.filter(c,e,tp)
	return  (c:IsFaceup(e) or not c:IsFaceup(e)) and not c:IsSetCard(0x666)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter,nil,e)
	if not Card.Type then 
	Duel.Exile(g,REASON_RULE)
	else
	if Card.Type then 
	 Duel.SendtoDeck(g,nil,-2,REASON_RULE)
	 end
end
end

