--Light Bringer Asahi
--by King Of Justice
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x616),2,2)
	c:EnableReviveLimit()
	
	--effect gain
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	
	--cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	
	--cards this card points to, indestructable by card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	
	--protecting Lucifer
	local e4=e3:Clone()
	e4:SetTarget(s.indtg2)
	c:RegisterEffect(e4)
	
	--cannot attack
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_ATTACK)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.tgcon)
	c:RegisterEffect(e5)
	
	--Destroy 1 card on the field
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetTarget(s.destg)
	e6:SetOperation(s.desop)
	c:RegisterEffect(e6)
	
	--remove
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(0,0xff)
	e7:SetValue(LOCATION_REMOVED)
	e7:SetTarget(s.rmtg)
	c:RegisterEffect(e7)

end
	
function s.filter(c)
	return c:IsCode(16022) 
end
function s.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.filter,1,nil) then
		local e1=Effect.CreateEffect(c)
	    e1:SetType(EFFECT_TYPE_SINGLE)
	    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	    e1:SetRange(LOCATION_MZONE)
	    e1:SetCode(EFFECT_UPDATE_ATTACK)
	    e1:SetValue(700)
	    c:RegisterEffect(e1)
	end
end

function s.indtg(e,c)
	return c:IsSetCard(0x616) and e:GetHandler():GetLinkedGroup():IsContains(c) 
end

function s.indtg2(e,c)
	return c:IsCode(21251800) and e:GetHandler():GetLinkedGroup():IsContains(c) 
end

function s.tgcon(e)
	return #(e:GetHandler():GetLinkedGroup():Filter(Card.IsType,nil,TYPE_MONSTER))>1
end

-------------------------------------------------------------------------------

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

-------------------------------------------------------------------------------

function s.rmtg(e,c)
	local tp=e:GetHandlerPlayer()
	return c:GetOwner()~=tp and Duel.IsPlayerCanRemove(tp,c) 
		and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE) 
end

	

	
	
	
	
	
	
	
