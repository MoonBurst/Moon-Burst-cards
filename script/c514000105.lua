--Evil Hero Shadow Hunter
--Scripted by OkumuraPlays
local s,id=GetID()
function s.initial_effect(c)
      c:AddSetcodesRule(id,true,0x6008)
      --act limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetCondition(s.con)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	c:RegisterEffect(e1)
      --Destroy Spell/Trap
	local e2=Effect.CreateEffect(c)
      e2:SetDescription(aux.Stringid(id,0))
      e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_CONFIRM)
      e2:SetCondition(s.condition)
      e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.con(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.desfilter(c,e,te)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
      local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end