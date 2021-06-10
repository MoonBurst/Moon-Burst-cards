--Night Hunter
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	--xyz summon
	Xyz.AddProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	--attack up
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    --draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61344030,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_series={0x196}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(500)
        c:RegisterEffect(e1)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
        if #g>0 then
            Duel.HintSelection(g)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_UPDATE_ATTACK)
            e2:SetValue(-1000)
            g:GetFirst():RegisterEffect(e2)
        end
    end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
