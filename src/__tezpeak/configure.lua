local _user = am.app.get("user", "root")
ami_assert(type(_user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)

local _ok, _uid = fs.safe_getuid(_user)
ami_assert(_ok, "Failed to get " .. _user .. "uid - " .. (_uid or ""))

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
_services.remove_all_services() -- cleanup past install

for k, v in pairs(_services.tezpeakServices) do
	local _serviceId = k
	local sourceFile = string.interpolate("${file}.${extension}", {
		file = v,
		extension = backend == "ascend" and "ascend.hjson" or "service"
	})
	local _ok, _error = serviceManager.safe_install_service(sourceFile, _serviceId)
	ami_assert(_ok, "Failed to install " .. _serviceId .. ".service " .. (_error or ""))
end

log_success(am.app.get("id") .. " services configured")

log_info("Granting access to " .. _user .. "(" .. tostring(_uid) .. ")...")
local _ok, _error = fs.chown(os.cwd(), _uid, _uid, { recurse = true })
ami_assert(_ok, "Failed to chown - " .. (_error or ""))

