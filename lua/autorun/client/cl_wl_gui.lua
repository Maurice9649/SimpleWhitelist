

local TDB = {}

local function colmul(A,B)
return Color(A.r*B.r,A.g*B.g,A.b*B.b,A.a*B.a)
end
local function coldar(A,B)
return Color(A.r*B,A.g*B,A.b*B,A.a)
end
local SWLPlyEnt = nil
local Lines = {}
local BG =  Color(63, 40, 40) -- Backdrop
local LG = coldar(BG,0.8) -- Object 
local TG = coldar(BG,1) -- List Primary 
local TG2 = coldar(BG,0.9) -- List Secondary
local BCG = coldar(BG,1.25) -- Headers
local CTX = Color(255,255,255) -- Text 
local BTX = coldar(BG,0.7) -- Button Down 
local function SetData(Team,ID,Value,...)
	net.Start("SWL_GUI_Return")
	net.WriteTable({Team,ID,Value,...})
	net.SendToServer() 
end
local W , H = ScrW()/1920 , ScrH()/1080
local FrameX , FrameY = 600*W , 600*H
local function MenuSWL() 
local Frame = vgui.Create("DFrame")
Frame:SetSize(FrameX*W,FrameX*H)
Frame:Center()
Frame:SetTitle("")
Frame:MakePopup()
Frame:SetSizable(false)
Frame.Paint = function(self , w , h )
local Brightness = 150
draw.RoundedBox( 0 , 0 , 0 , w , h , BG )
end
local FrameX , FrameY = Frame:GetSize()
local Teams = vgui.Create("DListView",Frame)
local XSize , YSize = 600*W*0.4 , 600*H*0.925
Teams:SetSize(XSize,YSize-35)
Teams:SetPos((FrameX/2-XSize)/2,(FrameY-YSize)/2+35)
local col1 = Teams:AddColumn("WL")
local col2 = Teams:AddColumn("Name")
col1:SetFixedWidth(XSize*0.1)
Teams:SetDataHeight(30)
Teams.Paint = function(p ,w , h)
              draw.RoundedBox(0, 0, 0, w, h,LG)
end

Teams.m_bHideHeaders = true
local Header1 =  vgui.Create( "DLabel", Frame )
Header1:SetPos((FrameX/2-XSize)/2,(FrameY-YSize)/2)
Header1:SetSize(XSize,30)
Header1:SetFont("CloseCaption_Normal")
Header1:SetText("Jobs/Teams")
Header1:SetTextColor(CTX)
Header1:SetContentAlignment( 5 ) 

function Header1:Paint(w,h)
              draw.RoundedBox(4, 0, 0, w, h,LG)

end

net.Receive("SWL_GUI_Data" , function()
	local Selected = Teams:GetSelectedLine()
	SWhitelist = net.ReadTable()
	SWLC = SWhitelist["##Admins##"]
	SWhitelist["##Admins##"] = nil
	local Jobs = team.GetAllTeams() or {}
	Teams:Clear()
	local I = true
	for k , v in pairs(Jobs) do
		I = not I
		if SWhitelist[team.GetName(k)] then
			Lines[k] = Teams:AddLine("✔",team.GetName(k))
			p = Lines[k]
			if I then function p:Paint(w , h) draw.RoundedBox(3, 2, 2, w-4, h-4,TG) end else function p:Paint(w , h) draw.RoundedBox(3, 2, 2, w-4, h-4,TG2) end p.cI = I
			end				
		else
			  Lines[k] = Teams:AddLine("✘",team.GetName(k))
			  p = Lines[k]
			if I then function p:Paint(w , h) draw.RoundedBox(3, 2, 2, w-4, h-4,TG) end else function p:Paint(w , h) draw.RoundedBox(3, 2, 2, w-4, h-4,TG2) end p.cI = I
			end
end
end
if Selected then
Teams:SelectItem(Teams:GetLine( Selected ))
end
end)
 





local List = vgui.Create("DListView",Frame)
local XSize , YSize = 600*W*0.4 , 600*H*0.925 -- 0.925
List:SetSize(XSize,YSize-35-60)
List:SetPos(FrameX*(0.75)-XSize/2,(FrameY-YSize)/2+35)
List.m_bHideHeaders = true
List:AddColumn("SteamID")
List:SetDataHeight(30)
local LPosX = FrameX*(0.75)-XSize/2
local LPosY = (FrameY-YSize)/2+35
local LSizeX = XSize
local LSizeY = YSize-35-60

List.Paint = function(p ,w , h)
              draw.RoundedBox(0, 0, 0, w, h,LG)
end



List:SetMouseInputEnabled(true)
function List:DoClick()

end
List.OnRowSelected = function(st,index,pnl)
local Menu = DermaMenu()
local RmWL = Menu:AddOption( "Remove WL" )
RmWL:SetIcon( "icon16/cancel.png" )
RmWL.DoClick = function(...)
local n = pnl:GetColumnText(1)
print("Removing "..n.." from "..Sel)
SetData(Sel,n,nil)
end

Menu:Open()
end



Teams.OnRowSelected = function ( st,index,pnl)
if pnl:GetColumnText(1) == "✔" then
List:Clear()
local II = true
for k , v in pairs(SWhitelist[pnl:GetColumnText(2)]) do
II = not II
			  p = List:AddLine(k)
			if II then function p:Paint(w , h) draw.RoundedBox(3, 2, 2, w-4, h-4,TG) end else function p:Paint(w , h) draw.RoundedBox(3, 2, 2, w-4, h-4,TG2) end p.cI = I
			end		
end



Sel = pnl:GetColumnText(2)
TDB = {st,index,pnl}
else
List:Clear()
Sel = pnl:GetColumnText(2)
TDB = {st,index,pnl}

end
end

function Teams:OnRowRightClick( lineID,  line )
local Team = line:GetColumnText(2)
CAMI.PlayerHasAccess(LocalPlayer(),"Whitelist_ManageJobs",function(b,s)
if b then 
if line:GetColumnText(1) == "✔" then
local Menu = DermaMenu()
local RmWL = Menu:AddOption( "Disable Whitelist" )
RmWL:SetIcon( "icon16/cancel.png" )
RmWL.DoClick = function(...)
SetData(Team,nil,nil)
end
Menu:Open()
else
local Menu = DermaMenu()
local RmWL = Menu:AddOption( "Enable Whitelist" )
RmWL:SetIcon( "icon16/add.png" )
RmWL.DoClick = function(...)
SetData(Team,nil,{})
end
Menu:Open()

end
end
end)
end



local UpdateB = vgui.Create("DButton",Frame)
local XSize , YSize = 600*W*0.175 , 50
--UpdateB:SetPos( FrameX*(0.75)-XSize/2 , FrameY*0.4-YSize/4-20 ) 
UpdateB:SetPos( LPosX-XSize/2+LSizeX/4 , LPosY+LSizeY+(585-(LPosY+LSizeY))/2-YSize/2) 
UpdateB:SetSize(XSize,YSize)
UpdateB:SetText("Add Player")
UpdateB.Paint = function(panel, w, h)
	if ( panel.Depressed )	then         draw.RoundedBox(4, 0, 0, w, h, BTX)  
	elseif ( panel.Hovered )	then         draw.RoundedBox(4, 0, 0, w, h, BCG) 			
	else        draw.RoundedBox(4, 0, 0, w, h, LG)  end
 



end



local RmvB = vgui.Create("DButton",Frame)
local XSize , YSize = 600*W*0.175 , 50
RmvB:SetPos( LPosX-XSize/2+LSizeX/4*3 , LPosY+LSizeY+(585-(LPosY+LSizeY))/2-YSize/2) 
RmvB:SetSize(XSize,YSize)
RmvB:SetText("Misc")

RmvB.Paint = function(panel, w, h)
	if ( panel.Depressed )	then         draw.RoundedBox(4, 0, 0, w, h, BTX)  
	elseif ( panel.Hovered )	then         draw.RoundedBox(4, 0, 0, w, h, BCG) 			
	else        draw.RoundedBox(4, 0, 0, w, h, LG)  end
 



end

local function Dpromp()
local MFrame = vgui.Create("DFrame")
local MFrameX , MFrameY = 500*W , 100*H
MFrame:SetSize(MFrameX*W,MFrameY*H)
MFrame:Center()
MFrame:SetTitle("")
MFrame:MakePopup()
MFrame:SetSizable(false)
MFrame:SetBackgroundBlur(true)
return MFrame
end


UpdateB.DoClick = function()
if Teams:GetSelectedLine() then
if   Teams:GetLine( Teams:GetSelectedLine() ):GetColumnText(1) == "✔" then

MFrame = Dpromp()
local MLabel = vgui.Create("DLabel",MFrame)
MLabel:Dock(TOP)
MLabel:SetTextColor(CTX)
MLabel:SetContentAlignment( 5 ) 
MLabel:SetText("Enter a SteamID to add it to WL")

local MButton = vgui.Create("DButton",MFrame)
MButton:Dock(BOTTOM)
MButton:SetSize( 40, 20 )

local MText = vgui.Create("DTextEntry",MFrame)
MText:Dock(BOTTOM)
MText:SetSize( 500*W*0.7, 20 )
MText:DockMargin(0,0,0,5)
MButton:SetText("Add SteamID to Whitelist")
MButton.DoClick = function()
SetData(Teams:GetLine( Teams:GetSelectedLine() ):GetColumnText(2),MText:GetValue(),true)
MFrame:Close()

end





else

end
end
end

RmvB.DoClick = function()

end

	net.Start("SWL_GUI")
	net.SendToServer()
end
properties.Add( "Whitelist", {
	MenuLabel = "#Whitelist", -- Name to display on the context menu
	Order = 999, -- The order to display this property relative to other properties
	MenuIcon = "icon16/database_key.png", -- The icon to display next to the property

	Filter = function( self, ent, ply )	-- A function that determines whether an entity is valid for this property

	if !CAMI then
			if ( !IsValid( ent ) ) then return false end
				  local addwl = function(ply) return ply:IsAdmin() end -- and and rm users too/from whitelists
				if ULib then
				addwl = function(ply)
				for k , v in pairs(SWLC) do
				if !ply:CheckGroup(k) then return true end
				end
				end
				end
		return ent:IsPlayer() and addwl(ply)
	else
	local a = false
	CAMI.PlayerHasAccess(ply,"Whitelist_Edit",function(b,s) a = b  end)
	return a
	end
	end,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )

		SWLPlyEnt = ent
	net.Start("SWL_GUI_S")
	net.SendToServer()
		
		
	end,
	Receive = function( self, length, player ) -- The action to perform upon using the property ( Serverside )
		  
		  
		  
		  
		  
	end
} )

function plyMenu()
local ent = SWLPlyEnt
		local Menu = DermaMenu()
		Menu:AddOption("Simple Whitelist")
		Menu:AddOption("Selected:"..ent:Nick())
		Menu:AddSpacer()
		local AddWL = Menu:AddSubMenu( "Add to Whitelist" )	
		local RmWL = Menu:AddSubMenu( "Remove from Whitelist" )	
		
		for k , v in pairs(SWhitelist) do
		if !(v[ent:SteamID()] or false)  then 
		local Job = AddWL:AddOption( k )
		Job.DoClick = function()
		SetData(k,ent:SteamID(),true,"silent")
		Menu:Remove()
		end
	
		else
		local Job = RmWL:AddOption( k )
		Job.DoClick = function()
		SetData(k,ent:SteamID(),nil,"silent")
		Menu:Remove()
		end
		end
		end
		
Menu:Open()

end

net.Receive("SWL_GUI_Data_S" , function()
	SWhitelist = net.ReadTable()
	SWLC = SWhitelist["##Admins##"]
	SWhitelist["##Admins##"] = nil
	plyMenu()
end)
concommand.Add("wl",function(ply)
CAMI.PlayerHasAccess(ply,"Whitelist_Edit",function(b,s) if b then  MenuSWL() end end)
end)
concommand.Add("whitelist",function(ply)
CAMI.PlayerHasAccess(ply,"Whitelist_Edit",function(b,s) if b then  MenuSWL() end end)
end)
