--Lunar Guardian's Blessing
local s,id=GetID()
function s.initial_effect(c)
c:EnableCounterPermit(0x99)
---c:SetCounterLimit(0x99,15)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--add counter
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.accon)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
	--sp summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(4066,7))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--move
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetDescription(aux.Stringid(4066,8))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.movecon)
	e4:SetTarget(s.movetg)
	e4:SetOperation(s.moveop)
	c:RegisterEffect(e4)
	--to hand
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetDescription(aux.Stringid(4066,15))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.searchcon)
	e5:SetTarget(s.searchtg)
	e5:SetOperation(s.searchop)
	c:RegisterEffect(e5)
	--destroy replace
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DESTROY_REPLACE)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTarget(s.destg)
	e6:SetValue(s.value)
	e6:SetOperation(s.desop)
	c:RegisterEffect(e6)
	--link zones
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_BECOME_LINKED_ZONE)
    e7:SetRange(LOCATION_SZONE)
    e7:SetValue(s.value)
    c:RegisterEffect(e7)
end
--activate card, get counters
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanAddCounter(tp,0x99,3,e:GetHandler()) 
end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x99)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
	c:AddCounter(0x99,3)
end
end
--Add Counters when targeted
function s.counterfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x666)
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false
end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.counterfilter,1,nil,tp)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x99,1)
end

--Special Summon from Hand
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x666) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x99)>=3
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
end
--Move
function s.movefilter(c)
	return c:IsType(TYPE_MONSTER)
end
function s.movecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x99)>=5
end
function s.movetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(s.movefilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	Duel.SelectTarget(tp,s.movefilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.moveop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0),2))
end
--add from Deck to hand.
function s.searchfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x666) and c:IsAbleToHand()
end
function s.searchcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x99)>=10
end
function s.searchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.searchfilter,tp,LOCATION_DECK,0,1,nil) 
end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.searchop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return
end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.searchfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
end
--pay counters to avoid destruction
function s.avoiddes(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD) and not c:IsReason(REASON_REPLACE) and c:IsType(TYPE_SPELL+TYPE_TRAP)
	and c:IsSetCard(0x666) and c:IsControler(tp) and c:IsReason(REASON_EFFECT)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
	local count=eg:FilterCount(s.avoiddes,nil,tp)
	e:SetLabel(count)
	return count>0 and Duel.IsCanRemoveCounter(tp,1,0,0x99,count*3,REASON_EFFECT)
end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.value(e,c)
	return c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD) and c:IsType(TYPE_SPELL+TYPE_TRAP)
	and c:IsSetCard(0x666) and c:IsControler(e:GetHandlerPlayer()) and c:IsReason(REASON_EFFECT)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabel()
	Duel.RemoveCounter(tp,1,0,0x99,count*3,REASON_EFFECT)
end
--link zones
function s.value(e)
    return 0x2+0x4+0x8<<16*e:GetHandlerPlayer()
	-- Zone values left to right 
	-- 0x1,0x2,0x4,0x8,0x10	
end

