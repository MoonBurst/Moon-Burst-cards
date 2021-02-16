--create card
local s,id=GetID()
function s.initial_effect(c)
	 	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.create)
	c:RegisterEffect(e1)
end
function s.create(e,c,tp,eg,ep,ev,re,r,rp,chk)  
	local c=e:GetHandler()
	local tp=c:GetControler()
	local sc=Duel.CreateToken(tp,id+1)
	Card.Type(sc,TYPE_SPELL+TYPE_QUICKPLAY)
	Duel.SendtoHand(sc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,sc)
	
end

