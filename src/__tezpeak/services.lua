local app_id = am.app.get("id")
local tezpeak_service_id = app_id .. "-tezpeak"

local user = am.app.get("user", "root")
ami_assert(type(user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)

local possible_residues = { }

local active_services = {
	[tezpeak_service_id] = am.app.get_configuration("TEZPEAK_SERVICE_FILE", "__tezpeak/assets/tezpeak")
}

local active_names = {}
for k, _ in pairs(active_services) do
        active_names[k:sub((#app_id + 2))] = k
end

--- cleanup names include everything including residues
---@type string[]
local cleanup_names = {}
cleanup_names = util.merge_arrays(cleanup_names, table.values(active_names))
cleanup_names = util.merge_arrays(cleanup_names, table.values(possible_residues))

return {
	tezpeak_service_id = tezpeak_service_id,
	active = active_services,
	active_names = active_names,
	all_names = all_names,
	cleanup_names = cleanup_names
}