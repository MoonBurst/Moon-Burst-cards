--Night Dance
local s,id=GetID()
function s.initial_effect(c)
    --special summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)
    --special summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end
s.listed_series={0x196}
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x196) and c:GetLevel()==4 
end
function s.spcon(e,c)
    if c==nil then return true end
    return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if chk==0 then
        if ft<0 then return false end
        if ft==0 then
            return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAbleToHandAsCost),tp,LOCATION_MZONE,0,1,nil)
        else
            return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAbleToHandAsCost),tp,LOCATION_ONFIELD,0,1,nil)
        end
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    if ft==0 then
        local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsAbleToHandAsCost),tp,LOCATION_MZONE,0,1,1,nil)
        Duel.SendtoHand(g,nil,REASON_COST)
    else
        local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsAbleToHandAsCost),tp,LOCATION_ONFIELD,0,1,1,nil)
        Duel.SendtoHand(g,nil,REASON_COST)
    end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,400)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.Damage(tp,400,REASON_EFFECT)
    end
end