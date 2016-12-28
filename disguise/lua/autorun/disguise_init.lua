if SERVER then
	hook.Add("Initialize","Init",function()
		AddCSLuaFile( "autorun/disguise_cl.lua" )
		include("autorun/disguise_sv.lua")

		resource.AddFile("materials/disguise/settings.png")
		resource.AddFile("materials/disguise/back.png")
	end)

	AddCSLuaFile( "autorun/disguise_cl.lua" )
	include("autorun/disguise_sv.lua")

	resource.AddFile("materials/disguise/settings.png")
	resource.AddFile("materials/disguise/back.png")
end