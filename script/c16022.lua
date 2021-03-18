--Light Bringer Nijiko
--by King Of Justice
local s,id=GetID()
function s.initial_effect(c)
    --link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)    

	--Link Summon once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.con)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	
	--cannot be target for attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tgcon)
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	
	--opponent cannot activate effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(1)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,aux.FilterBoolFunction(Card.IsSetCard,0x616) or id,ACTIVITY_SPSUMMON,aux.FilterBoolFunction(Card.IsCode,21251800))
	
	--gain life
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(aux.bfgcost)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.gatarget)
	e4:SetOperation(s.gaoperation)
	c:RegisterEffect(e4)
	
	--cannot attack
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_ATTACK)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.tgcon)
	c:RegisterEffect(e5)
	
	--cannot be targeted by card effect
	local e6=e2:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e6:SetValue(aux.tgoval)
	c:RegisterEffect(e6)
	
	--opponent cannot activate effects (lucifer)
	local e7=e3:Clone()
	e7:SetCondition(s.actcon2)
	c:RegisterEffect(e7)
end

function s.matfilter(c,lc,sumtype,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x616,lc,sumtype,tp) 
end
	
---------------------------------------------------------------------------	
	
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK
end
---------------------------------------------------------------------------

function s.tgcon(e)
	return #(e:GetHandler():GetLinkedGroup():Filter(Card.IsType,nil,TYPE_MONSTER))>0
end

---------------------------------------------------------------------------

function s.actcon(e)
	local a=Duel.GetAttacker()
	return a and a:IsControler(e:GetHandlerPlayer()) and a:IsSetCard(0x616) 
		and e:GetHandler():GetLinkedGroup():IsContains(a)
end

function s.actcon2(e)
	local a=Duel.GetAttacker()
	return a and a:IsControler(e:GetHandlerPlayer()) and a:IsCode(21251800)
		and e:GetHandler():GetLinkedGroup():IsContains(a)
end

-------------------------------------------------------------------------
function s.gatarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsSetCard,0x616),tp,LOCATION_MZONE,0,nil)
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,ct*300)
end
function s.gaoperation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsSetCard,0x616),tp,LOCATION_MZONE,0,nil)
	Duel.Recover(p,ct*300,REASON_EFFECT)
end







