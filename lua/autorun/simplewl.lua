local Dir = "SimpleWhiteList"
local RJMsg = "You are not Whitelisted to this Job!"
local addwljob = function(ply) return ply:IsSuperAdmin() end -- add and rm whitelists
local addwl = function(ply) return ply:IsAdmin() end -- and and rm users too/from whitelists
if ULib then
addwl = function(ply)
for k , v in pairs(SWAdmins) do
if ply:CheckGroup(k) then return true end
end
end
end




---- Test at a Simple WL System ----
if SERVER then
util.AddNetworkString("wl_clcmds")
SWhitelist = {}
SWAdmins = {["superadmin"] = true}

function wl_load()
if file.Exists( Dir .. "/Teams.txt" , "DATA" ) then
print("Loading Teams") 
local data = file.Read( Dir .. "/Teams.txt", "DATA")

SWhitelist = util.JSONToTable(data) or {}
end
if file.Exists( Dir .. "/Groups.txt" , "DATA" ) then
print("Loading Groups") 
local data = file.Read( Dir .. "/Groups.txt", "DATA")

SWAdmins = util.JSONToTable(data) or {}
end


end
wl_load() 
hook.Add("playerCanChangeTeam","SWL_WL_CHECK",function(ply,Team)
if SWhitelist[team.GetName(Team)] then
return SWhitelist[team.GetName(Team)][ply:SteamID()] or false , RJMsg
end
end)

function wl_save()
local data = util.TableToJSON(SWhitelist)
if not file.Exists( Dir , "DATA" ) then file.CreateDir(Dir) print("Created Dir"..Dir) end
file.Write(Dir.."/Teams.txt",data)
file.Write(Dir.."/Groups.txt",util.TableToJSON(SWAdmins))




end
hook.Add("ShutDown","SWL_Save_OnShutdown",wl_save())



function wl_removeuser(ply,cmd,args)
local Results = {}
local SID = ""
	if args[1] and args[2] then
		if  SWhitelist[args[1]] then
			 Results = DarkRP.findPlayers(args[2]) or {}
			if table.Count(Results) == 1 then
				 SID = Results[1]:SteamID()
				SWhitelist[args[1]][SID]	 = nil
				wl_save() 
				if team.GetName(Results[1]:Team()) == args[1] then
					Results[1]:changeTeam(GAMEMODE.DefaultTeam,true)
				end
			else
				return "Cannot remove from whitelist, Found:"..table.Count(Results).." Targets"
			end
		else 
			return "Team has no WL"	
		end 
	else
		return "Invalid Arguments , wl_removeuser TeamName PlyName" 
	end 
return "Removed:"..Results[1]:Nick().."("..SID..")".." from "..args[1]
	end
 
 
function wl_adduser(ply,cmd,args)
local Results = {}
local SID = ""
if args[1] and args[2] then
 if  SWhitelist[args[1]] then
 Results = DarkRP.findPlayers(args[2]) or {}
 if table.Count(Results) == 1 then
 SID = Results[1]:SteamID()
 SWhitelist[args[1]][SID]	 = true
 wl_save() 
 else
 return "Cannot add to whitelist, found:"..table.Count(Results).." Targets"
 end
 else 
 return "Team has no WL - use wl_add before"	
 end else return "Invalid Arguments , wl_adduser TeamName PlyName" end 
 return "Added:"..Results[1]:Nick().."("..SID..")".." too "..args[1]
 end
 
function wl_adduserid(ply,cmd,args)
 if args[1] and args[2] then
	if  SWhitelist[args[1]] then
	SWhitelist[args[2]] = true
	else
	return "Cannot add, job has no whitelist"
	end
 else
 return "Invalid Amount of arguments given , wl_adduserid teamName SteamID"
 end
 return "Added "..args[1].." too "..args[2]
 end

function wl_removeuserid(ply,cmd,args)
 if args[1] and args[2] then
	if  SWhitelist[args[1]] then
	SWhitelist[args[2]] = nil
	else
	return "Cannot remove, player has no whitelist "
	end
 else
 return "Invalid Amount of arguments given , wl_removeuserid teamName SteamID"
 end
 return "Removed "..args[1].." from "..args[2]
 end
 
 
concommand.Add("wl_add",function(ply,cmd,args) if not (args[1] == "") then  if addwl(ply) then   SWhitelist[args[1]] = {} wl_save() else  ply:SendLua("print('No Permission')")	end end end )
concommand.Add("wl_adduser",function(ply,cmd,args) if addwl(ply) then  print(wl_adduser(ply,cmd,args)) else  ply:SendLua("print('No Permission')")	end end)
concommand.Add("wl_removeuser",function(ply,cmd,args) if addwl(ply) then  print(wl_removeuser(ply,cmd,args)) else  ply:SendLua("print('No Permission')")	end end)
concommand.Add("wl_remove",function(ply,cmd,args)  if addwl(ply) then if !(args[1] == "") then  SWhitelist[args[1]] = nil wl_save() end else  ply:SendLua("print('No Permission')")	end	end)
concommand.Add("wl_adduserid",function(ply,cmd,args) if addwl(ply) then  wl_adduserid(ply,cmd,args) else  ply:SendLua("print('No Permission'))")	end end)
concommand.Add("wl_removeuserid",function(ply,cmd,args) if addwl(ply) then  wl_removeuserid(ply,cmd,args) else  ply:SendLua("print('No Permission')")	end end)
concommand.Add("wl_list",function(ply,cmd,args) PrintTable(SWhitelist) end)
concommand.Add("wl_conf_add",function(ply,cmd,args)	if ply:IsSuperAdmin() then	SWAdmins[args[1]] = true  wl_save() end end)
concommand.Add("wl_conf_remove",function(ply,cmd,args)	if ply:IsSuperAdmin() then	SWAdmins[args[1]] = nil wl_save()end end)
concommand.Add("wl_conf_list",function() PrintTable(SWAdmins) end)

net.Receive("wl_clcmds",function()
local args = net.ReadTable()
if args["key"] == "wl_add" then
if addwl(args["ply"]) then
if !(args[1] == "") then  SWhitelist[args[1]] = {} wl_save()	end
else args["ply"]:SendLua("print('Insufficent Permission')")  end end

if args["key"] == "wl_adduser"  then
if addwljob(args["ply"]) then
args["ply"]:SendLua("print('"..wl_adduser(ply,cmd,args).."')")
else args["ply"]:SendLua("print('Insufficent Permission')") end end

if args["key"] == "wl_adduserid" then
if addwljob(args["ply"]) then
args["ply"]:SendLua("print('"..wl_adduserid(ply,cmd,args).."')")
else args["ply"]:SendLua("print('Insufficent Permission')") end end

if args["key"] == "wl_remove" then
if addwl(args["ply"]) then
if !(args[1] == "") then  SWhitelist[args[1]] = nil wl_save()	end
else args["ply"]:SendLua("print('Insufficent Permission')") end end

if args["key"] == "wl_removeuser" then
if addwljob(args["ply"]) then
args["ply"]:SendLua("print('"..wl_removeuser(ply,cmd,args).."')")
else args["ply"]:SendLua("print('Insufficent Permission')") end end

if args["key"] == "wl_removeuserid" then
if addwljob(args["ply"]) then
args["ply"]:SendLua("print('"..wl_removeuserid(ply,cmd,args).."')")
else args["ply"]:SendLua("print('Insufficent Permission')") end end
 

end)



end



----GAMEMODE.DefaultTeam
if CLIENT then
function wl_sendcom(cmd,args) 
local dat = {}
dat["key"] = cmd
dat["ply"] = LocalPlayer()
net.Start("wl_clcmds")
net.WriteTable(table.Merge(args,dat))
net.SendToServer()
end





end




