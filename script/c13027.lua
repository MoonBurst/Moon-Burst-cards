--Poltergeist Maximus
--by King Of Justice
--Artist: Ell
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon Material
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2)
    
	--Add 1 "Poltergeist" Monster From Your Deck To Your Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcondition)
	e1:SetTarget(s.thtarget)
	e1:SetOperation(s.thoperation)
	c:RegisterEffect(e1)
	
	--Cannot Be Destroy By Battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	
	--Add 1 "Poltergeist" Card From Your Graveyard Or Banished Zone To Your Hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	
	--Special Summon This Card From Your GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+200)
	e4:SetCondition(aux.exccon)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	
	--Cannot Be Destroy By Battle
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.indtg)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	
	--local e6=e3:Clone()
	--e6:SetDescription(aux.Stringid(id,3))
	--e6:SetCost(s.thcost2)
	--c:RegisterEffect(e6)
end

function s.matfilter(c,lc,sumtype,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x67C,lc,sumtype,tp) 
end

--------------------------------------------------------------------------------------------------------

function s.thcondition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.thfilter(c)
	return c:IsSetCard(0x67C) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--------------------------------------------------------------------------------------------------------

function s.thfilter2(c,ft,tp)
	return c:IsFaceup() and c:IsSetCard(0x67C) and c:IsType(TYPE_MONSTER) 
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroupCost(tp,s.thfilter2,1,false,nil,nil,ft,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.thfilter2,1,1,false,nil,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end

--function s.cfilter(c,tp,cg)
	--return cg:IsContains(c) and c:IsType(TYPE_MONSTER) --and Duel.IsExistingTarget(Card.IsFaceup,tp,0,0,LOCATION_MZONE,c)
--end

--function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	--local c=e:GetHandler()
	--local cg=c:GetLinkedGroup()
	--if chk==0 then return Duel.CheckReleaseGroupCost(1-tp,s.cfilter,1,false,nil,nil,1-tp,cg) end
	--local g=Duel.SelectReleaseGroupCost(1-tp,s.cfilter,1,1,false,nil,nil,1-tp,cg)
	--Duel.Release(g,REASON_COST)
--end

function s.thfilter3(c)
	return c:IsSetCard(0x67C) and c:IsType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter3,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter3,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--------------------------------------------------------------------------------------------------------

function s.spfilter(c,ft,tp)
	return c:IsFaceup() and c:IsSetCard(0x67C) and c:IsType(TYPE_MONSTER) 
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroupCost(tp,s.spfilter,1,false,nil,nil,ft,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.spfilter,1,1,false,nil,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 and
		c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Banish it if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end

--------------------------------------------------------------------------------------------------------

function s.indtg(e,c)
	return c:IsType(TYPE_MONSTER) and e:GetHandler():GetLinkedGroup():IsContains(c)
end