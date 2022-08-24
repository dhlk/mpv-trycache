local utils = require("mp.utils")

local function exists(path)
	local f = io.open(path, "rb")
	if f ~= nil then
		f:close()
		return true
	else
		return false
	end
end

local function readConfig()
	local path = mp.command_native({"expand-path", "~~/trycache.json"})

	local f, err = io.open(path, "rb")
	if err ~= nil then
		mp.msg.error("config does not exist ('" .. path .. "')")
		return nil
	end

	local json = f:read("*a")
	f:close()

	local t, err = utils.parse_json(json)
	if err ~= nil then
		mp.msg.error("unable to parse json ('" .. path .. "')")
		return nil
	end

	return t
end

local config = readConfig()
if config == nil then
	mp.msg.error("unable to read config")
	return
end

local function onload(hook)
	local target = mp.get_property("stream-open-filename", "")
	for _, conf in pairs(config) do
		r, n = string.gsub(target, conf.pattern, conf.repl)
		if n == 1 and string.find(r, "/%.%./") == nil and exists(r) then
			mp.set_property("stream-open-filename", r)
			return
		end
	end
end

mp.add_hook("on_load", 8, onload)
