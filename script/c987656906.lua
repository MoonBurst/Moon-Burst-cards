--Infernashade Staging
--Scripted by "Nekro"
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(0xc66) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g>0 then 
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.mvfilter(c)
	return c:IsType(TYPE_MONSTER)
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.mvfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.mvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFirstTarget()
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	Duel.MoveSequence(g,nseq)
	if g:IsSetCard(0xc66) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local off=1
	local ops={}
	local opval={}
	if Duel.IsExistingTarget(s.mvfilter,tp,0,LOCATION_MZONE,1,nil) then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if Duel.IsExistingTarget(s.mvfilter,tp,LOCATION_MZONE,0,1,nil) then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then --Move 1 monster you control
			local g2=Duel.SelectTarget(tp,Card.IsType(),tp,LOCATION_MZONE,0,1,1,TYPE_MONSTER)
			local s2=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
			local nseq=math.log(s2,2)
			Duel.MoveSequence(g2,nseq)
		end
	elseif opval[op]==2 then --Move 1 monster your opponent controls
			local g2=Duel.SelectTarget(tp,Card.IsType(),tp,0,LOCATION_MZONE,1,1,TYPE_MONSTER)
			local s2=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
			local nseq=math.log(s2,2)
			Duel.MoveSequence(g2,nseq)
		end
end
