--Evil Hero Shadow Wing
--Scripted by OkumuraPlays
local s,id=GetID()
function s.initial_effect(c)
      c:AddSetcodesRule(id,true,0x6008)
      --cos
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x6008}
s.listed_names={21844576}
function s.filter(c,tc,tp)
	if not (c:IsSetCard(0x6008) and not c:IsForbidden()) then return false end
	local effs={c:GetCardEffect(id)}
	for _,te in ipairs(effs) do
		if te:GetValue()(tc,c,tp) then return true end
	end
	return false
end
function s.costfilter(c,ec)
	return c:IsSetCard(0x6008) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		and not c:IsSummonCode(nil,SUMMON_TYPE_FUSION,PLAYER_NONE,ec:GetCode(nil,SUMMON_TYPE_FUSION))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local cg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,c)
	Duel.SendtoGrave(cg,REASON_COST)
	e:SetLabel(cg:GetFirst():GetCode())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
      local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(e:GetLabel())
	e1:SetOperation(s.chngcon)
	c:RegisterEffect(e1)
      local e2 = e1:Clone()
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetValue(e:GetLabel())
	c:RegisterEffect(e2)
      local e3 = e1:Clone()
	e3:SetCode(EFFECT_ADD_ATTRIBUTE)
	e3:SetValue(e:GetLabel())
	c:RegisterEffect(e3)
end
function s.chngcon(scard,sumtype,tp)
	return (sumtype&MATERIAL_FUSION)~=0
end





























