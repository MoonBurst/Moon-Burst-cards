--Thaumic Etheus
--Scripted by Nekro
local s,id=GetID()
function s.initial_effect(c)
    --Fusion Material
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.ffilter,aux.FilterBoolFunctionEx(Card.IsSetCard,0xc54),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE))
	--Place 1 "Thaumic" monster in S/T
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.plctg)
	e1:SetOperation(s.plcop)
	c:RegisterEffect(e1)
	--Destroy or Special Summon (2)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

--Fusion Material
function s.ffilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xc54) or c:IsAttribute(ATTRIBUTE_FIRE))
end

--Place 1 "Thaumic" monster in S/T (1)
function s.filter(c)
	return c:IsSetCard(0xc54) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end

function s.plccon(e)
	return e:GetHandler():GetMaterial():FilterCount(Card.IsCode,nil,98765686)>0
end

function s.plctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end

function s.plcop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local ex1=Effect.CreateEffect(e:GetHandler())
		ex1:SetCode(EFFECT_CHANGE_TYPE)
		ex1:SetType(EFFECT_TYPE_SINGLE)
		ex1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ex1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		ex1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(ex1)
	end
end

--Destroy or Special Summon (2)
function s.cfilter(c)
	return c:IsSetCard(0xc54)
end

function s.desfilter(c,g)
	return g:IsContains(c)
end

function s.desfilter2(c,s,p)
	local seq=c:GetSequence()
	return seq<5 and c:IsControler(p) and math.abs(seq-s)==1
end

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	Duel.SendtoGrave(g,REASON_COST)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,c:GetColumnGroup())
	if chk==0 then return (c:IsDestructable() and #g>0)
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=0
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))+1
	if opt==1 then
		local dg=e:GetLabelObject()
		local lg=dg:GetColumnGroup()
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,lg)
			if #g==0 then return end
			Duel.BreakEffect()
			local tc=nil
			if #g==1 then
				tc=g:GetFirst()
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				tc=g:Select(tp,1,1,nil):GetFirst()
			end
			local seq=tc:GetSequence()
			local dg=Group.CreateGroup()
			if seq<5 then dg=Duel.GetMatchingGroup(s.desfilter2,tp,0,LOCATION_MZONE,nil,seq,tc:GetControler()) end
			if Duel.Destroy(tc,REASON_EFFECT)~=0 and #dg>0 then
				Duel.Destroy(dg,REASON_EFFECT)
		end
	end
	if opt==2 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.cfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
