local needs_json_output = am.options.OUTPUT_FORMAT == "json"

local user = am.app.get("user", "root")
ami_assert(type(user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)

local service_manager = require"__xtz.service-manager"
service_manager = service_manager.with_options({ container = user })

local info = {
	level = "ok",
	status = "tezpeak is operational",
	version = am.app.get_version(),
	type = am.app.get_type(),
	services = {}
}

local services = require "__tezpeak.services"
for k, v in pairs(services.all_names) do
	if type(v) ~= "string" then goto CONTINUE end
	local ok, status, started = service_manager.safe_get_service_status(v)
	ami_assert(ok, "Failed to get status of " .. v .. ".service " .. (status or ""), EXIT_PLUGIN_EXEC_ERROR)
	info.services[k] = {
		status = status,
		started = started
	}
	if status ~= "running" then
		info.status = "One or more tezpeak services is not running!"
		info.level = "error"
	end
	::CONTINUE::
end

if needs_json_output then
	print(hjson.stringify_to_json(info, { indent = false }))
else
	print(hjson.stringify(info, { sortKeys = true }))
end