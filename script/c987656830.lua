--Azure Dragon of Reincarnation
local s,id=GetID()
Duel.LoadScript("proc_runic.lua")
function s.initial_effect(c)
	Altar.AddProcedure(c,nil)
end