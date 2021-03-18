--Light Shift
--by King Of Justice
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	--If you control a "Light Bringer" monster, add this card to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	end
	
function s.condition(e,tp,eg,ep,ev,re,r,rp)

	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	local tc=Duel.GetAttacker()
	if not tc:IsControler(tp) then tc,bc=bc,tc end
	e:SetLabelObject(tc)
	return not bc:IsControler(tp) and tc:IsSetCard(0x616) and tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE) or tc:IsCode(21251800) and tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local bc=tc:GetBattleTarget()
	if tc:IsRelateToBattle() and not tc:IsImmuneToEffect(e)
		and tc:IsControler(tp) and not bc:IsControler(tp) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(bc:GetAttack()+500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EVENT_DAMAGE_STEP_END)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		Duel.RegisterEffect(e2,tp)
	end
end
--------------------------------------------------------------------------------------------

--Check if player controls a "Light Bringer" monster
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x616),tp,LOCATION_MZONE,0,1,nil) and Duel.GetTurnPlayer()==tp
end
	--Activation legality
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_GRAVE)
end
	--Add this card from GY to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,tp,REASON_EFFECT)
	end
end