--The Spirit-Sleeping Ocean, Denad
--Scripted by "Nekronomikon"
local s,id=GetID()
function s.initial_effect(c)
	--Activate (1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Send a Spirit to GY (2-3)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Set or Normal Summon (4)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end

--Send a Spirit to GY (2-3)
function s.tgfilter(c)
    return c:IsType(TYPE_SPIRIT) and c:IsAbleToGrave()
end
function s.drcfilter(c,tp)
	return c:IsType(TYPE_SPIRIT) and not c:IsType(TYPE_TOKEN) and c:IsSummonPlayer(tp)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.drcfilter,1,nil,tp)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

--Set or Normal Summon (4)
function s.spifilter(c)
    return c:IsType(TYPE_SPIRIT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.spifilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.setfilter(c,tp)
	return c:GetType()==TYPE_TRAP and c:IsSSetable() and aux.IsCodeListed(c,987656959)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,tp)
		or Duel.IsExistingMatchingCard(s.spifilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local off=1
	local ops={}
	local opval={}
	if (Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,tp)) then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if (Duel.IsExistingMatchingCard(s.spifilter,tp,LOCATION_HAND,0,1,nil)) then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
		if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then --Set Trap
		ops[off]=aux.Stringid(id,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,rc:GetCode())
		if #g>0 then
			Duel.SSet(tp,g)
		end
	elseif opval[op]==2 then --Normal Summon
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local gc=Duel.SelectMatchingCard(tp,s.spifilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.Summon(tp,gc:GetFirst(),true,nil)
	end
end
