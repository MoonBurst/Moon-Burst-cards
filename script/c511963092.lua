--Night Magic Girl
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,511963018,511963053)
	--to grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Cannot change control
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    c:RegisterEffect(e2)
    --remove
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local sg=g:Select(tp,1,1,nil)
        Duel.HintSelection(sg)
        Duel.SendtoGrave(sg,REASON_EFFECT)
end
function s.rmfilter1(c,tp)
	return c:IsSetCard(0x196) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToRemove() and aux.SpElimFilter(c,true,true)
		and Duel.IsExistingMatchingCard(s.rmfilter2,tp,0,LOCATION_MZONE,1,nil,c:GetAttribute())
end
function s.rmfilter2(c,att)
	return c:IsFaceup() and c:IsAttribute(att) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.rmfilter1(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectTarget(tp,s.rmfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	local g2=Duel.GetMatchingGroup(s.rmfilter2,tp,0,LOCATION_MZONE,nil,g1:GetFirst():GetAttribute())
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,#g1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local tg=Group.FromCards(tc)
		if tc:IsFaceup() then
			local g=Duel.GetMatchingGroup(s.rmfilter2,tp,0,LOCATION_MZONE,nil,tc:GetAttribute())
			tg:Merge(g)
		end
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
