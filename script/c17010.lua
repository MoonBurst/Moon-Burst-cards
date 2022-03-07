--Enchantress Stardust
--by King Of Justice
local s,id=GetID()
function s.initial_effect(c)
    --Activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	
	--Become Xyz material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
	
	--Perform an Xyz Summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_FREE_CHAIN)
	--e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+100)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
s.listed_series={0x1B36}

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1B36) and c:HasLevel()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsCanBeEffectTarget(e)
end

function s.rfilter(c,lv)
	return c:GetLevel()==lv
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and g:GetClassCount(Card.GetLevel)>=2 end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetLevel),1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,2,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #sg>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if #sg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg=sg:Select(tp,ft,ft,nil)
	end
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end

------------------------------------------------------------------------------------------------

function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1B36) and c:IsType(TYPE_XYZ)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,c)
	end
end
------------------------------------------------------------------------------------------------

function s.xyzfilter(c)
	return c:IsSetCard(0x1B36) and c:IsXyzSummonable()
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=g:Select(tp,1,1,nil)
		Duel.XyzSummon(tp,tg:GetFirst())
	end
end
