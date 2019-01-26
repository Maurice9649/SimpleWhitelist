AddCSLuaFile("cl_wl_gui.lua")
util.AddNetworkString("SWL_GUI")
util.AddNetworkString("SWL_GUI_S")
util.AddNetworkString("SWL_GUI_Data")
util.AddNetworkString("SWL_GUI_Data_S")
util.AddNetworkString("SWL_GUI_Return")
net.Receive( "SWL_GUI", function( len, ply )
	net.Start("SWL_GUI_Data")
	local SW =  SWhitelist
	SW["##Admins##"] = SWL.Admins
	net.WriteTable(SW)
	net.Send(ply) 
end )
net.Receive( "SWL_GUI_S", function( len, ply )
	net.Start("SWL_GUI_Data_S")
	local SW =  SWhitelist
	SW["##Admins##"] = SWL.Admins
	net.WriteTable(SW)
	net.Send(ply) 
end )
net.Receive("SWL_GUI_Return",function(len,ply)
local WLE = false
local WLM = false
CAMI.PlayerHasAccess(ply,"Whitelist_Edit",function(b,s) WLE = b  end)
CAMI.PlayerHasAccess(ply,"Whitelist_ManageJobs",function(b,s) WLM = b end)

local data = net.ReadTable()
if data[2] and data[1] then
if WLE then
SWhitelist[data[1]][data[2]] = data[3]
print("Changed "..data[2].." / "..data[1].." too"..(tostring(data[3])or"nil"))
end
else 

if WLM then

SWhitelist[data[1]] = data[3] 
end
end

	if data[4] or false then 
	--	net.Start("SWL_GUI_Data_S")
	--net.WriteTable(SWhitelist)
	--net.Send(ply)
	else
	net.Start("SWL_GUI_Data")
	net.WriteTable(SWhitelist)
	net.Send(ply)
	end
	wl_save()
	end)
