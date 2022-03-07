--Enchantress Eye
--by King Of Justice
--Artist: CLIP STUDIO PAINT by Akylha
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	--Level Change
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	--e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.lvcost)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
s.listed_series={0x1B36}

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,1-tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(p,g)
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
		local sg=g:Select(p,1,1,nil)
		Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
		Duel.ShuffleHand(1-p)
	end
end


--------------------------------------------------------------------------------------

function s.lvfilter(c)
    local lv=c:GetLevel()
	return c:IsSetCard(0x1B36) and lv>0 and lv~=clv and c:IsAbleToRemoveAsCost()
end

function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_GRAVE,0,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_GRAVE,0,1,1,nil,c)
	local lv=g:GetFirst():GetLevel()
	Duel.SetTargetParam(lv)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSetCard,0x1B36),tp,LOCATION_MZONE,0,nil)
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv+2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end




