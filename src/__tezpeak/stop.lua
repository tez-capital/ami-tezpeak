local serviceManager = require"__xtz.service-manager"
local _services = require"__tezpeak.services"

log_info("Stopping tezpeak services... this may take few minutes.")
for _, service in pairs(_services.allNames) do
	-- skip false values
	if type(service) ~= "string" then goto CONTINUE end
	local _ok, _error = serviceManager.safe_stop_service(service)
	ami_assert(_ok, "Failed to stop " .. service .. ".service " .. (_error or ""))
	::CONTINUE::
end
log_success("tezpeak services succesfully stopped.")