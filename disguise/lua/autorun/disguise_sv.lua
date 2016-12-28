if SERVER then
	AddCSLuaFile( "autorun/disguise_cl.lua" )

	util.AddNetworkString( "DisguiseData" )
	util.AddNetworkString( "DisguisePrompt" )
	util.AddNetworkString( "DisguiseNick" )
	util.AddNetworkString( "DisguiseClear" )
	util.AddNetworkString( "DisguiseBlacklist")
	util.AddNetworkString( "DisguisePriority")
	util.AddNetworkString( "DisguiseSettings")

	ULib.ucl.registerAccess( "disguise_access", ULib.ACCESS_ADMIN, "Ability to disuise yourself as anyone else( Logged everytime it is used).", "Disguise" )
	ULib.ucl.registerAccess( "disguise_priority_owner", ULib.ACCESS_ADMIN, "Sets a rank's priority to 0 when using Masquerade (Can over-ride all blacklist entries)", "Disguise" )
	ULib.ucl.registerAccess( "disguise_priority_superadmin", ULib.ACCESS_ADMIN, "Sets a rank's priority to 1 when using Masquerade (Can over-ride all blacklist entries, except for 0)", "Disguise" )
	ULib.ucl.registerAccess( "disguise_priority_admin", ULib.ACCESS_ADMIN, "Sets a rank's priority to 2 when using Masquerade (Anyone with a priority level of 1 can over-ride this priority).", "Disguise" )

	require( "mysqloo" )

	ddb = mysqloo.connect( "darkstorm.hosted.nfoservers.com", "darkstorm", "7L9vagDGnmB8nhgW", "darkstorm_masquerade", 3306  )
	--ddb = mysqloo.connect( "localhost", "mechanist", "", "timestamp", 3306 )

	function ddb:onConnected()
	    for k,v in pairs(player.GetAll()) do
	    	v:PrintMessage( HUD_PRINTTALK, "[Masquerade] Database Connected" )
	    end

	    masquerade_create()
	end

	function ddb:onConnectionFailed( err )
		for k,v in pairs(player.GetAll()) do
	    	v:PrintMessage( HUD_PRINTTALK, "[Masquerade] Database Failed to Connect" )
	    end

	    print( "Connection to database failed!" )
	    print( "Error:", err )
	end

	ddb:connect()

	function masquerade_create()
		local query = ddb:query("CREATE TABLE IF NOT EXISTS masquerade_blacklist ( pid INTEGER PRIMARY KEY AUTO_INCREMENT, name varchar(255), priority varchar(255))")

		query:start()
	end

	function getdisguiseblacklist()
		local query = ddb:query("SELECT * FROM masquerade_blacklist")

		query:start()

		function query:onSuccess(data)
			for k,v in pairs(data) do
				if k==1 then 
					net.Start("DisguiseBlacklist")
					net.WriteBool(true)
					net.WriteString(tostring(data[k].name))
					net.WriteString(tostring(data[k].priority))
					net.Broadcast()
				else
					net.Start("DisguiseBlacklist")
					net.WriteBool(false)
					net.WriteString(tostring(data[k].name))
					net.WriteString(tostring(data[k].priority))
					net.Broadcast()
				end
			end
		end
	end
	
	local Player = FindMetaTable("Player") //this sets the new Player variable to the metadata table that all players get a copy of

	local oldplayernick = Player.Nick //this creates a backup copy of the original NickNick finding function
	function Player:Nick() //now we're overriding the function so that all players will have this one instead
	     if self.newnick != nil then //if the player object whose nickNick is being checked posesses a subvariable called newnick
	          return self.newnick //then we return that variable
	     else //otherwise, run the original backed up function that will use their steam Nick
	          return oldplayernick(self) //this works because a function trying to access the term self will use the first argument given in the event that it isn't run on another object to reference the self from
	     end
	end

	function Player:GetPriority()
		if ULib.ucl.query( self, "disguise_priority_owner" ) then
			return 0
		elseif ULib.ucl.query( self, "disguise_priority_superadmin" ) then
			return 1
		elseif ULib.ucl.query( self, "disguise_priority_admin" ) then
			return 2
		else
			return 3
		end
	end

	function adddisguiseblacklist(name,ply)
		local query = ddb:query("INSERT INTO masquerade_blacklist VALUES (NULL ,'"..name.."','"..ply:GetPriority().."')")

		query:start()

		function query:onSuccess(data)
			getdisguiseblacklist()
		end

		ply:SetPData("OnBlacklist",true)

		net.Start("DisguiseSettings")
		net.WriteBool(true)
		net.Send(ply)
	end

	function removedisguiseblacklist(name,ply)
		local query = ddb:query("DELETE FROM masquerade_blacklist WHERE name='"..name.."'")

		query:start()

		ply:SetPData("OnBlacklist",false)

		net.Start("DisguiseSettings")
		net.WriteBool(false)
		net.Send(ply)

		timer.Simple(1,function()
			getdisguiseblacklist()
		end)
	end

	net.Receive("DisguiseBlacklist",function(len, ply)
		local change = net.ReadBool()
		local name = ply:GetName()

		if change then
			adddisguiseblacklist(name,ply)
		else
			removedisguiseblacklist(name,ply)
		end
	end)

	function undisguise(ply)
		ULib.ucl.addUser( ply:SteamID(), allows, denies, ply.returngroup )

		ply:SetUTime( ply.returntime )
		ply:SetUTimeStart( CurTime() )

		net.Start("DisguiseNick")
		net.WriteEntity(ply)
		net.WriteString(" ")
		net.Broadcast()

		ply.newnick = nil
		ply.disguisetimer = nil

		--RunConsoleCommand( "ulx" ,"settime", ply:Nick(), ply.returntime  )

		updateAll()
	end

	net.Receive("DisguiseData",function(len, ply)
		ply.newnick = net.ReadString()

		ply.disguisegroup = net.ReadString()

		ply.newtime = tonumber(net.ReadString())

		ply.disguisetimer = tonumber(net.ReadString())

		ply.returngroup = net.ReadString()

		ply.returntime = ply:GetUTime()

		ULib.ucl.addUser( ply:SteamID(), allows, denies, ply.disguisegroup )

		ply:SetUTime( ply.newtime * 3600 )
		ply:SetUTimeStart( CurTime() )

		--RunConsoleCommand( "ulx" ,"settime", ply:Nick(), ply.newtime  )

		net.Start("DisguiseNick")
		net.WriteEntity(ply)
		net.WriteString(ply.newnick)
		net.Broadcast()

		updateAll()

		timer.Simple(ply.disguisetimer,function()
			if ply.newnick ~= nil then
				undisguise(ply)
			end
		end)
	end)

	hook.Add( "DoPlayerDeath", "Pre-Death", function(Player, Entity, CTakeDamageInfo)
		if Player.newnick~=nil then
			Player:KillSilent()
		end
	end)

	hook.Add( "PlayerSay", "chatCommand", function( ply, text, public )
		text = string.Explode(" ",text)
		if ULib.ucl.query( ply, "disguise_access" ) then
			if string.lower(text[1]) == "!disguise" then
				net.Start("DisguisePrompt")
				net.Send(ply)
			end
		end

		if string.lower(text[1]) == "!clear" and ply.newnick~=nil then
			ply:PrintMessage( HUD_PRINTTALK, "[Masquerade] Clearing Your Current Disguise . . ." )

			net.Start("DisguiseClear")
			net.Send(ply)

			undisguise(ply)
		end
	end)

	hook.Add("PlayerInitialSpawn","Disguise_Blacklist",function(ply)
		getdisguiseblacklist()

		net.Start("DisguisePriority")
		net.WriteString(tostring(ply:GetPriority()))
		net.Send(ply)

		net.Start("DisguiseSettings")
		net.WriteBool(ply:GetPData("OnBlacklist",false))
		net.Send(ply)
	end)

	hook.Add("PlayerDisconnected","Disguise_Clear",function(ply)
		if ply.newnick ~= nil then
			undisguise(ply)
		end
	end)
end