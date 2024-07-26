local _user = am.app.get("user", "root")
ami_assert(type(_user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)

local serviceManager = require"__xtz.service-manager"
serviceManager = serviceManager.with_options({ container = _user })
local _services = require"__tezpeak.services"

for _, service in pairs(_services.allNames) do
	-- skip false values
	if type(service) ~= "string" then goto CONTINUE end
	local _ok, _error = serviceManager.safe_start_service(service)
	ami_assert(_ok, "Failed to start " .. service .. ".service " .. (_error or ""))
	::CONTINUE::
end

log_success("tezpeak services succesfully started.")