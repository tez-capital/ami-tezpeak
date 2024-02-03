local appId = am.app.get("id")
local tezpeakServiceId = appId .. "-tezpeak"

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
	local backend = am.app.get_configuration("backend", os.getenv("ASCEND_SERVICES") ~= nil and "ascend" or "systemd")

	local serviceManager = nil
	if backend == "ascend" then
		local ok, asctl = am.plugin.safe_get("asctl")
		ami_assert(ok, "Failed to load asctl plugin")
		serviceManager = asctl
	else
		local ok, systemctl = am.plugin.safe_get("systemctl")
		ami_assert(ok, "Failed to load systemctl plugin")
		serviceManager = systemctl
	end

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