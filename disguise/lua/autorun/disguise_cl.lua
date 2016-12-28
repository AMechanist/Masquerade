if CLIENT then
	local settingsvtf = Material("disguise/settings.png")
	local backvtf = Material("disguise/back.png")

	local exitvtf = Material("sil/close.png")

	local ShopSize = 500

	local scaleh = ScrH()/1024
	local scalew = ScrW()/1280

	local boxes = {}
	local comboboxes = {}
	local disguiseblacklist = {}

	local disguise_hud = {}

	local disguisetimer = 0

	local settings = false

	local init = false

	local textboxinfo = {
		"Fake Name",
		"Fake Group",
		"Fake Time",
		"Time Limit(Seconds)"
	}

	local optionstext = {
		"Add me to the Blacklist"
	}


	local disguisenews = {
		"[Version 1.9 of Masquerade]",
		" ",
		"-Don't want another staff \n member wandering around \n with your name? Head \n over to the settings \n and add yourself to the \n Blacklist!",
		" ",
		"-Currently, when using \n Masquerade, you physically \n appear as yourself, but \n in chat and on the \n scoreboard, you can be \n anyone!",
		" ",
		"-Using !Clear will \n completely remove your \n disguise and reset your \n rank, hours, and name!",
		" ",
		"-Have you discovered a \n bug with Masquerade,\n report it to Mechanist!",
		" ",
		--"-Please don't disguise yourself, and then disguise again, you will break the fourth, fifth, and sixth dimensions. If you don't want to harm innocent fifth dimension dwellers, don't use !disguise without caution!",
		--" ",
		"-Sponsored by the \n inhabitants of the 24th \n dimension, thanks guys, I \n couldn't have done it \n without you. It would be \n nice if I could comprehend \n you though."
	
	}
	
	local dcolors =
	{
	 
		background =
		{
	 
			border = Color( 230, 230, 230, 0 ),
			background = Color( 50, 50, 50, 200 )
	 
		},
	 
		text =
		{
	 
			shadow = Color( 0, 0, 0, 255 ),
			text = Color( 0,0, 0, 255 )
	 
		},

		whitetext =
		{
	 
			shadow = Color( 255, 255, 255, 255 ),
			text = Color( 255, 255, 255, 205 )
	 
		},

		redtext =
		{
	 
			shadow = Color( 0, 0, 255, 0 ),
			text = Color( 61, 132, 183, 150 )
	 
		},
	 
		health_bar =
		{
	 
			border = Color( 255, 0, 0, 0 ),
			background = Color( 255, 0, 0, 75 ),
			shade = Color( 255, 104, 104, 255 ),
			fill = Color( 232, 0, 0, 255 )
	 
		},

		white_bar =
		{
	 
			border = Color( 0, 0, 0, 0 ),
			background = Color( 255, 255, 255, 255 ),
			shade = Color( 0, 0, 0, 0 ),
			fill = Color( 0, 0, 0, 0 )
	 
		},
	 
		suit_bar =
		{
	 
			border = Color( 0, 0, 255, 0 ),
			background = Color( 0, 0, 255, 75 ),
			shade = Color( 136, 136, 255, 255 ),
			fill = Color( 0, 0, 219, 255 )
	 
		},

		speed_bar =
		{
	 
			border = Color( 0, 0, 255, 0 ),
			background = Color( 255, 255, 20, 75 ),
			shade = Color( 225, 225, 181, 255 ),
			fill = Color( 225, 225, 51, 255 )
	 
		},

		itembackground =
		{
	 
			border = Color( 230, 230, 230, 0 ),
			background = Color( 40, 40, 40, 150 )
	 
		},

		descbackground =
		{
	 
			border = Color( 230, 230, 230, 0 ),
			background = Color( 40,141,215, 30 )
	 
		},

		bluebackground =
		{
	 
			border = Color( 0, 0, 255, 0 ),
			background = Color( 61, 132, 183, 150 )
	 
		},
	 
	}

	local dvars =
	{
	 
		font = "Trebuchet22",
	 
		padding = 40,
		margin = 35,
	 
		text_spacing = 7,
		bar_spacing = -3,
	 
		bar_height = 24,
	 
		width = 0.25
	 
	}

	local function clr( color ) return color.r, color.g, color.b, color.a end

	function disguise_hud:TextSize( text, font )
 
		surface.SetFont( font );
		return surface.GetTextSize( text );
	 
	end
 	
 	function disguise_hud:PaintPanel( x, y, w, h, dcolors )
	 
		surface.SetDrawColor( clr( dcolors.border ) )
		surface.DrawOutlinedRect( x, y, w, h )

		x = x + 1
		y = y + 1
		w = w - 2 
		h = h - 2
	 
		surface.SetDrawColor( clr( dcolors.background ) )
		surface.DrawRect( x, y, w, h )
	 
	end

	function disguise_hud:PaintBar( x, y, w, h, dcolors, value )
	 
		self:PaintPanel( x, y, w, h, dcolors )
	 
		x = x + 1 
		y = y + 1
		w = w - 2 
		h = h - 2
	 
		local width = w * math.Clamp( value, 0, 1 )
		local shade = 4
	 
		surface.SetDrawColor( clr( dcolors.shade ) )
		surface.DrawRect( x, y, width, shade )
	 
		surface.SetDrawColor( clr( dcolors.fill ) )
		surface.DrawRect( x, y + shade, width, h - shade )
	 
	end

	function disguise_hud:PaintText( x, y, text, font, dcolors )
 
		surface.SetFont( font );			-- set text font
	 
		surface.SetTextPos( x + 1, y + 1 );		-- set shadow position
		surface.SetTextColor( clr( dcolors.shadow ) );	-- set shadow color
		surface.DrawText( text );			-- draw shadow text
	 
		surface.SetTextPos( x, y );			-- set text position
		surface.SetTextColor( clr( dcolors.text ) );	-- set text color
		surface.DrawText( text );			-- draw text
	 
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

	function disguise_hud:DisguiseTextBox(x,y,w,h,entry)
		local textbox = vgui.Create("DTextEntry", DMenu)
		textbox:SetMultiline(false)
		textbox.Paint = function(self)
			surface.SetDrawColor(Color(40, 40, 40, 150))
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			self:DrawTextEntryText(Color( 230, 230, 230, 215 ), Color(30, 130, 255), Color(255, 255, 255))
		end
		textbox:SetText(entry)
		textbox:SetSize(w,h) 
		textbox:SetPos(x,y)
		textbox:SetFont("Trebuchet22")
		textbox:SetTextColor(Color(40,40,40,190))
		textbox:SetEditable(true)
		textbox:SetEnterAllowed(true)

		if #boxes == 5 then
			textbox.AllowInput = function( self, stringValue )
				return true
			end
		end

		textbox.OnGetFocus = function()
			if textbox:GetText() == entry and textboxinfo[5] ~=entry then
				textbox:SetText("")
			elseif entry == textboxinfo[5] then
				textbox:SetText(entry)
			end
		end

		table.insert(boxes,textbox)
	end

	function disguise_hud:DisguiseComboBox(x,y,w,h)
		DComboBox = vgui.Create( "DComboBox", DMenu )
		DComboBox:SetPos( x, y )
		DComboBox:SetSize( w, h )
		DComboBox:SetFont("Trebuchet22")
		DComboBox:SetTextColor(Color( 230, 230, 230, 215 ))
		DComboBox.Paint = function()
			draw.RoundedBox( 0, 0, 0, DComboBox:GetWide(), DComboBox:GetTall(), Color(40,40,40,190) )
		end

		DComboBox:SetValue( "Fake Rank" )
		for k,v in pairs(team.GetAllTeams()) do
			DComboBox:AddChoice( v.Name )
		end

		table.insert(comboboxes,DComboBox)
	end

	function disguise_hud:DisguiseButton(x,y,w,h,buttontype)
		local DButton1 = vgui.Create( "DButton", DMenu )
		DButton1:SetTextColor( Color(230, 230, 230, 215 ) )
		DButton1:SetPos( x, y)
		DButton1:SetFont("SmallShopText")
		DButton1:SetSize( w, h )
		DButton1.Paint = function()
			if buttontype == "exit" then
				draw.RoundedBox( 0, 0, 0, DButton1:GetWide(), DButton1:GetTall(), Color( 0, 0, 0, 0 ) )
			else
				draw.RoundedBox( 0, 0, 0, DButton1:GetWide(), DButton1:GetTall(), Color(50, 50, 50, 170) )
			end
		end

		if buttontype == "submit" then
			DButton1:SetText( "Disguise" )
		else
			DButton1:SetText( "" )
		end

		DButton1.DoClick = function()
			if buttontype == "exit" then
				DMenu:Remove()
				boxes = {}
				MechDisguise = false
			end

			if buttontype == "settings" then
				if settings == false then
					DMenu:Remove()
					boxes = {}

					disguise_settings()

					settings = true
				else
					DMenu:Remove()
					boxes = {}

					disguise_menu()

					settings = false
				end
			end

			if buttontype == "submit" then

				for k,v in pairs(disguiseblacklist) do
					if string.lower(v) == string.lower(boxes[1]:GetText()) then 
						if tonumber(dpriority) < tonumber(disguiseblacklist[k+1]) then
							return false 
						end
					end
				end

				DMenu:Remove()
				MechDisguise = false

				net.Start("DisguiseData")
					net.WriteString(boxes[1]:GetText())
					if LocalPlayer():CheckGroup(boxes[1]:GetText()) or LocalPlayer():IsSuperAdmin() then
						net.WriteString(boxes[2]:GetText())
					else
						net.WriteString(textboxinfo[5])
					end
					net.WriteString(boxes[3]:GetText())
					net.WriteString(boxes[4]:GetText())
					net.WriteString(textboxinfo[5])
				net.SendToServer()

				LocalPlayer().newnick = boxes[1]:GetText()
				disguisetimer = tonumber(boxes[4]:GetText())

				timer.Simple(disguisetimer,function()
					if LocalPlayer().newnick~=nil then
						LocalPlayer().newnick = nil
					end
				end)

				boxes = {}
				comboboxes = {}
			end
		end
	end 

	function disguise_hud:DCheckBox(x,y,text)
		local DermaCheckbox = vgui.Create( "DCheckBoxLabel" ) 
		DermaCheckbox:SetParent( DMenu )
		DermaCheckbox:SetPos( x, y )
		DermaCheckbox:SetFont("Trebuchet22")						
		DermaCheckbox:SetText( text )	
		if onblacklist then				
			DermaCheckbox:SetValue( 1 )	
		else
			DermaCheckbox:SetValue( 0 )		
		end	 
		DermaCheckbox:SizeToContents()	

		function DermaCheckbox.OnChange()
			if text == optionstext[1] then
			    if DermaCheckbox:GetChecked() then
			    	net.Start("DisguiseBlacklist")
			    	net.WriteBool(true)
			    	net.SendToServer()
			    else
			    	net.Start("DisguiseBlacklist")
			    	net.WriteBool(false)
			    	net.SendToServer()
			    end
			end
		end
	end

	hook.Add("Think","timer_decay",function()
		if disguisetimer>0 then
			disguisetimer = disguisetimer-0.07
		end
	end)

	function MechDsPaint()

		disguise_hud:PaintPanel(ScrW()/2-ShopSize/2*scalew,ScrH()/2-ShopSize/2*scaleh,ShopSize*scalew,ShopSize*scaleh,dcolors.background)

		disguise_hud:PaintPanel(ScrW()/2-ShopSize/2*scalew,ScrH()/2-ShopSize/2*scaleh,500*scalew,50*scaleh,dcolors.background)
		disguise_hud:PaintPanel(ScrW()/2-ShopSize/2*scalew,ScrH()/2-ShopSize/2*scaleh,500*scalew,50*scaleh,dcolors.background)

		disguise_hud:PaintPanel(ScrW()/2-ShopSize/2*scalew,ScrH()/2-ShopSize/2*scaleh,500*scalew,50*scaleh,dcolors.background)

		local text = "Masquerade"
		disguise_hud:PaintText( ScrW()/2-ShopSize/2*scalew+10*scalew,ScrH()/2-ShopSize/2*scaleh+5*scaleh, text, "ShopText", dcolors.redtext )

		--surface.SetDrawColor( 0, 0, 0, 255 )
		--surface.SetMaterial( novtf)
		--surface.DrawTexturedRect( ScrW()/2-ShopSize/2*scalew+5*scalew,ScrH()/2-ShopSize/2*scaleh+2*scaleh,30,30, 30, 30 )

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( exitvtf)
		surface.DrawTexturedRect( ScrW()/2-ShopSize/2*scalew+460*scalew,ScrH()/2-ShopSize/2*scaleh+8*scaleh,32,32, 32, 32 )

		if settings == false then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( settingsvtf)
			surface.DrawTexturedRect( ScrW()/2-ShopSize/2*scalew+420*scalew,ScrH()/2-ShopSize/2*scaleh+8*scaleh,32,32, 32, 32 )
		else
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( backvtf)
			surface.DrawTexturedRect( ScrW()/2-ShopSize/2*scalew+420*scalew,ScrH()/2-ShopSize/2*scaleh+8*scaleh,32,32, 32, 32 )
		end
	end

	function DsTimer()
		if LocalPlayer().newnick~=nil then
			local text = tostring(math.Round(disguisetimer,0)).. " Seconds Left as: "..LocalPlayer().newnick
			disguise_hud:PaintText( ScrW()/2-600*scalew,ScrH()/(30*scaleh), text, "SmallShopText", dcolors.whitetext )
		end
	end

	hook.Add( "HUDPaint", "PaintOurHud", function() 
		if MechDisguise == true then
			MechDsPaint()		
		elseif disguisetimer>0 then
			DsTimer()
		end
	end)

	function disguise_settings()
		DMenu = vgui.Create( "DFrame" )
		DMenu:SetPos(ScrW()/2-ShopSize/2*scalew,ScrH()/2-ShopSize/2*scaleh)
		DMenu:SetSize( ShopSize*scalew,ShopSize*scaleh)
		DMenu:SetTitle( " " )
		DMenu:SetVisible( true )
		DMenu:SetDraggable( false )
		DMenu:ShowCloseButton( false )
		DMenu:MakePopup()
		DMenu.Paint = function()
			draw.RoundedBox( 0, 0, 0, DMenu:GetWide(), DMenu:GetTall(), Color( 20, 20, 20, 0 ) )
		end

		local DScrollPanel = vgui.Create( "DScrollPanel", DMenu )
		DScrollPanel:SetSize(220*scalew,367*scaleh)
		DScrollPanel:SetPos(DMenu:GetWide()/2-ShopSize/2*scalew+265*scalew,DMenu:GetTall()/2-ShopSize/2*scaleh+87*scaleh)

		function DScrollPanel:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color(40, 40, 40, 150) )
		end

		local sbar = DScrollPanel:GetVBar()
		function sbar:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color(40, 40, 40, 150) )
		end
		function sbar.btnUp:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 120 ) )
		end
		function sbar.btnDown:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 150 ) )
		end
		function sbar.btnGrip:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 150 ) )
		end

		local str = ""
		for i = 0, #disguiseblacklist,2 do 
			if i == 2 then
				str = str .. disguiseblacklist[i-1] .."\n"
				str = str .. "\n-".. disguiseblacklist[i] .."\n"
			elseif i~=0 then
				str = str .. "\n-".. disguiseblacklist[i] .."\n"
			end
		end

		local DLabel = vgui.Create( "DLabel", DScrollPanel )
		DLabel:SetText( str )
		DLabel:SetFont("Trebuchet20")
		DLabel:Center()

		DScrollPanel:SizeToContentsX()

		DLabel:SizeToContents()

		local y = -15

		for k,v in pairs(optionstext) do
			y = 70 + y

			disguise_hud:DCheckBox( DMenu:GetWide()/2-ShopSize/2*scalew+30*scalew,DMenu:GetTall()/2-ShopSize/2*scaleh+(y+22)*scaleh,tostring(optionstext[k]))
		end

		disguise_hud:DisguiseButton( DMenu:GetWide()/2-ShopSize/2*scalew+460*scalew,DMenu:GetTall()/2-ShopSize/2*scaleh+8*scaleh,32,32,"exit")

		disguise_hud:DisguiseButton( DMenu:GetWide()/2-ShopSize/2*scalew+420*scalew,DMenu:GetTall()/2-ShopSize/2*scaleh+8*scaleh,32,32,"settings")
	end

	function disguise_menu()
		settings = false
		
		DMenu = vgui.Create( "DFrame" )
		DMenu:SetPos(ScrW()/2-ShopSize/2*scalew,ScrH()/2-ShopSize/2*scaleh)
		DMenu:SetSize( ShopSize*scalew,ShopSize*scaleh)
		DMenu:SetTitle( " " )
		DMenu:SetVisible( true )
		DMenu:SetDraggable( false )
		DMenu:ShowCloseButton( false )
		DMenu:MakePopup()
		DMenu.Paint = function()
			draw.RoundedBox( 0, 0, 0, DMenu:GetWide(), DMenu:GetTall(), Color( 20, 20, 20, 0 ) )
		end

		local DScrollPanel = vgui.Create( "DScrollPanel", DMenu )
		DScrollPanel:SetSize(220*scalew,367*scaleh)
		DScrollPanel:SetPos(DMenu:GetWide()/2-ShopSize/2*scalew+265*scalew,DMenu:GetTall()/2-ShopSize/2*scaleh+87*scaleh)

		function DScrollPanel:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color(40, 40, 40, 150) )
		end

		local sbar = DScrollPanel:GetVBar()
		function sbar:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color(40, 40, 40, 150) )
		end
		function sbar.btnUp:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 120 ) )
		end
		function sbar.btnDown:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 150 ) )
		end
		function sbar.btnGrip:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 150 ) )
		end

		local str = ""
		for i = 1, #disguisenews do str = str .. disguisenews[i] .."\n" end

		local DLabel = vgui.Create( "DLabel", DScrollPanel )
		DLabel:SetText( str )
		DLabel:SetFont("Trebuchet20")
		DLabel:Center()

		DScrollPanel:SizeToContentsX()

		DLabel:SizeToContents()

		local y = -15

		for k,v in pairs(textboxinfo) do
			y = 70 + y

			--if v~="Fake Group" then
				disguise_hud:DisguiseTextBox( DMenu:GetWide()/2-ShopSize/2*scalew+30*scalew,DMenu:GetTall()/2-ShopSize/2*scaleh+(y+22)*scaleh,220,42,tostring(textboxinfo[k]))
			--else
				--disguise_hud:DisguiseComboBox( DMenu:GetWide()/2-ShopSize/2*scalew+30*scalew,DMenu:GetTall()/2-ShopSize/2*scaleh+(y+22)*scaleh,220,42)
			--end
		end

		disguise_hud:DisguiseButton( DMenu:GetWide()/2-ShopSize/2*scalew+460*scalew,DMenu:GetTall()/2-ShopSize/2*scaleh+8*scaleh,32,32,"exit")

		disguise_hud:DisguiseButton( DMenu:GetWide()/2-ShopSize/2*scalew+420*scalew,DMenu:GetTall()/2-ShopSize/2*scaleh+8*scaleh,32,32,"settings")

		disguise_hud:DisguiseButton( DMenu:GetWide()/2-ShopSize/2*scalew+70*scalew,DMenu:GetTall()/2-ShopSize/2*scaleh+430*scaleh,140,37,"submit")

		MechDisguise = true
	end

	net.Receive("DisguisePrompt",function()
		disguise_menu()

		LocalPlayer():PrintMessage( HUD_PRINTTALK, "[Masquerade] Opening Menu . . ." )
	end)

	net.Receive("DisguiseNick",function()
		ply = net.ReadEntity()
		local nick = net.ReadString()
		if nick ~= " " then
			ply.newnick = nick
		else
			ply.newnick = nil
		end
	end)

	hook.Add("Think","LocalPlayer",function()
		if LocalPlayer()~=nil and init == false then
			table.insert(textboxinfo,tostring(LocalPlayer():GetUserGroup()))

			LocalPlayer().newnick = nil

			init = true
		end
	end)

	net.Receive("DisguiseClear",function()
		LocalPlayer().newnick = nil
		disguisetimer = 0
	end)

	net.Receive("DisguisePriority",function()
		dpriority = tonumber(net.ReadString())
	end)

	net.Receive("DisguiseSettings",function()
		onblacklist = net.ReadBool()
	end)

	net.Receive("DisguiseBlacklist",function()
		local dclear = net.ReadBool()

		if dclear == true then
			print("#####DISGUISE_NAME_BLACKLIST#####")

			disguiseblacklist = {}

			table.insert(disguiseblacklist,"[Names Blacklist]")
		end

		local drow = net.ReadString()
		local drow2 = net.ReadString()

		print("-"..tostring(drow) .. " Priority=".. drow2)
		table.insert(disguiseblacklist,drow)
		table.insert(disguiseblacklist,drow2)
	end)
end