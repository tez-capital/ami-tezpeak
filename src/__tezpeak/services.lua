local app_id = am.app.get("id")
local tezpeak_service_id = app_id .. "-tezpeak"

local user = am.app.get("user", "root")
ami_assert(type(user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)

local possible_residues = { }

local tezpeak_services = {
	[tezpeak_service_id] = am.app.get_configuration("TEZPEAK_SERVICE_FILE", "__tezpeak/assets/tezpeak")
}

local tezpeak_service_names = {}
for k, _ in pairs(tezpeak_services) do
        tezpeak_service_names[k:sub((#app_id + 2))] = k
end

local all_names = util.clone(tezpeak_service_names)

local function remove_all_services()
	local service_manager = require"__xtz.service-manager"
	service_manager = service_manager.with_options({ container = user })

	local all = table.values(tezpeak_service_names)
	all = util.merge_arrays(all, possible_residues)

	for _, service in ipairs(all) do
		if type(service) ~= "string" then goto CONTINUE end
		local ok, err = service_manager.safe_remove_service(service)
		if not ok then
			ami_error("Failed to remove " .. service .. ": " .. (err or ""))
		end
		::CONTINUE::
	end
end

return {
	tezpeak_service_id = tezpeak_service_id,
	tezpeak_services = tezpeak_services,
	tezpeak_service_names = tezpeak_service_names,
	all_names = all_names,
	remove_all_services = remove_all_services
}