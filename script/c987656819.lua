--Thaumic Firestorm
--Scripted by "Nekro"
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,2,3,s.lcheck)
	--Use Materials in S/T (1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(1,1)
	e1:SetOperation(s.extracon)
	e1:SetValue(s.extraval)
	c:RegisterEffect(e1)
	--Send Monster to GY (2)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--Activation Limit (3)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(1)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
	--ATK+ for Linked (4)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
end

--Summon Filters
function s.matfilter(c)
	return c:IsSetCard(0xc54) and (c:IsAttribute(ATTRIBUTE_FIRE) or (c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)))
end
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end

--Use Material in S/T (1)
s.curgroup=nil
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	return not s.curgroup or #(sg&s.curgroup)<3
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local c=e:GetHandler()
		local ex=Effect.CreateEffect(c)
		ex:SetType(EFFECT_TYPE_SINGLE)
		ex:SetCode(EFFECT_ADD_TYPE)
		ex:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ex:SetReset(RESET_EVENT+RESETS_STANDARD)
		ex:SetOperation(s.chngcon)
		ex:SetValue(TYPE_MONSTER)
		c:RegisterEffect(ex)
		local ex2=Effect.CreateEffect(c)
		ex2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		ex2:SetRange(LOCATION_EXTRA)
		ex2:SetTargetRange(LOCATION_SZONE,0)
		ex2:SetTarget(s.eftg)
		ex2:SetLabelObject(ex)
		c:RegisterEffect(ex2)
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			s.curgroup=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_SZONE,0,nil)
			s.curgroup:KeepAlive()
			return s.curgroup
		end
	elseif chk==2 then
		if s.curgroup then
			s.curgroup:DeleteGroup()
		end
		s.curgroup=nil
	end
end
function s.eftg(e,c)
	return c:IsSetCard(0xc54) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)
end
function s.chngcon(scard,sumtype,tp)
    return (sumtype&SUMMON_TYPE_LINK|MATERIAL_LINK)==SUMMON_TYPE_LINK|MATERIAL_LINK
end

--Send Opponent's Monster to GY (1)
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMaterial():FilterCount(Card.IsCode,nil,987656806)>0
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToGrave() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
	local dam=g:GetAttack()/2
    if dam<0 then dam=0 end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(dam)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
	end
end

--Activation Limit (3)
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end

--ATK+ for Linked (4)
function s.atkval(e,c)
	return c:GetLinkedGroup():FilterCount(aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),nil)*300
end