--Princess Witch Baal
--by King Of Justice
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Materials
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x313),2,s.mfilter,1)
	--Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x313),2)
	
	--Treated as Lady Witch Sora
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	e1:SetValue(15005)
	c:RegisterEffect(e1)
	
	--If This card is Fusion Summoned using Lady Witch Sora as a Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
	
	--This card cannot be destroy by battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	
	--Immune to Your opponent's Spells
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	
	--MUST BE FUSION SUMMONED
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(aux.fuslimit)
	c:RegisterEffect(e5)
	
	--Your Opponent cannot activate any Spell/Trap cards or Monster effects
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(EFFECT_CANNOT_ACTIVATE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,1)
	e6:SetValue(s.aclimit)
	e6:SetCondition(s.actcon)
	c:RegisterEffect(e6)
	
	--You take no battle damage involving this card
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e7:SetValue(1)
	c:RegisterEffect(e7)
	
	--Inflict Damage and Destroy
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_BATTLED)
	e8:SetCondition(s.condition)
	e8:SetTarget(s.target)
	e8:SetOperation(s.operation)
	c:RegisterEffect(e8)
	
	--When Fusion Summoned
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
	e9:SetCategory(CATEGORY_DESTROY)
	e9:SetCountLimit(1)
	e9:SetTarget(s.target2)
	e9:SetOperation(s.operation2)
	c:RegisterEffect(e9)
end

function s.mfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x313 or 0x314)
end

-----------------------------------------------------------------------------------------------------------

function s.matfilter(c)
	return c:IsCode(15005) 
end

function s.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.matfilter,1,nil) then
		local e1=Effect.CreateEffect(c)
	    e1:SetType(EFFECT_TYPE_SINGLE)
	    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	    e1:SetRange(LOCATION_MZONE)
	    e1:SetValue(1)
	    c:RegisterEffect(e1)
	end
end

-----------------------------------------------------------------------------------------------------------

function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_SPELL)
end

-----------------------------------------------------------------------------------------------------------

function s.aclimit(e,re,tp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))  
end

function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end

-----------------------------------------------------------------------------------------------------------

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and (bc:GetSummonType()&SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL and c:GetBaseAttack()~=bc:GetBaseAttack()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsRelateToBattle() end
	local atk=math.abs(e:GetHandler():GetBaseAttack()-bc:GetBaseAttack())
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetFirstTarget()
	if not bc then return false end
	local atk=math.abs(e:GetHandler():GetBaseAttack()-bc:GetBaseAttack())
	if bc:IsRelateToEffect(e) and bc:IsFaceup() and Duel.Damage(1-tp,atk,REASON_EFFECT)~=0 then
		Duel.Destroy(bc,REASON_EFFECT)
	end
end

-----------------------------------------------------------------------------------------------------------

function s.filter(c)
	return c:IsType(TYPE_MONSTER)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,c) end
	local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,e:GetHandler())
	Duel.Destroy(sg,REASON_EFFECT)
end




