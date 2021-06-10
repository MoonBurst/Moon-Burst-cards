--Night Attack!
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,511963018)
end
function s.filter(c)
    return c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
    Duel.Destroy(g,REASON_EFFECT)
end
