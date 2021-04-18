--Poltergeist Luciana
--by King Of Justice
--Artist: Ell
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	
	--Must Be Ritual Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	
	--Control Of This Card Cannot Be Switched
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    c:RegisterEffect(e2)
	
	--Cannot Attack Directly
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e3)
	
	--This Card Can Attack All Monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	
	--Your Opponent Cannot Activate Any Spell/Trap Cards When This Card Attacks
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetValue(s.aclimit)
	e5:SetCondition(s.actcon)
	c:RegisterEffect(e5)
	
	--If This Card Inflict Battle Damage, Inflict 500 Points Of Damage
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_BATTLE_DAMAGE)
	e6:SetCondition(s.condition)
	e6:SetTarget(s.target)
	e6:SetOperation(s.operation)
	c:RegisterEffect(e6)

    --Inflict 200 For Each "Poltergeist" Monster In Your Graveyard
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetCountLimit(1,id)
	e7:SetTarget(s.damtg)
	e7:SetOperation(s.damop)
	c:RegisterEffect(e7)
end

function s.aclimit(e,re,tp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE))
end

function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end

--------------------------------------------------------------------------------------------------------

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

--------------------------------------------------------------------------------------------------------

function s.damfilter(c)
	return c:IsSetCard(0x67C) and c:IsType(TYPE_MONSTER) 
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_GRAVE,0,nil)*200
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_GRAVE,0,nil)*200
	Duel.Damage(p,dam,REASON_EFFECT)
end
