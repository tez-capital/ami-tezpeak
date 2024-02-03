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