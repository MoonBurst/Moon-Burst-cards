--Princess Witch Jeanne
--by King Of Justice
local s,id=GetID()
function s.initial_effect(c)
    --Link Materials
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x313),2,2)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	c:AddSetcodesRule(0x313) --This card is always treated as a "Lady Witch" card

	--Link Summon Effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	
	--If This card is Link Summoned using Lady Witch Camellia as a Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
	
	--If This card is Link Summoned using Lady Witch Sarissa as a Material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.matcheck2)
	c:RegisterEffect(e3)
	
	--A "Princess Witch" monster using this card as a Material cannot be destroyed by card effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCondition(s.flcon)
	e4:SetOperation(s.flop)
	c:RegisterEffect(e4)
	
	--Destroy a Set card
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	--e5:SetCondition(aux.exccon)
	e5:SetCost(aux.bfgcost)
	e5:SetTarget(s.target)
	e5:SetOperation(s.activate)
	c:RegisterEffect(e5)
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.setfilter(c)
	return c:IsSetCard(0x313) and c:IsType(TYPE_TRAP+TYPE_SPELL) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
		if tc.act_turn then
			local e0=Effect.CreateEffect(tc)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e0)
		end
	end
end

------------------------------------------------------------------------------------------------------

function s.matfilter(c)
	return c:IsCode(15006) 
end
function s.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.matfilter,1,nil) then
		local e1=Effect.CreateEffect(c)
	    e1:SetType(EFFECT_TYPE_SINGLE)
	    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	    e1:SetRange(LOCATION_MZONE)
	    e1:SetValue(1)
	    c:RegisterEffect(e1)
	end
end

--------------------------------------------------------------------------------------------------------------

function s.matfilter2(c)
	return c:IsCode(15008) 
end
function s.matcheck2(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.matfilter2,1,nil) then
		local e1=Effect.CreateEffect(c)
	    e1:SetType(EFFECT_TYPE_SINGLE)
	    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	    e1:SetRange(LOCATION_MZONE)
	    e1:SetValue(1)
	    c:RegisterEffect(e1)
	end
end

--------------------------------------------------------------------------------------------------------------

function s.flcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_ONFIELD) and (r==REASON_FUSION or r==REASON_LINK) and c:GetReasonCard():IsSetCard(0x313 or 0x314)
end

function s.flop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	rc:RegisterEffect(e1)
end

--------------------------------------------------------------------------------------------------------------

function s.filter(c)
	return c:IsFacedown()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE+LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_SZONE+LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_SZONE+LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(s.limit(g:GetFirst()))
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.limit(c)
	return	function (e,lp,tp)
				return e:GetHandler()~=c
			end
end

