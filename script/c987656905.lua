--Infernashade Concert
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.filter(c)
    return c:IsSetCard(0xc66) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local off=1
	local ops={}
	local opval={}
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then --Draw 1 card
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local c,g=e:GetHandler(),Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			--cannot special summon
			local e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetRange(LOCATION_HAND)
			e1:SetCode(EFFECT_SPSUMMON_CONDITION)
			e1:SetTarget(s.distg)
			e1:SetLabel(g:GetOriginalCodeRule())
			Duel.RegisterEffect(e1,tp)
		end
	elseif opval[op]==2 then --Set 1 "Mayakashi" spell/trap from deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
			--cannot special summon
			local e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetRange(LOCATION_GRAVE)
			e1:SetCode(EFFECT_SPSUMMON_CONDITION)
			e1:SetTarget(s.distg)
			e1:SetLabel(g:GetOriginalCodeRule())
			Duel.RegisterEffect(e1,tp)
		end
	end
end

function s.distg(e,c)
	local code=e:GetLabel()
	local code1,code2=c:GetOriginalCodeRule()
	return code1==code or code2==code
end