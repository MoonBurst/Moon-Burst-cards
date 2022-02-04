--Night Rose
local s,id=GetID()
function s.initial_effect(c)
    --special summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --destroy
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end 
function s.spcon(e,c)
    if c==nil then return true end
    return Duel.CheckReleaseGroup(c:GetControler(),Card.IsRace,1,false,1,true,c,c:GetControler(),nil,false,nil,RACE_PSYCHIC)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,false,true,true,c,nil,nil,false,nil,RACE_PSYCHIC)
    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
    return true
    end
    return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    Duel.Release(g,REASON_COST)
    local atk=g:GetFirst():GetBaseAttack()
    if atk<0 then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(atk/2)
    e1:SetReset(RESET_EVENT+(RESET_EVENT|RESETS_STANDARD_DISABLE)&~RESET_TOFIELD)
    e:GetHandler():RegisterEffect(e1)
    g:DeleteGroup()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_DESTROY)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
