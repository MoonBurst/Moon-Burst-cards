--Utopian Linker
--Scripted by "Nekro"
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must be Special Summoned by Its Own Method
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Special Summon Procedure
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon1)
	e2:SetTarget(s.sptg1)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)
	--Immunity for Linked Group
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.immcon)
	e3:SetCost(s.immcost)
	e3:SetTarget(s.immtg)
	e3:SetOperation(s.immop)
	c:RegisterEffect(e3)
end
function s.spfilter1(c,tp)
	return c:IsFaceup() and c:IsLevel(4) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToGraveAsCost() --and Duel.GetMZoneCount(tp,c)>0
end
function s.spcon1(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local rg=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil,tp)
	return ft>-1 and #rg>0 and aux.SelectUnselectGroup(rg,e,tp,3,3,nil,0)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil,tp)
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	local c=e:GetHandler()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	local cn=0
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 then
		local oc=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_GRAVE,0,3,3,nil)
		Duel.Overlay(c,oc)
	else
		local oc=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_GRAVE,0,2,2,nil)
		Duel.Overlay(c,oc)
	end
	g:DeleteGroup()
end

function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end

function s.immcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.immtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
	for tc in ~g do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3110)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_BATTLE)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
	end
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end