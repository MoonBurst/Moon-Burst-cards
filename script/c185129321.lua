--Justice Reversed - Nihilis Scourge
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,8,3,nil,nil,nil,nil,99,s.xyzcheck)
	--stats up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--change attribute
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e3:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e3)
	--banish stuff
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.con)
	e4:SetCost(s.detatch)
	e4:SetTarget(s.hdtg)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)
	--negate till end phase
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1)
	e5:SetCondition(s.discon)
	e5:SetTarget(s.distg)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
end
function s.xyzcheck(g)
	return g:IsExists(Card.IsSetCard,1,nil,0x1145)
end
--banish stuff
function s.confilter(c)
	return c:IsFaceup() and (c:IsType(TYPE_FUSION) or c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_XYZ) or c:IsType(TYPE_LINK))	
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,0,LOCATION_MZONE,1,nil)
end
function s.detatch(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end



function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local off=1
	local ops={}
	local opval={}
	if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_EXTRA,0,1,TYPE_FUSION,tp) and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,1,TYPE_FUSION,tp) then
		ops[off]=aux.Stringid(id,3)
		opval[off-1]=1
		off=off+1
	end
	if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_EXTRA,0,1,TYPE_SYNCHRO,tp) and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,1,TYPE_SYNCHRO,tp) then
		ops[off]=aux.Stringid(id,4)
		opval[off-1]=2
		off=off+1
	end
	if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_EXTRA,0,1,TYPE_XYZ,tp) and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,1,TYPE_XYZ,tp) then
		ops[off]=aux.Stringid(id,5)
		opval[off-1]=3
		off=off+1
	end
	if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_EXTRA,0,1,TYPE_LINK,tp) and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,1,TYPE_LINK,tp) then
		ops[off]=aux.Stringid(id,6)
		opval[off-1]=4
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then --Banish all Fusion
		local fus=Duel.GetMatchingGroup(Card.IsType,1-tp,0,LOCATION_EXTRA,TYPE_FUSION)
		Duel.Remove(fus,POS_FACEUP,REASON_EFFECT)
	elseif opval[op]==2 then --Banish all Synchro
			local syn=Duel.GetMatchingGroup(Card.IsType,1-tp,0,LOCATION_EXTRA,TYPE_SYNCHRO)
			Duel.Remove(syn,POS_FACEUP,REASON_EFFECT)
	elseif opval[op]==3 then --Banish all Xyz
		local xyz=Duel.GetMatchingGroup(Card.IsType,1-tp,0,LOCATION_EXTRA,TYPE_XYZ)
		Duel.Remove(xyz,POS_FACEUP,REASON_EFFECT)
	elseif opval[op]==4 then --Banish all Link
		local lin=Duel.GetMatchingGroup(Card.IsType,1-tp,0,LOCATION_EXTRA,TYPE_LINK)
		Duel.Remove(lin,POS_FACEUP,REASON_EFFECT)
	end
end


















--negate effect till end phase
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1145)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.disfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.disfilter1(c)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.disfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
