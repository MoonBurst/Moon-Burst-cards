--Enchantress Odette
--by King Of Justice
--Artist: irua
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x1B36),4,2,s.ovfilter,aux.Stringid(id,0),7)
	
	--Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.attval)
	c:RegisterEffect(e1)

	--Cannot Be Destroyed By Battle
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(s.btindes)
	c:RegisterEffect(e2)
	
	--Negate Trap card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.tdcost)
	e3:SetCondition(s.tdcondition)
	e3:SetTarget(s.tdtarget)
	e3:SetOperation(s.tdactivate)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	
	--Negate Monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
s.listed_series={0x1B36}

function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsType(TYPE_LINK,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsSetCard(0x1B36,xyzc,SUMMON_TYPE_XYZ,tp)
end

-------------------------------------------------------------------------------------------------

function s.attval(e,c)
	local att=0
	local og=e:GetHandler():GetOverlayGroup()
	for tc in aux.Next(og) do
		att=att|tc:GetAttribute()
	end
	return att
end

-------------------------------------------------------------------------------------------------
function s.btindes(e,c)
	return c:IsAttribute(e:GetHandler():GetAttribute())
end
-------------------------------------------------------------------------------------------------

function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.tdcondition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end

function s.tdtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end

function s.tdactivate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		ec:CancelToGrave()
		Duel.SendtoDeck(ec,nil,2,REASON_EFFECT)
	end
end

-------------------------------------------------------------------------------------------------
function s.negfilter(c,e,tp)
	return c:IsFaceup()
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.negfilter(chkc) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and s.negfilter(tc) and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END) 
		tc:RegisterEffect(e2)

	end
end

