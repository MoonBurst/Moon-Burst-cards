--Night Mercenary
local s,id=GetID()
function s.initial_effect(c)
	--Link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
    --special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.atkval(e,c)
	return c:GetLinkedGroup():FilterCount(aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),nil)*500
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.mtfilter(c)
	return not c:IsType(TYPE_TOKEN) and c:IsAbleToChangeControler()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) 
		and Duel.IsExistingTarget(s.mtfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,#g1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,s.mtfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=tg:Filter(s.spfilter,nil,e,tp):GetFirst()
	if tc and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_GRAVE) 
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local oc=tg:Filter(s.mtfilter,tc,e,tp):GetFirst()
		if oc and oc:IsControler(1-tp) and oc:IsRelateToEffect(e) and not oc:IsImmuneToEffect(e) then
			local og=oc:GetOverlayGroup()
			if #og>0 then
				Duel.SendtoGrave(og,REASON_RULE)
			end
			oc:CancelToGrave()
			Duel.Overlay(tc,Group.FromCards(oc))
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
end
function s.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end
