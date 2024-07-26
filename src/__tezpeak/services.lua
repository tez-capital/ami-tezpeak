local appId = am.app.get("id")
local tezpeakServiceId = appId .. "-tezpeak"

local _user = am.app.get("user", "root")
ami_assert(type(_user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)

local possibleResidue = { }

local tezpeakServices = {
	[tezpeakServiceId] = am.app.get_configuration("TEZPEAK_SERVICE_FILE", "__tezpeak/assets/tezpeak")
}

local tezpeakServiceNames = {}
for k, _ in pairs(tezpeakServices) do
        tezpeakServiceNames[k:sub((#appId + 2))] = k
end

local allNames = util.clone(tezpeakServiceNames)

local function remove_all_services()
	local serviceManager = require"__xtz.service-manager"
	serviceManager = serviceManager.with_options({ container = _user })

	local all = table.values(tezpeakServiceNames)
	all = util.merge_arrays(all, possibleResidue)

	for _, service in ipairs(all) do
		if type(service) ~= "string" then goto CONTINUE end
		local _ok, _error = serviceManager.safe_remove_service(service)
		if not _ok then
			ami_error("Failed to remove " .. service .. ": " .. (_error or ""))
		end
		::CONTINUE::
	end
end

return {
	tezpeakServiceId = tezpeakServiceId,
	tezpeakServices = tezpeakServices,
	tezpeakServiceNames = tezpeakServiceNames,
	allNames = allNames,
	remove_all_services = remove_all_services
}