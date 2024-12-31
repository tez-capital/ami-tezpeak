local user = am.app.get("user", "root")
ami_assert(type(user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)

local service_manager = require"__xtz.service-manager"
service_manager = service_manager.with_options({ container = user })
local services = require"__tezpeak.services"

log_info("Stopping tezpeak services... this may take few minutes.")
for _, service in pairs(services.all_names) do
	-- skip false values
	if type(service) ~= "string" then goto CONTINUE end
	local ok, err = service_manager.safe_stop_service(service)
	ami_assert(ok, "Failed to stop " .. service .. ".service " .. (err or ""))
	::CONTINUE::
end
log_success("tezpeak services succesfully stopped.")