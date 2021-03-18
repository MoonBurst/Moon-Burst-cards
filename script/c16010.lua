--Light World
--by King Of Justice
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	
	--atk & def for light bringers
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x616)) 
	e2:SetValue(500)
	c:RegisterEffect(e2)
	
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	
	--atk & def for lucifer
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsCode,21251800)) 
	e4:SetValue(1000)
	c:RegisterEffect(e4)
	
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	
	--Lucifer effect immunity
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetTarget(s.etarget)
	e6:SetValue(s.efilter)
	c:RegisterEffect(e6)
	
	--Destroy a card
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCountLimit(1,id)
	e7:SetCondition(s.condition)
	e7:SetTarget(s.target)
	e7:SetOperation(s.activate)
	c:RegisterEffect(e7)
	
	--negate
	--local e8=Effect.CreateEffect(c)
	--e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	--e8:SetCode(EVENT_ATTACK_ANNOUNCE)
	--e8:SetRange(LOCATION_FZONE)
	--e8:SetCondition(s.discon)
	--e8:SetOperation(s.disop)
	--c:RegisterEffect(e8)
	
end
	
function s.etarget(e,c)
	return c:IsCode(21251800)
end
function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(21251800)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)  --e7:SetCondition(s.condition)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.activate(e)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end



--------------------------------------------------------------------------------

--function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- a=Duel.GetAttacker()
	--local at=Duel.GetAttackTarget()
	--return at and a:IsCode(21251800)
--end
--function s.disop(e,tp,eg,ep,ev,re,r,rp)
	--local tc=Duel.GetAttackTarget()
	--local e1=Effect.CreateEffect(e:GetHandler())
	--e1:SetType(EFFECT_TYPE_SINGLE)
	--e1:SetCode(EFFECT_DISABLE)
	--e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	--tc:RegisterEffect(e1)
	--local e2=Effect.CreateEffect(e:GetHandler())
	--e2:SetType(EFFECT_TYPE_SINGLE)
	--e2:SetCode(EFFECT_DISABLE_EFFECT)
	--e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	--tc:RegisterEffect(e2)
--end











