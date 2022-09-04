--Evil Hero Dark Shield
--Scripted by OkumuraPlays
local s,id=GetID()
function s.initial_effect(c)
      c:AddSetcodesRule(id,true,0x6008)
      -- Special Summon and Negate attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
      e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_HAND)
      e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
      --Type change
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target(LOCATION_MZONE))
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={0x6008}
s.listed_names={84327329}
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
      return at and at:IsControler(tp)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		Duel.NegateAttack()
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x6008)
end
function s.target(oppo)
	return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and (oppo==0 or chkc:IsControler(tp)) and s.filter(chkc) and chkc:IsDifferentRace(e:GetLabel()) end
		if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
		local g=Duel.GetMatchingGroup(aux.AND(s.filter,Card.IsCanBeEffectTarget),tp,LOCATION_MZONE,0,nil)
		local rc=aux.AnnounceAnotherRace(g,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sel=g:FilterSelect(tp,Card.IsDifferentRace,1,1,nil,rc)
		Duel.SetTargetCard(sel)
		e:SetLabel(rc)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(e:GetLabel())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end

