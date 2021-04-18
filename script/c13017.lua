--Poltergeist Cemetery
--by King Of Justice (Moon Burst Helped)
local s,id=GetID()
function s.initial_effect(c)
    --Activation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	
	--Negate Monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.negcondition)
	e2:SetTarget(s.negtarget)
	c:RegisterEffect(e2)
	
	--Negate Monster's Effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.negcondition)
	e3:SetOperation(s.negoperation)
	c:RegisterEffect(e3)
	
	--Negate And Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
    e4:SetCondition(s.negcon)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
	
	local e5=e4:Clone()
	e5:SetCondition(s.negcon2)
	c:RegisterEffect(e5)
	
	--Special Summon A Banished "Poltergeist" Monster
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1,id+100)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
	
	--Destruction Replacement
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTarget(s.desreptg)
	c:RegisterEffect(e5)
end

function s.negtarget(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsSummonLocation(LOCATION_GRAVE)
end

function s.negoperation(e,tp,eg,ep,ev,re,r,rp)
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonLocation(LOCATION_GRAVE) 
	 and re:GetHandler():IsControler(1-tp) then
		Duel.NegateEffect(ev)
	end
end

function s.negfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x67C) and c:IsType(TYPE_MONSTER)
end

function s.negcondition(e,c,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.IsExistingMatchingCard(s.negfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
--------------------------------------------------------------------------------------------------------

function s.negfilter2(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.negfilter2,1,nil,tp) and Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
	and Duel.GetTurnPlayer()~=tp
end

function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and Duel.IsChainNegatable(ev) and loc==LOCATION_GRAVE and Duel.GetTurnPlayer()~=tp
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------------------------------

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x67C) and c:IsType(TYPE_MONSTER) 
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false) --and c:IsLevelBelow(4)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
	end
end

--------------------------------------------------------------------------------------------------------

function s.repfilter(c)
	return c:IsSetCard(0x67C) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() 
end

function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then	return not c:IsReason(REASON_REPLACE)  and c:IsReason(REASON_EFFECT)
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,c) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,c)  
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
