--Enchantress Godiva
--by King Of Justice
--Artist: irua
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x1B36),7,2,nil,nil,7)
	
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
	
	--Cannot Be Destroyed Card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	
	--Can Attack twice
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	
	--Cannot Attack Link Monsters
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetValue(s.atlimit)
	c:RegisterEffect(e5)
	
	--Destroy 1 card
	local e6=Effect.CreateEffect(c)
	--e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(s.target)
	e6:SetOperation(s.operation)
	c:RegisterEffect(e6)
	
	--Negate Monster effect card
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_CHAINING)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,id)
	e7:SetCost(s.tdcost)
	e7:SetCondition(s.tdcondition)
	e7:SetTarget(s.tdtarget)
	e7:SetOperation(s.tdactivate)
	c:RegisterEffect(e7,false,REGISTER_FLAG_DETACH_XMAT)
	
	--Special Summon An Xyz Monster from GY
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,0))
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e8:SetCode(EVENT_LEAVE_FIELD)
	e8:SetCountLimit(1,id+100,EFFECT_COUNT_CODE_OATH)
	e8:SetCondition(s.spcon)
	e8:SetTarget(s.sptg)
	e8:SetOperation(s.spop)
	c:RegisterEffect(e8)
	
	--Special Summon An Xyz Monster from Extra Deck
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,1))
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e9:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e9:SetCode(EVENT_TO_GRAVE)
	e9:SetCountLimit(1,id+100,EFFECT_COUNT_CODE_OATH)
	e9:SetCondition(s.spcon)
	e9:SetTarget(s.sptg2)
	e9:SetOperation(s.spop2)
	c:RegisterEffect(e9)
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

function s.atlimit(e,c)
	return c:IsFaceup() and (c:IsSetCard(0x1B36) and c:IsLinkMonster()) or (c:IsType(TYPE_XYZ) and c:IsSetCard(0x1B36) and c:IsRankBelow(4))
end

-------------------------------------------------------------------------------------------------

function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

-------------------------------------------------------------------------------------------------

function s.tdcondition(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and (loc==LOCATION_HAND or loc==LOCATION_GRAVE) and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end

function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
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

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsSummonType(SUMMON_TYPE_XYZ)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1B36) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
	and c:IsRankBelow(7)
end

function s.mtfilter(c)
	return c:IsSetCard(0x1B36)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.IsExistingTarget(s.mtfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,#g1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,s.mtfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=tg:Filter(s.spfilter,nil,e,tp):GetFirst()
	if tc and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_GRAVE)
		and Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		local oc=tg:Filter(s.mtfilter,tc,e,tp):GetFirst()
		if oc and oc:IsControler(tp) and oc:IsRelateToEffect(e) and not oc:IsImmuneToEffect(e) then
			oc:CancelToGrave()
			Duel.Overlay(tc,oc,true)
		end
	end
end


--|||||||||||||||||||||||||||||||||||||||||||||---------------------------------------------------

function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x1B36) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
	and c:IsRankBelow(7) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,0)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 and c:IsRelateToEffect(e) then
		Duel.Overlay(g:GetFirst(),c)
	end
end

