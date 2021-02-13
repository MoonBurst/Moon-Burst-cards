--召喚獣プルガトリオ
local s,id=GetID()
function s.initial_effect(c)
    --fusion material
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xc54),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE))
end