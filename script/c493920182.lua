-- Voltmaster of Sevens
-- Scripted by Nekro for public use (with credit)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- "Sevens Road Magician" + "Lightning Voltcondor"
	Fusion.AddProcMix(c,true,true,CARD_SEVENS_ROAD_MAGICIAN,160002017)
	-- Reduce ATK to 0, gain reduced ATK [1]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- Destroy Monsters, Destroy S/T [2]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

-- Reduce ATK to 0, gain reduced ATK [1]
function s.tgfilter(c,tp,e)
    return c:IsMonster() and c:IsAbleToGrave()
        and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),c:GetAttribute())
end
function s.atkfilter(c,att)
    return c:IsFaceup() and c:IsMonster() and c:IsAttribute(att) and c:IsAttackAbove(0)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil,tp,e) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --requirement
    local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil,tp,e):GetFirst()
    if Duel.SendtoGrave(tc,REASON_COST)>0 then
        --effect
        local og=Duel.GetOperatedGroup():GetFirst()
        local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c,og:GetAttribute())
        if g and #g>0 then
            for sc in g:Iter() do
				local base=sc:GetBaseAttack()
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_SET_ATTACK_FINAL)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                e1:SetValue(0)
                sc:RegisterEffect(e1)
				c:UpdateAttack(base)
            end
        end
    end
end

-- Destroy Monsters, Destroy S/T [2]
function s.tgfilter2(c,tp)
    return c:IsMonster() and c:IsAbleToGrave()
        and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttribute())
end
function s.desfilter(c,att)
    return c:IsFaceup() and c:IsMonster() and c:IsAttribute(att) and c:IsAbleToGrave()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_HAND,0,1,nil,tp) end
    local sg=Duel.GetMatchingGroup(s.tgfilter2,tp,0,LOCATION_MZONE,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.opfilter(c)
	return c:IsSpellTrap()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	--requirement
    local tc=Duel.SelectMatchingCard(tp,s.tgfilter2,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
    if Duel.SendtoGrave(tc,REASON_COST)>0 then
		--effect
		local sg=Duel.GetMatchingGroup(s.tgfilter2,tp,0,LOCATION_MZONE,nil,tp)
			for sc in sg:Iter() do
				local cg=sc:GetColumnGroup():Filter(s.opfilter,nil)
				Duel.Destroy(sg,REASON_EFFECT)
				Duel.Destroy(cg,REASON_EFFECT)
		end
	end
end
