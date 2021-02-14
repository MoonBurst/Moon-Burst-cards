--Thaumic Earthquake
--Scripted by "Nekro"
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,2,3,s.lcheck)
	--Use as Material in S/T (0)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_EXTRA_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e0:SetTargetRange(1,1)
	e0:SetOperation(aux.TRUE)
	e0:SetValue(s.extraval)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_SZONE,0)
    e1:SetOperation(s.chngcon(c))
	e1:SetTarget(aux.TargetBoolFunction(s.filter))
    e1:SetValue(TYPE_MONSTER)
    c:RegisterEffect(e1)
	--Opponent Cannot Target and Cannot Be Destroyed (2-3)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(1)
	e2:SetCondition(s.indcon)
	c:RegisterEffect(e2)
	local e2=e2:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	--ATK+ Linked "Thaumic" Monsters (4)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.tgtg)
	e4:SetValue(500)
	c:RegisterEffect(e4)
	--Change Target Position + No Material (5)
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCountLimit(1)
	e5:SetTarget(s.postg)
	e5:SetOperation(s.posop)
	c:RegisterEffect(e5)
end

function s.eftg(e,c)
	return s.filter(c)
end

--Summon Filters
function s.matfilter(c,e,tp)
	return (c:IsSetCard(0xc54) and c:IsAttribute(ATTRIBUTE_EARTH)) or s.filter(c)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end
function s.chngcon(c)
	return function(scard,sumtype,tp)
		return (sumtype&SUMMON_TYPE_LINK|MATERIAL_LINK)==SUMMON_TYPE_LINK|MATERIAL_LINK and scard==c
	end
end

--Use as Material in S/T (0)
function s.filter(c)
	return c:IsSetCard(0xc54) and c:IsType(TYPE_SPELL+TYPE_CONTINUOUS)
end

function s.extraval(chk,summon_type,e,...)
    local c=e:GetHandler()
    if chk==0 then
        local tp,sc=...
        if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
            return Group.CreateGroup()
        else
            return Duel.GetMatchingGroup(s.eftg,tp,0,LOCATION_SZONE,nil)
        end
    end
end

--Opponent Cannot Target and Cannot Be Destroyed (2-3)
function s.indcon(e)
	return e:GetHandler():GetMaterial():FilterCount(Card.IsCode,nil,98765686)>0
end

--ATK+ Linked "Thaumic" Monsters (4)
function s.tgtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsSetCard(0xc54) 
end

--Change Target Position + No Material (5)
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		--Cannot be Material (ex3)
		local ex1=Effect.CreateEffect(c)
		ex1:SetType(EFFECT_TYPE_SINGLE)
		ex1:SetCode(EFFECT_UNRELEASABLE_SUM)
		ex1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ex1:SetValue(1)
		tc:RegisterEffect(ex1)
		local ex2=ex1:Clone()
		ex2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(ex2)
		local ex3=Effect.CreateEffect(c)
		ex3:SetDescription(aux.Stringid(id,2))
		ex3:SetType(EFFECT_TYPE_SINGLE)
		ex3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CLIENT_HINT)
		ex3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		ex3:SetTarget(s.expostg)
		ex3:SetValue(function(e,c,sumtype,tp)
						local sum=sumtype&(SUMMON_TYPE_FUSION|SUMMON_TYPE_SYNCHRO|SUMMON_TYPE_XYZ|SUMMON_TYPE_LINK)
						return (sum==SUMMON_TYPE_FUSION or sum==SUMMON_TYPE_SYNCHRO or sum==SUMMON_TYPE_XYZ or sum==SUMMON_TYPE_LINK) and 1 or 0
					end)
		ex3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ex3)
	end
end

function s.expostg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return c:IsOnField() and c:IsFaceup() and c:IsDefensePos() end
end