--Enchantress Rayne
--by King Of Justice
--Artist: irua
-- BIG THANKS TO MOON BURST :3 
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x1B36),6,2,nil,nil,7)
	
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
	
	--Unaffected by Spell Cards
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	
	--Special Summon Effect
	local e4=Effect.CreateEffect(c)
	--e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,id)
	--e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
	
	--Attach 1 card from your GY 
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+100)
	e5:SetCondition(s.condition)
	e5:SetTarget(s.target)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
	
	--Negate Monster card
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id+200)
	e6:SetCost(s.tdcost)
	e6:SetCondition(s.tdcondition)
	e6:SetTarget(s.tdtarget)
	e6:SetOperation(s.tdactivate)
	c:RegisterEffect(e6,false,REGISTER_FLAG_DETACH_XMAT)
	
	--Destroy this card instead
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_DESTROY_REPLACE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,id+300)
	e7:SetCondition(s.repcon)
	e7:SetTarget(s.reptg)
	e7:SetValue(s.repval)
	e7:SetOperation(s.repop)
	c:RegisterEffect(e7)
end
s.listed_series={0x1B36}

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

function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end

-------------------------------------------------------------------------------------------------
function s.setfilter(c)
	return c:IsCode(17013) and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,1,nil) end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
			local e0=Effect.CreateEffect(tc)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e0)
	end
end

-------------------------------------------------------------------------------------------------

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	return c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,17013)
end

function s.filter(c,tp)
	return c:IsSetCard(0x1B36) --and c:IsType(TYPE_MONSTER)
end

function s.filter2(c,tp)
	return c:IsSetCard(0x1B36) and c:IsType(TYPE_XYZ)
end

--function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    --if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc) end
    --if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,nil)
        --and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,e:GetHandler(),0x1B36) end
    --Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    --Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
    --Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
--end

--function s.operation(e,tp,eg,ep,ev,re,r,rp)
    --local tc=Duel.GetFirstTarget()
    --if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_XYZ)
        --and not tc:IsImmuneToEffect(e) then
        --Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
        --local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_GRAVE,0,1,1,nil,0x1B36)
        --if #g==0 then return end
        --Duel.Overlay(tc,g)
    --end
--end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,tp) and chkc~=e:GetHandler() end
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
   Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFirstTarget()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local xyz=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil,g)
        if #xyz>0 then
            Duel.HintSelection(xyz)
            Duel.Overlay(xyz:GetFirst(),g)
    end
end
    

-------------------------------------------------------------------------------------------------

function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.tdcondition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
	and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,17013)
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
function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayCount()==0
end

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsSetCard(0x1B36) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)    
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end

