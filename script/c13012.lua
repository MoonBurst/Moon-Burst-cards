--Poltergeist Haven
--by King Of Justice (Moon Burst Helped)
local s,id=GetID()
function s.initial_effect(c)
    --Activation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	--e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	
	--Cannot Be Destroyed By Battle 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.batarget)
	e2:SetValue(s.bafilter)
	c:RegisterEffect(e2)
	
	--Negate And Destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+100)
    e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	
	local e4=e3:Clone()
	e4:SetCondition(s.negcon2)
	c:RegisterEffect(e4)
	
	--"Poltergeist" Monsters You Control Gain 500 ATK Points
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x67C))
	e5:SetCondition(s.atkcon)
	e5:SetValue(500)
	c:RegisterEffect(e5)
	
	--Destruction Replacement
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EFFECT_DESTROY_REPLACE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTarget(s.reptarget)
	e6:SetOperation(s.repoperation)
	c:RegisterEffect(e6)
	
end

function s.cbnfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
end

--------------------------------------------------------------------------------------------------------

function s.batarget(e,c)
	return c:IsSetCard(0x67C) and c:IsType(TYPE_MONSTER)
end

function s.bafilter(e,c)
	return c:IsSummonLocation(LOCATION_GRAVE)
end

--------------------------------------------------------------------------------------------------------

function s.negfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.negfilter,1,nil,tp) and Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
	and Duel.GetTurnPlayer()==tp
end

function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and Duel.IsChainNegatable(ev) and loc==LOCATION_GRAVE and Duel.GetTurnPlayer()==tp
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------------------------------

function s.atkcon(e)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
end

--------------------------------------------------------------------------------------------------------

function s.repfilter(c)
	return c:IsSetCard(0x67C) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and aux.nvfilter(c)
end

function s.reptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_RULE)
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end

function s.repoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_REPLACE)
end


