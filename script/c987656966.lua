--Decad Rising
--Scripted by "Nekronomikon"
local s,id=GetID()
function s.initial_effect(c)
	--Activate (1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

--Activate (1)
function s.filter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsFaceup()
end
function s.ecfilter(c,code)
	return c:IsType(TYPE_SPIRIT) and not c:IsCode(code)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and (Duel.IsExistingMatchingCard(s.ecfilter,tp,LOCATION_DECK,0,1,nil) or Duel.IsExistingMatchingCard(s.ecfilter,tp,LOCATION_GRAVE,0,1,nil)
			or Duel.IsExistingMatchingCard(s.ecfilter,tp,LOCATION_HAND,0,1,nil)) end
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst():GetCode()
	e:SetLabel(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local off=1
	local ops={}
	local opval={}
	if (Duel.IsExistingMatchingCard(s.ecfilter,tp,LOCATION_DECK,0,1,nil,code)) then --CHECK FOR ADD TO HAND
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if (Duel.IsExistingMatchingCard(s.ecfilter,tp,LOCATION_GRAVE,0,1,nil,code)) then --CHECK FOR ADD FROM GRAVE
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if (Duel.IsExistingMatchingCard(s.ecfilter,tp,LOCATION_HAND,0,1,nil,code)) then --CHECK FOR NORMAL SUMMON
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=3
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then --ADD 1 SPIRIT FROM DECK
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local gc=Duel.SelectMatchingCard(tp,s.ecfilter,tp,LOCATION_DECK,0,1,1,nil,code)
		if #gc>0 then
			Duel.SendtoHand(gc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,gc)
	end
	elseif opval[op]==2 then --RETURN SPIRIT FROM GY, NORMAL SUMMON SPIRIT
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local gc=Duel.SelectMatchingCard(tp,s.ecfilter,tp,LOCATION_GRAVE,0,1,1,nil,code)
		if #gc>0 then
			Duel.SendtoHand(gc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,gc)
			Duel.Summon(tp,gc:GetFirst(),true,nil)
		end
	elseif opval[op]==3 then --NORMAL SUMMON SPIRIT
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local gc=Duel.SelectMatchingCard(tp,s.ecfilter,tp,LOCATION_HAND,0,1,1,nil,code)
		Duel.Summon(tp,gc:GetFirst(),true,nil)
	end
end