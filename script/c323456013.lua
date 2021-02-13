--Number A79: Chaos Dragon Lord Nokturne
--Scripted by Nekronomikon
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Procedure
	Xyz.AddProcedure(c,nil,8,2,nil,nil,99)
	c:EnableReviveLimit()
	--Attribute Change
	local ex1=Effect.CreateEffect(c)
	ex1:SetType(EFFECT_TYPE_SINGLE)
	ex1:SetCode(EFFECT_ADD_ATTRIBUTE)
	ex1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	ex1:SetRange(LOCATION_MZONE)
	ex1:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(ex1)
	--Overlay from GY!
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.matcon)
	e1:SetTarget(s.mattg)
	e1:SetOperation(s.matop)
	c:RegisterEffect(e1)
	--Detach; Apply Light or Dark
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.xyz_number=79
--Overlay from GY!
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and (c:GetLevel()==7 or c:GetLevel()==8)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_GRAVE,0,1,2,nil)
	if #g>=0 then
		Duel.Overlay(e:GetHandler(),g)
	end
end

--Detach; Apply Light or Dark
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_LIGHT)<=1
		and sg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_DARK)<=1
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	local att=0
	if Duel.IsExistingMatchingCard(s.refilter,tp,LOCATION_REMOVED,0,1,nil) then att=att | ATTRIBUTE_LIGHT end
	if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.CheckReleaseGroupCost(tp,Card.IsType,1,false,nil,nil,TYPE_MONSTER) then att=att | ATTRIBUTE_DARK end
	if chk==0 then return att>0 and g:IsExists(Card.IsAttribute,1,nil,att) end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=c:GetOverlayGroup()
	local att=0
	if Duel.IsExistingMatchingCard(s.refilter,tp,LOCATION_REMOVED,0,1,nil) then att=att | ATTRIBUTE_LIGHT end
	if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.CheckReleaseGroupCost(tp,Card.IsType,1,false,nil,nil,TYPE_MONSTER) then att=att | ATTRIBUTE_DARK end
	if att==0 then return end
	local sg=aux.SelectUnselectGroup(g:Filter(Card.IsAttribute,nil,att),e,tp,1,1,s.rescon,1,tp,HINTMSG_XMATERIAL)
	local lb=0
	for tc in aux.Next(sg) do
		lb=lb | tc:GetAttribute()
	end
	--lb=lb & 0x7
	Duel.SendtoGrave(sg,REASON_EFFECT)
	Duel.RaiseSingleEvent(c,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	Debug.Message(lb)
	Duel.BreakEffect()
	if lb & ATTRIBUTE_LIGHT ~=0 then
		local g=Duel.SelectMatchingCard(tp,s.dafilter,tp,LOCATION_REMOVED,0,1,2,nil,e,tp)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_COST+REASON_RETURN)
			local ct=#(Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE))
			if ct>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local dg=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
				Duel.SpecialSummon(dg,0,tp,tp,false,false,POS_FACEUP)
				local ex2=Effect.CreateEffect(c)
				ex2:SetCountLimit(1,id+1000)
				c:RegisterEffect(ex2)
			end
		end
	end
	if lb & ATTRIBUTE_DARK ~=0 then
		local g=Duel.SelectReleaseGroupCost(tp,Card.IsType,1,2,false,nil,nil,TYPE_MONSTER)
		Duel.Release(g,REASON_COST)
		if #g>0 then
			local gc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,#g,nil)
			if #gc>0 then
				Duel.SendtoGrave(gc,REASON_EFFECT)
				local ex2=Effect.CreateEffect(c)
				ex2:SetCountLimit(1,id+100)
				c:RegisterEffect(ex2)
			end
		end
	end
end

function s.ssfilter(c,e,tp)
    return (c:IsAttribute(ATTRIBUTE_DARK) or c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.dfilter(c,e,tp)
    return c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER)
end

function s.dafilter(c,e,tp)
    return c:IsType(TYPE_MONSTER)
end

function s.refilter(c,e,tp)
    return c:IsAbleToGrave() and c:IsType(TYPE_MONSTER)
end

function s.tgfilter(c)
    return (c:IsAttribute(ATTRIBUTE_DARK) or c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsAbleToGrave()
end