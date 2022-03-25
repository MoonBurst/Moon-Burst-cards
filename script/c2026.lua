--Machynic Synclone Blow Away
--Scripted by King Of Justice
--Artist:
local s,id=GetID()
function s.initial_effect(c)
    --Negate Attack And Shuffle
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	
	--Negate Effect And Shuffle
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.listed_series={0x8FC}

function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(6) and (c:IsSetCard(0x8FC) or c:IsSetCard(0x8FE))
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and tp~=Duel.GetTurnPlayer()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
	if chk==0 then return c:IsAbleToDeck() and #cg>0 end
	cg:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,cg,#cg,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
	Duel.NegateAttack()
	if c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.SendtoDeck(cg,nil,2,REASON_EFFECT)
	end
end
------------------------------------------------------------------------------------

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and rp==1-tp and Duel.IsChainDisablable(ev)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
	if chk==0 then return c:IsAbleToDeck() and #cg>0 end
	cg:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,cg,#cg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
	Duel.NegateEffect(ev)
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 and #cg>0 then
		Duel.BreakEffect()
		Duel.SendtoDeck(cg,nil,2,REASON_EFFECT)
	end
end